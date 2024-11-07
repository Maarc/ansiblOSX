#!/bin/bash

# Script to Download Google Drive Documents as pdf and compress them

set -e
set -u
set -o pipefail
#set -x # SET THIS FOR DEBUGGING

GDRIVE_REMOTE='drive'
LOCAL_DOWNLOAD_FOLDER='/Users/mzottner/Downloads/'
GOOGLE_DRIVE_ID=$(pbpaste | perl -n -e'/([-\w]{25,})/ && print $1')
OBJECT_NAME=$(rclone -vv backend copyid --use-json-log "${GDRIVE_REMOTE}:" "${GOOGLE_DRIVE_ID}" "${LOCAL_DOWNLOAD_FOLDER}" --drive-export-formats pdf 2<&1 | sed 'x;$!d' | jq --raw-output .object)

# Compress downloaded pdf
gs -sstdout=%stderr -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -dDetectDuplicateImages -dCompressFonts=true -r150 -sOutputFile="${LOCAL_DOWNLOAD_FOLDER}compressed.pdf" "${LOCAL_DOWNLOAD_FOLDER}${OBJECT_NAME}" 2>/dev/null
mv "${LOCAL_DOWNLOAD_FOLDER}compressed.pdf" "${LOCAL_DOWNLOAD_FOLDER}${OBJECT_NAME}"
echo "${LOCAL_DOWNLOAD_FOLDER}${OBJECT_NAME}"
