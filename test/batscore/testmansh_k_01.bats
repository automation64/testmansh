setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -k" {
  run "$DEVTMSH_TEST_TARGET" -k -p "$TESTMANSH_PROJECT_ROOT"

  assert_success
}

teardown() {
  :
}
