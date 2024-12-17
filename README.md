# AnsiblOSX

OS X environment provisioning using Ansible.


## Preparation

* Set name of Mac in `System Settings` -> `General` -> `About`
* Activate universal control: https://support.apple.com/en-us/102459 or install Synergy


## Installation

Open a "Terminal" of a fresh macOS installation and execute the following commands:

```sh
# Setup [Homebrew](http://brew.sh/)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essentials formulaes 
brew install ansible git zsh nvm jump thefuck zsh-autosuggestions rust rustup mas
# Install essential casks
brew install --cask iterm2 sourcetree spotify brave-browser visual-studio-code dropboxdrop 1password@7 karabiner-elements espanso rectangle

# Install OhMyZsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install PowerLevel10k Theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Initialize rust
rustup default stable

# Optional: configure Dropbox / 1Password / zsh

# Retrieve this project including its configuration
mkdir -p ~/git/private/OSX ~/Sync
cd ~/git/private/OSX

# Clone this project, making sure you have the GitHub SSH key configured properly following https://docs.github.com/de/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
git clone git@github.com:Maarc/ansiblOSX.git
cd ansiblOSX

# Edit the group_wars/*_vars.yml file to select the software you want to install
# Import the used roles
ansible-galaxy install -r roles/requirements.yml -p roles --force

# Install all used software and dependencies
ansible-playbook -K main.yml

# Seed the conf files (dot and espanso)
cd dotfiles/
./conf/update_conf_files.sh
```

## Update software lists

This section helps you to update the lists of software to install (group_vars/*_var.yml) based on your current setup.

### Brew

Dump all installed taps:
```sh
brew tap | sort | sed 's/^/  - /'
````

Dump all installed apps:
```sh
brew list | sort | sed 's/^/  - /'
```

Dump all installed casks:
```sh
brew cask list | sort | sed 's/^/  - /'
```

### Ruby gem

Dump all installed gems and their version:
```sh
gem list | tail -n+1 | sed 's/^/  - { name: /' |sed 's/ (/, version: /' | sed 's/)/, pre: false }/' | sed 's/ default: / /'
```

... or without version:

```sh
gem list | tail -n+1 | sed 's/^/  - { name: /' |sed 's/ (.*/ }/'
```

Update the field "pre" to "true" for "asciidoctor-pdf" and remove the duplicated versions.


### Apple store (mas)

Dump all installed applications from the app store and their unique id:

```sh
mas list |sort -k2 |rev |cut -f2- -d' ' |rev |sed 's/ /, name: "/1' |sed 's/^/  - { id: /' |sed 's/$/" }/'
```

## Sources

* [OSXC](https://osxc.github.io/)
* [Battleschool](https://github.com/spencergibb/battleschool)
* [dotfiles](https://github.com/ricbra/dotfiles)
* [Managing your macbook with Ansible](http://blog.james-carr.org/2016/03/29/managing-your-macbook-with-ansible/)
* [demo](https://github.com/jamescarr/ansible-mac-demo)
* [How to automate your Mac OS X setup with Ansible](https://blog.vandenbrand.org/2016/01/04/how-to-automate-your-mac-os-x-setup-with-ansible/)
* [Awesome mac os command line](https://github.com/herrbischoff/awesome-osx-command-line) and [Awesome list](https://github.com/sindresorhus/awesome)
