#!/usr/bin/env bash

# Compare the ebuilds pointed to by paths stored in environment variables
# EXPECTED and ACTUAL for equivalence.

# Prepare the ebuild passed in via standard input for comparison, and print the
# preprocessing result to standard output.
#
# Preprocessing steps include:
# 1. Removal of lines that only contain a comment
preprocess_ebuild() {
    grep -v '^#'
}

# Compare EXPECTED and ACTUAL, and print the difference to standard output.
#
# The rules for comparison are:
# - Line ordering matters
# - Differences in white space are ignored
# - Preprocessing done by the 'preprocess_ebuild' function is applied
compare_ebuilds() {
    diff -w --color=always -u \
        <(preprocess_ebuild < "${EXPECTED}") \
        <(preprocess_ebuild < "${ACTUAL}")
}
