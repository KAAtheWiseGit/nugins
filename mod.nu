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
		| str replace --all --multiline --regex ".age$" ""
		| fzf
		| path expand
		| {
			parent: ($in | path dirname),
			stem: ($in | path basename),
			extension: "age",
		}
		| path join
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
	| str replace --all --multiline --regex ".age$" ""
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

export def add [
	name		# name for the new secret

	--force (-f)	# overwrite
] {
	let path = (get_repo_abs_path $name)
	check_secret_name_not_taken $path $force (metadata $name).span

	let tmp = $"($path).tmp"
	nvim tmp
	open tmp | encrypt | save $path --force
	rm tmp

	git_commit $name "add secret"
}

export def edit [
	name		# name of the new secret to edit
] {
	let path = (get_repo_abs_path $name)

	check_secret_name_exists $path (metadata $name).span

	let tmp = $"($path).tmp"
	open $path | decrypt | save $tmp
	nvim $tmp
	open $tmp | encrypt | save $path --force
	rm $tmp

	git_commit $name "edit secret"
}

# Delete a secret
export def delete [
	name		# name of the secret
] {
	let path = (get_repo_abs_path $name)

	check_secret_name_exists $path (metadata $name).span

	rm $path
	git_commit $name "delete secret"
}

export def move [
	old_name	# current name of the secret
	new_name	# new secret name

	--force (-f)	# overwrite
] {
	let old_path = (get_repo_abs_path $old_name)
	let new_path = (get_repo_abs_path $new_name)

	check_secret_name_exists $old_path (metadata $old_name).span
	check_secret_name_not_taken $new_path $force (metadata $new_name).span

	mkdir ($new_path | path dirname)
	mv --force $old_path $new_path

	git_commit $new_name $"rename from ($old_name)"
}
