use util *

# Select a secret using `fzf` and copy it to the clipboard.
export def main [
	--force (-f)	# Print the secret instead of copying it
] {
	cd $env.NUPASS.REPOSITORY
	let path = (
		ls **/*.age
		| each {|f| $f.name}
		| to text
		| str replace --all --multiline --regex ".age$" ""
		| fzf
		| if $in == "" { return } else { $in }
		| str trim  # needed, because previous if adds a newline
		| path expand
		| {
			parent: ($in | path dirname),
			stem: ($in | path basename),
			extension: "age",
		}
		| path join
	)

	print $"Getting (ansi yellow)(
		$path
		| path relative-to $env.NUPASS.REPOSITORY
		| str replace --regex ".age$" ""
	)(ansi reset)"

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

# Print a tree of all existing secrets.
export def tree [] {
	^tree $env.NUPASS.REPOSITORY
	| str replace --all --multiline --regex ".age$" ""
}

# Generate a new diceware password.
export def generate [
	name		# Name for the new secret
	num: int	# Number of words in the passphrase

	--force (-f)	# If another secret exists at {name}, overwrite it
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

	check_secret_name_not_taken $path $force (metadata $name).span

	$passphrase
	| encrypt
	| if $force {
		save --force $path
	} else {
		save $path
	}

	git_commit $name "generate secret"
}

# Add a secret using $EDITOR.
export def add [
	name		# Name for the new secret

	--force (-f)	# If another secret exists at {name}, overwrite it
] {
	let path = (get_repo_abs_path $name)
	check_secret_name_not_taken $path $force (metadata $name).span

	let tmp = $"($path).tmp"
	^$env.EDITOR tmp
	open tmp | encrypt | save $path --force
	rm tmp

	git_commit $name "add secret"
}

# Edit a secret using $EDITOR.
export def edit [
	name		# Name of the secret to edit
] {
	let path = (get_repo_abs_path $name)

	check_secret_name_exists $path (metadata $name).span

	let tmp = $"($path).tmp"
	open $path | decrypt | save $tmp
	^$env.EDITOR $tmp
	open $tmp | encrypt | save $path --force
	rm $tmp

	git_commit $name "edit secret"
}

# Delete a secret.
export def delete [
	name		# Name of the secret
] {
	let path = (get_repo_abs_path $name)

	check_secret_name_exists $path (metadata $name).span

	rm $path
	git_commit $name "delete secret"
}

# Move an existing secret to another path.
export def move [
	old_name	# Current name of the secret
	new_name	# New name for the secret

	--force (-f)	# If another secret exists at {new_name}, overwrite it
] {
	let old_path = (get_repo_abs_path $old_name)
	let new_path = (get_repo_abs_path $new_name)

	check_secret_name_exists $old_path (metadata $old_name).span
	check_secret_name_not_taken $new_path $force (metadata $new_name).span

	mkdir ($new_path | path dirname)
	mv --force $old_path $new_path

	git_commit $new_name $"rename from ($old_name)"
}
