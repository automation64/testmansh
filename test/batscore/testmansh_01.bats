setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: no args" {
  run "$DEVTMSH_BUILD_TARGET"

  assert_failure
}

@test "testmansh: -h" {
  run "$DEVTMSH_BUILD_TARGET" -h
  assert_success
}
