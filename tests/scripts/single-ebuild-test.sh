#!/usr/bin/env bash

# Create an ebuild for MAVEN_ARTS, and test if the ebuild java-ebuilder created
# for it is equivalent to the expected output.

source "${SRC_ROOT}/tests/scripts/compare-ebuilds.sh"
source "${SRC_ROOT}/tests/scripts/movl-mock.sh"

run_single_ebuild_test() {
    EXPECTED="${EXPECTED_EBUILDS_DIR}/${EBUILD_PATH}"
    ACTUAL="${MAVEN_OVERLAY_DIR}/${EBUILD_PATH}"

    movl_mock stage2
    compare_ebuilds
    cmp_result=$?
    movl_mock clean
    return ${cmp_result}
}
