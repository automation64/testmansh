# Contributing

## Prepare Development Environment

- Prepare dev tools
  - Install GIT
  - Install bats-core and plugins (file, assert, support)
  - Install container engine (docker or podman)
- Clone GIT repository

  ```shell
  git clone https://github.com/serdigital64/testmansh
  ```

- Adjust environment variables to reflect your configuration:

  ```shell
  # Copy environment definition files from templates:
  cp dot.local .local
  cp dot.secrets .secrets
  # Review and update content for both files
  ```

- Initialize dev environment variables

```shell
source bin/devtmsh-set
```

- Download the latest version of [BashLib64](https://github.com/serdigital64/bashlib64) to: `lib/`

## Update source code

- Add/Edit source code in: `src/`
- Build the `testmansh` script:

```shell
./bin/devtmsh-build
```

## Test source code

- Add/update test-cases in: `test/batscore`
- Run test cases

```test
./testmansh -b
```

## Repositories

- Project GIT repository: [https://github.com/serdigital64/testmansh](https://github.com/serdigital64/testmansh)
- Project Documentation: [https://github.com/serdigital64/testmansh](https://github.com/serdigital64/testmansh)
- Release history: [CHANGELOG](CHANGELOG.md)
