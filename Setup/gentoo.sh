#!/bin/bash

if [ -f /etc/gentoo-release ]; then
    printf "%s\n" "Gentoo detected. Continuing..."
else
    echo "This script is only for Gentoo"
    exit 1
fi

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists curl || ! command_exists git; then
    echo "Please install 'curl' and 'git' before running this script."
    exit 1
fi

printf "%s\n" "> Started Setting Up Build Environment."

sudo emerge -av app-crypt/gnupg app-arch/zip[-natspec] app-arch/unzip dev-lang/python:2.7 dev-libs/libxslt dev-libs/libxml2 dev-util/android-tools dev-util/ccache dev-util/gperf dev-vcs/git media-libs/libsdl media-libs/mesa net-misc/curl net-misc/rsync sys-devel/bc sys-devel/bison sys-devel/flex sys-devel/gcc[cxx] sys-libs/ncurses-compat:5=[abi_x86_32,tinfo] sys-libs/readline[abi_x86_32] sys-libs/zlib[abi_x86_32] sys-process/schedtool sys-fs/squashfs-tools x11-base/xorg-proto x11-libs/libX11 x11-libs/wxGTK:3.0

printf "%s\n" "> Which editor do you want to use for git? Tell the executable name (vim, nano, emacs, code, etc.):"
read -r editor
git config --global core.editor "$editor"

printf "%s\n" "> Enter your name:"
read -r name
git config --global user.name "$name"
printf "%s\n" "> Enter your email:"
read -r email
git config --global user.email "$email"

printf "%s\n" "> Do you want to authenticate using gh tool (and authenticate git tool)? (y/n)"
read -r gh
if [ "$gh" = "y" ]; then
    gh auth login
fi

printf "%s\n" "> Installing repo tool..."
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

printf "%s\n" "Done! Thanks for using this script."
