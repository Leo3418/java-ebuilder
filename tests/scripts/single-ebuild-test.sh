#!/usr/bin/env bash

# Create ebuild(s) for MAVEN_ARTS, and test if the ebuild(s) java-ebuilder
# created for it is equivalent to the expected output.

source "${SRC_ROOT}/tests/scripts/compare-ebuilds.sh"
source "${SRC_ROOT}/tests/scripts/movl-mock.sh"

# Initialize the REPOS environment variable from the list of ebuild
# repositories used by the system, and any custom repositories used for the
# current test case specified by the TEST_REPOS environment variable.
init_repos() {
    local portage_repos
    portage_repos=$(portageq get_repo_path / $(portageq get_repos /))
    # Change new lines to spaces
    portage_repos=$(tr '\n' ' ' <<< "${portage_repos}")

    local test_repos_array
    test_repos_array=()
    if [[ -n "${TEST_REPOS}" ]]; then
        for repo in ${TEST_REPOS}; do
            test_repos_array+=( "${TEST_REPOS_DIR}/${repo}" )
        done
    fi

    REPOS="${portage_repos} ${test_repos_array[*]}"
}

run_single_ebuild_test() {
    init_repos

    movl_mock stage2
    for ebuild in ${EBUILD_PATHS}; do
        # Remove leading and trailing white space
        local ebuild=$(sed \
            -e 's/^[[:space:]]*//' \
            -e 's/[[:space:]]*$//' <<< "${ebuild}")
        local search_path="${EXPECTED_EBUILDS_ROOT}/${EXPECTED_EBUILDS_SUBDIR}"
        local EXPECTED="${search_path}/${ebuild}"
        local ACTUAL="${MAVEN_OVERLAY_DIR}/${ebuild}"
        compare_ebuilds
    done
    local cmp_result=$?
    movl_mock clean
    return ${cmp_result}
}
