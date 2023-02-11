@test "container: exported variables" {
  [[ -n "$TESTMANSH_CMD_BATS_HELPER_SUPPORT" ]] &&
  [[ -n "$TESTMANSH_CMD_BATS_HELPER_ASSERT" ]] &&
  [[ -n "$TESTMANSH_CMD_BATS_HELPER_FILE" ]] &&
  [[ -n "$TESTMANSH_PROJECT_ROOT" ]]
}
