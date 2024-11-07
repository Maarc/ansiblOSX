#!/usr/bin/env bash

##############################################################################################################
# Generate the summary of a Youtube video / HTML article with Fabric
##############################################################################################################

export URL PREFIX
FABRIC_DIR="/Users/marc/git/bins/fabric"
OUT_DIR="${FABRIC_DIR}/results"

function usage() {
	echo "Usage:"
	printf "    %s <url>\n" "$(basename "$0")"
}

function process_article() {
	local TITLE TITLE_READABLE OUTPUT
	TITLE=$(echo "${URL}" | sed -E 's|(.+)/$|\1|' | sed -E 's|(.+)\.html$|\1|' | rev | cut -d'/' -f 1 | rev)
	TITLE_READABLE=$(echo "${TITLE}" | tr '-' ' ' | tr '-' ' ' | tr '&' ' ' | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
	OUTPUT="${OUT_DIR}/${PREFIX}__Article__${TITLE}__Extract_wisdom.txt"
	curl -s "${URL}" -o "${OUT_DIR}/page.html"
	lynx -dump -nolist --display_charset=utf-8 "${OUT_DIR}/page.html" >"${OUT_DIR}/page.txt"
	cat "${OUT_DIR}/page.txt" | fabric -sp extract_wisdom >"${OUT_DIR}/wisdom.txt"
	{
		echo "# ${TITLE_READABLE}"
		echo ""
		echo "#fabric_summary"
		echo ""
		echo "URL: ${URL}"
		echo ""
		cat "${OUT_DIR}/wisdom.txt" | sed -E 's|([A-Z -]*):|## \1|'
	} >"${OUTPUT}"
	rm -f "${OUT_DIR}/wisdom.txt" "${OUT_DIR}/page.txt" "${OUT_DIR}/page.html"
	echo "Checkout: ${OUTPUT}"
}

function process_youtube_video() {
	local LANG
	LANG=en
	if [[ -n "${2}" ]]; then
		LANG=${2}
	fi
	YOUTUBE_ID=$(echo "${URL}" | sed -E 's|.*\?v\=(.+)$|\1|' | sed -E 's|^(.+)&.*|\1|')
	OUTPUT="${OUT_DIR}/${PREFIX}__Youtube__${YOUTUBE_ID}__Extract_wisdom.txt"
	yt --transcript "${URL}" --lang "${LANG}" | fabric -p extract_wisdom >"${OUT_DIR}/wisdom.txt"
	{
		echo "# Youtube - ${YOUTUBE_ID}"
		echo ""
		echo "#fabric_summary"
		echo ""
		echo "URL: ${URL}"
		echo ""
		cat "${OUT_DIR}/wisdom.txt" | sed -E 's|([A-Z -]*):|## \1|'
	} >"${OUTPUT}"
	rm -f "${OUT_DIR}/wisdom.txt"
	echo "Checkout: ${OUTPUT}"
}

function process_local_file() {
	local CURRENT_DIR FILE
	CURRENT_DIR=$(pwd)
	FILE="${CURRENT_DIR}/${URL}"
	if [ -f "$FILE" ]; then
		OUTPUT="${OUT_DIR}/${PREFIX}__Local_file__${URL}__Extract_wisdom.txt"
		cat "${FILE}" | fabric -p extract_wisdom >"${OUT_DIR}/wisdom.txt"
		{
			echo "# File - ${URL} (${CURRENT_DIR})"
			echo ""
			echo "#fabric_summary"
			echo ""
			cat "${OUT_DIR}/wisdom.txt" | sed -E 's|([A-Z -]*):|## \1|'
		} >"${OUTPUT}"
		echo "Checkout: ${OUTPUT}"
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
	elif [[ "${URL}" == *http://* ]]; then
		process_article "$@"
	else
		process_local_file "$@"
	fi
}

main "$@"
