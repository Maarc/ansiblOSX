if [[ $(uname -m) == "arm64" ]]; then
	# For ARM architecture (Apple Silicon)
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	# For x86 architecture (Intel)
	eval "$(/usr/local/bin/brew shellenv)"
fi
