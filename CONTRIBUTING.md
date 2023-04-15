# Contributing

## Prepare Development Environment

- Prepare dev tools
  - Install GIT
  - Install bats-core and plugins (file, assert, support)
  - Install container engine (docker or podman)
- Clone GIT repository

  ```shell
  git clone https://github.com/serdigital64/testmansh
  git flow init
  ```

- Adjust environment variables to match your configuration:

  - Copy environment definition files from templates:

  ```shell
  cp dot.local .local
  cp dot.secrets .secrets
  ```

  - Review and update content for both files to match your environment

- Download dev support scripts

```shell
./bin/dev-lib
```

## Update source code

- Add/Edit source code in: `src/`

## Build

- Build the `testmansh` script:

```shell
./bin/dev-build
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
