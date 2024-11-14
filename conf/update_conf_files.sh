#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

ESPANSO_DIR="${HOME}/Library/Application Support/espanso/match"
FABRIC_BIN="/${HOME}/go/bin/fabric"
FABRIC_DIR="/Users/marc/.config/fabric/patterns"

function rsync_dotfiles() {
	echo "=> Updating dot files"
	rsync --exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "*_to_review" \
		-avh --no-perms . ~
}

function update_dotfiles() {
	pushd "${SCRIPT_DIR}/dotfiles" &>/dev/null || exit
	if [[ "${1}" == "--force" ]] || [[ "${1}" == "-f" ]]; then
		rsync_dotfiles
	else
		read -r -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
		echo ""
		if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
			rsync_dotfiles
		fi
	fi
	unset rsync_dotfiles
	popd &>/dev/null || exit
}

function update_espanso_config() {
	if [ -d "${ESPANSO_DIR}" ]; then
		echo "=> Updating Espanso files"
		pushd "${SCRIPT_DIR}/espanso" &>/dev/null || exit
		rsync --exclude ".DS_Store" \
			--exclude ".osx" \
			-avh --no-perms base.yml "${ESPANSO_DIR}"
		popd &>/dev/null || exit
	fi
}

function update_fabric() {
	if [ -d "${FABRIC_DIR}" ]; then
		echo "=> Updating Fabric patterns"
		pushd "${SCRIPT_DIR}/fabric/patterns" &>/dev/null || exit
		rm -Rf "${FABRIC_DIR}/*"
		${HOME}/go/bin/fabric -U
		rsync --exclude ".DS_Store" \
			--exclude ".osx" \
			-avh --no-perms --ignore-existing * "${FABRIC_DIR}"
		popd &>/dev/null || exit
	fi
}

function main() {
	#git pull origin master;

	# Update dotfiles
	update_dotfiles

	# Update Espanso config file
	update_espanso_config

	# Update Fabric patterns
	update_fabric
}


main