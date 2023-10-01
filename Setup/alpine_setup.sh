#!/bin/sh
# For Personal usage (sarhakroy2002)

echo 'Lets start Setup'

# Install Essential stuff
apk update
apk add bc bison build-base ccache curl flex g++ git gnupg gperf imagemagick ncurses-dev readline-dev zlib-dev lz4 libncurses5 libgcc libstdc++ sdl-dev openssl wxgtk3.0 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib-dev
apk add python3 tmate openssh python2 patchelf binutils zram-config
echo 'Essential stuff are installed successfully'

# My Git Config
git config --global user.email "sarthakroy2002@gmail.com"
git config --global user.name "Sarthak Roy"
echo 'Your Git config is set successfully'

# Store my Git credentials (whenever needed to)
# git config --global credential.helper store
# echo 'Git will store your credentials globally'

# Install repo
mkdir ~/bin && export PATH=~/bin:$PATH && curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo && chmod a+x ~/bin/repo

# Setup Change-id hooks
git config --global init.templatedir '~/.git-templates'
mkdir -p ~/.git-templates/hooks
curl -Lo ~/.git-templates/hooks/commit-msg https://raw.githubusercontent.com/sarthakroy2002/Scripts/main/commit-msg
chmod 755 ~/.git-templates/hooks/commit-msg
echo 'Change-id hooks are been setup successfully'

# Setting up Ssh Key.
sh sshid_setup.sh
