# Templating

Simple string templating for Nushell, powered by [TinyTemplate][tt].


## Usage

```Nushell
~> "Running task {name}
	Processing files {{ for file in files -}}
	{file} {{- if not @last}}, {{ endif }}
	{{- endfor }}.

	{{ if result.success -}}
	Output: {result.output}
	{{- else -}}
	Failure!
	{{- endif -}}"
	| template {
		name: check
		files: [main.rs, util.rs, json.rs]
		result: { success: true, output: "No errors found" }
	}
Running task check
Processing files main.rs, util.rs, json.rs.

Output: No errors found
```

For the full syntax description, see the [TinyTemplate docs][syntax].


[tt]: https://lib.rs/crates/tinytemplate
[syntax]: https://docs.rs/tinytemplate/1.2.1/tinytemplate/syntax/index.html
