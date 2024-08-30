#!/bin/bash
# For Personal usage (sarhakroy2002)

echo 'Lets start Setup'

# Install Essential stuff
sudo apt update
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
sudo apt install -y python tmate ssh python2 patchelf binutils python-is-python3 zram-config git-lfs
echo 'Essential stuff are installed successfully'

# My Git Config
git config --global user.email "sarthakroy2002@gmail.com"
git config --global user.name "Sarthak Roy"
echo 'Your Git config is set successfully'

# Install repo
mkdir ~/bin && PATH=~/bin:$PATH && curl https://storage.googleapis.com/git-repo-downloads/repo >~/bin/repo && chmod a+x ~/bin/repo
