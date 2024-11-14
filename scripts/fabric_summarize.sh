#!/usr/bin/env bash

##############################################################################################################
# Generate the summary of a Youtube video / HTML article with Fabric
##############################################################################################################
export URL PREFIX MODEL PATTERN
FABRIC_DIR="/Users/marc/git/bins/fabric"
OUT_DIR="${FABRIC_DIR}/results"
# Available model can be listed executing 'fabric -L'
MODEL='gpt-4o-mini'
# Available patterns can be found here: https://github.com/danielmiessler/fabric/tree/main/patterns
PATTERN='extract_wisdom'

function usage() {
	echo "Usage:"
	printf "    %s <url>\n" "$(basename "$0")"
}

function output() {
	echo "Checkout: ${1}"
	code "${OUT_DIR}" -g "${1}"
}

function process_article() {
	local TITLE TITLE_READABLE OUT OUTPUT ORIGINAL
	TITLE=$(echo "${URL}" | sed -E 's|(.+)/$|\1|' | sed -E 's|(.+)\.html$|\1|' | rev | cut -d'/' -f 1 | rev)
	TITLE_READABLE=$(echo "${TITLE}" | tr '-' ' ' | tr '-' ' ' | tr '&' ' ' | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
	OUT="${OUT_DIR}/${PREFIX}__Article__${TITLE}"
	OUTPUT="${OUT}__Extract_wisdom.txt"
	ORIGINAL="${OUT}___Original_article.txt"
	curl -s "${URL}" -o "${OUT_DIR}/page.html"
	lynx -dump -nolist --display_charset=utf-8 "${OUT_DIR}/page.html" >"${ORIGINAL}"
	(fabric -m "${MODEL}" -p "${PATTERN}" <"${ORIGINAL}") >"${OUT_DIR}/wisdom.txt"
	{
		echo "# ${TITLE_READABLE}"
		echo ""
		echo "#fabric_summary"
		echo ""
		echo "URL: ${URL}"
		echo ""
		sed -E 's|([A-Z -]*):|## \1|' "${OUT_DIR}/wisdom.txt"
	} >"${OUTPUT}"
	rm -f "${OUT_DIR}/wisdom.txt" "${OUT_DIR}/page.html"
	output "${OUTPUT}"
}

function process_youtube_video() {
	local LANG YOUTUBE_ID OUT OUTPUT ORIGINAL
	LANG=en
	if [[ -n "${2}" ]]; then
		LANG=${2}
	fi
	YOUTUBE_ID=$(echo "${URL}" | sed -E 's|.*\?v\=(.+)$|\1|' | sed -E 's|^(.+)&.*|\1|')
	OUT="${OUT_DIR}/${PREFIX}__Youtube__${YOUTUBE_ID}"
	OUTPUT="${OUT}__Extract_wisdom.txt"
	ORIGINAL="${OUT}___Original_transcript.txt"
	yt --transcript "${URL}" --lang "${LANG}" >"${ORIGINAL}"
	(fabric -m "${MODEL}" -p "${PATTERN}" <"${ORIGINAL}") >"${OUT_DIR}/wisdom.txt"
	{
		echo "# Youtube - ${YOUTUBE_ID}"
		echo ""
		echo "#fabric_summary"
		echo ""
		echo "URL: ${URL}"
		echo ""
		sed -E 's|([A-Z -]*):|## \1|' "${OUT_DIR}/wisdom.txt"
	} >"${OUTPUT}"
	rm -f "${OUT_DIR}/wisdom.txt"
	output "${OUTPUT}"
}

function process_local_file() {
	local CURRENT_DIR FILE OUT OUTPUT ORIGINAL
	CURRENT_DIR=$(pwd)
	FILE="${CURRENT_DIR}/${URL}"
	if [ -f "${FILE}" ]; then
		OUT="${OUT_DIR}/${PREFIX}__Local_file__${URL}"
		OUTPUT="${OUT}__Extract_wisdom.txt"
		ORIGINAL="${OUT}___Original_file.txt"
		cp -f "${FILE}" "${ORIGINAL}"
		(fabric -m "${MODEL}" -p "${PATTERN}" <"${FILE}") >"${OUT_DIR}/wisdom.txt"
		{
			echo "# File - ${URL} (${CURRENT_DIR})"
			echo ""
			echo "#fabric_summary"
			echo ""
			sed -E 's|([A-Z -]*):|## \1|' "${OUT_DIR}/wisdom.txt"
		} >"${OUTPUT}"
		rm -f "${OUT_DIR}/wisdom.txt"
		output "${OUTPUT}"
	else
		echo "[ERROR] File does not exist: ${FILE}"
	fi
}

function main() {
	URL="${1}"
	PREFIX=$(date -u +%Y.%m.%d)

	if [[ ! -d ${FABRIC_DIR} ]]; then
		echo "[ERROR] Missing local fabric directory: ${FABRIC_DIR}"
		exit 1
	fi

	if [[ ! -d ${OUT_DIR} ]]; then
		mkdir -p "${OUT_DIR}"
	fi

	if [[ -z ${URL} ]]; then
		usage
		exit 1
	fi

	if [[ "${URL}" == *www.youtube.com* ]]; then
		process_youtube_video "$@"
	elif [[ "${URL}" == *http[s]*://* ]]; then
		process_article "$@"
	else
		process_local_file "$@"
	fi
}

main "$@"
