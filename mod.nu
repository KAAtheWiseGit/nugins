const DEFAULT = {
	keep-session: false
	net: false

	import: []
	env: []
	dev: []
	read: []
	write: []
}

def "make cmd" [] {
	let config = $in
	let config = $DEFAULT | merge $config

	mut cmd = [/usr/bin/bwrap]

	$cmd ++= [
		--unshare-all
		--die-with-parent
		--clearenv

		--dev /dev
		--proc /proc

		--tmpfs /tmp
		# --setenv TMPDIR /temporary
	]

	if not $config.keep-session {
		$cmd ++= [--new-session]
	}

	if $config.net {
		$cmd ++= [--share-net]
	}

	if $config.hostname? != null {
		$cmd ++= [--hostname $config.hostname]
	}

	for value in $config.env {
		match ($value | describe --detailed | get type) {
		string => {
			$cmd ++= [--setenv $value ($env | get $value)]
		}
		list => {
			$cmd ++= [--setenv $value.0 $value.1]
		}
		}
	}

	for value in $config.dev {
		$cmd ++= [--dev-bind $value $value]
	}

	for value in $config.read {
		match ($value | describe --detailed | get type) {
		string => {
			$cmd ++= [--ro-bind-try $value $value]
		}
		list => {
			$cmd ++= [--ro-bind-try $value.0 $value.1]
		}
		}
	}

	for value in $config.write {
		match ($value | describe --detailed | get type) {
		string => {
			$cmd ++= [--bind-try $value $value]
		}
		list => {
			$cmd ++= [--bind-try $value.0 $value.1]
		}
		}
	}

	$cmd ++= [-- $config.binary]

	$cmd
}

export def main --wrapped [
	--exec

	...args
] {
	let config = $in
	let cmd = $config | make cmd

	if $exec {
		exec ...$cmd ...$args
	} else {
		run-external ...$cmd ...$args
	}
}
