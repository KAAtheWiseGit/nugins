let wayland_display = [$env.XDG_RUNTIME_DIR $env.WAYLAND_DISPLAY] | path join
let audio = [$env.XDG_RUNTIME_DIR pulse] | path join

(
	bwrap
	--unshare-all
	--share-net
	--new-session
	--die-with-parent
	--clearenv
	--setenv HOME $env.HOME
	--setenv WAYLAND_DISPLAY $env.WAYLAND_DISPLAY
	--setenv XDG_CACHE_HOME $env.XDG_CACHE_HOME
	--setenv XDG_RUNTIME_DIR $env.XDG_RUNTIME_DIR

	--dev /dev/
	--proc /proc/
	--dev-bind /dev/dri /dev/dri
	--dev-bind /dev/snd /dev/snd
	--ro-bind /sys/dev/char /sys/dev/char
	--ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00

	--ro-bind /etc/fonts/ /etc/fonts/
	--ro-bind /etc/resolv.conf /etc/resolv.conf

	--ro-bind $audio $audio
	--ro-bind $wayland_display $wayland_display

	--bind /home/kaathewise/.cache/firefox /home/kaathewise/.cache
	--bind /home/kaathewise/.local/share/firefox /home/kaathewise/.mozilla
	--bind /home/kaathewise/download /home/kaathewise/download

	--ro-bind /lib /lib
	--ro-bind /usr/lib /usr/lib

	--ro-bind /usr/share/X11/xkb/ /usr/share/X11/xkb/
	--ro-bind /usr/share/fontconfig/ /usr/share/fontconfig/
	--ro-bind /usr/share/fonts/ /usr/share/fonts/
	--ro-bind /usr/share/glib-2.0/ /usr/share/glib-2.0/
	--ro-bind /usr/share/icons/ /usr/share/icons/
	--ro-bind /usr/share/icu/ /usr/share/icu/
	--ro-bind /usr/share/mime/ /usr/share/mime/

	/usr/lib/firefox/firefox
)
