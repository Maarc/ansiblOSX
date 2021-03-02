# Post installation instructions

This section describes the steps to be performed for transforming a newly installed system into a fully operational machine.

1) Reduce Spotlight indexing
Open system preferences -> Spotlight
-> Restrict search results to "Applications" and "System Preferences"
-> Untick "Allow Spotlight Suggestions in Look up"
-> Under "Privacy" add all other local disks to prevent them to be indexed
-> Keyboard Shortcuts -> remove both shortcuts

2) Configure the application in the following order

2.0) (optional) Copy files from another Mac
Open system preferences -> Sharing
-> Allow "Remote Login" (access only for Administrators)
-> Open transmit and add the new installation
-> Copy Dropbox directory / .extra file

2.1) Dropbox
-> to speed-up the first sync, quit the application after the first successful login and overwrite the created dir by a local copy of the DB folder
-> configure "Notifications"
-> enable selective sync
-> change dropbox location to "~/Sync" (will create a "Dropbox" directory)

2.2) 1password
-> Used 1password before, sync over dropbox
-> Answer all questions
-> Search for "1password 7" and double-click on the license attachment to register
-> Install the browser extensions (Safari + Chrome)

2.3) Alfred
-> Activate Powerpack using key in 1password
-> "Advanced" -> "Set preference folder" -> set the dropbox folder
-> launch at login
-> Preference -> General -> change Alfred Hotkey
-> install mirror displays (https://www.npmjs.com/package/alfred-mirror-displays)
	$npm install --global alfred-mirror-displays
-> Register Spotify extension (http://alfred-spotify-mini-player.com/setup/)

2.3) Pathfinder
-> Install from https://get.cocoatech.com/PF7.zip
-> Open pathfinder and enter license key

2.4) Transmit
-> Enter license key
-> Activate Panic Sync to get the latest configuration

2.5) Bartender
-> Add license
-> Open at login
-> Configure manually and shift icons

2.6) iStats
-> Add license
-> File -> Import settings from dropbox

2.7) Fantastical 2
-> Disable all notifications
-> "Appearance" -> "Menu bar icon shows" -> "Date & Month"
-> "Appearance" -> "App icon badge shows" -> Nothing
-> "Appearance" -> "Hide Fantastical in Dock"

-> "Update" -> disable "include anonymous system profile"

2.8) Source tree
-> Login using the atlassian account

2.9) Things
-> activate Things cloud
-> right click: open at login
-> Preferences -> Quick Entry -> Disable quick entry

2.10) Telegram
-> Connect account

2.11) Spectacle
-> open and finish install
-> change shortcut for fullscreen (alt+command+-)
-> launch at login

2.12) Viscosity
-> open and finish install

2.13) PureVPN
-> login

2.14) Spotify
-> login

2.15) Clean my mac
-> register
-> Privacy -> disable all

2.16) Path Finder
-> Finder -> Hide Finder's desktop
-> General -> set as default file browser
-> General -> Set default file (Visual Studio Code) and Terminal (iTerm)
-> General -> Remove menu bar icon
-> Hide drop stack
-> Hide section "RECENT DOCUMENTS" / "SEARCH FOR"

2.17) Install CheatSheet
-> Open the app

2.18) Sublime Text
-> enter license

2.19) Capture One
-> register

2.20) Install MySides
https://github.com/mosen/mysides

2.21) Instal Photo Mechanic
http://www.camerabits.com/downloads/

2.21) (optional) Install synergy 1 Pro
-> Downalod, configure & register from the web page

2.23) (optional) Toggl
-> Login
-> Preferences -> General -> untick "Show dock icon"

2.24) (optional) Install Kindle Upload
Install send to kindle: https://www.amazon.com/gp/sendtokindle/mac

2.25) (optional) Steam
-> Login

2.26) (optional) Install Paragon NTFS
-> run the installer manually in "/usr/local/Caskroom/parafon-ntfs/15/Install/..‚"
-> login & restart

2.27) (optional) Install Grammaly
-> Enter license key

2.28) (optional) Install music software
-> Foobar2000 (https://www.foobar2000.org/mac)
-> Hauptwerk + organs
-> Midi interface
-> Cakewalk

2.29) (optional) Install photo software
-> Photo Mechanic (http://www.camerabits.com/downloads/)
-> Photo Lemur (https://photolemur.com/rd/s_Mac)
-> Topaz Denoise

2.30) Configure Karabiner-Elements
-> simple modification: assign "F19" to num lock to all keyboards and configure alfred to be launched by F19
-> for external mac keyboard switch assignments: https://github.com/pqrs-org/Karabiner-Elements/issues/1426
-> make sure that the "German" (not "German - Standard" keyboard is in use)


2.31) Install software for scanner:
- open http://scansnap.com/d/, download the installer and follow the instructions to add the WLAN scanner
- download and install nuance pdf for man: http://scansnap.com/r/nuance3/ -> redirect to "kofax"

2.32) Install Pictogram App
https://pictogramapp.com/

3) Further configuration

3.1) System preferences
-> General -> Use dark menu bar and Dock
-> Date & Time -> "Clock" -> don't show the day of the week, show the seconds, 24-hour clock
-> Keyboard -> Key repeat: fastest & Delay until repeat: shortest

3.2) iTerm2 & Terminal
-> iTerm2 -> Make default terminal
-> iTerm2 -> Install shell integration (curl -L https://iterm2.com/misc/install_shell_integration.sh | bash)
-> iTerm2 -> Preferences -> General -> Load preferences from a custom folder or URL (select DropBox folder)
-> Terminal -> Preferences -> General -> Set "/usr/local/Cellar/bash/5.1.4/bin/bash" as "Shell open with -> Command (complete path)"

# Change the used bash (https://stackoverflow.com/questions/23059662/how-can-i-get-iterm-to-use-the-newer-version-of-bash-that-brew-shows-change-a-u)
$ sudo bash -c 'echo /usr/local/Cellar/bash/5.1.4/bin/bash >> /etc/shells'
$ chsh -s /usr/local/Cellar/bash/5.1.4/bin/bash

3.3) Git configuration with SSH key 
Generate and add an SSH key checkout / push changes from GitHub (https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)
(https://help.github.com/articles/caching-your-github-password-in-git/)
$ git config --global credential.helper osxkeychain

3.4) Install cask-repair (cf. instructions on Bear)

3.5) Install and configure Little Snitch
According to the instructions, run the installer (e.g. '/usr/local/Caskroom/little-snitch/4.4.3/LittleSnitch-4.4.3.dmg')

3.6) Configure ZSH

## Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## Install and configure Power10k according to https://github.com/romkatv/powerlevel10k#homebrew
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

## Execute and configure zsh (install font, set font as defautl in iTerm2 ...)
zsh


### Add cf completion following instructions here:
https://github.com/norman-abramovitz/cf-zsh-autocomplete-plugin


4) Install additional software (currently missing)

- WebCam Driver: https://support.logi.com/hc/en-us/articles/360024699934--Downloads-C922-Pro-Stream-Webcam
- Docfetcher
- Tinker Tool (not TT System) (https://www.bresink.com/osx/-TinkerTool.html)
- GCViewer (https://github.com/chewiebug/GCViewer/wiki/Changelog)
- Snap Camera https://snapcamera.snapchat.com/download/
Install latest Ruby version
https://gorails.com/setup/osx/11.0-big-sur

Load testing: install ad / JMeter / Locust / The Grinder

Install Sony Imaging Edge
https://imagingedge.sony.net/de-de/ie-desktop.html




# gradle
$ sdk install gradle
# mysql
$ brew install mysql
# mongodb
$ brew install mongodb
# elasticsearch
$ brew install elasticsearch

# AWS CLI
brew install awscli

# Azure CLI
brew install azure-cli

# GCP CLI
brew cask install google-cloud-sdk

# CloudFoundry CLI
brew tap cloudfoundry/tap
brew install bosh-cli
brew install cf-cli
brew install credhub-cli
brew install bbl
brew install bbr

# Pivotal CLI
brew tap nevenc/tap
brew install pivnet-cli
brew install om-cli
brew install pace-cli

# Kubernetes CLI
brew install kubernetes-cli


## Todo

* Checkout content of: https://github.com/tiiiecherle/osx_install_config

Import / export dock icons - add separators
$ defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'
$ killall Dock
