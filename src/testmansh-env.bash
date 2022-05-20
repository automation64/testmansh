#
###[ embedded-bashlib64-end ]#####################
#

#
# Globals
#

# Constants
export TESTMANSH_DEFAULT_TEST_PREFIX='test/batscore'
export TESTMANSH_DEFAULT_LINT_PREFIX='src'

# External parameters
export TESTMANSH_PROJECT
export TESTMANSH_DEFAULT_TEST_PATH
export TESTMANSH_DEFAULT_LINT_PATH
export TESTMANSH_ENV
export TESTMANSH_CMD_BATS="${TESTMANSH_CMD_BATS:-/opt/bats-core/bin/bats}"
export TESTMANSH_CMD_SHELLCHECK="${TESTMANSH_CMD_SHELLCHECK:-/usr/bin/shellcheck}"
export TESTMANSH_REGISTRY="${TESTMANSH_REGISTRY:-ghcr.io/serdigital64}"
export TESTMANSH_IMAGES_TEST="${TESTMANSH_IMAGES_TEST:-}"

# Bats-core internal variables
export BATSLIB_TEMP_PRESERVE_ON_FAILURE
export BATSLIB_TEMP_PRESERVE

# Container variables for container64 based images
export TESTMANSH_CONTAINER64_PROJECT="/prj"
export TESTMANSH_CONTAINER64_BATS="/opt/bats-core/bin/bats"
export TESTMANSH_CONTAINER64_BATS_HELPER_SUPPORT='/opt/bats-core/test_helper/bats-support'
export TESTMANSH_CONTAINER64_BATS_HELPER_ASSERT='/opt/bats-core/test_helper/bats-assert'
export TESTMANSH_CONTAINER64_BATS_HELPER_FILE='/opt/bats-core/test_helper/bats-file'

# Default paths for using in test-cases. Path is automatically adjusted for container run
export TESTMANSH_PROJECT_ROOT=''
export TESTMANSH_PROJECT_BIN='bin'
export TESTMANSH_PROJECT_SRC='src'
export TESTMANSH_PROJECT_LIB='lib'
export TESTMANSH_PROJECT_BUILD='build'
export TESTMANSH_TEST='test'
export TESTMANSH_TEST_SAMPLES='test/samples'
export TESTMANSH_TEST_LIB='test/lib'
export TESTMANSH_TEST_BATSCORE_SETUP='test/lib/batscore-setup.bash'
export TESTMANSH_CMD_BATS_HELPER_SUPPORT
export TESTMANSH_CMD_BATS_HELPER_ASSERT
export TESTMANSH_CMD_BATS_HELPER_FILE

# Default container images based on container64
export TESTMANSH_IMAGES_LINT="${TESTMANSH_IMAGES_LINT:-alpine-3-shell-lint:latest}"
export TESTMANSH_CONTAINER64_TEST=''
TESTMANSH_CONTAINER64_TEST="${TESTMANSH_CONTAINER64_TEST} almalinux-8-bash-test:latest"
TESTMANSH_CONTAINER64_TEST="${TESTMANSH_CONTAINER64_TEST} alpine-3-bash-test:latest"
TESTMANSH_CONTAINER64_TEST="${TESTMANSH_CONTAINER64_TEST} rhel-8-bash-test:latest"
TESTMANSH_CONTAINER64_TEST="${TESTMANSH_CONTAINER64_TEST} centos-7-bash-test:latest centos-8-bash-test:latest centos-9-bash-test:latest"
TESTMANSH_CONTAINER64_TEST="${TESTMANSH_CONTAINER64_TEST} oraclelinux-7-bash-test:latest oraclelinux-8-bash-test:latest"
TESTMANSH_CONTAINER64_TEST="${TESTMANSH_CONTAINER64_TEST} fedora-33-bash-test:latest fedora-34-bash-test:latest fedora-35-bash-test:latest"
TESTMANSH_CONTAINER64_TEST="${TESTMANSH_CONTAINER64_TEST} debian-9-bash-test:latest debian-10-bash-test:latest debian-11-bash-test:latest"
TESTMANSH_CONTAINER64_TEST="${TESTMANSH_CONTAINER64_TEST} ubuntu-20.4-bash-test:latest ubuntu-21.4-bash-test:latest"
export TESTMANSH_IMAGES_TEST="${TESTMANSH_IMAGES_TEST:-${TESTMANSH_CONTAINER64_TEST}}"
