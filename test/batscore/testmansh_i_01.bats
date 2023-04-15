setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -i" {
  run "$DEVTMSH_BUILD_FULL_PATH" -i -p "$TESTMANSH_PROJECT_ROOT"

  assert_success
}

teardown() {
  :
}
