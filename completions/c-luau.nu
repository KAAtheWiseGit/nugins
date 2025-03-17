export extern luau [
	--coverage		# Collect code coverage while running the code and output results to coverage.out
	--help(-h)		# Display this usage message.
	--interactive(-i)	# Run an interactive REPL after executing the last script specified.
	-O			# Compile with optimization level (default 1, n should be between 0 and 2).
	-g 			# Compile with debug level (default 1, n should be between 0 and 2).
	--profile		# Profile the code using N Hz sampling (default 10000) and output results to profile.out
	--timetrace		# Record compiler time tracing information into trace.json
	--codegen		# Execute code using native code generation
	--program-args(-a)	# Declare start of arguments to be passed to the Luau program

	...FILES: path
]

def formatter [] { [plain gnu] }

export extern luau-analyze [
	--formatter: string@formatter	# Report analysis errors in Luacheck or GNU-compatible format
	--timetrace			# Record compiler time tracing information into trace.json

	...FILES: path
]

def compile-mode [] { [binary text remarks codegen] }

def target [] { [a64 x64 a64_nf x64_ms] }

def granularity [] { [total, file, function] }

export extern luau-compile [
	--mode: string@compile-mode
	--help(-h)		# Display this usage message.

	-O			# Compile with optimization level (default 1, n should be between 0 and 2).
	-g			# Compile with debug level (default 1, n should be between 0 and 2).

	--target: string@target	# Compile code for specific architecture
	--timetrace		# Record compiler time tracing information into trace.json
	--record-stats: string@granularity	# Granularity of compilation stats
	--bytecode-summary	# Compute bytecode operation distribution.

	--stats-files: path = stats.json	# File in which compilation stats will be recored
	--vector-lib: string	# File in which compilation stats will be recored
	--vector-ctor: string	# Name of the function constructing a vector value.
	--vector-type: string	# Name of the vector type
]
