#!/usr/bin/nu

const sys = "/sys/class/"
const backlight = "/sys/class/backlight"
const leds = "/sys/class/leds"
const brightness = "brightness"
const max_brightness = "max_brightness"

def get_devices [] {
	[] | append (ls $backlight) | append (ls $leds) | $in.name
}

def get_brightness [device: path] {
	open --raw ($device | path join $brightness) | into int
}

def get_max_brightness [device: path] {
	open --raw ($device | path join $max_brightness) | into int
}

def set_brightness [device, value: int] {
	let $value = (
		if $value > $device.max_brightness { $device.max_brightness }
		else $value
	)

	let $path = (
		$sys
		| path join $device.class
		| path join $device.name
		| path join "brightness"
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

export def "brightness list" [] {
	let $devices = (get_devices)

	$devices | each { |device|
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
}

export def brightness [
	operation: string
	value?

	--quiet (-q)	# Suppress output
] {
	let $device = (brightness list | first)

	if $operation != "info" {
		if $value != null {
			let $span = (metadata $value).span
			let $value = (parse_value $value $span $device)

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

	let $device = (brightness list | first)

	if not $quiet {
		print $device
	}
}
