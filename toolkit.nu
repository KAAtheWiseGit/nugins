# Install the program along with the `udev` rules.
export def install [
	--udev-rules-dir: string = "/usr/lib/udev/rules.d/"	# Path to install udev rules to
] {
	# copy the Nushell script to $nu.vendor when it gets implemented

	# copy udev rules
	try {
		^install -m 0644 -o root 90-brightness.rules $udev_rules_dir
	} catch {
		error make --unspanned { msg: "`install` has to be ran as root" }
	}
}
