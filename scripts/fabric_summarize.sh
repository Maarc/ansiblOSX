#!/usr/bin/env bash

##############################################################################################################
# Generate the summary of a Youtube video / HTML article with Fabric
##############################################################################################################

export URL PREFIX YT_BIN LYNX_BIN READABILITY_BIN FABRIC_BIN OUT_DIR MODEL PATTERN

#----- Binary executable used
# YouTube downloader binary
YT_BIN="${HOME}/.local/bin/yt"
# Text web browser used to convert HTML to text - https://lynx.invisible-island.net/
LYNX_BIN="/usr/local/bin/lynx"
# Used to clean HTML markup before passing it to Lynx - https://gitlab.com/gardenappl/readability-cli (Setup with Deno)
READABILITY_BIN="/${HOME}/git/bins/readability-cli/readable.ts"
# Fabric - https://github.com/danielmiessler/fabric
FABRIC_BIN="/${HOME}/go/bin/fabric"

#----- Parameters
# Local directory to store results
OUT_DIR="${HOME}/git/bins/fabric/results"
# Model to be used. Available model can be listed executing 'fabric -L'
MODEL='gpt-4o-mini'
# Fabric pattern to use. Available patterns can be found here: https://github.com/danielmiessler/fabric/tree/main/patterns
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
	curl -s "${URL}" \
		-H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8' \
		-H 'accept-language: de,en-GB;q=0.9,en-US;q=0.8,en;q=0.7,fr;q=0.6' \
		-H 'cache-control: no-cache' \
		-H 'pragma: no-cache' \
		-H 'priority: u=0, i' \
		-H 'sec-ch-ua: "Chromium";v="130", "Brave";v="130", "Not?A_Brand";v="99"' \
		-H 'sec-ch-ua-mobile: ?0' \
		-H 'sec-ch-ua-platform: "macOS"' \
		-H 'sec-fetch-dest: document' \
		-H 'sec-fetch-mode: navigate' \
		-H 'sec-fetch-site: none' \
		-H 'sec-fetch-user: ?1' \
		-H 'sec-gpc: 1' \
		-H 'upgrade-insecure-requests: 1' \
		-H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
		-o "${OUT_DIR}/page_curl.html"

	if [[ -f "${READABILITY_BIN}" ]]; then
		${READABILITY_BIN} "${OUT_DIR}/page_curl.html" -o "${OUT_DIR}/page.html" >/dev/null 2>&1
	else
		mv "${OUT_DIR}/page_curl.html" "${OUT_DIR}/page.html"
	fi

	${LYNX_BIN} -dump -nolist --display_charset=utf-8 "${OUT_DIR}/page.html" >"${ORIGINAL}"

	if [[ -s "${ORIGINAL}" ]]; then
		if (head -n 1 "${ORIGINAL}" | grep -q "302 Found"); then
			echo "[ERROR] Empty article - Error 302 Found" >"${OUT_DIR}/wisdom.txt"
		else
			(${FABRIC_BIN} -m "${MODEL}" -p "${PATTERN}" <"${ORIGINAL}") >"${OUT_DIR}/wisdom.txt"
		fi
	else
		echo "[ERROR] Empty article" >"${OUT_DIR}/wisdom.txt"
	fi
	{
		echo "# ${TITLE_READABLE}"
		echo ""
		echo "#fabric_summary"
		echo ""
		echo "URL: ${URL}"
		echo ""
		sed -E 's|([A-Z -]*):|## \1|' "${OUT_DIR}/wisdom.txt"
	} >"${OUTPUT}"
	rm -f "${OUT_DIR}/wisdom.txt" "${OUT_DIR}/page.html" "${OUT_DIR}/page_curl.html"
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
	${YT_BIN} --transcript "${URL}" --lang "${LANG}" >"${ORIGINAL}"
	if [[ -s "${ORIGINAL}" ]]; then
		if (head -n 1 "${ORIGINAL}" | grep -q "Transcript not available in the selected language"); then
			echo "[ERROR] Empty YouTube video transcript" >"${OUT_DIR}/wisdom.txt"
		else
			(${FABRIC_BIN} -m "${MODEL}" -p "${PATTERN}" <"${ORIGINAL}") >"${OUT_DIR}/wisdom.txt"
		fi
	else
		echo "[ERROR] Empty YouTube video transcript" >"${OUT_DIR}/wisdom.txt"
	fi
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
		if [[ -s "${ORIGINAL}" ]]; then
			(${FABRIC_BIN} -m "${MODEL}" -p "${PATTERN}" <"${FILE}") >"${OUT_DIR}/wisdom.txt"
		else
			echo "[ERROR] Empty provided file" >"${OUT_DIR}/wisdom.txt"
		fi
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

	if [[ ! -d ${OUT_DIR} ]]; then
		echo "[WARNING] Missing local result directory: ${OUT_DIR}"
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
