#!/usr/bin/env bash

# Create a config file for java-ebuilder.  Although the values included in the
# config file can be accessed via environment variables, the tree.sh helper
# script honors only the values in a config file.

# Path to the config file to be created
CONFIG="${TEST_TMPDIR}/java-ebuilder.conf"

create_config() {
    echo "\
POMDIR=${POMDIR}
MAVEN_OVERLAY_DIR=${MAVEN_OVERLAY_DIR}
CACHEDIR=${CACHEDIR}
MAVEN_ARTS=${MAVEN_ARTS}" > ${CONFIG}
}
