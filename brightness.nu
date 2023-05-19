#!/usr/bin/nu

const sys = "/sys/class/"
const backlight = "/sys/class/backlight"
const leds = "/sys/class/leds"
const brightness = "brightness"
const max_brightness = "max_brightness"

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
	| if $first or $device != null { first } else {}
}

def get_brightness [device: path] {
	open --raw ($device | path join $brightness) | into int
}

def get_max_brightness [device: path] {
	open --raw ($device | path join $max_brightness) | into int
}

def set_brightness [device, value: int] {
	let $value = ([$value $device.max_brightness] | math min)

	let $path = (
		$sys
		| path join $device.class
		| path join $device.name
		| path join $brightness
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

# List devices with available brightness controls
export def "brightness list" [] {
	get_devices
}

export def brightness [
	operation: string
	value?

	--quiet (-q)		# Suppress output
	--min (-m): int = 1	# Minimum below whcih the brightness will not be lowered
	--device (-d): string	# Device name (can be a regex)
	--class (-c): string	# Device class
] {
	if $operation != "info" {
		if $value != null {
			let $device = (get_devices -d $device -c $class --first)

			let $span = (metadata $value).span
			let $value = (parse_value $value $span $device)
			let $value = ([$min $value] | math max)

			let $value = match $operation {
			"set" => $value
			"increase" => ($device.brightness + $value)
			"decrease" => ($device.brightness - $value)
			}

			set_brightness $device $value
		} else {
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
	}

	let $device = (get_devices -d $device -c $class --first)

	if not $quiet { print $device }
}
