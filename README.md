# Script: testmansh

## Overview

Simple tool for running Bash tests using bats-core in either native environment or purpuse-build container images.

Supported features:

- Run test inside container using docker compatible container engine
- Run test using native bash

## Usage

```text
Usage: testmansh <-b|-o|-l|-i|-q> [-p Project] [-c Case] [-e Image] [-r Registry] [-s BatsCore] [-u user] [-f EnvFile] [-g] [-h]

Run bash test cases

Commands

  -b         : Run tests
  -o         : Run tests in containers
  -q         : Open testing container
  -l         : List test cases
  -i         : List container images

Flags

  -g         : Enable debug mode
  -h         : Show Help

Parameters

  -p Project : Full path to the project location. Alternative: exported shell variable TESTMANSH_PROJECT. Default: test/batscore
  -c Case    : Test case name. Default: all
  -e Image   : Image name to use for running the container test. Default: all
  -r Registry: Container registry URL. Alternative: exported shell variable TESTMANSH_REGISTRY. Default: ghcr.io/serdigital64
  -u User    : Use name for container test. Alternative: exported shell variable TESTMANSH_USER. Default: test
  -f EnvFile : Full path to the container environment file. Default: none
  -s BatsCore: Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS. Default: /usr/local/bin/bats
```

### Run test in container images

```shell
testmansh -o
```

## Deployment

### Compatibility

### Requirements

- Bash >= v4
- Container test
  - Podman >= v3

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

[Guidelines](CONTRIBUTING)
[Contributor Covenant Code of Conduct](CODE_OF_CONDUCT)

### License

[GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.txt)

### Author

- [SerDigital64](https://serdigital64.github.io/)
