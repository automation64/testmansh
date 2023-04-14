setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: no args" {
  run "$DEVTMSH_BUILD_FULL_PATH"

  assert_failure
}

@test "testmansh: -h" {
  run "$DEVTMSH_BUILD_FULL_PATH" -h
  assert_success
}
