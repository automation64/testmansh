setup() {
  . "$DEVTMSH_TEST_SETUP"
}

@test "testmansh: -t" {
  run "$DEVTMSH_TEST_TARGET" -t -c "test/samples/simple.bash"

  assert_success
}

teardown() {
  :
}
