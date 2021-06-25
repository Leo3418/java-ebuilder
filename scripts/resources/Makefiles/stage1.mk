
.PHONY: stage1 clean-stage1

${STAGE2_MAKEFILE}: ${PRE_STAGE1_CACHE}
	mkdir -p ${STAGE1_DIR}
	mkdir -p "$(shell dirname "$@")"

	# Set up stage1 ebuild repository with minimal metadata files required by
	# java-ebuilder and egencache
	mkdir "${STAGE1_DIR}/profiles"
	echo "stage1" > "${STAGE1_DIR}/profiles/repo_name"
	echo "app-maven" > "${STAGE1_DIR}/profiles/categories"

	CUR_STAGE_DIR="$(shell echo ${STAGE1_DIR})" CUR_STAGE=stage1\
		CACHE_TIMESTAMP="$(shell echo ${CACHE_TIMESTAMP})"\
		GENTOO_CACHE="$(shell echo ${PRE_STAGE1_CACHE})"\
		EBUILD_METADATA_CACHE=${EBUILD_METADATA_CACHE}\
		TARGET_MAKEFILE="$@"\
		TSH=${TSH} CONFIG=${CONFIG}\
		${TSH_WRAPPER}
	touch "$@"

stage1: ${STAGE2_MAKEFILE}

clean-stage1:
	if [[ -f ${STAGE2_MAKEFILE} ]]; then rm ${STAGE2_MAKEFILE}; fi
	if [[ -d ${STAGE1_DIR} ]]; then rm ${STAGE1_DIR} -r; fi
	if [[ -d ${POMDIR} ]]; then touch ${POMDIR}/pseudo; rm ${POMDIR}/* -r; fi
