# AnsiblOSX - Post installation instructions

This section describes the steps to be performed for transforming a newly installed system into a fully operational machine.

## (0) Configure Git with SSH key 
Generate and add an SSH key checkout / push changes from GitHub (https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)
(https://help.github.com/articles/caching-your-github-password-in-git/)

```sh
git config --global credential.helper osxkeychain
```

Alternative: Copy the `.ssh` directory from another mac

## (1) Reduce Spotlight indexing

* Open system preferences -> Spotlight
  * Restrict search results to "Applications" and "System Preferences"
  * Untick "Help Apple Improve Search"
  * Under "Privacy" add all other local disks to prevent them to be indexed
  * system preferences -> Keyboard Shortcuts -> Keyboard Shortcuts -> Spotlight -> remove both shortcuts
  x Untick "Allow Spotlight Suggestions in Look up"


## (2) Configure the application in the following order

### 2.0) (optional) Copy files from another Mac
* Open system preferences -> Sharing
  * Allow "Remote Login" (access only for Administrators)
  * Open transmit and add the new installation
  * Copy Dropbox directory / .extra file

### 2.1) 1Password v7
* Check that the right licensed version is in use (7)
* Used 1password before, sync over icloud
* Answer all questions
* Search for "1password 7" and double-click on the license attachment to register
* Install the browser extensions (Safari + Chrome)
  * Safari: open "Safari" -> "Safari Extensions"
  * Chrome: install the plugin / extension

### 2.2) Dropbox
* Enable selective sync
* Change dropbox location to "~/Sync" (will create a "Dropbox" directory)
* Configure "Notifications"
* `optional` To speed-up the first sync, quit the application after the first successful login and overwrite the created dir by a local copy of the DB folder

### 2.3) Alfred
* Activate Powerpack using key in 1password
* "Advanced" -> "Set preference folder" -> set the dropbox folder
* launch at login
* Preference -> General -> change Alfred Hotkey
* `optional` -> install mirror displays (https://www.npmjs.com/package/alfred-mirror-displays): `npm install --global alfred-mirror-displays`
* `optional` -> Register Spotify extension (http://alfred-spotify-mini-player.com/setup/)

### 2.4) Configure Karabiner-Elements
* simple modification: assign from caps_lock to key "F16" on all keyboards and configure alfred to be launched by F16
* make sure that the "German" (not "German - Standard" keyboard is in use)
* `optional` for external mac keyboard switch assignments: https://github.com/pqrs-org/Karabiner-Elements/issues/1426

### 2.5) Configure system clock
* Open Dock & Menu Bar and set ...
  * Show date "NEVER"
  * Disable "Show the day of the week"
  * Set "Use a 24-hour clock"
  * Set "Display the time with seconds"
  * Disable other options

### 2.6) Bartender
* Tick "Launch Bartender at login" box
* Add license
* Configure manually (from another mac) and shift icons

### 2.7) iStats
* Add license
* File -> Import settings from dropbox

### 2.8) Rectangle (replacing old Spectable)
* Open and finish install
* Change shortcut for fullscreen (alt+command+-)
* Launch at login

### 2.9) Transmit
* Enter license key
* Activate Panic Sync to get the latest configuration

### 2.10) Itsycal
* Launch at login
* Configure apparence

### 2.11) Source tree
* Login using the atlassian account & GitHub one

### 2.12) Things
* Activate Things cloud
* Right click: open at login
* Preferences -> Quick Entry -> Disable quick entry

### 2.13) Telegram
* Connect account
* Configure apparence and notifications

### 2.14) Spotify
* Login

### 2.15) CleanMyMac X
* Register
* Privacy -> disable all

### 2.16) Configure ZSH & My Zsh

#### Install Oh My Zsh

`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

#### Install and configure Power10k according to https://github.com/romkatv/powerlevel10k#homebrew

```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo 'source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

#### Install fonts

Download "Hack" and "" from here: https://www.nerdfonts.com/font-downloads

Then unzip and execute `open *.ttf` to install the font on MacOS.


#### Fix terminal in visual studio code
Follow these instructions: https://gist.github.com/480/3b41f449686a089f34edb45d00672f28

```yml
"terminal.integrated.fontFamily": "Hack Nerd Font",
"terminal.integrated.shell.osx": "/bin/zsh"
```

#### (Optional) Add cf completion following instructions here:
https://github.com/norman-abramovitz/cf-zsh-autocomplete-plugin


### 2.17) Configure Google Chrome
* Sync plugins and bookmarks with sync mechanism
* Import "Awesome" shortcuts for the home page

### 2.18) Configure Visual Studio Code
* Use "Settings Sync" extension (https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync) to load the latest extensions and settings
* Log into Copilot

### 2.19) iTerm2 & Terminal

* iTerm2 -> Make default terminal
* iTerm2 -> Install shell integration (curl -L https://iterm2.com/misc/install_shell_integration.sh | bash)
* iTerm2 -> Preferences -> General -> Load preferences from a custom folder or URL (select DropBox folder)

* Terminal -> Shell -> Open (from Dropbox folder)
* Terminal -> Shell -> Use Settings as Default

#### Change the used bash (https://stackoverflow.com/questions/23059662/how-can-i-get-iterm-to-use-the-newer-version-of-bash-that-brew-shows-change-a-u)
```sh
$ sudo bash -c 'echo /usr/local/Cellar/bash/5.1.8/bin/bash >> /etc/shells'
```

#### Keep zsh as default for iterm
```sh
chsh -s /bin/zsh
# This would change the default shell
## chsh -s /usr/local/Cellar/bash/5.1.8/bin/bash
```

### 2.20) MoneyMoney
Configure the software by importing the database.
https://www.heise.de/ratgeber/Tipp-MoneyMoney-Datenbank-auf-neuen-Mac-uebertragen-6054587.html

### 2.21) (optional) Install synergy 1 Pro
* Downalod, configure & register from the web page

### 2.22) (optional) Toggl
* Login
* Preferences -> General -> untick "Show dock icon"

### 2.23) (optional) Install Kindle Upload
	Install send to kindle: https://www.amazon.com/gp/sendtokindle/mac

### 2.24) (optional) Steam
* Login

### 2.25) (optional) Install Paragon NTFS
* run the installer manually in "/usr/local/Caskroom/parafon-ntfs/15/Install/..‚"
* login & restart

### 2.26) (optional) Install music software
* Foobar2000 (https://www.foobar2000.org/mac)
* Hauptwerk + organs
* Midi interface
* Cakewalk

### 2.27) (optional) Install photo software
* CaptureOne -> install manually as cask has been removed & register
* Photo Mechanic (http://www.camerabits.com/downloads/)
* Photo Lemur (https://photolemur.com/rd/s_Mac - https://photolemur.en.softonic.com/mac)
* Topaz Denoise
* MySides (https://github.com/mosen/mysides)

### 2.28) Install software for scanner
* Open http://scansnap.com/d/, download the installer and follow the instructions to add the WLAN scanner
* Download and install nuance pdf for man: http://scansnap.com/r/nuance3/ -> redirect to "kofax"

### 2.29) Install Pictogram App
https://pictogramapp.com/

### 2.30) Bear
Start and launch Synchronization

## (3) Further configuration

### 3.1) iCloud & storage

Turn off the Optimize Storage option. Apple menu > System Preferences > Apple ID > Optimize Mac Storage.

### 3.2) System preferences
* General -> Use dark menu bar and Dockbash
* Date & Time -> "Clock" -> don't show the day of the week, show the seconds, 24-hour clock
* Keyboard -> Key repeat: fastest & Delay until repeat: shortest
* Trackpad -> Look up & data detectors -> Off (disables dictionnary - see https://macpaw.com/how-to/turn-off-dictionary-mac)


### 3.3) Dock configuration

Group apps by creating folders and app symlinks, for example:
`ln -s ../../Paintbrush.app Paintbrush.app`

Add icons to the folders
https://support.apple.com/en-gb/guide/mac-help/mchlp2313/mac

Import / export dock icons - add separators
```sh
defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'
killall Dock
```

## (4) Install additional software (currently missing)

* __Captvty__ https://captvty.fr/ (See https://captvty.fr/faq#macos)
* __WebCam Driver__ https://support.logi.com/hc/en-us/articles/360024699934--Downloads-C922-Pro-Stream-Webcam
* __Docfetcher__
* __Tinker Tool__ (not TT System) (https://www.bresink.com/osx/-TinkerTool.html)
* __GCViewer__ (https://github.com/chewiebug/GCViewer/wiki/Changelog)
* __Snap Camera__ https://snapcamera.snapchat.com/download/
* __Ruby__ (latest version): https://gorails.com/setup/osx/11.0-big-sur
* __Sony Imaging Edge__: https://imagingedge.sony.net/de-de/ie-desktop.html
* __BAT themes__: https://github.com/catppuccin/bat?tab=readme-ov-file
* __Gradle__: `sdk install gradle`
* __Kubernetes CLI__: `brew install kubernetes-cli`

## (99) Archive - Not used anymore

__Applescript to add a date shortcut__: https://discussions.apple.com/thread/8651300#:~:text=It%20just%20works.,for%20the%20first%20time%20only.
```sh
on run {input, parameters}
	set thedate to (do shell script "date \"+%Y.%m.%d\"") as string
	tell application "System Events"
		keystroke thedate
	end tell
end run
```

__AWS CLI__
```sh
brew install awscli
```
__Azure CLI__
```sh
brew install azure-cli
```

__GCP CLI__
```sh
brew cask install google-cloud-sdk
```

__CloudFoundry CLI__
```sh
brew tap cloudfoundry/tap
brew install bosh-cli
brew install cf-cli
brew install credhub-cli
brew install bbl
brew install bbr
```

__Pivotal CLI__
```sh
brew tap nevenc/tap
brew install pivnet-cli
brew install om-cli
brew install pace-cli
```

__mysql__
```sh
brew install mysql
```

__mongodb__
```sh
brew install mongodb
```

__elasticsearch__
```sh
brew install elasticsearch
```
