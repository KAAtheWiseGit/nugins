# Nupass

A simple Nushell script, which manages secrets inside a git repository
in a `pass`-like manner.


## Setup

Add `use path/to/nupass` to `config.nu`.  The following environmental
variables are required (for now, all environmental variables must be
absolute paths):

- `NUPASS.REPOSITORY`

  Local file path to the Git repository with secrets.

- `NUPASS.IDENTITY`

  Identity file for decryption, passed to `age` with the `-i` flag.

- `NUPASS.RECIPIENTS`

  Recipients file, passed to `age` with the `-R` flag.

- `NUPASS.WORDLIST`

  Path to the dictionary, used for generating diceware
  passwords[^generate].  It must be a plain-text file, with words
  separated by newlines.


[^generate]: See `nupass generate`
