setup() {
  . "$DEVTMSH_TEST_SETUP"
}

@test "testmansh: no args" {
  run "$DEVTMSH_TEST_TARGET"

  assert_failure
}

@test "testmansh: -h" {
  run "$DEVTMSH_TEST_TARGET" -h

  assert_success
}
