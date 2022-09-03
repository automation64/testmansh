# Script: testmansh

## Overview

Simple tool for testing Bash scripts in native environment or purpose-build container images.

Supported features:

- Run tests inside container using docker or podman container engines
- Run tests in native environment (localhost)

Supported tools

- code linting: shell check
- code testing: bats-core, bats-helpers file, asset, support

## Usage

```text
Usage: testmansh <-b|-t|-q|-l|-i|k> [-p Project] [-c Case] [-e Image] [-r Registry] [-s BatsCore] [-u ShellCheck] [-f EnvFile] [-m Format|-j JUnitFile] [-g] [-h]

Simple tool for testing Bash scripts in native environment or purpose-build container images.

By default testmansh assumes that scripts are organized using the following directory structure:

  - project_path/: project base path
  - project_path/src/: bash scripts
  - project_path/test/: test-cases repository
  - project_path/test/batscore/: test cases in bats-core format
  - project_path/test/samples/: test samples
  - project_path/test/lib/: shared code for test cases

The tool also sets and exports shell environment variables that can be used directly in test cases. The content is automatically adjusted to native or container execution:

  - TESTMANSH_PROJECT_ROOT: project base path (project/)
  - TESTMANSH_PROJECT_BIN: dev time scripts (project/bin)
  - TESTMANSH_PROJECT_SRC: source code (project/src)
  - TESTMANSH_PROJECT_LIB: dev time libs (project/lib)
  - TESTMANSH_PROJECT_BUILD: location for dev,test builds (project/build)
  - TESTMANSH_TEST: tests base path (project/test)
  - TESTMANSH_TEST_SAMPLES: test samples (project/test/samples)
  - TESTMANSH_TEST_LIB: test shared libs (project/test/lib)
  - TESTMANSH_TEST_BATSCORE_SETUP: batscore setup script (project/test/lib/batscore-setup.bash)
  - TESTMANSH_CMD_BATS_HELPER_SUPPORT: full path to the bats-core support helper
  - TESTMANSH_CMD_BATS_HELPER_ASSERT: full path to the bats-core assert helper
  - TESTMANSH_CMD_BATS_HELPER_FILE: full path to the bats-core file helper

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
  -c Case      : Test case name (for -b) or source code (for -t). Default: all. Format: path/file or path/ (relative to TESTMANSH_PROJECT)
  -e Image     : Image name to use for running the container test (-b) or open (-q). Alternative: exported shell variable TESTMANSH_IMAGES_TEST. Default: predefined list
  -r Registry  : Container registry URL. Alternative: exported shell variable TESTMANSH_REGISTRY
  -f EnvFile   : Full path to the container environment file. Default: TESTMANSH_PROJECT/test/container.env
  -s BatsCore  : Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS
  -u ShellCheck: Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_SHELLCHECK
  -m Format    : Show test results on STDOUT using the Format type. Format: shellcheck and bats-core dependant
  -j JUnitFile : Save test results in JUnit format to the file JUnitFile. Format: full path
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

Same as [bashlib64](https://github.com/serdigital64/bashlib64#os-compatibility)

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

- [Guidelines](https://github.com/serdigital64/testmansh/blob/main/CONTRIBUTING.md)
- [Contributor Covenant Code of Conduct](https://github.com/serdigital64/testmansh/blob/main/CODE_OF_CONDUCT.md)

### License

[GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.txt)

### Author

- [SerDigital64](https://serdigital64.github.io/)
