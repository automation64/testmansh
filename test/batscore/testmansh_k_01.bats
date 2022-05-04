setup() {
  . "$DEVTMSH_TEST_SETUP"
}

@test "testmansh: -k" {
  run "$DEVTMSH_TEST_TARGET" -k

  assert_success
}

teardown() {
  :
}
