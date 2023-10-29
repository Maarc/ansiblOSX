# Post installation instructions

This section describes the steps to be performed for transforming a newly installed system into a fully operational machine.

0) Configure Git with SSH key 
Generate and add an SSH key checkout / push changes from GitHub (https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)
(https://help.github.com/articles/caching-your-github-password-in-git/)
$ git config --global credential.helper osxkeychain

Alternative: Copy the ".ssh" directory from another mac


(1) Reduce Spotlight indexing
Open system preferences -> Spotlight
-> Restrict search results to "Applications" and "System Preferences"
-> Untick "Allow Spotlight Suggestions in Look up"
-> Under "Privacy" add all other local disks to prevent them to be indexed
-> Keyboard Shortcuts -> remove both shortcuts

(2) Configure the application in the following order

2.0) (optional) Copy files from another Mac
Open system preferences -> Sharing
-> Allow "Remote Login" (access only for Administrators)
-> Open transmit and add the new installation
-> Copy Dropbox directory / .extra file

2.1) 1password
-> Check that the right licensed version is in use (7)
-> Used 1password before, sync over icloud
-> Answer all questions
-> Search for "1password 7" and double-click on the license attachment to register
-> Install the browser extensions (Safari + Chrome)
	-> Safari: open "Safari" -> "Safari Extensions"
	-> Chrome: install the plugin / extension

2.2) Dropbox
-> enable selective sync
-> change dropbox location to "~/Sync" (will create a "Dropbox" directory)
-> configure "Notifications"
<optional> -> to speed-up the first sync, quit the application after the first successful login and overwrite the created dir by a local copy of the DB folder


2.3) Alfred
-> Activate Powerpack using key in 1password
-> "Advanced" -> "Set preference folder" -> set the dropbox folder
-> launch at login
-> Preference -> General -> change Alfred Hotkey
<optional> -> install mirror displays (https://www.npmjs.com/package/alfred-mirror-displays)
	$npm install --global alfred-mirror-displays
<optional> -> Register Spotify extension (http://alfred-spotify-mini-player.com/setup/)

2.4) Configure Karabiner-Elements
-> simple modification: assign from caps_lock to key "F19" on all keyboards and configure alfred to be launched by F19
-> make sure that the "German" (not "German - Standard" keyboard is in use)
<optional> -> for external mac keyboard switch assignments: https://github.com/pqrs-org/Karabiner-Elements/issues/1426

2.5) Configure system clock
-> Open Dock & Menu Bar and set ...
- Show date "NEVER"
- Disable "Show the day of the week"
- Set "Use a 24-hour clock"
- Set "Display the time with seconds"
- Disable other options

2.6) Bartender
-> Tick "Launch Bartender at login" box
-> Add license
-> Configure manually (from another mac) and shift icons

2.7) iStats
-> Add license
-> File -> Import settings from dropbox

2.8) Spectacle
-> open and finish install
-> change shortcut for fullscreen (alt+command+-)
-> launch at login

2.9) Transmit
-> Enter license key
-> Activate Panic Sync to get the latest configuration

2.10) Itsycal
-> Launch at login
-> Configure apparence

2.11) Source tree
-> Login using the atlassian account & GitHub one

2.12) Things
-> activate Things cloud
-> right click: open at login
-> Preferences -> Quick Entry -> Disable quick entry

2.13) Telegram
-> Connect account
-> Configure apparence and notifications

2.14) Spotify
-> login

2.15) CleanMyMac
-> register
-> Privacy -> disable all

2.16) (optional) Install Grammaly
-> Enter license key

2.17) Configure ZSH & My Zsh

## Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## Install and configure Power10k according to https://github.com/romkatv/powerlevel10k#homebrew
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo 'source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

## Execute and configure zsh (install font, set font as defautl in iTerm2 ...)
zsh

### Add cf completion following instructions here:
https://github.com/norman-abramovitz/cf-zsh-autocomplete-plugin

### Fix terminal in visual studio code following those instructions:
https://gist.github.com/480/3b41f449686a089f34edb45d00672f28
"terminal.integrated.fontFamily": "Hack Nerd Font",
"terminal.integrated.shell.osx": "/bin/zsh"


2.18) Configure Google Chrome
-> Sync plugins and bookmarks with sync mechanism
-> Import "Awesome" shortcuts for the home page


2.19) Configure Visual Studio Code
-> Use "Settings Sync" extension (https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync) to load the latest extensions and settings
-> Log into Copilot


2.20) iTerm2 & Terminal
-> iTerm2 -> Make default terminal
-> iTerm2 -> Install shell integration (curl -L https://iterm2.com/misc/install_shell_integration.sh | bash)
-> iTerm2 -> Preferences -> General -> Load preferences from a custom folder or URL (select DropBox folder)

-> Terminal -> Shell -> Open (from Dropbox folder)
-> Terminal -> Shell -> Use Settings as Default

# Change the used bash (https://stackoverflow.com/questions/23059662/how-can-i-get-iterm-to-use-the-newer-version-of-bash-that-brew-shows-change-a-u)
$ sudo bash -c 'echo /usr/local/Cellar/bash/5.1.8/bin/bash >> /etc/shells'

# Keep zsh as default for iterm
$ chsh -s /bin/zsh
# This would change the default shell
## chsh -s /usr/local/Cellar/bash/5.1.8/bin/bash


2.21) MoneyMoney

Configure the software by importing the database.
https://www.heise.de/ratgeber/Tipp-MoneyMoney-Datenbank-auf-neuen-Mac-uebertragen-6054587.html


<OPTIONAL>

	2.22) (optional) Install synergy 1 Pro
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

	2.27) (optional) Install music software
	-> Foobar2000 (https://www.foobar2000.org/mac)
	-> Hauptwerk + organs
	-> Midi interface
	-> Cakewalk

	2.28) (optional) Install photo software
	-> CaptureOne -> install manually as cask has been removed & register
	-> Photo Mechanic (http://www.camerabits.com/downloads/)
	-> Photo Lemur (https://photolemur.com/rd/s_Mac - https://photolemur.en.softonic.com/mac)
	-> Topaz Denoise
	-> MySides (https://github.com/mosen/mysides)


	2.29) Install software for scanner:
	- open http://scansnap.com/d/, download the installer and follow the instructions to add the WLAN scanner
	- download and install nuance pdf for man: http://scansnap.com/r/nuance3/ -> redirect to "kofax"

	2.30) Install Pictogram App
	https://pictogramapp.com/

	2.18) Install AskCommand
	https://askcommand.com/

</OPTIONAL>


3) Further configuration

3.1) iCloud & storage

-> Turn off the Optimize Storage option. Apple menu > System Preferences > Apple ID > Optimize Mac Storage.

3.2) System preferences
-> General -> Use dark menu bar and Dockbash
-> Date & Time -> "Clock" -> don't show the day of the week, show the seconds, 24-hour clock
-> Keyboard -> Key repeat: fastest & Delay until repeat: shortest

3.3) Dock configuration

Group apps by creating folders and app symlinks, for example:
`ln -s ../../Paintbrush.app Paintbrush.app`

Add icons to the folders
https://support.apple.com/en-gb/guide/mac-help/mchlp2313/mac

Import / export dock icons - add separators
$ defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'
$ killall Dock


3.3) Create an applescript to add a date shortcut

Follow: https://discussions.apple.com/thread/8651300#:~:text=It%20just%20works.,for%20the%20first%20time%20only.


```
on run {input, parameters}
	set thedate to (do shell script "date \"+%Y.%m.%d\"") as string
	tell application "System Events"
		keystroke thedate
	end tell
end run
```




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

