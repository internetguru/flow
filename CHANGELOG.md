# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

### Added
 - All key branches validation on existence and merge status.
 - Version validation across all key branches.
 - Tag validation on the main branch.
 - Separate stable branch for each major version, e.g. `prod-1`.
 - Key branch names adaptation to pre-existing branches.
 - Option --auto-entry to skip changelog prompt.
 - Consider remote branches if key branch not found.
 - Local branch behind remote validation.

### Changed
 - Exit codes validation error fixable and unfixable.
 - Default branch names changed to main and staging.
 - Options --conform and --init require confirmations (forceable with --yes).
 - Merge staging branch into main after releasing (do not delete).
 - Auto version increment after releasing dev branch.
 - Keyword argument redesign.
 - Option --what-now rephrased.
 - Option --dry-run also checks attributes after validation.
 - Documentation updated with new git flow example.
 - Insert default changelog entry if empty or skipped.
 - Environmental variable names now start with 'GF_'.
 - Merge hotfix according to its major version number.
 - Show usage after all invalid option error.
 - Show hint after all fixable validation errors.
 - Project renamed from 'omgf' to 'flow'

## [2.2.0] - 2017-06-05
### Changed
 - Increment minor version when release is created #31
 
### Fixed
 - Initialization checks only local branches #73
 - `omgf pull` updates only local branches with remote branch #59

## [2.1.2] - 2017-04-10
### Fixed
 - Repair --help option #64

## [2.1.1] - 2017-04-07
### Fixed
 - Show links URL in man page #57

## [2.1.0] - 2017-04-03
### Added
 - Support for macOS #41
 - Check for requirements upon start, document requirements in README #30

### Changed
 - Improve README: add Setup and Alternatives, add OMGF's output and simplify installation instructions.
 - Use `env` instead of hardcoded path to Bash in shebang

### Fixed
 - Fix Unreleased URL generated for CHANGELOG

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

[2.2.0]: https://github.com/internetguru/flow/compare/v2.1.2...v2.2.0
[2.1.2]: https://github.com/internetguru/flow/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/internetguru/flow/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/internetguru/flow/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/internetguru/flow/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/internetguru/flow/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/internetguru/flow/compare/v1.1.1...v2.0.0
[1.1.1]: https://github.com/internetguru/flow/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/internetguru/flow/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/internetguru/flow/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/internetguru/flow/compare/v0.0.0...v1.0.0
