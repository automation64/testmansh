# Script: testmansh

## Overview

Simple tool for testing Bash scripts in either native environment or purpose-build container images.

Supported features:

- Run tests inside container using docker or podman container engines
- Run tests in native environment (localhost)

Supported tools

- code linting: shell check
- code testing: bats-core, bats-helpers file, asset, support

By default `testmansh` assumes that scripts are organized using the following directory structure:

- `project_path/`: project base path
- `project_path/src`: bash scripts
- `project_path/test`: test-cases repository
- `project_path/test/batscore`: test-cases in bats-core format

## Usage

```text
Usage: testmansh <-b|-t|-q|-l|-i|k> [-p Project] [-c Case] [-e Image] [-r Registry] [-s BatsCore] [-u ShellCheck] [-f EnvFile] [-m Format] [-g] [-h]

Run test cases

Commands

  -b           : Run bats-core tests
  -t           : Run shellcheck linter
  -q           : Open bats-core container
  -l           : List bats-core test cases
  -i           : List bats-core container images
  -k           : List shellcheck targets

Flags

  -g           : Enable debug mode
  -o           : Enable container mode (for -b and -t)
  -h           : Show Help

Parameters

  -p Project   : Full path to the project location. Alternative: exported shell variable TESTMANSH_PROJECT. Default: current location
  -c Case      : Test case name. Default: all. Format: path/file (relative to Project)
  -e Image     : Image name to use for running the container test (-b) or open (-q). Alternative: exported shell variable TESTMANSH_IMAGES_TEST. Default: predefined list
  -r Registry  : Container registry URL. Alternative: exported shell variable TESTMANSH_REGISTRY
  -f EnvFile   : Full path to the container environment file. Default: none
  -s BatsCore  : Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS
  -u ShellCheck: Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS
  -m Format    : Set report format type. Valued values: shellcheck and bats-core dependant
```

### Run bats-core test-cases in container images

```shell
# Change directory to the project location
cd PROJECT_PATH

# (Optional) List available containers and select one. All containers are included by default
testmansh -i

# (Optional) List available test-cases using default location and select one. All test-cases are included by default
testmansh -l

# Run test-cases (with optional container and test case selection)
testmansh -b -o [-c CASE_PATH] [-e IMAGE_NAME]
```

### Run code linter

```shell
# Change directory to the project location
cd PROJECT_PATH

# Run linter using default code location src/
testmansh -t -o
```

## Deployment

### Compatibility

- AlmaLinux8
- Alpine3
- CentOS7
- CentOS8
- CentOS9
- Debian9
- Debian10
- Debian11
- Fedora33
- Fedora34
- Fedora35
- MacOS12
  - Requires Bash4 (e.g. homebrew install bash)
- OracleLinux7
- OracleLinux8
- RedHatLinux8
- Ubuntu20
- Ubuntu21

### Requirements

- Bash >= v4
- Container test
  - Docker or Podman

### Installation

Download **testmansh** from the source GitHub repository:

```shell
curl -O https://raw.githubusercontent.com/serdigital64/testmansh/main/testmansh
chmod 0755 testmansh
# Optional: move to searchable path
mv testmansh ~/.local/bin
```

## Contributing

Help on implementing new features and maintaining the code base is welcomed.

- [Guidelines](CONTRIBUTING.md)
- [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md)

### License

[GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.txt)

### Author

- [SerDigital64](https://serdigital64.github.io/)
