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

# Generate a new diceware password
export def generate [
	name		# name for the new secret
	num: int	# number of words in the passphrase

	--force (-f)	# overwrite
] {
	let path = $"($name).age"
	cd ~

	let $wordlist = (open $env.NUPASS_WORDLIST | lines)
	let $passphrase = (
		1..($num)
		| each {||
			let i = random integer 1..($wordlist | length)
			$wordlist | get ($i - 1)
		}
		| str join " "
	)

	let $enc_secret = (
		$passphrase
		| age --armor --recipients-file $env.NUPASS_RECIPIENTS
	)

	cd $env.NUPASS_REPOSITORY

	if (($path | path exists) and (not $force)) {
		let $span = (metadata $name).span
		error make {
			msg: "Secret with this name already exists"
			label: {
				text: "name already taken"
				start: $span.start
				end: $span.end
			}
		}
	}

	$enc_secret
	| if $force {
		save --force $path
	} else {
		save $path
	}

	git add $path
	git commit -m $"($name): generate secret"
	git push
}
