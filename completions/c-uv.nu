def vcs [] { [git, none] }

def author-from [] { [auto, git, none] }

def build-backend [] { [hatch, flit, pdm, setuptools, maturin, scikit] }

# Create a new project
export extern "uv init" [
	--name: string # The name of the project
	--bare # Only create a `pyproject.toml`
	--package # Set up the project to be built as a Python package
	--no-package # Do not set up the project to be built as a Python package
	--app # Create a project for an application
	--lib # Create a project for a library
	--script # Create a script
	--description: string # Set the project description
	--no-description # Disable the description for the project
	--vcs: string@vcs # Initialize a version control system for the project
	--build-backend: string # Initialize a build-backend of choice for the project
	--no-readme # Do not create a `README.md` file
	--author-from: string@author-from # Fill in the `authors` field in the `pyproject.toml`
	--no-pin-python # Do not create a `.python-version` file for the project
	--no-workspace # Avoid discovering a workspace and create a standalone project

	PATH: path # The path to use for the project/script
]

# Add dependencies to the project
export extern "uv add" [
	--requirements(-r): path # Add all packages listed in the given `requirements.txt` files
	--dev # Add the requirements to the development dependency group
	--optional: string # Add the requirements to the package's optional dependencies for the specified extra
	--group: string # Add the requirements to the specified dependency group
	--editable # Add the requirements as editable
	--raw-sources # Add source requirements to `project.dependencies`, rather than `tool.uv.sources`
	--rev: string # Commit to use when adding a dependency from Git
	--tag: string # Tag to use when adding a dependency from Git
	--branch: string # Branch to use when adding a dependency from Git
	--extra: string # Extras to enable for the dependency
	--no-sync # Avoid syncing the virtual environment [env: UV_NO_SYNC=]
	--locked # Assert that the `uv.lock` will remain unchanged [env: UV_LOCKED=]
	--frozen # Add dependencies without re-locking the project [env: UV_FROZEN=]
	--active # Prefer the active virtual environment over the project's virtual environment
	--package: string # Add the dependency to a specific package in the workspace
	--script: path # Add the dependency to the specified Python script, rather than to a project

	...PACKAGES: string # The packages to add, as PEP 508 requirements (e.g., `ruff==0.5.0`)
]

# Remove dependencies from the project
export extern "uv remove" [
	--dev # Remove the packages from the development dependency group
	--optional: string # Remove the packages from the project's optional dependencies for the specified extra
	--group: string # Remove the packages from the specified dependency group
	--no-sync # Avoid syncing the virtual environment after re-locking the project [env: UV_NO_SYNC=]
	--active # Prefer the active virtual environment over the project's virtual environment
	--locked # Assert that the `uv.lock` will remain unchanged [env: UV_LOCKED=]
	--frozen # Remove dependencies without re-locking the project [env: UV_FROZEN=]
	--package: string # Remove the dependencies from a specific package in the workspace
	--script: string # Remove the dependency from the specified Python script, rather than from a project

	...PACKAGES: string # The names of the dependencies to remove (e.g., `ruff`)
]

# Update the project's environment
export extern "uv sync" [
	--extra: string # Include optional dependencies from the specified extra name
	--all-extras # Include all optional dependencies
	--no-extra: string # Exclude the specified optional dependencies, if `--all-extras` is supplied
	--no-dev # Disable the development dependency group
	--only-dev # Only include the development dependency group
	--group: string # Include dependencies from the specified dependency group
	--no-group: string # Disable the specified dependency group
	--no-default-groups # Ignore the the default dependency groups
	--only-group: string # Only include dependencies from the specified dependency group
	--all-groups # Include dependencies from all dependency groups
	--no-editable # Install any editable dependencies, including the project and any workspace members, as non-editable
	--inexact # Do not remove extraneous packages present in the environment
	--active # Prefer the active virtual environment over the project's virtual environment
	--no-install-project # Do not install the current project
	--no-install-workspace # Do not install any workspace members, including the root project
	--no-install-package: string # Do not install the given package(s)
	--locked # Assert that the `uv.lock` will remain unchanged [env: UV_LOCKED=]
	--frozen # Sync without updating the `uv.lock` file [env: UV_FROZEN=]
	--dry-run # Perform a dry run, without writing the lockfile or modifying the project environment
	--all-packages # Sync all packages in the workspace
	--package: string # Sync for a specific package in the workspace
	--script: path # Sync the environment for a Python script, rather than the current project
]

# Update the project's lockfile
export extern "uv lock" [
	--check # Check if the lockfile is up-to-date [env: UV_LOCKED=]
	--check-exists # Assert that a `uv.lock` exists without checking if it is up-to-date [env: UV_FROZEN=]
	--dry-run # Perform a dry run, without writing the lockfile
	--script: string # Lock the specified Python script, rather than the current project
]

def format [] { [requirements-txt] }

# Export the project's lockfile to an alternate format
export extern "uv export" [
	--format: string@format # The format to which `uv.lock` should be exported [default: requirements-txt]
	--all-packages # Export the entire workspace
	--package: string # Export the dependencies for a specific package in the workspace
	--prune: string # Prune the given package from the dependency tree
	--extra: string # Include optional dependencies from the specified extra name
	--all-extras # Include all optional dependencies
	--no-extra: string # Exclude the specified optional dependencies, if `--all-extras` is supplied
	--no-dev # Disable the development dependency group
	--only-dev # Only include the development dependency group
	--group: string # Include dependencies from the specified dependency group
	--no-group: string # Disable the specified dependency group
	--no-default-groups # Ignore the the default dependency groups
	--only-group: string # Only include dependencies from the specified dependency group
	--all-groups # Include dependencies from all dependency groups
	--no-header # Exclude the comment header at the top of the generated output file
	--no-editable # Install any editable dependencies, including the project and any workspace members, as non-editable
	--no-hashes # Omit hashes in the generated output
	--output-file(-o): path # Write the exported requirements to the given file
	--no-emit-project # Do not emit the current project
	--no-emit-workspace # Do not emit any workspace members, including the root project
	--no-emit-package: string # Do not emit the given package(s)
	--locked # Assert that the `uv.lock` will remain unchanged [env: UV_LOCKED=]
	--frozen # Do not update the `uv.lock` before exporting [env: UV_FROZEN=]
	--script: path # Export the dependencies for the specified PEP 723 Python script, rather than the current project
]

def python-platform [] {
	[
		windows, linux, macos, "x86_64-pc-windows-msvc",
		"i686-pc-windows-msvc", "x86_64-unknown-linux-gnu",
		"aarch64-apple-darwin", "x86_64-apple-darwin",
		"aarch64-unknown-linux-gnu", "aarch64-unknown-linux-musl",
		"x86_64-unknown-linux-musl", "x86_64-manylinux2014",
		"x86_64-manylinux_2_17", "x86_64-manylinux_2_28",
		"x86_64-manylinux_2_31", "x86_64-manylinux_2_32",
		"x86_64-manylinux_2_33", "x86_64-manylinux_2_34",
		"x86_64-manylinux_2_35", "x86_64-manylinux_2_36",
		"x86_64-manylinux_2_37", "x86_64-manylinux_2_38",
		"x86_64-manylinux_2_39", "x86_64-manylinux_2_40",
		"aarch64-manylinux2014", "aarch64-manylinux_2_17",
		"aarch64-manylinux_2_28", "aarch64-manylinux_2_31",
		"aarch64-manylinux_2_32", "aarch64-manylinux_2_33",
		"aarch64-manylinux_2_34", "aarch64-manylinux_2_35",
		"aarch64-manylinux_2_36", "aarch64-manylinux_2_37",
		"aarch64-manylinux_2_38", "aarch64-manylinux_2_39",
		"aarch64-manylinux_2_40",
	]
}

# Display the project's dependency tree
export extern "uv tree" [
	--universal # Show a platform-independent dependency tree
	--depth(-d): int # Maximum display depth of the dependency tree [default: 255]
	--prune: string # Prune the given package from the display of the dependency tree
	--package: string # Display only the specified packages
	--no-dedupe # Do not de-duplicate repeated dependencies. Usually, when a package has already displayed its dependencies, further occurrences will not re-display its dependencies, and will include a (*) to indicate it has already been shown. This flag will cause those duplicates to be repeated
	--invert # Show the reverse dependencies for the given package. This flag will invert the tree and display the packages that depend on the given package
	--outdated # Show the latest available version of each package in the tree
	--only-dev # Only include the development dependency group
	--no-dev # Disable the development dependency group
	--group: string # Include dependencies from the specified dependency group
	--no-group: string # Disable the specified dependency group
	--no-default-groups # Ignore the the default dependency groups
	--only-group: string # Only include dependencies from the specified dependency group
	--all-groups # Include dependencies from all dependency groups
	--locked # Assert that the `uv.lock` will remain unchanged [env: UV_LOCKED=]
	--frozen # Display the requirements without locking the project [env: UV_FROZEN=]
	--script: path # Show the dependency tree the specified PEP 723 Python script, rather than the current project
	--python-version: string # The Python version to use when filtering the tree
	--python-platform: string@python-platform # The platform to use when filtering the tree
]

# TODO: `tool` and subcommands
# TODO: `python` and subcommands
# TODO: `pip` and subcommands

export extern "uv pip" []

def annotation-style [] { [line, split] }

# Compile a `requirements.in` file to a `requirements.txt` file
export extern "uv pip compile" [
	--constraints(-c): path # Constrain versions using the given requirements files
	--overrides: path # Override versions using the given requirements files
	--build-constraints(-b): path # Constrain build dependencies using the given requirements files when building source distributions
	--extra: string # Include optional dependencies from the specified extra name; may be provided more than once
	--all-extras # Include all optional dependencies
	--no-deps # Ignore package dependencies, instead only add those packages explicitly listed on the command line to the resulting requirements file
	--output-file(-o): path # Write the compiled requirements to the given `requirements.txt` file
	--no-strip-extras # Include extras in the output file
	--no-strip-markers # Include environment markers in the output file
	--no-annotate # Exclude comment annotations indicating the source of each package
	--no-header # Exclude the comment header at the top of the generated output file
	--annotation-style: string@annotation-style # The style of the annotation comments included in the output file, used to indicate the source of each package
	--custom-compile-command: string # The header comment to include at the top of the output file generated by `uv pip compile`
	--system # Install packages into the system Python environment
	--generate-hashes # Include distribution hashes in the output file
	--no-build # Don't build source distributions
	--no-binary: string # Don't install pre-built wheels
	--only-binary: string # Only use pre-built wheels; don't build source distributions
	--python-platform: string@python-platform # The platform for which requirements should be resolved
	--universal # Perform a universal resolution, attempting to generate a single `requirements.txt` output file that is compatible with all operating systems, architectures, and Python implementations
	--no-emit-package: string # Specify a package to omit from the output resolution. Its dependencies will still be included in the resolution. Equivalent to pip-compile's `--unsafe-package` option
	--emit-index-url # Include `--index-url` and `--extra-index-url` entries in the generated output file
	--emit-find-links # Include `--find-links` entries in the generated output file
	--emit-build-options # Include `--no-binary` and `--only-binary` entries in the generated output file
	--emit-index-annotation # Include comment annotations indicating the index used to resolve each package (e.g., `# from https://pypi.org/simple`)

	SRC_FILE: path # Include all packages listed in the given `requirements.in` files
]

# Sync an environment with a `requirements.txt` file
export extern "uv pip sync" [
	--constraints(-c): path # Constrain versions using the given requirements files
	--build-constraints(-b): path # Constrain build dependencies using the given requirements files when building source distributions
	--require-hashes # Require a matching hash for each requirement
	--no-verify-hashes # Disable validation of hashes in the requirements file
	--system # Install packages into the system Python environment
	--break-system-packages # Allow uv to modify an `EXTERNALLY-MANAGED` Python installation
	--no-break-system-packages
	--target: path # Install packages into the specified directory, rather than into the virtual or system Python environment. The packages will be installed at the top-level of the directory
	--prefix: path # Install packages into `lib`, `bin`, and other top-level folders under the specified directory, as if a virtual environment were present at that location
	--no-build # Don't build source distributions
	--no-binary: string # Don't install pre-built wheels
	--only-binary: string # Only use pre-built wheels; don't build source distributions
	--allow-empty-requirements # Allow sync of empty requirements, which will clear the environment of all packages
	--no-allow-empty-requirements
	--python-version: string # The minimum Python version that should be supported by the requirements (e.g., `3.7` or `3.7.9`)
	--python-platform: string@python-platform # The platform for which requirements should be installed
	--strict # Validate the Python environment after completing the installation, to detect packages with missing dependencies or other issues
	--dry-run # Perform a dry run, i.e., don't actually install anything but resolve the dependencies and print the resulting plan

	SRC_FILE: path # Include all packages listed in the given `requirements.txt` files
]

# Install packages into an environment
export extern "uv pip install" [
	--requirements: path # Install all packages listed in the given `requirements.txt` files
	--editable: path # Install the editable package based on the provided local file path
	--constraints: path # Constrain versions using the given requirements files [env: UV_CONSTRAINT=]
	--overrides: path # Override versions using the given requirements files [env: UV_OVERRIDE=]
	--build-constraints: path # Constrain build dependencies using the given requirements files when building source distributions [env: UV_BUILD_CONSTRAINT=]
	--extra: string # Include optional dependencies from the specified extra name; may be provided more than once
	--all-extras # Include all optional dependencies
	--no-deps # Ignore package dependencies, instead only installing those packages explicitly listed on the command line or in the requirements files
	--require-hashes # Require a matching hash for each requirement [env: UV_REQUIRE_HASHES=]
	--no-verify-hashes # Disable validation of hashes in the requirements file [env: UV_NO_VERIFY_HASHES=]
	--system # Install packages into the system Python environment [env: UV_SYSTEM_PYTHON=]
	--break-system-packages # Allow uv to modify an `EXTERNALLY-MANAGED` Python installation [env: UV_BREAK_SYSTEM_PACKAGES=]
	--no-break-system-packages #
	--target: path # Install packages into the specified directory, rather than into the virtual or system Python environment. The packages will be installed at the top-level of the directory
	--prefix: path # Install packages into `lib`, `bin`, and other top-level folders under the specified directory, as if a virtual environment were present at that location
	--no-build # Don't build source distributions
	--no-binary: string # Don't install pre-built wheels
	--only-binary: string # Only use pre-built wheels; don't build source distributions
	--python-version: string # The minimum Python version that should be supported by the requirements (e.g., `3.7` or `3.7.9`)
	--python-platform: string@python-platform # The platform for which requirements should be installed
	--exact # Perform an exact sync, removing extraneous packages
	--strict # Validate the Python environment after completing the installation, to detect packages with missing dependencies or other issues
	--dry-run # Perform a dry run, i.e., don't actually install anything but resolve the dependencies and print the resulting plan
	--user #

	...PACKAGE: string # Install all listed packages
]

def keyring-provider [] { [disabled, subprocess] }

# Uninstall packages from an environment
export extern "uv pip uninstall" [
	--requirements: path # Uninstall all packages listed in the given requirements files
	--keyring-provider: string@keyring-provider # Attempt to use `keyring` for authentication for remote requirements files
	--system # Use the system Python to uninstall packages
	--break-system-packages # Allow uv to modify an `EXTERNALLY-MANAGED` Python installation
	--no-break-system-packages #
	--target: path # Uninstall packages from the specified `--target` directory
	--prefix: path # Uninstall packages from the specified `--prefix` directory
	--dry-run # Perform a dry run, i.e., don't actually uninstall anything but print the resulting plan

	...PACKAGE: string # Uninstall all listed packages
]

# List, in requirements format, packages installed in an environment
export extern "uv pip freeze" [
	--exclude-editable # Exclude any editable packages from output
	--strict # Validate the Python environment, to detect packages with missing dependencies and other issues
	--path: path # Restrict to the specified installation path for listing packages (can be used multiple times)
	--system # List packages in the system Python environment
]

def format-list [] { [columns, freeze, json] }

# List, in tabular format, packages installed in an environment
export extern "uv pip list" [
	--editable(-e) # Only include editable projects
	--exclude-editable # Exclude any editable packages from output
	--exclude: string # Exclude the specified package(s) from the output
	--format: string@format-list # Select the output format
	--outdated # List outdated packages
	--strict # Validate the Python environment, to detect packages with missing dependencies and other issues
	--system # List packages in the system Python environment
]

# Show information about one or more installed packages
export extern "uv pip show" [
	--strict # Validate the Python environment, to detect packages with missing dependencies and other issues
	-f, --files # Show the full list of installed files for each package
	--system # Show a package in the system Python environment [env: UV_SYSTEM_PYTHON=]

	...PACKAGE: string # The package(s) to display
]

# Display the dependency tree for an environment
export extern "uv pip tree" [
    --show-version-specifiers # Show the version constraint(s) imposed on each package
    --depth(-d): int # Maximum display depth of the dependency tree [default: 255]
    --prune: string # Prune the given package from the display of the dependency tree
    --package: string # Display only the specified packages
    --no-dedupe # Do not de-duplicate repeated dependencies.
    --invert: string # Show the reverse dependencies for the given package.
    --outdated # Show the latest available version of each package in the tree
    --strict # Validate the Python environment, to detect packages with missing dependencies and other issues
    --system # List packages in the system Python environment [env: UV_SYSTEM_PYTHON=]
]

# Verify installed packages have compatible dependencies
export extern "uv pip check" [
    --system # Check packages in the system Python environment [env: UV_SYSTEM_PYTHON=]
]

def index-strategy [] { [first-index, unsafe-first-match, unsafe-best-match] }

def link-mode [] { [clone, copy, hardlink, symlink] }

# Create a virtual environment
export extern "uv venv" [
    --no-project # Avoid discovering a project or workspace
    --seed # Install seed packages (one or more of: `pip`, `setuptools`, and `wheel`) into the virtual environment [env: UV_VENV_SEED=]
    --allow-existing # Preserve any existing files or directories at the target path
    --prompt: string # Provide an alternative prompt prefix for the virtual environment.
    --system-site-packages # Give the virtual environment access to the system site packages directory
    --relocatable # Make the virtual environment relocatable
    --index-strategy: string@index-strategy # The strategy to use when resolving against multiple index URLs [env: UV_INDEX_STRATEGY=]
    --keyring-provider: string@keyring-provider # Attempt to use `keyring` for authentication for index URLs [env: UV_KEYRING_PROVIDER=]
    --exclude-newer: string # Limit candidate packages to those that were uploaded prior to the given date [env: UV_EXCLUDE_NEWER=]
    --link-mode: string@link-mode # The method to use when installing packages from the global cache [env: UV_LINK_MODE=]

    PATH: path # The path to the virtual environment to create
]

# Build Python packages into source distributions and wheels
export extern "uv build" [
    --package: string # Build a specific package in the workspace
    --all-packages # Builds all packages in the workspace
    --out-dir(-o): path # The output directory to which distributions should be written
    --sdist # Build a source distribution ("sdist") from the given directory
    --wheel # Build a binary distribution ("wheel") from the given directory
    --no-build-logs # Hide logs from the build backend
    --force-pep517 # Always build through PEP 517, don't use the fast path for the uv build backend
    --build-constraints(-b): path # Constrain build dependencies using the given requirements files when building distributions [env: UV_BUILD_CONSTRAINT=]
    --require-hashes # Require a matching hash for each requirement [env: UV_REQUIRE_HASHES=]
    --no-verify-hashes # Disable validation of hashes in the requirements file [env: UV_NO_VERIFY_HASHES=]

    SRC: path # The directory from which distributions should be built, or a source distribution archive to build into a wheel
]

def trusted_publishing [] { [automatic, always, never] }

def keyring_provider [] { [disabled, subprocess] }

# Upload distributions to an index
export extern "uv publish" [
    --index: string # The name of an index in the configuration to use for publishing [env: UV_PUBLISH_INDEX=]
    --username(-u): string # The username for the upload [env: UV_PUBLISH_USERNAME=]
    --password(-p): string # The password for the upload [env: UV_PUBLISH_PASSWORD=]
    --token(-t): string # The token for the upload [env: UV_PUBLISH_TOKEN=]
    --trusted-publishing: string@trusted_publishing # Configure using trusted publishing through GitHub Actions
    --keyring-provider: string@keyring_provider # Attempt to use `keyring` for authentication for remote requirements files [env: UV_KEYRING_PROVIDER=]
    --publish-url: string # The URL of the upload endpoint (not the index URL) [env: UV_PUBLISH_URL=]
    --check-url: string # Check an index URL for existing files to skip duplicate uploads [env: UV_PUBLISH_CHECK_URL=]

    ...FILES: path # Paths to the files to upload. Accepts glob expressions [default: dist/*]
]

# TODO: `cache` and subcommands

# Manage the uv executable
export extern "uv self" []

# Update uv
export extern "uv self update" [
    --token: string # A GitHub token for authentication. A token is not required but can be used to reduce the chance of encountering rate limits [env: UV_GITHUB_TOKEN=]

    TARGET_VERSION: string # Update to the specified version. If not provided, uv will update to the latest version
]

def output-format [] { [text, json] }

# Display uv's version
export extern "uv version" [
    --output-format: string@output-format = text
]
