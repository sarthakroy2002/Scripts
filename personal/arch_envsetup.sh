#!/usr/bin/env bash

## Cherry-picked and Adapted from AkhilNarang's script. HatsOFF to him for making things simple and Easier.
#
# Script to setup an android build environment on Arch Based Distro With Pacman Package Manager.
printf %"s\n" "Started Setting Up Build Environment." | typing

# Enabling the multilib repo, incase it was commented out
printf "Enabling multilib repo."
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//'/etc/pacman.conf

# Updating the system to the latest release.
printf "Updating..................."
sudo pacman -Syyu --noconfirm

# Installing the Packages req' for Build Environment.
printf "Installing Android building prerequisites packages. " 
sudo pacman -Syyu --noconfirm \
    multilib-devel git wget multilib-devel cmake \
    svn clang lzip patchelf inetutils python2 python3 python-pip \
    perl-switch zip unzip ccache java-environment repo gperf \
    schedtool ninja lzop pngcrush fakeroot \
    base-devel make libxcrypt-compat android-sdk-platform-tools \
    android-udev esd-oss pngcrush figlet fortune-mod hub byobu

# Install android build prerequisites
printf "Building and Installing Android building prerequisites."

# Packages needed to be build and installed.
packages="ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel"
for package in $packages; do
    printf %"s\n" "Cloning the $package." ""
    git clone https://aur.archlinux.org/"$package"
    cd "$package" || exit
    printf %"s\n" "Building the $package." ""
    makepkg -s
    printf %"s\n" "Installing the $package." ""
    makepkg -si --skippgpcheck --noconfirm --needed
    cd - || exit
done

# Installation Done.
printf "Build Envirnoment is Successful"

