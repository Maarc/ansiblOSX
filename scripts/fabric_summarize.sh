#!/usr/bin/env bash

##############################################################################################################
# Generate the summary of a Youtube video / HTML article with Fabric
#
# - - - - - Installations - - - - -
# - Install prerequisites: brew install lynx go
# - mkdir -p /Users/marc/git/bins
# - Install youtube-transcript-api: `pipx install --system youtube-transcript-api`
# - Install Fabric: `go install github.com/danielmiessler/fabric@latest`
#
# - - - - - Setup - - - - -
# - `fabric --setup` -> 1 OpenAI / 10 40 gpt-4o-mini / 12 Youtube / 11 Patterns
# - Reset and update the local custom pattern repository (`sb`)
# - cd readability; pnpm install
##############################################################################################################

set -e          # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Return exit status of last command in a pipeline that failed.

export MODEL PATTERN OUT_DIR READABILITY_SCRIPT YT_TRANSCRIPT_API_BIN LYNX_BIN FABRIC_BIN URL PREFIX

#----- Configuration: Please adjust the following variables according to your environment
# Model to be used. Available model can be listed executing 'fabric -L'
MODEL='gpt-4o-mini'
# Fabric pattern to use. Available patterns can be found here: https://github.com/danielmiessler/fabric/tree/main/patterns
PATTERN='extract_wisdom_marc'
# Local directory to store results
OUT_DIR="${HOME}/git/bins/fabric/results"

#----- Binary executable used
# Used to clean HTML markup before passing it to Lynx - https://gitlab.com/gardenappl/readability-cli (Setup with Deno)
READABILITY_SCRIPT="${HOME}/git/private/OSX/ansiblOSX/scripts/readability/cleanup.js"
# YouTube transcript downloader binary - https://github.com/jdepoix/youtube-transcript-api
YT_TRANSCRIPT_API_BIN="${HOME}/.local/bin/youtube_transcript_api"
# Text web browser used to convert HTML to text - https://lynx.invisible-island.net/
LYNX_BIN="/opt/homebrew/bin/lynx"
# Fabric - https://github.com/danielmiessler/fabric
FABRIC_BIN="/${HOME}/go/bin/fabric"

# Function to print script usage
usage() {
	echo "Usage:"
	printf "    %s <url>\n" "$(basename "$0")"
}

# Function to display the output file in a code viewer
output() {
	echo "Checkout: ${1}"
	code "${OUT_DIR}" -g "${1}"
}

# Function to process an HTML article
process_article() {
	local TITLE TITLE_READABLE OUT OUTPUT ORIGINAL
	TITLE=$(echo "${URL}" | sed -E 's|(.+)/$|\1|' | sed -E 's|(.+)\.html$|\1|' | rev | cut -d'/' -f 1 | rev)
	TITLE_READABLE=$(echo "${TITLE}" | tr '-' ' ' | tr '-' ' ' | tr '&' ' ' | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
	OUT="${OUT_DIR}/${PREFIX}__Article__${TITLE}"
	OUTPUT="${OUT}__${PATTERN}.txt"
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

	if [[ -f "${READABILITY_SCRIPT}" ]]; then
		node "${READABILITY_SCRIPT}" "${OUT_DIR}/page_curl.html" 1>"${OUT_DIR}/page.html" 2>/dev/null
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

# Function to process a YouTube video
process_youtube_video() {
	local TITLE TITLE_CLEAN YOUTUBE_ID LANG OUT OUTPUT ORIGINAL

	TITLE=$(node "${READABILITY_SCRIPT}" "${URL}" 2>/dev/null | head -1 | sed 's/ - YouTube.*//')
	TITLE_CLEAN=$(echo "${TITLE}" | tr -cs '[:alpha:]' '_')
	YOUTUBE_ID=$(echo "${URL}" | sed -E 's|.*\?v\=(.+)$|\1|' | sed -E 's|^(.+)&.*|\1|')

	LANG=$(${YT_TRANSCRIPT_API_BIN} "${YOUTUBE_ID}" --list-transcripts | grep "' -" | head -1 | cut -d' ' -f 4)

	OUT="${OUT_DIR}/${PREFIX}__Youtube__[${LANG^^}]__${TITLE_CLEAN}"
	OUTPUT="${OUT}__${PATTERN}.txt"
	ORIGINAL="${OUT}___Original_transcript.txt"
	${YT_TRANSCRIPT_API_BIN} --language "${LANG}" --format text "${YOUTUBE_ID}" >"${ORIGINAL}"

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
		echo "# [${LANG^^}] ${TITLE} (Youtube - ${YOUTUBE_ID})"
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

# Function to process a local file
process_local_file() {
	local CURRENT_DIR FILE OUT OUTPUT ORIGINAL
	CURRENT_DIR=$(pwd)
	FILE="${CURRENT_DIR}/${URL}"
	if [ -f "${FILE}" ]; then
		OUT="${OUT_DIR}/${PREFIX}__Local_file__${URL}"
		OUTPUT="${OUT}__${PATTERN}.txt"
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

# Main script logic
main() {
	PREFIX=$(date -u +%Y.%m.%d)
	URL="${1}"

	# Override pattern used if necessary
	if [[ -n "${2}" ]]; then
		PATTERN=${2}
	fi

	if [[ ! -d ${OUT_DIR} ]]; then
		echo "[WARNING] Missing local result directory: ${OUT_DIR}"
		mkdir -p "${OUT_DIR}"
	fi

	if [[ -z ${URL} ]]; then
		usage
		exit 1
	fi

	case "${URL}" in
	*www.youtube.com*)
		process_youtube_video "$@"
		;;
	*http[s]*://*)
		process_article "$@"
		;;
	*)
		process_local_file "$@"
		;;
	esac

}

main "$@"
