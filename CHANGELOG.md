# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
## [Unreleased]
### Added
 - Add Requirements section to README #30

### Changed
 - Improve README: add Setup and Alternatives, add OMGF's output and simplify intallation instructions.
 - Use `env` instead of harcoded path to Bash in shebang

## [2.0.2] - 2017-03-11
### Fixed
 - Fix load user options to be case-sensitive #27
 - `make clean` and `make distclean` force removes files #28

## [2.0.1] - 2017-03-06
### Fixed
 - Fix `make dist`
 - Fix README.md Install section

## [2.0.0] - 2017-03-05

### Added
 - Add [EditorConfig](http://editorconfig.org/) file to enforce standard formatting

### Changed
 - Rename gf to omgf
 - Makefile uses BINDIR instead of EXEC_PREFIX

## [1.1.1] - 2017-01-30

## [1.1.0] - 2017-01-30
### Added
 - Automatic deployment into GitHub releases
 - `make distsingle` target compiles gf into a single file

## [1.0.1] - 2017-01-02
### Fixed
 - Proper changelog keywords listing

## [1.0.0] - 2016-12-22

[Unreleased]: https://github.com/InternetGuru/omgf/compare/dev...master
[2.0.2]: https://github.com/InternetGuru/omgf/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/InternetGuru/omgf/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/InternetGuru/omgf.git/compare/v1.1.1...v2.0.0
[1.1.1]: https://github.com/InternetGuru/omgf/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/InternetGuru/omgf/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/InternetGuru/omgf/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/InternetGuru/gf/compare/v0.0.0...v1.0.0
