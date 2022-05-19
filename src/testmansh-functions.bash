#
# Functions
#

function testmansh_run_linter() {
  local container="$1"
  local format="$2"
  local case="$3"
  local target=''
  local flags=''
  local prefix=''

  [[ "$format" == "$BL64_LIB_DEFAULT" ]] && format='gcc'
  flags="--shell=bash --color=never --wiki-link-count=0 --external-sources --severity=style --format=$format"

  if [[ "$case" == 'all' ]]; then
    bl64_check_directory "$TESTMANSH_DEFAULT_LINT_PATH" 'default path for source code files not found. Please use -c to indicate where cases are.' || return $?

    if [[ "$container" == "$BL64_LIB_VAR_ON" ]]; then
      prefix="/prj/${TESTMANSH_DEFAULT_LINT_PREFIX}/"
    else
      prefix="$TESTMANSH_DEFAULT_LINT_PREFIX"
    fi

    # shellcheck disable=SC2164
    target="$(
      cd "$TESTMANSH_DEFAULT_LINT_PATH"
      bl64_fs_find_files | bl64_fmt_list_to_string "$BL64_LIB_DEFAULT" "${prefix}"
    )"

  elif [[ -d "${TESTMANSH_PROJECT}/${case}" ]]; then

    if [[ "$container" == "$BL64_LIB_VAR_ON" ]]; then
      prefix="/prj/${case}/"
    else
      prefix="${case}/"
    fi

    # shellcheck disable=SC2164
    target="$(
      cd "${TESTMANSH_PROJECT}/${case}"
      bl64_fs_find_files | bl64_fmt_list_to_string "$BL64_LIB_DEFAULT" "${prefix}"
    )"
  elif [[ -f "${TESTMANSH_PROJECT}/${case}" ]]; then
    if [[ "$container" == "$BL64_LIB_VAR_ON" ]]; then
      target="/prj/${case}"
    else
      target="$case"
    fi
  else
    bl64_msg_show_error "source path not found ($case)"
    return 1
  fi

  # shellcheck disable=SC2086
  if [[ "$container" == "$BL64_LIB_VAR_ON" ]]; then
    testmansh_run_linter_container "$format" "$flags" $target
  else
    testmansh_run_linter_native "$format" "$flags" $target
  fi
}

function testmansh_run_linter_container() {
  local format="$1"
  local flags="$2"

  shift
  shift
  # shellcheck disable=SC2086
  bl64_cnt_run_interactive \
    --volume "${TESTMANSH_PROJECT}:/prj" \
    "${TESTMANSH_REGISTRY}/${TESTMANSH_IMAGES_LINT}" \
    $flags \
    "$@"
}

function testmansh_run_linter_native() {
  local format="$1"
  local flags="$2"

  bl64_check_command "$TESTMANSH_CMD_SHELLCHECK" || return $?

  shift
  shift
  cd "$TESTMANSH_PROJECT" || return 1
  # shellcheck disable=SC2086
  "$TESTMANSH_CMD_SHELLCHECK" \
    $flags \
    "$@"
}

function testmansh_run_test() {
  local container="$1"
  local format="$2"
  local debug="$3"
  local case="$4"
  local flags=''

  [[ "$format" == "$BL64_LIB_DEFAULT" ]] && format='tap'
  flags="--recursive --formatter $format"

  if [[ "$debug" == '1' ]]; then
    flags="$flags --timing --verbose-run --no-tempdir-cleanup --print-output-on-failure --show-output-of-passing-tests"
    BATSLIB_TEMP_PRESERVE_ON_FAILURE=1
    BATSLIB_TEMP_PRESERVE=1
  else
    BATSLIB_TEMP_PRESERVE_ON_FAILURE=0
    BATSLIB_TEMP_PRESERVE=0
  fi

  if [[ "$case" == 'all' ]]; then
    case="${TESTMANSH_DEFAULT_TEST_PREFIX}"
    bl64_check_directory "$TESTMANSH_DEFAULT_TEST_PATH" 'default path for test-cases not found. Please use -c to indicate where the code is.' || return $?
  else
    [[ ! -d ${TESTMANSH_PROJECT}/${case} ]] && case="${case}.bats"
  fi

  if [[ "$container" == "$BL64_LIB_VAR_ON" ]]; then
    testmansh_run_test_container "$flags" "/test/${case}"
  else
    testmansh_run_test_native "$flags" "${TESTMANSH_PROJECT}/${case}"
  fi
}

function testmansh_run_test_native() {
  local flags="$1"
  local target="$2"

  bl64_check_command "$TESTMANSH_CMD_BATS" || return $?
  bl64_dbg_app_show_vars 'target' 'flags'

  # shellcheck disable=SC2086
  "$TESTMANSH_CMD_BATS" $flags "$target"
}

function testmansh_run_test_container() {
  local flags="$1"
  local target="$2"
  local container=''
  local env_file=''

  [[ -n "$TESTMANSH_ENV" && -r "$TESTMANSH_ENV" ]] && env_file="--env-file $TESTMANSH_ENV"

  for container in $TESTMANSH_IMAGES_TEST; do
    unset IFS
    bl64_msg_show_task "run test cases on the container image: $container"
    # shellcheck disable=SC2086
    bl64_cnt_run \
      $env_file \
      --env TESTMANSH_BIN \
      --env TESTMANSH_SRC \
      --env TESTMANSH_LIB \
      --env TESTMANSH_TEST \
      --env TESTMANSH_TEST_SAMPLES \
      --env TESTMANSH_TEST_LIB \
      --env TESTMANSH_TEST_BATSCORE_SETUP \
      --env TESTMANSH_BATS_HELPER_SUPPORT \
      --env TESTMANSH_BATS_HELPER_ASSERT \
      --env TESTMANSH_BATS_HELPER_FILE \
      --env BATSLIB_TEMP_PRESERVE_ON_FAILURE \
      --env BATSLIB_TEMP_PRESERVE \
      --volume "${TESTMANSH_PROJECT}:/test" \
      "${TESTMANSH_REGISTRY}/${container}" \
      $flags \
      "$target" ||
      return $?
  done
}

function testmansh_open_container() {
  local target='/bin/bash'
  local env_file=''

  [[ -n "$TESTMANSH_ENV" && -r "$TESTMANSH_ENV" ]] && env_file="--env-file $TESTMANSH_ENV"
  bl64_dbg_app_show_vars 'env'

  # shellcheck disable=SC2086
  bl64_cnt_run_interactive \
    $env_file \
    --env TESTMANSH_BIN \
    --env TESTMANSH_SRC \
    --env TESTMANSH_LIB \
    --env TESTMANSH_TEST \
    --env TESTMANSH_TEST_SAMPLES \
    --env TESTMANSH_TEST_LIB \
    --env TESTMANSH_TEST_BATSCORE_SETUP \
    --env TESTMANSH_BATS_HELPER_SUPPORT \
    --env TESTMANSH_BATS_HELPER_ASSERT \
    --env TESTMANSH_BATS_HELPER_FILE \
    --env BATSLIB_TEMP_PRESERVE_ON_FAILURE \
    --env BATSLIB_TEMP_PRESERVE \
    --volume "${TESTMANSH_PROJECT}:/test" \
    --entrypoint "$target" \
    "${TESTMANSH_REGISTRY}/${TESTMANSH_IMAGES_TEST}"
}

function testmansh_list_images() {
  bl64_msg_show_text "Container images for bats-core test cases:"
  echo "$TESTMANSH_IMAGES_TEST"
  bl64_msg_show_text "Container image for shellcheck:"
  echo "$TESTMANSH_IMAGES_LINT"
}

function testmansh_list_test_scope() {
  bl64_check_directory "$TESTMANSH_DEFAULT_TEST_PATH" 'default path for test-cases not found. Please use -c to indicate where the code is.' || return $?
  bl64_msg_show_text "Test cases scope for bats-core (project: $TESTMANSH_PROJECT)"
  # shellcheck disable=SC2164
  cd "$TESTMANSH_PROJECT"
  bl64_fs_find_files "$TESTMANSH_DEFAULT_TEST_PREFIX"
}

function testmansh_list_linter_scope() {
  bl64_check_directory "$TESTMANSH_DEFAULT_LINT_PATH" 'default path for source code files not found. Please use -c to indicate where cases are.' || return $?
  bl64_msg_show_text "Source code scope for shellcheck (project: $TESTMANSH_PROJECT)"
  # shellcheck disable=SC2164
  cd "$TESTMANSH_PROJECT"
  bl64_fs_find_files "$TESTMANSH_DEFAULT_LINT_PREFIX"
}

function testmansh_setup_globals() {
  bl64_cnt_setup || return $?

  TESTMANSH_CMD_BATS="${TESTMANSH_CMD_BATS:-/usr/local/bin/bats}"
  TESTMANSH_CMD_SHELLCHECK="${TESTMANSH_CMD_SHELLCHECK:-/usr/bin/shellcheck}"
  TESTMANSH_REGISTRY="${TESTMANSH_REGISTRY:-ghcr.io/serdigital64}"

  TESTMANSH_PROJECT="${TESTMANSH_PROJECT:-${PWD}}"

  TESTMANSH_DEFAULT_TEST_PREFIX='test/batscore'
  TESTMANSH_DEFAULT_LINT_PREFIX='src'
  TESTMANSH_DEFAULT_TEST_PATH="${TESTMANSH_PROJECT}/${TESTMANSH_DEFAULT_TEST_PREFIX}"
  TESTMANSH_DEFAULT_LINT_PATH="${TESTMANSH_PROJECT}/${TESTMANSH_DEFAULT_LINT_PREFIX}"

  TESTMANSH_IMAGES_TEST="${TESTMANSH_IMAGES_TEST:-}"
  TESTMANSH_ENV="${TESTMANSH_ENV:-${TESTMANSH_PROJECT}/test/container.env}"

  if [[ -z "$TESTMANSH_IMAGES_TEST" ]]; then
    TESTMANSH_IMAGES_TEST=''
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST almalinux-8-bash-test:latest"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST alpine-3-bash-test:latest"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST rhel-8-bash-test:latest"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST centos-7-bash-test:latest centos-8-bash-test:latest centos-9-bash-test:latest"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST oraclelinux-7-bash-test:latest oraclelinux-8-bash-test:latest"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST fedora-33-bash-test:latest fedora-34-bash-test:latest fedora-35-bash-test:latest"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST debian-9-bash-test:latest debian-10-bash-test:latest debian-11-bash-test:latest"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST ubuntu-20.4-bash-test:latest ubuntu-21.4-bash-test:latest"
  fi
  TESTMANSH_IMAGES_LINT='alpine-3-shell-lint:latest'
}

function testmansh_check_requirements() {
  [[ -z "$testmansh_command" ]] && testmansh_help && return 1

  bl64_check_directory "$TESTMANSH_PROJECT" || return $?

  return 0
}

function testmansh_help() {
  bl64_msg_show_usage \
    '<-b|-t|-q|-l|-i|k> [-p Project] [-c Case] [-e Image] [-r Registry] [-s BatsCore] [-u ShellCheck] [-f EnvFile] [-m Format] [-g] [-h]' \
    'Simple tool for testing Bash scripts with shellcheck and bats-core in either native environment or purpose-build container images.' \
    '
  -b           : Run bats-core tests
  -t           : Run shellcheck linter
  -q           : Open bats-core container
  -l           : List bats-core test cases
  -i           : List bats-core container images
  -k           : List shellcheck targets
    ' '
  -g           : Enable debug mode
  -o           : Enable container mode (for -b and -t)
  -h           : Show Help
    ' "
  -p Project   : Full path to the project location. Alternative: exported shell variable TESTMANSH_PROJECT. Default: current location
  -c Case      : Test case name (for -b) or source code (for -t). Default: all. Format: path/file or path/ (relative to TESTMANSH_PROJECT)
  -e Image     : Image name to use for running the container test (-b) or open (-q). Alternative: exported shell variable TESTMANSH_IMAGES_TEST. Default: predefined list
  -r Registry  : Container registry URL. Alternative: exported shell variable TESTMANSH_REGISTRY
  -f EnvFile   : Full path to the container environment file. Default: TESTMANSH_PROJECT/test/container.env
  -s BatsCore  : Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS
  -u ShellCheck: Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_SHELLCHECK
  -m Format    : Set report format type. Valued values: shellcheck and bats-core dependant
    "
}
