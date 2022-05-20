setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -i" {
  run "$DEVTMSH_TEST_TARGET" -i

  assert_success
}

teardown() {
  :
}
