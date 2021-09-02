#!/bin/bash

# Script by Mik Freedman to Copy Files Between Google Drive and One Drive
# https://gitlab.eng.vmware.com/-/snippets/1780

set -e
set -u
set -o pipefail
set -x # SET THIS FOR DEBUGGING

ONEDRIVE_REMOTE='od'
GDRIVE_REMOTE='drive'
ONEDRIVE_TARGET_FOLDER='Converted'
GOOGLE_DRIVE_ID=$(pbpaste | perl -n -e'/([-\w]{25,})/ && print $1')
OBJECT_NAME=$(rclone -vv backend copyid --use-json-log "${GDRIVE_REMOTE}:" "${GOOGLE_DRIVE_ID}" "${ONEDRIVE_REMOTE}:/${ONEDRIVE_TARGET_FOLDER}/" 2<&1 | sed 'x;$!d' | jq --raw-output .object)

rclone link --onedrive-link-scope=organization "${ONEDRIVE_REMOTE}:/${ONEDRIVE_TARGET_FOLDER}/${OBJECT_NAME}"
