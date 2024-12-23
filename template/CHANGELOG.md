# Changelog

## [0.101.0] — 2024-12-23

### Fixed

- Handle errors for the input values: error objects are bubbled up and
  types unconvertible to JSON result in a custom error.


## [0.100.0] — 2024-11-16

### Fixed

- Bump the Nushell version to 0.100.0.


## [0.2.0] — 2024-09-07

### Fixed

- Don't panic on `NaN` and `inf` float values (`0a91905`).
- Bubble up TinyTemplate errors to the user instead of panicking
  (`1bd6b20`).


## [0.1.0] — 2024-09-03

Initial release
