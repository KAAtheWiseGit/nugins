use util *

# Get a secret and copy it to the clipboard
export def main [
	--force (-f)	# Print the secret into stdout instead of copying it
] {
	cd $env.NUPASS.REPOSITORY
	# this doesn't handle interrupts in fzf gracefully
	let path = (
		ls **/*.age
		| each {|f| $f.name}
		| to text
		| fzf
		| path expand
	)

	open $path
	| decrypt
	| if $force {
		print
	} else {
		split row "\n"
		| first
		| wl-copy --trim-newline
	}
}

# Print a tree of all existing secrets
export def tree [] {
	^tree $env.NUPASS.REPOSITORY
}

# Generate a new diceware password
export def generate [
	name		# name for the new secret
	num: int	# number of words in the passphrase

	--force (-f)	# overwrite
] {
	let path = (get_repo_abs_path $name)

	let $wordlist = (open $env.NUPASS.WORDLIST | lines)
	let $passphrase = (
		1..($num)
		| each {||
			let i = random integer 1..($wordlist | length)
			$wordlist | get ($i - 1)
		}
		| str join " "
	)

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

	$passphrase
	| encrypt
	| if $force {
		save --force $path
	} else {
		save $path
	}

	git_commit $name "generate secret"
}

# Delete a secret
export def delete [
	name		# name of the secret
] {
	let path = (get_repo_abs_path $name)

	if not ($path | path exists) {
		let $span = (metadata $name).span
		error make {
			msg: "Secret not found"
			label: {
				text: "a secret with this name doesn't exist"
				start: $span.start
				end: $span.end
			}
		}
	}

	rm $path
	git_commit $name "delete secret"
}
