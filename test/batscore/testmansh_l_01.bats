setup() {
  . "$DEVTMSH_TEST_SETUP"
}

@test "testmansh: -l" {
  run "$DEVTMSH_TEST_TARGET" -l

  assert_success
}

teardown() {
  :
}
