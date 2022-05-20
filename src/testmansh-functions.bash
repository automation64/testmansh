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
      prefix="${TESTMANSH_CONTAINER64_PROJECT}/${TESTMANSH_DEFAULT_LINT_PREFIX}/"
    else
      prefix="$TESTMANSH_DEFAULT_LINT_PREFIX/"
    fi

    # shellcheck disable=SC2164
    target="$(
      cd "$TESTMANSH_DEFAULT_LINT_PATH"
      bl64_fs_find_files | bl64_fmt_list_to_string "$BL64_LIB_DEFAULT" "${prefix}"
    )"

  elif [[ -d "${TESTMANSH_PROJECT}/${case}" ]]; then

    if [[ "$container" == "$BL64_LIB_VAR_ON" ]]; then
      prefix="${TESTMANSH_CONTAINER64_PROJECT}/${case}/"
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
      target="${TESTMANSH_CONTAINER64_PROJECT}/${case}"
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
    --volume "${TESTMANSH_PROJECT}:${TESTMANSH_CONTAINER64_PROJECT}" \
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
    bl64_check_directory "$TESTMANSH_DEFAULT_TEST_PATH" 'default path for test-cases not found. Please use -c to indicate where the code is.' || return $?
    case="${TESTMANSH_DEFAULT_TEST_PREFIX}"
  else
    [[ ! -d ${TESTMANSH_PROJECT}/${case} ]] && case="${case}.bats"
  fi

  if [[ "$container" == "$BL64_LIB_VAR_ON" ]]; then
    testmansh_run_test_container "$flags" "${TESTMANSH_CONTAINER64_PROJECT}/${case}"
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
    bl64_cnt_run_interactive \
      $env_file \
      --env TESTMANSH_PROJECT_BIN \
      --env TESTMANSH_PROJECT_SRC \
      --env TESTMANSH_PROJECT_LIB \
      --env TESTMANSH_PROJECT_BUILD \
      --env TESTMANSH_TEST \
      --env TESTMANSH_TEST_SAMPLES \
      --env TESTMANSH_TEST_LIB \
      --env TESTMANSH_TEST_BATSCORE_SETUP \
      --env TESTMANSH_CMD_BATS_HELPER_SUPPORT \
      --env TESTMANSH_CMD_BATS_HELPER_ASSERT \
      --env TESTMANSH_CMD_BATS_HELPER_FILE \
      --env BATSLIB_TEMP_PRESERVE_ON_FAILURE \
      --env BATSLIB_TEMP_PRESERVE \
      --volume "${TESTMANSH_PROJECT}:${TESTMANSH_CONTAINER64_PROJECT}" \
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
    --env TESTMANSH_PROJECT_BIN \
    --env TESTMANSH_PROJECT_SRC \
    --env TESTMANSH_PROJECT_LIB \
    --env TESTMANSH_PROJECT_BUILD \
    --env TESTMANSH_TEST \
    --env TESTMANSH_TEST_SAMPLES \
    --env TESTMANSH_TEST_LIB \
    --env TESTMANSH_TEST_BATSCORE_SETUP \
    --env TESTMANSH_CMD_BATS_HELPER_SUPPORT \
    --env TESTMANSH_CMD_BATS_HELPER_ASSERT \
    --env TESTMANSH_CMD_BATS_HELPER_F \
    --env BATSLIB_TEMP_PRESERVE_ON_FAILURE \
    --env BATSLIB_TEMP_PRESERVE \
    --volume "${TESTMANSH_PROJECT}:${TESTMANSH_CONTAINER64_PROJECT}" \
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
  local container="$1"

  bl64_cnt_setup || return $?

  TESTMANSH_PROJECT="${TESTMANSH_PROJECT:-${PWD}}"
  TESTMANSH_DEFAULT_TEST_PATH="${TESTMANSH_PROJECT}/${TESTMANSH_DEFAULT_TEST_PREFIX}"
  TESTMANSH_DEFAULT_LINT_PATH="${TESTMANSH_PROJECT}/${TESTMANSH_DEFAULT_LINT_PREFIX}"
  TESTMANSH_ENV="${TESTMANSH_ENV:-${TESTMANSH_PROJECT}/test/container.env}"

  # Adjust test-case default paths based on container mode flag
  if [[ "$container" == "$BL64_LIB_VAR_ON" ]]; then
    TESTMANSH_PROJECT_BIN="${TESTMANSH_CONTAINER64_PROJECT}/bin"
    TESTMANSH_PROJECT_SRC="${TESTMANSH_CONTAINER64_PROJECT}/src"
    TESTMANSH_PROJECT_LIB="${TESTMANSH_CONTAINER64_PROJECT}/lib"
    TESTMANSH_PROJECT_BUILD="${TESTMANSH_CONTAINER64_PROJECT}/build"
    TESTMANSH_TEST="${TESTMANSH_CONTAINER64_PROJECT}/test"
    TESTMANSH_TEST_SAMPLES="${TESTMANSH_CONTAINER64_PROJECT}/test/samples"
    TESTMANSH_TEST_LIB="${TESTMANSH_CONTAINER64_PROJECT}/test/lib"
    TESTMANSH_TEST_BATSCORE_SETUP="${TESTMANSH_CONTAINER64_PROJECT}/test/lib/batscore-setup.bash"
    TESTMANSH_CMD_BATS_HELPER_SUPPORT="${TESTMANSH_CONTAINER64_BATS_HELPER_SUPPORT}/load.bash"
    TESTMANSH_CMD_BATS_HELPER_ASSERT="${TESTMANSH_CONTAINER64_BATS_HELPER_ASSERT}/load.bash"
    TESTMANSH_CMD_BATS_HELPER_FILE="${TESTMANSH_CONTAINER64_BATS_HELPER_FILE}/load.bash"
  else
    TESTMANSH_PROJECT_BIN="${TESTMANSH_PROJECT}/bin"
    TESTMANSH_PROJECT_SRC="${TESTMANSH_PROJECT}/src"
    TESTMANSH_PROJECT_LIB="${TESTMANSH_PROJECT}/lib"
    TESTMANSH_PROJECT_BUILD="${TESTMANSH_PROJECT}/build"
    TESTMANSH_TEST="${TESTMANSH_PROJECT}/test"
    TESTMANSH_TEST_SAMPLES="${TESTMANSH_PROJECT}/test/samples"
    TESTMANSH_TEST_LIB="${TESTMANSH_PROJECT}/test/lib"
    TESTMANSH_TEST_BATSCORE_SETUP="${TESTMANSH_PROJECT}/test/lib/batscore-setup.bash"
    TESTMANSH_CMD_BATS_HELPER_SUPPORT="${TESTMANSH_CMD_BATS_HELPER_SUPPORT:-/opt/bats-core/test_helpers/support/load.bash}"
    TESTMANSH_CMD_BATS_HELPER_ASSERT="${TESTMANSH_CMD_BATS_HELPER_ASSERT:-/opt/bats-core/test_helpers/assert/load.bash}"
    TESTMANSH_CMD_BATS_HELPER_FILE="${TESTMANSH_CMD_BATS_HELPER_FILE:-/opt/bats-core/test_helpers/file/load.bash}"
  fi
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
