#!/usr/bin/nu

const backlight = "/sys/class/backlight"
const led = "/sys/class/leds"
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
	[] | append (ls $backlight) | append (ls $led) | $in.name
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
			brightness:		$brightness
			"brightness (%)":	$brightness_percent
			max_brightness:		$max_brightness
		}
	}
}

brightness list
