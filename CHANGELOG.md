# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.11.0]

### Added

- Autodetect mode flag to select container or native execution mode

## [1.10.0]

### Changed

- Open container image now requires Image name parameter (-e)
- Updated default container image list for bash test

### Fixed

- Linter in container mode now sets workdir to the project path

## [1.9.1]

### Added

- Verbose and debug modes

## [1.8.0]

### Added

- Fedora 36 support

## [1.7.0]

### Added

- Option to create JUnit test report file

## [1.6.0]

### Added

- Container variables for bats-core test-cases

### Changed

- Set default path for container env option -f

## [1.5.0]

### Changed

- Added more debugging information for option -g

## [1.4.0]

### Added

- Allow parameter -c (case) to accept directories in addition to all and files

### Fixed

- Fixed container open option

## [1.3.0]

### Added

- ShellCheck support

### Changed

- Refactored default paths to allow case selection based on project location

## [1.0.0]

### Changed

- Remove tool from project bashlib64 and make stand-alone

[1.11.0]: https://github.com/automation64/testmansh/compare/1.10.0...1.11.0
[1.10.0]: https://github.com/automation64/testmansh/compare/1.9.1...1.10.0
[1.9.1]: https://github.com/automation64/testmansh/compare/1.8.0...1.9.1
[1.8.0]: https://github.com/automation64/testmansh/compare/1.7.0...1.8.0
[1.7.0]: https://github.com/automation64/testmansh/compare/1.6.0...1.7.0
[1.6.0]: https://github.com/automation64/testmansh/compare/1.5.0...1.6.0
[1.5.0]: https://github.com/automation64/testmansh/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/automation64/testmansh/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/automation64/testmansh/compare/1.0.0...1.3.0
[1.0.0]: https://github.com/automation64/testmansh/releases/tag/1.0.0
