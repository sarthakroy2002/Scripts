

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew update

# docker
brew cask install docker
brew install docker docker-completion docker-compose-completion
brew install kubernetes-cli kompose, kubernetes-helm

# security
brew cask install 1password

# Dev
brew cask install miniconda
brew tap adoptopenjdk/openjdk
brew cask install adoptopenjdk11
brew install maven
brew install bower cmake

# Dev CLI
brew install cocoapods tldr tree sbt tmux wget gettext

# Dev IDE
brew cask install atom visual-studio-code pycharm-ce intellij-idea-ce
brew cask install paw sourcetree

# collaboration tools
brew cask install microsoft-teams mattermost slack

# productivity
brew cask install firefox
brew cask install setapp the-unarchiver vlc
brew cask install appcleaner balenaetcher daisydisk bettertouchtool

# design
brew cask install sf-symbols sketch

# misc
brew cask install sf-symbols sketch
brew cask install roaringapps
brew cask install wireshark

# install from mac app store (e.g.  mas search "final cut")
brew install mas
# Xcode, Final Cut Pro, Fantastical
# mas install 497799835 424389933 975937182

# drivers
brew tap homebrew/cask-drivers
brew cask install logitech-options

# shell configuration
#brew install zsh
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

brew cleanup

# configure Atom
# apm install pp-markdown markdown-to-pdf pretty-json
# apm install atom-ide-ui ide-python


# finally
echo "Please reboot now!"