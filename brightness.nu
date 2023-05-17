#!/usr/bin/nu

const sys = "/sys/class/"
const backlight = "/sys/class/backlight"
const leds = "/sys/class/leds"
const brightness = "brightness"
const max_brightness = "max_brightness"

def brightness [] {
	let $devices = (ls $backlight | $in.name)

	for $path in $devices {
		for $file in (ls $path).name {
			if ($file | path basename) == "brightness" {
				# set brightness to 100%
				"255" | save $file --force
			}
		}
	}
}

def get_devices [] {
	[] | append (ls $backlight) | append (ls $leds) | $in.name
}

def get_default_device [] {
	get_devices | first
}

def get_brightness [device: path] {
	open --raw ($device | path join $brightness) | into int
}

def get_max_brightness [device: path] {
	open --raw ($device | path join $max_brightness) | into int
}

def "brightness list" [] {
	let $devices = (get_devices)

	$devices | each { |device|
	 	let $name = ($device | path basename)
	 	let $class = ($device | path dirname | path basename)
	 	let $brightness = (get_brightness $device)
	 	let $max_brightness = (get_max_brightness $device)
		let $brightness_percent = $brightness / $max_brightness * 100

		{
			name:			$name
			class:			$class
			"brightness (%)":	$brightness_percent
			brightness:		$brightness
			max_brightness:		$max_brightness
		}
	}
}

def "brightness info" [] {
	# brightnessctl seems to just be returning the first device
	brightness list | first
}

def "brightness set" [
	value: int	# new device brightness
] {
	let $device = (brightness info)

	if $value > $device.max_brightness {
		let span = (metadata $value).span;

		error make {
			msg: "Tried to set brightness higher than maximum",
			label: {
				text: $"Must be less than or equal to ($device.max_brightness)",
				start: $span.start,
				end: $span.end,
			}
		}
	}

	let $path = (
		$sys
		| path join $device.class
		| path join $device.name
		| path join "brightness"
	)

	$value | save $path --force
}
