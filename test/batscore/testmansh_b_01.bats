setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -b" {
  run "$DEVTMSH_BUILD_FULL_PATH" -b -c "test/samples/simple" -p "$TESTMANSH_PROJECT_ROOT"

  assert_success
}

teardown() {
  :
}
