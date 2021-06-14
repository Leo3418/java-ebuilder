#!/usr/bin/env bash

# Mock the behavior of the 'movl' script installed with java-ebuilder.

# The classpath used to run java-ebuilder
CLASSPATH="${CLASSPATH:-"${SRC_ROOT}/target/classes"}"

# The command to run java-ebuilder
JAVA_EBUILDER="java -classpath ${CLASSPATH} org.gentoo.java.ebuilder.Main" 

# The look-up table's path
LUTFILE="${SRC_ROOT}/scripts/resources/resources/LUT"

# The directory that contains the helper scripts
HELPERS_ROOT="${SRC_ROOT}/scripts/bin"

# The directory that contains Makefiles that invoke java-ebuilder
MAKEFILE_DIR="${SRC_ROOT}/scripts/resources/Makefiles"

# The Makefile that serves as the entry point to all Makefiles in MAKEFILE_DIR
MAKEFILE="${MAKEFILE_DIR}/Makefile"

# Mock the 'movl' helper script.
movl_mock() {
    if ! "${VERBOSE}"; then
        local output_redirect=" > /dev/null 2>&1"
    fi
    # Assemble a command like
    # env NAME="${VALUE}" make -f "${MAKEFILE}" "$@" "${output_redirect}"
    # to copy environment variables in the current shell into the new
    # environment for 'make' invocation
    eval "env \
        CACHEDIR=\"${CACHEDIR}\" \
        CONFIG=\"${CONFIG}\" \
        HELPERS_ROOT=\"${HELPERS_ROOT}\" \
        JAVA_EBUILDER=\"${JAVA_EBUILDER}\" \
        LUTFILE=\"${LUTFILE}\" \
        MAKEFILE_DIR=\"${MAKEFILE_DIR}\" \
        MAVEN_ARTS=\"${MAVEN_ARTS}\" \
        MAVEN_OVERLAY_DIR=\"${MAVEN_OVERLAY_DIR}\" \
        POMDIR=\"${POMDIR}\" \
        REPOS=\"${REPOS}\" \
        STAGE1_DIR=\"${STAGE1_DIR}\" \
        STAGE2_MAKEFILE=\"${STAGE2_MAKEFILE}\"" \
        make -f "${MAKEFILE}" "$@" "${output_redirect}"
}
