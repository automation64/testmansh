#
###[ embedded-bashlib64-end ]#####################
#

function testmansh_run_bats() {

  local debug="$1"
  local case="$2"
  local target=''
  local bats_verbose=''

  if [[ "$case" != 'all' ]]; then
    target="${TESTMANSH_PROJECT}/${BATSLIB_CASES}/${case}.bats"
  else
    target="${TESTMANSH_PROJECT}/${BATSLIB_CASES}"
  fi

  if [[ "$debug" == '1' ]]; then
    bats_verbose='--timing --verbose-run --no-tempdir-cleanup --print-output-on-failure'
    BATSLIB_TEMP_PRESERVE_ON_FAILURE=1
    BATSLIB_TEMP_PRESERVE=1
  else
    bats_verbose='--formatter tap'
  fi

  # shellcheck disable=SC2086
  "$TESTMANSH_CMD_BATS" $bats_verbose "$target"

}

function testmansh_run_bats_container() {

  local debug="$1"
  local case="$2"
  local container=''
  local target=''
  local bats_verbose=''
  local env=''

  if [[ "$case" != 'all' ]]; then
    target="/test/${BATSLIB_CASES}/${case}.bats"
  else
    target="/test/${BATSLIB_CASES}"
  fi

  [[ -n "$TESTMANSH_ENV" && -r "$TESTMANSH_ENV" ]] && env="--env-file $TESTMANSH_ENV"
  if [[ "$debug" == '1' ]]; then
    bats_verbose='--timing --verbose-run --no-tempdir-cleanup --print-output-on-failure'
    BATSLIB_TEMP_PRESERVE_ON_FAILURE=1
    BATSLIB_TEMP_PRESERVE=1
  else
    bats_verbose='--formatter tap'
    BATSLIB_TEMP_PRESERVE_ON_FAILURE=0
    BATSLIB_TEMP_PRESERVE=0
  fi

  IFS=' '
  for container in $TESTMANSH_IMAGES; do
    unset IFS
    bl64_msg_show_task "run test cases on the container image: $container"
    # shellcheck disable=SC2086
    "$DEVBL_CMD_PODMAN" \
      run \
      $env \
      --rm \
      --user "$TESTMANSH_USER" \
      --env BATSLIB_TEMP_PRESERVE_ON_FAILURE \
      --env BATSLIB_TEMP_PRESERVE \
      --volume "${TESTMANSH_PROJECT}:/test" \
      "${TESTMANSH_REGISTRY}/${container}" \
      $bats_verbose \
      "$target"
  done

}

function testmansh_open_container() {

  local target='/bin/bash'
  local env=''

  [[ -n "$TESTMANSH_ENV" && -r "$TESTMANSH_ENV" ]] && env="--env-file $TESTMANSH_ENV"

  "$DEVBL_CMD_PODMAN" \
    run \
    $env \
    --rm \
    --interactive \
    --tty \
    --user "$TESTMANSH_USER" \
    --env BATSLIB_TEMP_PRESERVE_ON_FAILURE \
    --env BATSLIB_TEMP_PRESERVE \
    --volume "${TESTMANSH_PROJECT}:/test" \
    --entrypoint "$target" \
    "${TESTMANSH_REGISTRY}/${TESTMANSH_IMAGES}"

}

function testmansh_list_images() {
  echo "$TESTMANSH_IMAGES"
}

function testmansh_list_cases() {
  "$BL64_OS_CMD_LS" "${TESTMANSH_PROJECT}"/*.bats
}

function testmansh_import() {
  TESTMANSH_PROJECT="${TESTMANSH_PROJECT:-test/${BATSLIB_CASES}}"
  TESTMANSH_CMD_BATS="${TESTMANSH_CMD_BATS:-/usr/local/bin/bats}"
  TESTMANSH_REGISTRY="${TESTMANSH_REGISTRY:-ghcr.io/serdigital64}"
  TESTMANSH_USER='test'

  TESTMANSH_IMAGES="${TESTMANSH_IMAGES:-}"
  TESTMANSH_ENV="${TESTMANSH_ENV:-}"

  if [[ -z "$TESTMANSH_IMAGES" ]]; then
    TESTMANSH_IMAGES=''
    TESTMANSH_IMAGES="$TESTMANSH_IMAGES almalinux-8-bash-test:0.3.0"
    TESTMANSH_IMAGES="$TESTMANSH_IMAGES alpine-3-bash-test:0.3.0"
    TESTMANSH_IMAGES="$TESTMANSH_IMAGES rhel-8-bash-test:0.4.0"
    TESTMANSH_IMAGES="$TESTMANSH_IMAGES centos-7-bash-test:0.2.0 centos-8-bash-test:0.3.0 centos-9-bash-test:0.2.0"
    TESTMANSH_IMAGES="$TESTMANSH_IMAGES oraclelinux-7-bash-test:0.2.0 oraclelinux-8-bash-test:0.5.0"
    TESTMANSH_IMAGES="$TESTMANSH_IMAGES fedora-33-bash-test:0.5.0 fedora-34-bash-test:0.2.0 fedora-35-bash-test:0.5.0"
    TESTMANSH_IMAGES="$TESTMANSH_IMAGES debian-9-bash-test:0.2.0 debian-10-bash-test:0.5.0 debian-11-bash-test:0.5.0"
    TESTMANSH_IMAGES="$TESTMANSH_IMAGES ubuntu-20.4-bash-test:0.7.0 ubuntu-21.4-bash-test:0.5.0"
  fi
  return 0
}

function testmansh_check() {

  bl64_check_command "$TESTMANSH_CMD_BATS" &&
    bl64_check_directory "$TESTMANSH_PROJECT" &&
    bl64_check_directory "${TESTMANSH_PROJECT}/${BATSLIB_CASES}" ||
    return 1
  return 0

}

function testmansh_run_tests_help() {
  bl64_msg_show_usage \
    '<-b|-o|-l|-i|-q> [-p Project] [-c Case] [-e Image] [-r Registry] [-s BatsCore] [-u user] [-f EnvFile] [-g] [-h]' \
    'Run bash test cases' \
    '
  -b         : Run tests
  -o         : Run tests in containers
  -q         : Open testing container
  -l         : List test cases
  -i         : List container images
    ' '
  -g         : Enable debug mode
  -h         : Show Help
    ' "
  -p Project : Full path to the project location. Alternative: exported shell variable TESTMANSH_PROJECT. Default: $TESTMANSH_PROJECT
  -c Case    : Test case name. Default: all
  -e Image   : Image name to use for running the container test (-o) or open (-q). Alternative: exported shell variable TESTMANSH_IMAGES. Default: predefined list
  -r Registry: Container registry URL. Alternative: exported shell variable TESTMANSH_REGISTRY. Default: ${TESTMANSH_REGISTRY}
  -u User    : Use name for container test. Alternative: exported shell variable TESTMANSH_USER. Default: ${TESTMANSH_USER}
  -f EnvFile : Full path to the container environment file. Default: none
  -s BatsCore: Full path to the bats-core shell script. Alternative: exported shell variable TESTMANSH_CMD_BATS. Default: $TESTMANSH_CMD_BATS
    "
}

#
# Main
#

# Imports
export TESTMANSH_PROJECT
export TESTMANSH_CMD_BATS
export TESTMANSH_REGISTRY
export TESTMANSH_USER
export TESTMANSH_IMAGES
export TESTMANSH_ENV

# Exports
export BATSLIB_TEMP_PRESERVE_ON_FAILURE
export BATSLIB_TEMP_PRESERVE

# Constants
readonly BATSLIB_CASES='batscore'

# Local variables
declare testmansh_run_tests_status=1
declare testmansh_run_tests_command=''
declare testmansh_run_tests_command_tag=''
declare testmansh_run_tests_option=''
declare testmansh_run_tests_case='all'
declare testmansh_run_tests_debug='0'

testmansh_import
(($# == 0)) && testmansh_run_tests_help && exit 1
while getopts ':blioqs:p:c:e:u:r:f:gh' testmansh_run_tests_option; do
  case "$testmansh_run_tests_option" in
  b)
    testmansh_run_tests_command='testmansh_run_bats'
    testmansh_run_tests_command_tag='run bats-core tests'
    ;;
  o)
    testmansh_run_tests_command='testmansh_run_bats_container'
    testmansh_run_tests_command_tag='run bats-core tests in containers'
    ;;
  l)
    testmansh_run_tests_command='testmansh_list_cases'
    testmansh_run_tests_command_tag='list test cases'
    ;;
  i)
    testmansh_run_tests_command='testmansh_list_images'
    testmansh_run_tests_command_tag='list container images'
    ;;
  q)
    testmansh_run_tests_command='testmansh_open_container'
    testmansh_run_tests_command_tag='open testing container'
    ;;
  p) TESTMANSH_PROJECT="$OPTARG" ;;
  s) TESTMANSH_CMD_BATS="$OPTARG" ;;
  r) TESTMANSH_REGISTRY="$OPTARG" ;;
  e) TESTMANSH_IMAGES="$OPTARG" ;;
  u) TESTMANSH_USER="$OPTARG" ;;
  f) TESTMANSH_ENV="$OPTARG" ;;
  c) testmansh_run_tests_case="$OPTARG" ;;
  g) testmansh_run_tests_debug='1' ;;
  h) testmansh_run_tests_help && exit ;;
  \?) testmansh_run_tests_help && exit 1 ;;
  esac
done
[[ -z "$testmansh_run_tests_command" ]] && testmansh_run_tests_help && exit 1
testmansh_check || exit 1

bl64_msg_show_batch_start "$testmansh_run_tests_command_tag"
case "$testmansh_run_tests_command" in
'testmansh_list_cases' | 'testmansh_list_images' | 'testmansh_open_container') "$testmansh_run_tests_command" ;;
'testmansh_run_bats') "$testmansh_run_tests_command" "$testmansh_run_tests_debug" "$testmansh_run_tests_case" ;;
'testmansh_run_bats_container') "$testmansh_run_tests_command" "$testmansh_run_tests_debug" "$testmansh_run_tests_case" ;;
esac
testmansh_run_tests_status=$?

bl64_msg_show_batch_finish $testmansh_run_tests_status "$testmansh_run_tests_command_tag"
exit $testmansh_run_tests_status
