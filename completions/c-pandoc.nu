def from-formats [] {
	^pandoc --list-input-formats | lines
}

def to-formats [] {
	^pandoc --list-output-formats | lines
}

def tf [] {
	["true" "false"]
}

def kv [] {
	["KEY:VAL"]
}

def changes [] {
	["accept" "reject" "all"]
}

export extern pandoc [
	--from (-f): string@from-formats	# Specify input format
	--to (-t): string@to-formats		# Specify output format
	--output (-o): string			# Write output to a file instead of stdout
	--data-dir: path			# Specify the user data directory to search for pandoc data files
	--defaults (-d): path			# Specify a set of default option settings
	--bash-completion			# Generate a bash completion script
	--verbose				# Give verbose debugging output
	--quiet					# Suppress warning messages
	--fail-if-warningsk: string@tf		# Exit with error status if there are any warnings
	--log: path				# Write log messages in machine-readable JSON format
	--list-input-formats			# List supported input formats
	--list-output-formats			# List supported output formats
	--list-extensions: string@to-formats	# List supported extensions for a format
	--list-highlight-languages		# List supported languages for syntax highlighting, one per line
	--list-highlight-styles			# List supported styles for syntax highlighting, one per line. See --highlight-style
	--version (-v)				# Print version
	--help (-h)				# Show usage message

	--shift-heading-level-by: int		# Shift heading levels by a positive or negative integer
	--indented-code-classes: string		# Specify classes to use for indented code blocks
	--default-image-extension: string	# Specify a default extension to use when image paths/URLs have no extension
	--file-scope: string@tf			# Parse each file individually before combining for multifile documents
	--filter (-f): path			# Specify an executable to be used as a filter transforming the pandoc AST
	--lua-filter (-l): path			# Transform the document in a similar fashion as a JSON `--filter`, but use pandoc’s built-in Lua filtering system
	--metadata (-M): string@kv		# Set the metadata field KEY to the value VAL
	--metadata-file: path			# Read metadata from the supplied YAML (or JSON) file
	--preserve-tabs (-p): string@tf		# Preserve tabs instead of converting them to spaces
	--tab-stop: int = 4			# Specify the number of spaces per tab.
	--track-changes: string@changes		# Specifies what to do with insertions, deletions, and comments produced by the MS Word "Track Changes" feature
	--extract-media: path			# Extract images and other media contained in or linked from the source document to the path
	--abbreviations: path			# Specifies a custom abbreviations file, with abbreviations one to a line
	--trace: string@tf			# Print diagnostic output tracing parser progress to stderr

	...files: path
]
