def installed-packages [] {
	open /etc/apk/world
	| lines
	# remove the version
	| str replace --regex `([^@]+).*` "${1}"
}

def get-all-packages [] {
	apk list
	| lines
	| uniq
	| parse "{name_version} {rest}"
	| get name_version
	| parse --regex `([a-zA-Z0-9+-]+)-([0-9.]+[a-z]?(_[a-zA-Z]+\d*)*)(-r\d+)`
	| insert version { $in.capture1 + $in.capture2 + $in.capture3 }
	| rename name
	| select name version
}

def all-packages [] {
	try {
		stor open | query db "select * from __comp_apk" | length
	} catch {
		stor create --table-name __comp_apk --columns {name: str, version: str}
		get-all-packages | stor insert --table-name __comp_apk
	}

	stor open | query db "select * from __comp_apk" | get name
}

# Alpine package manager
export extern apk []

# Add or modify constraints in WORLD and commit changes
export extern "apk add" [
	--initdb	# Initialize a new package database
	--latest (-l)	# Always choose the latest package by version
	--upgrade (-u)	# Upgrade packages and it's dependencies
	--virtual (-t): string	# Create virtual package with given dependencies
	--no-chown	# Do not change file owner or group

	...CONSTRAINTS: string@all-packages
]

# Remove constraints from WORLD and commit changes
export extern "apk del" [
	--rdepends (-r)	# Recursively delete all top-level reverse dependencies, too

	...CONSTRAINTS: string@installed-packages
]

# Fix, reinstall or upgrade packages without modifying WORLD
export extern "apk fix" [
	--depends (-d)		# Also fix dependencies of specified packages
	--reinstall (-r)	# Reinstall packages (default)
	--upgrade (-u)		# Upgrade name PACKAGE if an upgrade exists and does not break dependencies
	--xattr (-x)		# Fix packages with broken xattrs
	--directory-permissions	# Reset all directory permissions

	...PACKAGES: string@all-packages
]

# Update repository indexes
export extern "apk update" []

# Install upgrades available from repositories
export extern "apk upgrade" [
	--available (-a)	# Reset all packages to versions available from current repositories
	--ignore		# Upgrade all other packages than the ones listed
	--latest (-l)		# Always choose the latest package by version
	--no-self-upgrade	# Do not do an early upgrade of the 'apk-tools'
	 package
	--prune			# Prune the WORLD by removing packages which are no longer available from any configured repository
	--self-upgrade-only	# Only perform a self-upgrade of the 'apk-tools' package

	...PACKAGES: string@all-packages
]

# Manage the local package cache
export extern "apk cache" [
	--add-dependencies	# Add the argument dependencies to WORLD dependencies when determining which packages to download
	--available (-a)	# Selected packages to be downloaded from active repositories even if it means replacing or downgrading the installed package
	--ignore-conflict	# Ignore conflicts when resolving dependencies
	--latest (-l)		# Always choose the latest package by version
	--upgrade (-u)		# When caching packages which are already installed, prefer their upgrades rather than considering the requirement fulfilled by the current installation
	--simulate (-s)		# Simulate the requested operation without making any changes
]

# Give detailed information about packages or repositories
export extern "apk info" [
	--all (-a)		# List all information known about the package
	--description (-d)	# Print the package description
	--installed (-e)	# Check package installed status
	--contents (-L)		# List files included in the package
	--provides (-P)		# List what the package provides
	--rdepends (-r)		# List reverse dependencies of the package (all other packages which depend on the package)
	--depends (-R)		# List the dependencies of the package
	--size (-s)		# Print the package's installed size
	--webpage (-w)		# Print the URL for the package's upstream webpage
	--who-owns (-W)		# Print the package which owns the specified file
	--install-if		# List the package's install_if rule
	--license		# Print the package SPDX license identifier
	--replaces		# List the other packages for which this package is marked as a replacement
	--rinstall-if		# List other packages whose install_if rules refer to this package
	--triggers (-t)		# Print active triggers for the package

	...PACKAGES: string@all-packages
]

# List packages matching a pattern or other criteria
export extern "apk list" [
	--installed (-I)	# Consider only installed packages
	--orphaned (-O)		# Consider only orphaned packages
	--available (-a)	# Consider only available packages
	--upgradable (-u)	# Consider only upgradable packages
	--origin (-o)		# List packages by origin
	--depends (-d)		# List packages by dependency
	--providers (-P)	# List packages by provider
]

# Render dependencies as graphviz graphs
export extern "apk dot" [
	--errors	# Consider only packages with errors
	--installed	# Consider only installed packages

	...PKGMASK: string
]

# Show repository policy for packages
export extern "apk policy" [
	...PACKAGES: string@all-packages
]

# Search for packages by name or description
export extern "apk search" [
	--all (-a)		# Print all matching package versions
	--description (-d)	# Also search for PATTERN in the package description
	--exact (-e)		# Match package names exactly
	--has-origin		# Match by package origin
	--origin (-o)		# Print base package name
	--rdepends (-r)		# Print reverse dependencies (other packages which depend on the package)

	...PATTERN: string
]

# Create repository index file from packages
export extern "apk index" [
	--description (-d): string	# Add a description to the index
	--merge				# Merge PACKAGES into the existing INDEX
	--output (-o): string		# Output generated index to a file
	--prune-origin			# Prune packages from the existing INDEX with same origin as any of the new PACKAGES during merge
	--index (-x): string		# Read an existing index to speed up the creation of the new index by reusing data when possible
	--no-warnings			# Disable the warning about missing dependencies
	--rewrite-arch: string		# Set all packages' architecture

	...PACKAGES: string@all-packages
]

# Download packages from repositories to a local directory
export extern "apk fetch" [
	--built-after: string		# Only fetch packages that have buildtime more recent than a timestamp
	--link (-l)			# Create hard links if possible
	--output (-o): path		# Write the downloaded file(s) to a directory
	--recursive (-R)		# Fetch packages and all of their dependencies
	--stdout (-s)			# Dump the .apk file(s) to stdout
	--world (-w)			# Download packages needed to satisfy WORLD
	--simulate			# Simulate the requested operation without making any changes
	--url				# Print the full URL for downloaded packages

	...PACKAGES: string@all-packages
]

# Show checksums of package contents
export extern "apk manifest" [
	...PACKAGES: string@all-packages
]

# Verify package integrity and signature
export extern "apk verify" [
	...FILES: path
]

# Audit system for changes
export extern "apk audit" [
	--backup			# Audit configuration files only (default)
	--check-permissions		# Check file permissions too
	--details			# Enable reporting of detail records
	--full				# Audit all system files
	--ignore-busybox-symlinks	# Ignore symlinks whose target is the BusyBox binary
	--packages			# Print only the packages with changed files
	--protected-paths: path		# Use given FILE for protected paths listings
	--system			# Audit all system files
	--recursive (-r)		# Descend into directories and audit them as well

	...DIRECTORIES: path
]

# Show statistics about repositories and installations
export extern "apk stats" []

# Compare package versions or perform tests on version strings
export extern "apk version" [
	--all (-a)		# Consider packages from all repository tags
	--check (-c)		# Check versions for validity
	--indexes (-I)		# Print the version and description for each repository's index
	--limit (-l): string	# Limit to packages with output matching the given operand
	--test (-t)		# Compare two version strings

	...PACKAGES: string@all-packages
]
