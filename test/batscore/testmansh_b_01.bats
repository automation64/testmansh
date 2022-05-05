setup() {
  . "$DEVTMSH_TEST_SETUP"
}

@test "testmansh: -b" {
  run "$DEVTMSH_TEST_TARGET" -b -c "test/samples/simple"

  assert_success
}

teardown() {
  :
}
