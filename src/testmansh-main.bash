#
# Main
#

# Local variables
declare testmansh_status=1
declare testmansh_command=''
declare testmansh_command_tag=''
declare testmansh_option=''
declare testmansh_case='all'
declare testmansh_debug="$BL64_VAR_OFF"
declare testmansh_format="$BL64_VAR_DEFAULT"
declare testmansh_container="$BL64_VAR_OFF"
declare testmansh_report="$BL64_VAR_DEFAULT"
declare testmansh_debug="$BL64_DBG_TARGET_NONE"
declare testmansh_verbose="$BL64_MSG_VERBOSE_APP"

(($# == 0)) && testmansh_help && exit 1
while getopts ':tbliokqs:p:c:e:r:f:m:u:gj:V:D:h' testmansh_option; do
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
  j) testmansh_report="$OPTARG" ;;
  p) TESTMANSH_PROJECT="$OPTARG" ;;
  s) TESTMANSH_CMD_BATS="$OPTARG" ;;
  u) TESTMANSH_CMD_SHELLCHECK="$OPTARG" ;;
  r) TESTMANSH_REGISTRY="$OPTARG" ;;
  e) TESTMANSH_IMAGES_TEST="$OPTARG" ;;
  f) TESTMANSH_ENV="$OPTARG" ;;
  c) testmansh_case="$OPTARG" ;;
  g) testmansh_debug="$BL64_VAR_ON" ;;
  o) testmansh_container="$BL64_VAR_ON" ;;
  h) testmansh_help && exit 0 ;;
  V) testmansh_verbose="$OPTARG" ;;
  D) testmansh_debug="$OPTARG" ;;
  *) testmansh_help && exit 1 ;;
  esac
done
testmansh_initialize "$testmansh_debug" "$testmansh_verbose" "$testmansh_command" "$testmansh_container" || exit 1

bl64_msg_show_batch_start "$testmansh_command_tag"
case "$testmansh_command" in
'testmansh_list_test_scope' | 'testmansh_list_images' | 'testmansh_open_container' | 'testmansh_list_linter_scope') "$testmansh_command" ;;
'testmansh_run_linter') "$testmansh_command" "$testmansh_container" "$testmansh_format" "$testmansh_report" "$testmansh_case" ;;
'testmansh_run_test') "$testmansh_command" "$testmansh_container" "$testmansh_format" "$testmansh_report" "$testmansh_debug" "$testmansh_case" ;;
*) bl64_check_alert_parameter_invalid "$testmansh_command" ;;
esac
testmansh_status=$?

# shellcheck disable=SC2248
bl64_msg_show_batch_finish $testmansh_status "$testmansh_command_tag"
# shellcheck disable=SC2248
exit $testmansh_status
