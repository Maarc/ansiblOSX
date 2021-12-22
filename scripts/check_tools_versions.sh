#!/usr/bin/env bash

# set -x 

##############################################################################################################
# Independant utility script to check for updates of the used tools.
##############################################################################################################

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

# Import all required python libraries
pip install bs4 >>/dev/null
pip install requests >>/dev/null

# Check for new versions
# shellcheck source=/dev/null
python "${SCRIPT_DIR}/check_tools_versions.py"
