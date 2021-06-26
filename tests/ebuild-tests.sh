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
: ${SRC_ROOT:=".."}

# The directory containing test cases
: ${TEST_CASES_DIR:="${SRC_ROOT}/tests/resources/ebuild-tests/test-cases"}

# The root directory of all directories containing expected output ebuilds.
# For each subdirectory in this directory, the layout of ebuilds in it should
# be the same as how they would appear in a normal ebuild repository.
: ${EXPECTED_EBUILDS_ROOT:="${SRC_ROOT}/tests/resources/ebuild-tests/expected-ebuilds"}

# The name of the default subdirectory under EXPECTED_EBUILDS_ROOT where
# expected ebuilds will be searched.  The layout of ebuilds in this directory
# should be the same as how they would appear in a normal ebuild repository.
EXPECTED_EBUILDS_SUBDIR="default"

# The directory containing ebuild repositories used by test cases
: ${TEST_REPOS_DIR:="${SRC_ROOT}/tests/resources/repos"}

# The directory used to store temporary test files
TEST_TMPDIR="$(mktemp -d)"

# The help message
HELP="\
Usage: $0 [FILE]...
Run ebuild comparison test case specified in each FILE.
Each FILE should define in Bash syntax:
- The MAVEN_ARTS environment variable
- An EBUILD_PATHS environment variable containing a whitespace-separated list
  of paths to ebuilds to be verified relative to the overlay's root
- Optionally, a local TEST_REPOS variable containing a whitespace-separated
  list of ebuild repositories that should be used by the test case, in
  addition to the Gentoo repository on the current system, where each
  repository is identified by the name of the directory containing it under
  ${TEST_REPOS_DIR}
- Optionally, a local EXPECTED_EBUILDS_SUBDIR variable to specify the name of
  the subdirectory where ebuilds listed in EBUILD_PATHS are searched under
  ${EXPECTED_EBUILDS_ROOT}
  (The default value for this variable is '${EXPECTED_EBUILDS_SUBDIR}')

With no FILE, run all test cases under
${TEST_CASES_DIR}.

Options:
  -v, --verbose print the output of java-ebuilder during test execution
      --help    display this help and exit"

source "${SRC_ROOT}/tests/scripts/create-config.sh"
source "${SRC_ROOT}/tests/scripts/single-ebuild-test.sh"

# Initialize the directory for temporary files and environment variables for
# them.
init_tmpdir() {
    POMDIR="${TEST_TMPDIR}/poms"
    MAVEN_OVERLAY_DIR="${TEST_TMPDIR}/overlay"
    CACHEDIR="${TEST_TMPDIR}/cache"
    # Clean up ebuild metadata cache with other cache files in tests to make
    # sure each test case runs individually and does not interfere with others
    EBUILD_METADATA_CACHE="${CACHEDIR}/ebuild-metadata-cache"
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

# Run a single test case specified by the first positional parameter.  By using
# a standalone function to execute each test individually, test cases can
# override variables with the 'local' shell built-in without affecting other
# test cases.
run_test() {
    # Read in the MAVEN_ARTS and EBUILD_PATHS environment variables, and any
    # other local variables
    echo "Running test case $1..."
    source -- "$1" || return 1
    # Update the config file with the new MAVEN_ARTS value
    create_config
    run_single_ebuild_test
}

# Run test for each test case listed in the positional parameters.
run_tests() {
    local overall_result=0
    for test_case in "$@"; do
        run_test "${test_case}"
        test ${overall_result} -eq 0 -a $? -eq 0
        local overall_result=$?
    done
    return ${overall_result}
}

# Perform tear-down tasks.
tear_down() {
    rm -rf "${TEST_TMPDIR}"
}

# Parse command-line options, and set environment variables that control how
# this script will run accordingly.
parse_options() {
    # Initialize variables with default values
    SHOW_HELP=false
    VERBOSE=false
    while :
    do
        case "$1" in
        --help)
            SHOW_HELP=true
            # No need to continue parsing remaining options
            break
            ;;
        -v | --verbose)
            VERBOSE=true
            shift
            ;;
        --)
            # End of option flags
            shift
            break
            ;;
        -*)
            echo "$0: unrecognized option '$1'"
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        *)
            # End of all command-line options
            break
            ;;
        esac
    done
    TEST_CASES_TO_RUN=("$@")
}

main() {
    parse_options "$@"

    if "${SHOW_HELP}"; then
        echo "${HELP}"
        tear_down
        exit 0
    fi

    init_tmpdir
    if [[ "${#TEST_CASES_TO_RUN[@]}" -eq 0 ]]; then
        # Run all test cases
        run_tests "${TEST_CASES_DIR}"/*;
    else
        # Run specified test cases
        run_tests "${TEST_CASES_TO_RUN[@]}"
    fi
    local result=$?
    tear_down
    echo
    if [[ ${result} -eq 0 ]]; then
        echo "All tests passed"
    else
        echo "Some tests failed -- Please check the output above for details"
    fi
    return ${result}
}

main "$@"
