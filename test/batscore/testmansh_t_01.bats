setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "testmansh: -t" {
  command -v shellcheck || skip "no shellcheck found"

  run "$DEVTMSH_BUILD_TARGET" -t -c "test/samples/simple.bash" -p "$TESTMANSH_PROJECT_ROOT"

  assert_success
}

teardown() {
  :
}
