#!/usr/bin/env bash

# Create ebuild(s) for MAVEN_ARTS, and test if the ebuild(s) java-ebuilder
# created for it is equivalent to the expected output.

source "${SRC_ROOT}/tests/scripts/compare-ebuilds.sh"
source "${SRC_ROOT}/tests/scripts/movl-mock.sh"

run_single_ebuild_test() {
    local portage_repos=$(portageq get_repo_path / $(portageq get_repos /))
    # Change new lines to spaces
    local portage_repos=$(tr '\n' ' ' <<< "${portage_repos}")
    local REPOS="${portage_repos} ${REPOS}"
    movl_mock stage2
    for ebuild in ${EBUILD_PATHS}; do
        # Remove leading and trailing white space
        local ebuild=$(sed \
            -e 's/^[[:space:]]*//' \
            -e 's/[[:space:]]*$//' <<< "${ebuild}")
        local EXPECTED="${EXPECTED_EBUILDS_DIR}/${ebuild}"
        local ACTUAL="${MAVEN_OVERLAY_DIR}/${ebuild}"
        compare_ebuilds
    done
    local cmp_result=$?
    movl_mock clean
    return ${cmp_result}
}
