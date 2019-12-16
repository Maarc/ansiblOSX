#!/usr/bin/env bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null || exit

#git pull origin master;

function doIt() {
	rsync --exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "update_dotfiles.sh" \
		--exclude "*_to_review" \
		-avh --no-perms . ~;
	source ~/.bash_profile;
}

if [ "${1}" == "--force" ] || [ "${1}" == "-f" ]; then
	doIt;
else
	read -r  -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;

popd &>/dev/null || exit
