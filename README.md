# AnsiblOSX

OS X environment provisioning using Ansible.

## Installation

Open a "Terminal" of a fresh macOS installation and execute the following commands:


```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"  # <1>
brew install ansible # <2>
mkdir -p ~/git/private/OSX ~/Sync
cd ~/git/private/OSX
git clone git@github.com:Maarc/ansiblOSX.git # <3>
cd ansiblOSX
# Edit the group_wars/*_vars.yml file to select the software you want to install
ansible-galaxy install -r roles/requirements.yml -p roles --force # <4>
ansible-playbook -K main.yml # <5>
cd dotfiles/
./update_dotfiles.sh <6>
```

* <1> Setup [Homebrew](http://brew.sh/)
* <2> Install Ansible
* <3> Clone this project, making sure you have the GitHub SSH key configured properly  
* <4> Import the used roles
* <5> Install the used software
* <6> Seed the dotfiles

## Update software lists

This section helps you to update the lists of software to install (group_vars/*_var.yml) based on your current setup.

### Brew

Dump all installed taps:

    $ brew tap | sort | sed 's/^/  - /'

Dump all installed apps:

    $ brew list | sort | sed 's/^/  - /'

Dump all installed casks:

    $ brew cask list | sort | sed 's/^/  - /'


### Ruby gem

Dump all installed gems and their version:

    $ gem list | tail -n+1 | sed 's/^/  - { name: /' |sed 's/ (/, version: /' | sed 's/)/, pre: false }/' | sed 's/ default: / /'

... or without version:

    $ gem list | tail -n+1 | sed 's/^/  - { name: /' |sed 's/ (.*/ }/'

Update the field "pre" to "true" for "asciidoctor-pdf" and remove the duplicated versions.


### Apple store (mas)

Dump all installed applications from the app store and their unique id:

    $ mas list |sort -k2 |rev |cut -f2- -d' ' |rev |sed 's/ /, name: "/1' |sed 's/^/  - { id: /' |sed 's/$/" }/'


## Sources

* [OSXC](https://osxc.github.io/)
* [Battleschool](https://github.com/spencergibb/battleschool)
* [dotfiles](https://github.com/ricbra/dotfiles)
* [Managing your macbook with Ansible](http://blog.james-carr.org/2016/03/29/managing-your-macbook-with-ansible/)
* [demo](https://github.com/jamescarr/ansible-mac-demo)
* [How to automate your Mac OS X setup with Ansible](https://blog.vandenbrand.org/2016/01/04/how-to-automate-your-mac-os-x-setup-with-ansible/)
* [Awesome mac os command line](https://github.com/herrbischoff/awesome-osx-command-line) and [Awesome list](https://github.com/sindresorhus/awesome)
