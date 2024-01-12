#!/usr/bin/env bash

#git pull origin master;

DIR_ESPANSO="${HOME}/Library/Application Support/espanso/match"

function updateDotfiles() {
	echo "=> Updating dot files"
	rsync --exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "*_to_review" \
		-avh --no-perms . ~
}

# Update dot files
pushd "$(dirname "${BASH_SOURCE[0]}")/dotfiles" &>/dev/null || exit
if [[ "${1}" == "--force" ]] || [[ "${1}" == "-f" ]]; then
	updateDotfiles
else
	read -r -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo ""
	if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
		updateDotfiles
	fi
fi
unset updateDotfiles
popd &>/dev/null || exit

# Update Espanso config file
if [ -d "${DIR_ESPANSO}" ]; then
	echo "=> Updating espanso files"
	pushd "$(dirname "${BASH_SOURCE[0]}")/espanso" &>/dev/null || exit
	rsync --exclude ".DS_Store" \
		--exclude ".osx" \
		-avh --no-perms base.yml "${DIR_ESPANSO}"
	popd &>/dev/null || exit
fi
