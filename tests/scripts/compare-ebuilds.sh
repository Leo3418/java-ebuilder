#!/usr/bin/env bash

# Compare the ebuilds pointed to by paths stored in environment variables
# EXPECTED and ACTUAL for equivalence.

# Prepare the ebuild(s) specified in positional parameters.  If there is not
# any ebuild specified in positional parameters, preprocess standard input and
# print the result to standard output.
#
# Preprocessing steps include:
# 1. Removal of lines that only contain a comment
preprocess_ebuild() {
    # 's/^#.*//' will replace each comment line with an empty line, which
    # allows line numbers of non-comment lines to stay the same
    local sed_scripts='-e s/^#.*//'
    if [[ $# -eq 0 ]]; then
        sed "${sed_scripts}"
    else
        # Edit in place it the ebuild is a file
        sed -i "${sed_scripts}" "$@"
    fi
}

# Compare EXPECTED and ACTUAL, and print the difference to standard output.
#
# The rules for comparison are:
# - Line ordering matters
# - Differences in white space are ignored
# - Preprocessing done by the 'preprocess_ebuild' function is applied
compare_ebuilds() {
    # The actual ebuild can be overwritten because it is ephemeral
    preprocess_ebuild "${ACTUAL}"
    # Use the '-N' option of diff in case the actual ebuild was not generated
    # at all due to errors
    diff -w --color=always -Nu \
        <(preprocess_ebuild < "${EXPECTED}") \
        "${ACTUAL}"
}
