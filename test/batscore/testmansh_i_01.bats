setup() {
  . "$DEVTMSH_TEST_SETUP"
}

@test "testmansh: -i" {
  run "$DEVTMSH_TEST_TARGET" -i

  assert_success
}

teardown() {
  :
}
