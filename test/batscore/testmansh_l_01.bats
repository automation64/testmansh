setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -l" {
  run "$DEVTMSH_BUILD_TARGET" -l -p "$TESTMANSH_PROJECT_ROOT"

  assert_success
}

teardown() {
  :
}
