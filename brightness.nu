const sys = "/sys/class/"
const backlight = "/sys/class/backlight"
const leds = "/sys/class/leds"
const brightness_name = "brightness"
const max_brightness_name = "max_brightness"

def get_devices [
	--device (-d): string
	--class (-c): string
	--first
] {
	[]
	| append (ls $backlight)
	| append (ls $leds)
	| $in.name
	| each {|device|
		let $name = ($device | path basename)
		let $class = ($device | path dirname | path basename)
		let $brightness = (get_brightness $device)
		let $max_brightness = (get_max_brightness $device)
		let $brightness_percent = (
			$brightness / $max_brightness * 100
			| math round
		)

		{
			name:			$name
			class:			$class
			"brightness (%)":	$brightness_percent
			brightness:		$brightness
			max_brightness:		$max_brightness
		}
	}
	| if $device != null { filter {|d| $d.name =~ $device } } else {}
	| if $class != null { filter {|d| $d.class == $class } } else {}
	| if $first {
		try { first } catch {
			error make { msg: $"Device matching ($device) not found" }
		}
	} else {}
}

def get_brightness [device: path] {
	open --raw ($device | path join $brightness_name) | into int
}

def get_max_brightness [device: path] {
	open --raw ($device | path join $max_brightness_name) | into int
}

def set_brightness [device, value: int] {
	let $value = ([$value $device.max_brightness] | math min)

	let $path = (
		$sys
		| path join $device.class
		| path join $device.name
		| path join $brightness_name
	)

	$value | save $path --force
}

const value_regex = '(?P<num>[[:digit:]]*)(?P<percentage>%?)'

def parse_value [value, span, device] {
	let $value = (try {
		$value | parse -r $value_regex | first | into int num
	} catch {
		error make {
			msg: "Brightness value must be an integer with an optional '%' at the end"
			label: {
				text: "malformed value"
				start: $span.start
				end: $span.end
			}
		}
	})

	match $value.percentage {
	'%' => { $value.num * $device.max_brightness / 100 }
	_ => $value.num
	} | math round
}

const tmp_dir = "/tmp/"
const runtime_dir = "nubrightness/"
const state_file = "state.nuon"

def get_state_file_path [] {
	let $dir = (
		if $env.XDG_RUNTIME_DIR? != null {
			$env.XDG_RUNTIME_DIR
		} else {
			$tmp_dir
		}
		| path join $runtime_dir
	)

	mkdir $dir

	$dir | path join $state_file
}

def operation_comp [] {
	["info", "list", "restore", "set", "increase", "decrease"]
}
def class_comp [] { ["backlight", "leds"] }

export def main [
	operation: string@operation_comp
	value?

	--quiet (-q)			# Suppress output
	--min (-m): int = 1		# Minimum below which the brightness will not be lowered
	--device (-d): string		# Device name (can be a regex)
	--class (-c): string@class_comp	# Device class
	--save				# Save previous state in a temporary file
] {
	if $save { get_devices | save -f (get_state_file_path) }

	match $operation {
	"info" => { get_devices -d $device -c $class --first }
	"list" => { get_devices -d $device -c $class }
	"restore" => {
		try {
			open (get_state_file_path)
		} catch {
			error make { msg: "No saved state to restore" }
		}
		| each {|d|
			set_brightness $d $d.brightness
		}

		null
	}
	"set" | "increase" | "decrease" => {
		if $value == null {
			let $span = (metadata $operation).span
			error make {
				msg: $"Missing a value to ($operation)"
				label: {
					text: "{value}"
					start: ($span.end - 1)
					end: ($span.end)
				}
			}
		}

		let $device = (get_devices -d $device -c $class --first)

		let $value = (
			parse_value $value (metadata $value).span $device
			| [$min $in] | math max
		)

		let $value = (match $operation {
		"set" => $value
		"increase" => ($device.brightness + $value)
		"decrease" => ($device.brightness - $value)
		})

		set_brightness $device $value

		let $device = (get_devices -d $device.name -c $class --first)
		if not $quiet { print $device }
	}
	_ => {
		let span = (metadata $operation).span
		error make {
			msg: $"Operation \"($operation)\" not found"
			label: {
				text: "invalid subcommand",
				start: $span.start,
				end: $span.end,
			}
		}
	}
	}
}
