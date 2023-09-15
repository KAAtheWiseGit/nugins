export def decrypt [] {
	age --decrypt --identity $env.NUPASS.IDENTITY
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
				start: $span.start
				end: $span.end
			}
		}
	}
}
