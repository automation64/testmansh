#
# Functions
#

function testmansh_run_linter() {

  local container="$1"
  local format="$2"
  local case="$3"
  local target=''
  local flags=''
  local prefix="${TESTMANSH_DEFAULT_LINT_PREFIX}"

  [[ "$format" == "$BL64_LIB_DEFAULT" ]] && format='gcc'
  flags="--shell=bash --color=never --wiki-link-count=0 --format=$format"

  if [[ "$case" == 'all' ]]; then
    bl64_check_directory "$TESTMANSH_DEFAULT_LINT_PATH" 'default path for source code files not found. Please use -c to indicate where cases are.' || return $?
    [[ "$container" == "$BL64_LIB_VAR_ON" ]] && prefix="/src/${TESTMANSH_DEFAULT_LINT_PREFIX}"
    target="$(
      cd "$TESTMANSH_DEFAULT_LINT_PATH"
      bl64_fs_find_files | bl64_fmt_list_to_string "$BL64_LIB_DEFAULT" "${prefix}/"
    )"
  else
    target="$case"
  fi

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
  bl64_cnt_run_interactive \
    --volume "${TESTMANSH_PROJECT}:/src" \
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
    flags="$flags --timing --verbose-run --no-tempdir-cleanup --print-output-on-failure"
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
    case="${case}.bats"
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
    bl64_cnt_run_interactive \
      $env_file \
      --env BATSLIB_TEMP_PRESERVE_ON_FAILURE \
      --env BATSLIB_TEMP_PRESERVE \
      --volume "${TESTMANSH_PROJECT}:/test" \
      "${TESTMANSH_REGISTRY}/${container}" \
      $flags \
      "$target"
  done

}

function testmansh_open_container() {

  local target='/bin/bash'
  local env_file=''

  [[ -n "$TESTMANSH_ENV" && -r "$TESTMANSH_ENV" ]] && env_file="--env-file $TESTMANSH_ENV"
  bl64_dbg_app_show_vars 'env'

  bl64_cnt_run_interactive
  $env_file \
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
  cd "$TESTMANSH_PROJECT"
  bl64_fs_find_files "$TESTMANSH_DEFAULT_TEST_PREFIX"

}

function testmansh_list_linter_scope() {

  bl64_check_directory "$TESTMANSH_DEFAULT_LINT_PATH" 'default path for source code files not found. Please use -c to indicate where cases are.' || return $?
  bl64_msg_show_text "Source code scope for shellcheck (project: $TESTMANSH_PROJECT)"
  cd "$TESTMANSH_PROJECT"
  bl64_fs_find_files "$TESTMANSH_DEFAULT_LINT_PREFIX"

}

function testmansh_setup_globals() {

  TESTMANSH_CMD_BATS="${TESTMANSH_CMD_BATS:-/usr/local/bin/bats}"
  TESTMANSH_CMD_SHELLCHECK="${TESTMANSH_CMD_SHELLCHECK:-/usr/bin/shellcheck}"
  TESTMANSH_REGISTRY="${TESTMANSH_REGISTRY:-ghcr.io/serdigital64}"

  TESTMANSH_PROJECT="${TESTMANSH_PROJECT:-${PWD}}"

  TESTMANSH_DEFAULT_TEST_PREFIX='test/batscore'
  TESTMANSH_DEFAULT_LINT_PREFIX='src'
  TESTMANSH_DEFAULT_TEST_PATH="${TESTMANSH_PROJECT}/${TESTMANSH_DEFAULT_TEST_PREFIX}"
  TESTMANSH_DEFAULT_LINT_PATH="${TESTMANSH_PROJECT}/${TESTMANSH_DEFAULT_LINT_PREFIX}"

  TESTMANSH_IMAGES_TEST="${TESTMANSH_IMAGES_TEST:-}"
  TESTMANSH_ENV="${TESTMANSH_ENV:-}"

  if [[ -z "$TESTMANSH_IMAGES_TEST" ]]; then
    TESTMANSH_IMAGES_TEST=''
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST almalinux-8-bash-test:0.3.0"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST alpine-3-bash-test:0.3.0"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST rhel-8-bash-test:0.4.0"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST centos-7-bash-test:0.2.0 centos-8-bash-test:0.3.0 centos-9-bash-test:0.2.0"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST oraclelinux-7-bash-test:0.2.0 oraclelinux-8-bash-test:0.5.0"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST fedora-33-bash-test:0.5.0 fedora-34-bash-test:0.2.0 fedora-35-bash-test:0.5.0"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST debian-9-bash-test:0.2.0 debian-10-bash-test:0.5.0 debian-11-bash-test:0.5.0"
    TESTMANSH_IMAGES_TEST="$TESTMANSH_IMAGES_TEST ubuntu-20.4-bash-test:0.7.0 ubuntu-21.4-bash-test:0.5.0"
  fi
  TESTMANSH_IMAGES_LINT='alpine-3-shell-lint:0.1.0'
  return 0
}

function testmansh_check_requirements() {

  [[ -z "$testmansh_command" ]] && testmansh_help && return 1

  bl64_check_directory "$TESTMANSH_PROJECT" || return $?

  return 0

}

function testmansh_help() {
  bl64_msg_show_usage \
    '<-b|-t|-q|-l|-i|k> [-p Project] [-c Case] [-e Image] [-r Registry] [-s BatsCore] [-u ShellCheck] [-f EnvFile] [-m Format] [-g] [-h]' \
    'Simple tool for testing Bash scripts in either native environment or purpose-build container images.' \
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
  -c Case      : Test case name. Default: all. Format: path/file (relative to Project)
  -e Image     : Image name to use for running the container test (-b) or open (-q). Alternative: exported shell variable TESTMANSH_IMAGES_TEST. Default: predefined list
  -r Registry  : Container registry URL. Alternative: exported shell variable TESTMANSH_REGISTRY
  -f EnvFile   : Full path to the container environment file. Default: none
  -s BatsCore  : Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS
  -u ShellCheck: Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS
  -m Format    : Set report format type. Valued values: shellcheck and bats-core dependant
    "
}

#
# Main
#

# Local variables
declare testmansh_status=1
declare testmansh_command=''
declare testmansh_command_tag=''
declare testmansh_option=''
declare testmansh_case='all'
declare testmansh_debug="$BL64_LIB_VAR_OFF"
declare testmansh_format="$BL64_LIB_DEFAULT"
declare testmansh_container="$BL64_LIB_VAR_OFF"

(($# == 0)) && testmansh_help && exit 1
while getopts ':tbliokqs:p:c:e:r:f:m:u:gh' testmansh_option; do
  case "$testmansh_option" in
  t)
    testmansh_command='testmansh_run_linter'
    testmansh_command_tag='run shellcheck linter'
    ;;
  b)
    testmansh_command='testmansh_run_test'
    testmansh_command_tag='run bats-core tests'
    ;;
  l)
    testmansh_command='testmansh_list_test_scope'
    testmansh_command_tag='list test cases for bats-core'
    ;;
  i)
    testmansh_command='testmansh_list_images'
    testmansh_command_tag='list container images'
    ;;
  k)
    testmansh_command='testmansh_list_linter_scope'
    testmansh_command_tag='list source code files for shellcheck'
    ;;
  q)
    testmansh_command='testmansh_open_container'
    testmansh_command_tag='open testing container'
    ;;
  m) testmansh_format="$OPTARG" ;;
  p)
    TESTMANSH_PROJECT="$OPTARG"
    ;;
  s) TESTMANSH_CMD_BATS="$OPTARG" ;;
  u) TESTMANSH_CMD_SHELLCHECK="$OPTARG" ;;
  r) TESTMANSH_REGISTRY="$OPTARG" ;;
  e) TESTMANSH_IMAGES_TEST="$OPTARG" ;;
  f) TESTMANSH_ENV="$OPTARG" ;;
  c) testmansh_case="$OPTARG" ;;
  g) testmansh_debug="$BL64_LIB_VAR_ON" ;;
  o) testmansh_container="$BL64_LIB_VAR_ON" ;;
  h) testmansh_help && exit 0 ;;
  *) testmansh_help && exit 1 ;;
  esac
done
testmansh_setup_globals
testmansh_check_requirements || exit 1

bl64_msg_show_batch_start "$testmansh_command_tag"
case "$testmansh_command" in
'testmansh_list_test_scope' | 'testmansh_list_images' | 'testmansh_open_container' | 'testmansh_list_linter_scope') "$testmansh_command" ;;
'testmansh_run_linter') "$testmansh_command" "$testmansh_container" "$testmansh_format" "$testmansh_case" ;;
'testmansh_run_test') "$testmansh_command" "$testmansh_container" "$testmansh_format" "$testmansh_debug" "$testmansh_case" ;;
*) bl64_check_show_undefined "$testmansh_command" ;;
esac
testmansh_status=$?

bl64_msg_show_batch_finish $testmansh_status "$testmansh_command_tag"
exit $testmansh_status
