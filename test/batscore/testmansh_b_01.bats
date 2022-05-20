setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -b" {
  run "$DEVTMSH_TEST_TARGET" -b -c "test/samples/simple"

  assert_success
}

teardown() {
  :
}
