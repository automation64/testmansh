setup() {
  . "$DEVTMSH_TEST_SETUP"
}

@test "testmansh: -t" {
  run "$DEVTMSH_TEST_TARGET" -t -c "${DEVTMSH_TEST_SAMPLES}/simple.bash"

  assert_success
}

teardown() {
  :
}
