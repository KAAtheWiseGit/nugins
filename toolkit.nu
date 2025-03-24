def runner [] {
	if (which doas | is-not-empty) {
		"doas"
	} else if (which sudo | is-not-empty) {
		"sudo"
	} else {
		error make --unspanned { msg: "Needs `sudo` or `doas`" }
	}
}

# Install the program along with the `udev` rules.
export def install [
	--udev-rules-dir: string = "/usr/lib/udev/rules.d/"	# Path with the `udev` rules
] {
	# copy the Nushell script to $nu.vendor when it gets implemented

	# check if `udev` is installed
	try {
		udevd --version | ignore
	} catch {
		error make --unspanned { msg: "`udev` is not installed" }
	}

	let runner = runner

	^$runner install -m 0644 -o root 90-brightness.rules $udev_rules_dir

	if ("/run/udev/control" | path exists) {
		if ("/run/udev/control" | path type) == "socket" {
			^$runner udevadm control --reload-rules
			^$runner udevadm trigger -s leds -s backlight -c add
		}
	}

	let vendor = $nu.vendor-autoload-dirs | last
	mkdir $vendor
	cp brightness.nu $vendor
}

# Uninstall `brightness.nu` files
export def uninstall [
	--udev-rules-dir: string = "/usr/lib/udev/rules.d/"	# Path with the `udev` rules
] {
	let installed = $nu.vendor-autoload-dirs | last | path join brightness.nu
	if not ($installed | path exists) {
		error make --unspanned {msg: "Brightness.nu isn't installed"}
	}

	rm $installed

	# udev
	let runner = runner
	^$runner rm ($udev_rules_dir | path join "90-brightness.rules")
}
