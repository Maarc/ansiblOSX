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
PATTERN='cleanup_transcript_marc'
# Hugo tag used for the output file
TAG='Transcript'
# Local directory to store results
OUT_DIR="${HOME}/git/bins/fabric/results"
HUGO_OUT_GIT_DIR="${HOME}/git/private/spoon-of-wisdom"
HUGO_OUT_DIR="${HUGO_OUT_GIT_DIR}/content/articles"
# Name of the output file
OUTPUT_FILE="${PATTERN}.md"
# Name of the temporary file
TEMP_FILE='temp.txt'

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
	#code "${OUT_DIR}" -g "${1}"
}

# Function to process an HTML article
process_article() {
	local TYPE TITLE TITLE_READABLE OUT OUTPUT ORIGINAL
	TYPE='Article'
	TITLE=$(echo "${URL}" | sed -E 's|(.+)/$|\1|' | sed -E 's|(.+)\.html$|\1|' | rev | cut -d'/' -f 1 | rev)
	TITLE_READABLE=$(echo "${TITLE}" | tr '-' ' ' | tr '-' ' ' | tr '&' ' ' | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
	OUT="${OUT_DIR}/${PREFIX}__${TYPE}__${TITLE}"
	OUTPUT="${OUT}__${OUTPUT_FILE}"
	ORIGINAL="${OUT}___Original_article.txt"
	OUTPUT_HUGO="${HUGO_OUT_DIR}/${TYPE}__${TITLE}.md"

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
			echo "[ERROR] Empty article - Error 302 Found" >"${OUT_DIR}/${TEMP_FILE}"
		else
			(${FABRIC_BIN} -m "${MODEL}" -p "${PATTERN}" <"${ORIGINAL}") >"${OUT_DIR}/${TEMP_FILE}"
		fi
	else
		echo "[ERROR] Empty article" >"${OUT_DIR}/${TEMP_FILE}"
	fi

	# Hugo output
	{
		echo "---"
		echo "title: \"${TITLE_READABLE}\""
		echo "date: $(date -u +%Y-%m-%dT%H:%M:%S)"
		echo "tags: [\"${TYPE}\", \"${TAG}\"]"
		echo "author: ${MODEL}"
		echo "source: ${URL}"
		echo "lang: ${LANG}"
		echo "---"
		cat "${OUT_DIR}/${TEMP_FILE}"
		echo ""
		echo "[Source ${TYPE}](${URL})"
	} >"${OUTPUT_HUGO}"

	pushd "${HUGO_OUT_GIT_DIR}" &>/dev/null || exit
	git pull
	git push
	git add "${OUTPUT_HUGO}"
	git commit -m "Add ${TYPE} - ${TITLE_READABLE}"
	git push
	git pull
	popd &>/dev/null || exit

	# Standard output
	{
		echo "# ${TITLE_READABLE}"
		echo ""
		echo "#fabric_summary"
		echo ""
		echo "URL: ${URL}"
		echo ""
		sed -E 's/^#/#&/' "${OUT_DIR}/${TEMP_FILE}"
	} >"${OUTPUT}"
	rm -f "${OUT_DIR}/${TEMP_FILE}" "${OUT_DIR}/page.html" "${OUT_DIR}/page_curl.html"
	output "${OUTPUT}"
}

# Function to process a YouTube video
process_youtube_video() {
	local TYPE TITLE TITLE_CLEAN YOUTUBE_ID LANG OUT OUTPUT ORIGINAL

	TYPE='YouTube'
	TITLE=$(node "${READABILITY_SCRIPT}" "${URL}" 2>/dev/null | head -1 | sed 's/ - YouTube.*//')
	TITLE_READABLE="${TITLE}"
	TITLE_CLEAN=$(echo "${TITLE}" | tr -cs '[:alpha:]' '_')
	YOUTUBE_ID=$(echo "${URL}" | sed -E 's|.*\?v\=(.+)$|\1|' | sed -E 's|^(.+)&.*|\1|')

	LANG=$(${YT_TRANSCRIPT_API_BIN} "${YOUTUBE_ID}" --list-transcripts | grep "' -" | head -1 | cut -d' ' -f 4)

	OUT="${OUT_DIR}/${PREFIX}__${TYPE}__[${LANG^^}]__${TITLE_CLEAN}"
	OUTPUT="${OUT}__${OUTPUT_FILE}"
	ORIGINAL="${OUT}___Original_transcript.txt"
	OUTPUT_HUGO="${HUGO_OUT_DIR}/${TYPE}__${TITLE_CLEAN}.md"

	${YT_TRANSCRIPT_API_BIN} --language "${LANG}" --format text "${YOUTUBE_ID}" >"${ORIGINAL}"

	if [[ -s "${ORIGINAL}" ]]; then
		if (head -n 1 "${ORIGINAL}" | grep -q "Transcript not available in the selected language"); then
			echo "[ERROR] Empty YouTube video transcript" >"${OUT_DIR}/${TEMP_FILE}"
		else
			(${FABRIC_BIN} -m "${MODEL}" -p "${PATTERN}" <"${ORIGINAL}") >"${OUT_DIR}/${TEMP_FILE}"
		fi
	else
		echo "[ERROR] Empty YouTube video transcript" >"${OUT_DIR}/${TEMP_FILE}"
	fi

	# Hugo output
	{
		echo "---"
		echo "title: \"${TITLE_READABLE}\""
		echo "date: $(date -u +%Y-%m-%dT%H:%M:%S)"
		echo "tags: [\"${TYPE}\", \"${TAG}\"]"
		echo "author: ${MODEL}"
		echo "source: ${URL}"
		echo "lang: ${LANG}"
		echo "---"
		cat "${OUT_DIR}/${TEMP_FILE}"
		echo ""
		echo "[Source ${TYPE}](${URL})"
	} >"${OUTPUT_HUGO}"

	pushd "${HUGO_OUT_GIT_DIR}" &>/dev/null || exit
	git pull
	git push
	git add "${OUTPUT_HUGO}"
	git commit -m "Add ${TYPE} - ${TITLE_READABLE}"
	git push
	git pull
	popd &>/dev/null || exit

	# Standard output
	{
		echo "# [${LANG^^}] ${TITLE} (Youtube - ${YOUTUBE_ID})"
		echo ""
		echo "#fabric_summary"
		echo ""
		echo "URL: ${URL}"
		echo ""
		sed -E 's/^#/#&/' "${OUT_DIR}/${TEMP_FILE}"
	} >"${OUTPUT}"
	rm -f "${OUT_DIR}/${TEMP_FILE}"
	output "${OUTPUT}"
}

# Function to process a local file
process_local_file() {
	local CURRENT_DIR FILE OUT OUTPUT ORIGINAL
	CURRENT_DIR=$(pwd)
	FILE="${CURRENT_DIR}/${URL}"
	if [ -f "${FILE}" ]; then
		OUT="${OUT_DIR}/${PREFIX}__Local_file__${URL}"
		OUTPUT="${OUT}__${OUTPUT_FILE}"
		ORIGINAL="${OUT}___Original_file.txt"
		cp -f "${FILE}" "${ORIGINAL}"
		if [[ -s "${ORIGINAL}" ]]; then
			(${FABRIC_BIN} -m "${MODEL}" -p "${PATTERN}" <"${FILE}") >"${OUT_DIR}/${TEMP_FILE}"
		else
			echo "[ERROR] Empty provided file" >"${OUT_DIR}/${TEMP_FILE}"
		fi
		{
			echo "# File - ${URL} (${CURRENT_DIR})"
			echo ""
			echo "#fabric_summary"
			echo ""
			#sed -E 's|([A-Z -]*):|## \1|' "${OUT_DIR}/${TEMP_FILE}"
			sed -E 's/^#/#&/' "${OUT_DIR}/${TEMP_FILE}"
		} >"${OUTPUT}"
		rm -f "${OUT_DIR}/${TEMP_FILE}"
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
