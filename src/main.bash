#
# Main
#

# Local variables
declare testmansh_command=''
declare testmansh_option=''
declare testmansh_case='all'
declare testmansh_debug_test="$BL64_VAR_OFF"
declare testmansh_format="$BL64_VAR_DEFAULT"
declare testmansh_container="$BL64_VAR_OFF"
declare testmansh_report="$BL64_VAR_DEFAULT"
declare testmansh_debug="$BL64_DBG_TARGET_NONE"
declare testmansh_verbose="$BL64_MSG_VERBOSE_APP"

(($# == 0)) && testmansh_help && exit 1
while getopts ':tbliokqs:p:c:e:r:f:m:u:gj:V:D:h' testmansh_option; do
  case "$testmansh_option" in
  t) testmansh_command='testmansh_run_linter' ;;
  b) testmansh_command='testmansh_run_test' ;;
  l) testmansh_command='testmansh_list_test_scope' ;;
  i) testmansh_command='testmansh_list_images' ;;
  k) testmansh_command='testmansh_list_linter_scope' ;;
  q) testmansh_command='testmansh_open_container' ;;
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
  o) testmansh_container="$BL64_VAR_ON" ;;
  h) testmansh_help && exit 0 ;;
  V) testmansh_verbose="$OPTARG" ;;
  D) testmansh_debug="$OPTARG" ;;
  *) testmansh_help && exit 1 ;;
  esac
done
testmansh_initialize "$testmansh_debug" "$testmansh_verbose" "$testmansh_container" "$testmansh_command" || exit 1

bl64_msg_show_batch_start "$testmansh_command"
case "$testmansh_command" in
'testmansh_list_test_scope' | 'testmansh_list_images' | 'testmansh_open_container' | 'testmansh_list_linter_scope') "$testmansh_command" ;;
'testmansh_run_linter') "$testmansh_command" "$testmansh_container" "$testmansh_format" "$testmansh_report" "$testmansh_case" ;;
'testmansh_run_test') "$testmansh_command" "$testmansh_container" "$testmansh_format" "$testmansh_report" "$testmansh_debug_test" "$testmansh_case" ;;
*) bl64_check_alert_parameter_invalid "$testmansh_command" ;;
esac
bl64_msg_show_batch_finish $? "$testmansh_command"
