export def decrypt [] {
	let output = age --decrypt --identity $env.NUPASS.IDENTITY | complete
	if $output.exit_code != 0 {
		error make --unspanned { msg: "Failed to decrypt the secret" }
	} else {
		return $output.stdout
	}
}

export def encrypt [] {
	age --encrypt --armor --recipients-file $env.NUPASS.RECIPIENTS
}

export def get_repo_abs_path [name] {
	{
		parent: $env.NUPASS.REPOSITORY,
		stem: $name,
		extension: "age"
	} | path join
}

export def git_commit [name, message] {
	let path = (get_repo_abs_path $name)

	cd $env.NUPASS.REPOSITORY

	git add $path
	git commit -m $"($name): ($message)"
	git push
}

export def check_secret_name_not_taken [path, force, span] {
	if (($path | path exists) and (not $force)) {
		error make {
			msg: "Secret with this name already exists"
			label: {
				text: "name already taken"
				span: $span
			}
		}
	}
}

export def check_secret_name_exists [path, span] {
	if not ($path | path exists) {
		error make {
			msg: "Secret not found"
			label: {
				text: "a secret with this name doesn't exist"
				span: $span
			}
		}
	}
}

export def secrets [] {
	cd $env.NUPASS.REPOSITORY
	ls **/*.age
	| $in.name
	| each {|f| str replace --regex ".age$" "" }
}

export def "into filepath" [] {
	[$env.NUPASS.REPOSITORY $in]
	| path join
	| path parse
	| upsert extension "age"
	| path join
}

export def "select secret" [] {
	# try guards against interrupts
	let selection = try { secrets | input list --fuzzy }

	if $selection == null {
		error make --unspanned { msg: "No secret selected" }
	}

	$selection
}
