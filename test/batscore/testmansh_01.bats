setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: no args" {
  run "$DEVTMSH_TEST_TARGET"

  assert_failure
}

@test "testmansh: -h" {
  run "$DEVTMSH_TEST_TARGET" -h

  assert_success
}
