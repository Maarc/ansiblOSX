#!/usr/bin/env bash

####### Folders

# Contains generated and copied files

if [ "$#" -gt 1 ]; then
  echo "Usage: ";
  echo "  Backup create : $0 ";
  echo "  Backup restore: $0 <BACKUP_FOLDER>";
  exit 1
fi

declare DIR_BACKUP IS_CREATE

if [[ -z "${1// }" ]]; then
  IS_CREATE=true
  DIR_BACKUP=$(pwd)/save_$(date +"%Y-%m-%d_%H-%M-%S")
else
  IS_CREATE=false
  DIR_BACKUP=${1}
fi

CURRENT_DIR=$(pwd)

# Backup of the ZAP scripts
DIR_ZAP=${DIR_BACKUP}/ZAP

# Backup of the added fonts
DIR_FONTS=${DIR_BACKUP}/FONTS

# Backup of the ascidoctor template
DIR_ASCIIDOC_TEMPLATE=${DIR_BACKUP}/ASCIIDOCTOR_PDF

# MacOS services (e.g. Token)
DIR_SERVICES=${DIR_BACKUP}/SERVICES

# Atom configuration
DIR_ATOM=${DIR_BACKUP}/ATOM

DIR_CHROME=${DIR_BACKUP}/CHROME

# Save various information that could not be directly restored.
function save_info() {
  INFO_PREFIX="info__"

  # Ruby gems
  gem list > ${DIR_BACKUP}/${INFO_PREFIX}gem_list.txt

  # Brew
  brew list > ${DIR_BACKUP}/${INFO_PREFIX}brew_app_list.txt
  brew cask list > ${DIR_BACKUP}/${INFO_PREFIX}brew_cask_list.txt
  brew tap > ${DIR_BACKUP}/${INFO_PREFIX}brew_tap_list.txt

  # Lists all installed applcations
  tree -L 2 /Applications/ > ${DIR_BACKUP}/${INFO_PREFIX}applications_tree.txt
  ls /Applications/ > ${DIR_BACKUP}/${INFO_PREFIX}applications_ls.txt
  ls -all /Applications/ > ${DIR_BACKUP}/${INFO_PREFIX}applications_ls_all.txt
}


# Save various configurations to a new directory
function save() {
  mkdir -p ${DIR_ZAP} ${DIR_FONTS} ${DIR_ASCIIDOC_TEMPLATE} ${DIR_SERVICES} ${DIR_ATOM} ${DIR_CHROME}

  # Atom
  apm list --installed --bare > ${DIR_ATOM}/packages.list
  cp ~/.atom/*.json ~/.atom/*.cson ~/.atom/*.coffee ~/.atom/*.less ${DIR_ATOM}

  # AppZap scripts
  cp -Rfp ~/Library/Application\ Support/ZAP/scripts/scripts/standalone/* ${DIR_ZAP}/.

  # Added fonts
  cp -Rfp /Library/Fonts/LiberationSans*  ${DIR_FONTS}/.

  # Asciidoctor templates
  cp -Rfp /opt/rubies/2.2.3/lib/ruby/gems/2.2.0/gems/asciidoctor-pdf-1.5.0.alpha.10/data/themes/default-theme.yml ${DIR_ASCIIDOC_TEMPLATE}

  # Token.workflow service
  sudo cp -Rfp ~/Library/Services/Token.workflow ${DIR_SERVICES}/.
  sudo cp -Rfp ~/Library/Services/Date.workflow ${DIR_SERVICES}/.
  sudo cp -Rfp ~/Library/Services/Date_Slash.workflow ${DIR_SERVICES}/.
  sudo cp -Rfp ~/Library/Services/Date_Underscore.workflow ${DIR_SERVICES}/.

  # Google Chrome bookmarks
  cp -Rfp ~/Library/Application\ Support/Google/Chrome/Default/Bookmarks.bak ${DIR_CHROME}/.

  # Save chrome extensions (https://developer.chrome.com/extensions/external_extensions)
  cd ~/Library/Application\ Support/Google/Chrome/Default/Extensions
  #find . -type f -name "manifest.json" -exec bash -c 'grep -E "^{|^}|\"version|update_url" ${1} > $(echo ${1}|cut -d"/" -f2).json' _ {} \;
  find . -type f -name "manifest.json" -exec bash -c 'grep -E "^{|^}|update_url" ${1} > $(echo ${1}|cut -d"/" -f2).json' _ {} \;
  mv *.json ${DIR_CHROME}
  cd ${DIR_CHROME}
  sed -i '' 's/\"update_url/\"external_update_url/g' *.json
  cp -Rfp ~/Library/Application\ Support/Google/Chrome/External\ Extensions/*.json .
  cd ${CURRENT_DIR}

  save_info
}


# Restore savec configuration
function restore() {
  # Atom
  echo apm install --packages-file ${DIR_ATOM}/packages.list
  echo cp ${DIR_ATOM}/*.json ${DIR_ATOM}/*.cson ${DIR_ATOM}/*.coffee ${DIR_ATOM}/*.less ~/.atom/.

  # AppZap scripts
  DIR_ZAP_TARGET="~/Library/Application\ Support/ZAP/scripts/scripts/standalone"
  echo mkdir -p ${DIR_ZAP_TARGET}
  echo cp -Rfp ${DIR_ZAP}/* ${DIR_ZAP_TARGET}

  # Added fonts
  echo cp -Rfp  ${DIR_FONTS}/* /Library/Fonts/LiberationSans/.

  # Asciidoctor templates
  echo cp -Rfp ${DIR_ASCIIDOC_TEMPLATE}/default-theme.yml /opt/rubies/2.2.3/lib/ruby/gems/2.2.0/gems/asciidoctor-pdf-1.5.0.alpha.10/data/themes/.

  # Token.workflow service
  echo sudo cp -Rfp ${DIR_SERVICES} ~/Library/Services/.

  echo cp -Rfp ${DIR_CHROME}/Bookmarks.bak ~/Library/Application\ Support/Google/Chrome/Default/.

  # Chrome extensions (https://developer.chrome.com/extensions/external_extensions)
  echo cp -Rfp ${DIR_CHROME}/*.json ~/Library/Application Support/Google/Chrome/External\ Extensions
}

function main() {

  if [ "${IS_CREATE}" = true ]; then
    echo "Save"
    save
  else
    echo "Restore"
    restore
  fi
}

main
