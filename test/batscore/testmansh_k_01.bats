setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -k" {
  run "$DEVTMSH_TEST_TARGET" -k

  assert_success
}

teardown() {
  :
}
