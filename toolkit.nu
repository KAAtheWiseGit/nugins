# Install the program along with the `udev` rules.
export def install [
	--udev-rules-dir: string = "/usr/lib/udev/rules.d/"	# Path to install udev rules to
] {
	# copy the Nushell script to $nu.vendor when it gets implemented

	# check if `udev` is installed
	try {
		udevd --version | null
	} catch {
		error make --unspanned { msg: "`udev` is not installed" }
	}

	# copy udev rules
	try {
		^install -m 0644 -o root 90-brightness.rules $udev_rules_dir
	} catch {
		error make --unspanned { msg: "`install` has to be ran as root" }
	}

	# if `udev` is running, reload
	if ("/run/udev/control" | path exists) {
		if (ls "/run/udev/control").type == "socket" {
			udevadm control --reload-rules
			udevadm trigger -s leds -s backlight -c add
		}
	}
}
