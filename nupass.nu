# Get a secret and copy it to the clipboard
export def main [
	--force (-f)	# Print the secret into stdout instead of copying it
] {
	cd ~
	cd $env.NUPASS_REPOSITORY
	# this doesn't handle interrupts in fzf gracefully
	let path = (ls **/*.age | each {|f| $f.name} | to text | fzf)
	# get absolute path to the encrypted file
	let path = ($path | path expand)

	cd ~
	let secret = (age -d -i $env.NUPASS_IDENTITY $path)
	if $force {
		print $secret
	} else {
		$secret
		| split row "\n"
		| first
		| wl-copy --trim-newline
	}
}

# Print a tree of all existing secrets
export def tree [] {
	cd ~
	cd $env.NUPASS_REPOSITORY
	^tree .
}
