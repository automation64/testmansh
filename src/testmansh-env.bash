#
###[ embedded-bashlib64-end ]#####################
#

#
# Globals
#

# Imports
export TESTMANSH_PROJECT
export TESTMANSH_DEFAULT_TEST_PREFIX
export TESTMANSH_DEFAULT_LINT_PREFIX
export TESTMANSH_DEFAULT_TEST_PATH
export TESTMANSH_DEFAULT_LINT_PATH
export TESTMANSH_CMD_BATS
export TESTMANSH_CMD_SHELLCHECK
export TESTMANSH_REGISTRY
export TESTMANSH_IMAGES_TEST
export TESTMANSH_IMAGES_LINT
export TESTMANSH_ENV

# Tools
export BATSLIB_TEMP_PRESERVE_ON_FAILURE
export BATSLIB_TEMP_PRESERVE

#
# Default container variables for bats-core
#
# * Paths are based on images from the container64 project for testing bash scripts. Do not change
# * Variables are to be used during the test-case setup to properly locate plugins and other external resources
#

export TESTMANSH_BIN='/test/bin'
export TESTMANSH_SRC='/test/src'
export TESTMANSH_LIB='/test/lib'
export TESTMANSH_TEST='/test/test'
export TESTMANSH_TEST_SAMPLES='/test/test/samples'
export TESTMANSH_TEST_LIB='/test/test/lib'

export TESTMANSH_TEST_BATSCORE_SETUP='/test/test/lib/batscore-setup.bash'

export TESTMANSH_BATS_HELPER_SUPPORT='/opt/bats-core/test_helper/bats-support'
export TESTMANSH_BATS_HELPER_ASSERT='/opt/bats-core/test_helper/bats-assert'
export TESTMANSH_BATS_HELPER_FILE='/opt/bats-core/test_helper/bats-file'
