#
# Functions
#

function testmansh_run_linter() {
  bl64_dbg_app_show_function "$@"
  local format="$1"
  local report="$2"
  local case="$3"
  local target=''
  local flags='--shell=bash --color=never --wiki-link-count=0 --external-sources --severity=style'
  local prefix=''

  # Set report output and format
  if [[ "$report" != "$BL64_VAR_DEFAULT" ]]; then
    flags="${flags} --format checkstyle"
  else
    [[ "$format" == "$BL64_VAR_DEFAULT" ]] && format='gcc'
    flags="${flags} --format $format"
  fi

  if [[ "$case" == 'all' ]]; then
    if [[ "$TESTMANSH_MODE" == "$TESTMANSH_MODE_CONTAINER" ]]; then
      prefix="${TESTMANSH_CONTAINER64_PROJECT}/${TESTMANSH_DEFAULT_LINT_PREFIX}/"
    else
      prefix="$TESTMANSH_DEFAULT_LINT_PREFIX/"
    fi

    # shellcheck disable=SC2164
    target="$(
      cd "$TESTMANSH_DEFAULT_LINT_PATH"
      bl64_fs_find_files | bl64_fmt_list_to_string "$BL64_VAR_DEFAULT" "${prefix}"
    )"

  elif [[ -d "${TESTMANSH_PROJECT}/${case}" ]]; then

    if [[ "$TESTMANSH_MODE" == "$TESTMANSH_MODE_CONTAINER" ]]; then
      prefix="${TESTMANSH_CONTAINER64_PROJECT}/${case}/"
    else
      prefix="${case}/"
    fi

    # shellcheck disable=SC2164
    target="$(
      cd "${TESTMANSH_PROJECT}/${case}"
      bl64_fs_find_files | bl64_fmt_list_to_string "$BL64_VAR_DEFAULT" "${prefix}"
    )"
  elif [[ -f "${TESTMANSH_PROJECT}/${case}" ]]; then
    if [[ "$TESTMANSH_MODE" == "$TESTMANSH_MODE_CONTAINER" ]]; then
      target="${TESTMANSH_CONTAINER64_PROJECT}/${case}"
    else
      target="$case"
    fi
  else
    bl64_msg_show_error "source path not found ($case)"
    return 1
  fi

  bl64_msg_show_text "Run shellcheck linter on project: ${TESTMANSH_PROJECT}"
  # shellcheck disable=SC2086
  if [[ "$TESTMANSH_MODE" == "$TESTMANSH_MODE_CONTAINER" ]]; then
    if [[ "$report" != "$BL64_VAR_DEFAULT" ]]; then
      testmansh_run_linter_container "$format" "$flags" $target >"$report"
    else
      testmansh_run_linter_container "$format" "$flags" $target
    fi
  else
    if [[ "$report" != "$BL64_VAR_DEFAULT" ]]; then
      testmansh_run_linter_native "$format" "$flags" $target >"$report"
    else
      testmansh_run_linter_native "$format" "$flags" $target
    fi
  fi
}

function testmansh_run_linter_container() {
  bl64_dbg_app_show_function "$@"
  local format="$1"
  local flags="$2"

  shift
  shift
  # shellcheck disable=SC2086
  bl64_cnt_run_interactive \
    --volume "${TESTMANSH_PROJECT}:${TESTMANSH_CONTAINER64_PROJECT}" \
    --workdir "${TESTMANSH_CONTAINER64_PROJECT}" \
    "${TESTMANSH_REGISTRY}/${TESTMANSH_IMAGES_LINT}" \
    $flags \
    "$@"
}

function testmansh_run_linter_native() {
  bl64_dbg_app_show_function "$@"
  local format="$1"
  local flags="$2"

  shift
  shift
  cd "$TESTMANSH_PROJECT" || return 1
  bl64_dbg_app_show_info "current path: $(pwd)"
  bl64_dbg_app_trace_start
  # shellcheck disable=SC2086
  "$TESTMANSH_CMD_SHELLCHECK" \
    $flags \
    "$@"
  bl64_dbg_app_trace_stop
}

function testmansh_run_test() {
  bl64_dbg_app_show_function "$@"
  local format="$1"
  local report="$2"
  local debug="$3"
  local case="$4"
  local flags='--recursive'

  # Set report output and format
  if [[ "$report" != "$BL64_VAR_DEFAULT" ]]; then
    flags="${flags} --formatter junit"
  else
    [[ "$format" == "$BL64_VAR_DEFAULT" ]] && format='tap'
    flags="${flags} --formatter $format"
  fi

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
  else
    [[ ! -d ${TESTMANSH_PROJECT}/${case} ]] && case="${case}.bats"
  fi

  bl64_msg_show_text "run bats-core test-cases on project: ${TESTMANSH_PROJECT}"
  if [[ "$TESTMANSH_MODE" == "$TESTMANSH_MODE_CONTAINER" ]]; then
    testmansh_run_test_container "$report" "$flags" "${TESTMANSH_CONTAINER64_PROJECT}/${case}"
  else
    testmansh_run_test_native "$report" "$flags" "${TESTMANSH_PROJECT}/${case}"
  fi
}

function testmansh_run_test_native() {
  bl64_dbg_app_show_function "$@"
  local report="$1"
  local flags="$2"
  local target="$3"

  bl64_dbg_app_show_vars 'target' 'flags'

  # shellcheck disable=SC2086
  if [[ "$report" != "$BL64_VAR_DEFAULT" ]]; then
    "$TESTMANSH_CMD_BATS" $flags "$target" >"$report"
  else
    "$TESTMANSH_CMD_BATS" $flags "$target"
  fi
}

function testmansh_run_test_container() {
  bl64_dbg_app_show_function "$@"
  local report="$1"
  local flags="$2"
  local target="$3"
  local container=''
  local env_file=' '

  [[ -n "$TESTMANSH_ENV" && -r "$TESTMANSH_ENV" ]] && env_file="--env-file $TESTMANSH_ENV"

  for container in $TESTMANSH_IMAGES_TEST; do
    unset IFS
    bl64_msg_show_task "run test cases on the container image: $container"
    if [[ "$report" != "$BL64_VAR_DEFAULT" ]]; then
      testmansh_run_test_container_batscore "$container" "$target" "$flags" "$env_file" >"$report" ||
        return $?
    else
      testmansh_run_test_container_batscore "$container" "$target" "$flags" "$env_file" ||
        return $?
    fi
  done

}

function testmansh_run_test_container_batscore() {
  bl64_dbg_app_show_function "$@"
  local container="$1"
  local target="$2"
  local flags="$3"
  local env_file="$4"

  # shellcheck disable=SC2086
  bl64_cnt_run_interactive \
    $env_file \
    --env TESTMANSH_PROJECT_ROOT \
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
    "$target"
}

function testmansh_open_container() {
  bl64_dbg_app_show_function
  local target='/bin/bash'
  local env_file=''

  [[ -n "$TESTMANSH_ENV" && -r "$TESTMANSH_ENV" ]] && env_file="--env-file $TESTMANSH_ENV"
  bl64_dbg_app_show_vars 'env_file'

  # shellcheck disable=SC2086
  bl64_cnt_run_interactive \
    $env_file \
    --env TESTMANSH_PROJECT_ROOT \
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
    --entrypoint "$target" \
    "${TESTMANSH_REGISTRY}/${TESTMANSH_IMAGES_TEST}"
}

function testmansh_list_images() {
  bl64_dbg_app_show_function
  bl64_msg_show_text "Container images for bats-core test cases:"
  echo "$TESTMANSH_IMAGES_TEST"
  bl64_msg_show_text "Container image for shellcheck:"
  echo "$TESTMANSH_IMAGES_LINT"
}

function testmansh_list_test_scope() {
  bl64_dbg_app_show_function
  bl64_msg_show_text "Test cases scope for bats-core (project: $TESTMANSH_PROJECT)"
  # shellcheck disable=SC2164
  cd "$TESTMANSH_PROJECT"
  bl64_fs_find_files "$TESTMANSH_DEFAULT_TEST_PREFIX"
}

function testmansh_list_linter_scope() {
  bl64_dbg_app_show_function
  bl64_msg_show_text "Source code scope for shellcheck (project: $TESTMANSH_PROJECT)"
  # shellcheck disable=SC2164
  cd "$TESTMANSH_PROJECT"
  bl64_fs_find_files "$TESTMANSH_DEFAULT_LINT_PREFIX"
}

function testmansh_initialize() {
  local command="$1"
  local case="$2"

  bl64_check_parameter 'command' ||
    { testmansh_help && return 1; }

  bl64_dbg_app_show_info 'determine execution mode'
  if [[ "$TESTMANSH_MODE" == "$TESTMANSH_MODE_CONTAINER" ]]; then
    bl64_cnt_setup || return $?
  elif [[ "$TESTMANSH_MODE" == "$TESTMANSH_MODE_DETECT" ]]; then
    if ! bl64_cnt_is_inside_container && bl64_cnt_setup 2>/dev/null; then
      TESTMANSH_MODE="$TESTMANSH_MODE_CONTAINER"
    else
      TESTMANSH_MODE="$TESTMANSH_MODE_NATIVE"
    fi
  fi

  bl64_dbg_app_show_info 'Adjust project paths'
  TESTMANSH_PROJECT="${TESTMANSH_PROJECT:-$(pwd)}"
  TESTMANSH_DEFAULT_TEST_PATH="${TESTMANSH_PROJECT}/${TESTMANSH_DEFAULT_TEST_PREFIX}"
  TESTMANSH_DEFAULT_LINT_PATH="${TESTMANSH_PROJECT}/${TESTMANSH_DEFAULT_LINT_PREFIX}"
  TESTMANSH_ENV="${TESTMANSH_ENV:-${TESTMANSH_PROJECT}/test/container.env}"
  bl64_check_directory "$TESTMANSH_PROJECT" || return $?

  bl64_dbg_app_show_info 'Adjust test-case default paths based on container mode flag'
  if [[ "$TESTMANSH_MODE" == "$TESTMANSH_MODE_CONTAINER" ]]; then
    TESTMANSH_PROJECT_ROOT="${TESTMANSH_CONTAINER64_PROJECT}"
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
    TESTMANSH_PROJECT_ROOT="${TESTMANSH_PROJECT}"
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
  bl64_dbg_app_show_vars \
    'TESTMANSH_PROJECT_ROOT' \
    'TESTMANSH_PROJECT_BIN' \
    'TESTMANSH_PROJECT_SRC' \
    'TESTMANSH_PROJECT_LIB' \
    'TESTMANSH_PROJECT_BUILD' \
    'TESTMANSH_TEST' \
    'TESTMANSH_TEST_SAMPLES' \
    'TESTMANSH_TEST_LIB' \
    'TESTMANSH_TEST_BATSCORE_SETUP' \
    'TESTMANSH_CMD_BATS_HELPER_SUPPORT' \
    'TESTMANSH_CMD_BATS_HELPER_ASSERT' \
    'TESTMANSH_CMD_BATS_HELPER_FILE'

  # shellcheck disable=SC2249
  case "$command" in
  'open_container')
    bl64_check_parameter 'TESTMANSH_IMAGES_TEST' 'Please specify what container image to open with the parameter -e Image' ||
      return $?
    ;;
  'run_linter')
    if [[ "$TESTMANSH_MODE" != "$TESTMANSH_MODE_CONTAINER" ]]; then
      bl64_check_command "$TESTMANSH_CMD_SHELLCHECK" ||
        return $?
    fi
    if [[ "$case" == 'all' ]]; then
      bl64_check_directory "$TESTMANSH_DEFAULT_LINT_PATH" 'default path for test-cases not found. Please use -c to indicate where the code is.' ||
        return $?
    fi
    ;;
  'run_test')
    if [[ "$TESTMANSH_MODE" != "$TESTMANSH_MODE_CONTAINER" ]]; then
      bl64_check_command "$TESTMANSH_CMD_SHELLCHECK" ||
        return $?
    fi
    if [[ "$case" == 'all' ]]; then
      bl64_check_directory "$TESTMANSH_DEFAULT_TEST_PATH" 'default path for test-cases not found. Please use -c to indicate where the code is.' ||
        return $?
    fi
    ;;
  'list_linter_scope')
    bl64_check_directory "$TESTMANSH_DEFAULT_LINT_PATH" 'default path for source code files not found. Please use -c to indicate where cases are.' ||
      return $?
    ;;
  'list_test_scope')
    bl64_check_directory "$TESTMANSH_DEFAULT_TEST_PATH" 'default path for test-cases not found. Please use -c to indicate where the code is.' ||
      return $?
    ;;
  esac

  return 0
}

function testmansh_help() {
  bl64_msg_show_usage \
    '<-b|-t|-q|-l|-i|k> [-p Project] [-c Case] [-e Image] [-o|-a] [-r Registry] [-s BatsCore] [-u ShellCheck] [-f EnvFile] [-m Format|-j JUnitFile] [-g] [-V Verbose] [-D Debug] [-h]' \
    'Simple tool for testing Bash scripts in native environment or purpose-build container images.

By default testmansh assumes that scripts are organized using the following directory structure:

  - project_path/: project base path
  - project_path/src/: bash scripts
  - project_path/test/: test-cases repository
  - project_path/test/batscore/: test cases in bats-core format
  - project_path/test/samples/: test samples
  - project_path/test/lib/: shared code for test cases

The tool also sets and exports shell environment variables  'run_linter')

  - TESTMANSH_PROJECT_LIB: dev time libs (project/lib)
  - TESTMANSH_PROJECT_BUILD: location for dev,test builds (project/build)
  - TESTMANSH_TEST: tests base path (project/test)
  - TESTMANSH_TEST_SAMPLES: test samples (project/test/samples)
  - TESTMANSH_TEST_LIB: test shared libs (project/test/lib)
  - TESTMANSH_TEST_BATSCORE_SETUP: batscore setup script (project/test/lib/batscore-setup.bash)
  - TESTMANSH_CMD_BATS_HELPER_SUPPORT: full path to the bats-core support helper
  - TESTMANSH_CMD_BATS_HELPER_ASSERT: full path to the bats-core assert helper
  - TESTMANSH_CMD_BATS_HELPER_FILE: full path to the bats-core file helper' \
    '
  -b           : Run bats-core tests
  -t           : Run shellcheck linter
  -q           : Open bats-core container
  -l           : List bats-core test cases
  -i           : List bats-core container images
  -k           : List shellcheck targets
    ' '
  -g           : Enable debug mode in test cases
  -o           : Enable container mode (for -b and -t)
  -a           : Autodetect best mode (for -t)
  -h           : Show Help
    ' "
  -p Project   : Full path to the project location. Alternative: exported shell variable TESTMANSH_PROJECT. Default: current location
  -c Case      : Test case name (for -b) or source code (for -t). Default: all. Format: path/file or path/ (relative to TESTMANSH_PROJECT)
  -e Image     : Image name to use for running the container test (-b) or open (-q). Alternative: exported shell variable TESTMANSH_IMAGES_TEST. Default: predefined list
  -r Registry  : Container registry URL. Alternative: exported shell variable TESTMANSH_REGISTRY
  -f EnvFile   : Full path to the container environment file. Default: TESTMANSH_PROJECT/test/container.env
  -s BatsCore  : Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS
  -u ShellCheck: Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_SHELLCHECK
  -m Format    : Show test results on STDOUT using the Format type. Format: shellcheck and bats-core dependant
  -j JUnitFile : Save test results in JUnit format to the file JUnitFile. Format: full path
  -V Verbose   : Set verbosity level. Format: one of BL64_MSG_VERBOSE_*
  -D Debug     : Enable debugging mode. Format: one of BL64_DBG_TARGET_*
    "
}
