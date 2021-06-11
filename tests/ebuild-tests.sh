#!/usr/bin/env bash

# Using java-ebuilder built from this Git tree, create ebuilds for the
# specified list of Maven artifacts, and compare them with the expected ebuild
# outputs.
#
# This script can be run directly when the 'tests' directory under the source
# tree is the working directory.  If not, then please manually specify the root
# directory of the source tree with SRC_ROOT environment variable.
#
# Before running this script, please build the Maven project with 'mvn compile'
# to make sure the compiled class files are both present and up-to-date.

# The root directory of the Git repository's source tree
SRC_ROOT="${SRC_ROOT:-".."}"

# The directory containing test cases.  Each test case should be represented by
# a file in this directory, with definition of the following variables:
# - MAVEN_ARTS: The value of 'MAVEN_ARTS' environment variable used by
#   java-ebuilder
# - EBUILD_PATHS: Path to the ebuild generated by java-ebuilder for MAVEN_ARTS,
#   relative to the overlay's root
TEST_CASES_DIR="${SRC_ROOT}/tests/resources/test-cases"

# The directory containing expected output ebuilds.  The layout of ebuilds in
# this directory should be the same as how they would appear in a normal
# Portage overlay.
EXPECTED_EBUILDS_DIR="${SRC_ROOT}/tests/resources/expected-ebuilds"

# The directory used to store temporary test files
TEST_TMPDIR="$(mktemp -d)"

source "${SRC_ROOT}/tests/scripts/create-config.sh"
source "${SRC_ROOT}/tests/scripts/single-ebuild-test.sh"

# Initialize the directory for temporary files and environment variables for
# them.
init_tmpdir() {
    POMDIR="${TEST_TMPDIR}/poms"
    MAVEN_OVERLAY_DIR="${TEST_TMPDIR}/overlay"
    CACHEDIR="${TEST_TMPDIR}/cache"
    STAGE1_DIR="${TEST_TMPDIR}/stage1"
    STAGE2_MAKEFILE="${STAGE1_DIR}/stage2.mk"

    mkdir \
        "${POMDIR}" \
        "${MAVEN_OVERLAY_DIR}" \
        "${CACHEDIR}" \
        "${STAGE1_DIR}"

    # Copy the basic metadata files required to create a functional overlay
    cp -r "${SRC_ROOT}/maven"/* "${MAVEN_OVERLAY_DIR}"
}

# Run test for each test case specified in TEST_CASES_DIR.
run_tests() {
    overall_result=0
    for test_case in "${TEST_CASES_DIR}"/*; do
        # Read in the MAVEN_ARTS and EBUILD_PATHS environment variables
        source "${test_case}"
        echo "Testing ${MAVEN_ARTS}..."
        # Update the config file with the new MAVEN_ARTS value
        create_config
        run_single_ebuild_test
        test ${overall_result} -eq 0 -a $? -eq 0
        overall_result=$?
    done
    return ${overall_result}
}

# Perform tear-down tasks.
tear_down() {
    rm -rf "${TEST_TMPDIR}"
}

main() {
    init_tmpdir
    run_tests
    result=$?
    tear_down
    echo
    if [[ ${result} -eq 0 ]]; then
        echo "All tests passed"
    else
        echo "Some tests failed -- Please check the diffs above for details"
    fi
    return ${result}
}

main
