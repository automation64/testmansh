setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -l" {
  run "$DEVTMSH_TEST_TARGET" -l

  assert_success
}

teardown() {
  :
}
