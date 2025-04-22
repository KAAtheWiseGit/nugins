const DEFAULT = {
	keep-session: false
	net: false

	env: []
	dev: []
	read: []
	write: []
}

def "merge config" [] {
	let config = $in

	let out = $DEFAULT | merge $config
	$out
}

def "make cmd" [] {
	let config = $in

	mut cmd = [/usr/bin/bwrap]

	$cmd ++= [
		--unshare-all
		--die-with-parent
		--clearenv

		--dev /dev
		--proc /proc

		--tmpfs /local-tmp
		--setenv TMPDIR /local-tmp
	]

	if not $config.keep-session {
		$cmd ++= [--new-session]
	}

	if $config.net {
		$cmd ++= [--share-net]
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
			$cmd ++= [--ro-bind $value $value]
		}
		list => {
			$cmd ++= [--ro-bind $value.0 $value.1]
		}
		}
	}

	for value in $config.write {
		match ($value | describe --detailed | get type) {
		string => {
			$cmd ++= [--bind $value $value]
		}
		list => {
			$cmd ++= [--bind $value.0 $value.1]
		}
		}
	}

	$cmd ++= [-- $config.binary]

	$cmd
}

export def main [
	--exec

	path: path

	...args
] {
	let cmd = open $path
		| merge config
		| make cmd

	if $exec {
		exec ...$cmd ...$args
	} else {
		run-external ...$cmd ...$args
	}
}
