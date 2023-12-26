#
# Main
#

# Local variables
declare testmansh_case='all'
declare testmansh_command="$BL64_VAR_NULL"
declare testmansh_debug_test="$BL64_VAR_OFF"
declare testmansh_debug="$BL64_DBG_TARGET_NONE"
declare testmansh_format="$BL64_VAR_DEFAULT"
declare testmansh_option=''
declare testmansh_report="$BL64_VAR_DEFAULT"
declare testmansh_verbose="$BL64_MSG_VERBOSE_APP"

(($# == 0)) && testmansh_help && exit 1
while getopts ':tblioakqs:p:c:e:r:f:m:u:gj:V:D:h' testmansh_option; do
  case "$testmansh_option" in
  t) testmansh_command='run_linter' ;;
  b) testmansh_command='run_test' ;;
  l) testmansh_command='list_test_scope' ;;
  i) testmansh_command='list_images' ;;
  k) testmansh_command='list_linter_scope' ;;
  q) testmansh_command='open_container' ;;
  m) testmansh_format="$OPTARG" ;;
  j) testmansh_report="$OPTARG" ;;
  p) TESTMANSH_PROJECT="$OPTARG" ;;
  s) TESTMANSH_CMD_BATS="$OPTARG" ;;
  u) TESTMANSH_CMD_SHELLCHECK="$OPTARG" ;;
  r) TESTMANSH_REGISTRY="$OPTARG" ;;
  e) TESTMANSH_IMAGES_TEST="$OPTARG" ;;
  f) TESTMANSH_ENV="$OPTARG" ;;
  c) testmansh_case="$OPTARG" ;;
  g) testmansh_debug_test="$BL64_VAR_ON" ;;
  o) TESTMANSH_MODE="$TESTMANSH_MODE_CONTAINER" ;;
  a) TESTMANSH_MODE="$TESTMANSH_MODE_DETECT" ;;
  h) testmansh_help && exit 0 ;;
  V) testmansh_verbose="$OPTARG" ;;
  D) testmansh_debug="$OPTARG" ;;
  *) testmansh_help && exit 1 ;;
  esac
done
bl64_dbg_set_level "$testmansh_debug" && bl64_msg_set_level "$testmansh_verbose" || exit $?
testmansh_initialize "$testmansh_command" || exit 1

bl64_msg_show_batch_start "$testmansh_command"
case "$testmansh_command" in
'list_test_scope' | 'list_images' | 'open_container' | 'list_linter_scope') "testmansh_${testmansh_command}" ;;
'run_linter') "testmansh_${testmansh_command}" "$testmansh_format" "$testmansh_report" "$testmansh_case" ;;
'run_test') "testmansh_${testmansh_command}" "$testmansh_format" "$testmansh_report" "$testmansh_debug_test" "$testmansh_case" ;;
*) bl64_check_alert_parameter_invalid "$testmansh_command" ;;
esac
bl64_msg_show_batch_finish $? "$testmansh_command"
