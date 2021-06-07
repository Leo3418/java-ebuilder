#!/usr/bin/env bash

# Create an ebuild for MAVEN_ARTS, and test if the ebuild java-ebuilder created
# for it is equivalent to the expected output.

source "${SRC_ROOT}/tests/scripts/movl-mock.sh"

run_single_ebuild_test() {
    expected="${EXPECTED_EBUILDS_DIR}/${EBUILD_PATH}"
    actual="${MAVEN_OVERLAY_DIR}/${EBUILD_PATH}"

    movl_mock build > /dev/null
    diff --color=always "${expected}" "${actual}"
    movl_mock clean > /dev/null
}
