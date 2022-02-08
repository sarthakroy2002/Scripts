#!/bin/bash
# For Personal usage (sarhakroy2002)

echo 'Lets start Setup'

# Install Essential stuff
sudo apt update 
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev 
sudo apt install -y python tmate ssh python2 patchelf binutils
echo 'Essential stuff are installed successfully'

# My Git Config
git config --global user.email "sarthakroy2002@gmail.com"
git config --global user.name "Sarthak Roy"
echo 'Your Git config is set successfully'

# Store my Git credentials (whenever needed to)
# git config --global credential.helper store
# echo 'Git will store your credentials globally'

# Setup Change-id hooks
git config --global init.templatedir '~/.git-templates'
mkdir -p ~/.git-templates/hooks
curl -Lo .git/hooks/commit-msg https://raw.githubusercontent.com/sarthakroy2002/my_scripts/main/commit-msg
chmod 755 ~/.git-templates/hooks/commit-msg
echo 'Change-id hooks are been setup successfully'
