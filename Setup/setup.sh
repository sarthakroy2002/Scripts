#!/bin/bash
# Detecting which System Package Manager is currently installed in system. 
# Thanks to StackOverflow Community for this Idea.
declare -A osInfo=(
    [/etc/dnf/dnf.conf]=dnf
    [/etc/arch-release]=pacman
    [/etc/debian_version]=apt
    [/etc/SuSE-release]=zypper
    [/etc/alpine-release]=apk
    [/etc/gentoo-release]=emerge
)

package=""

for f in "${!osInfo[@]}"; do
    if [[ -f $f ]]; then
        package="${osInfo[$f]}"
        break
    fi
done

if [[ "$package" == "pacman" ]]; then
    bash arch_envsetup.sh
elif [["$package" == "dnf"]]; then
    bash fedora_envsetup.sh
elif [[ "$package" == "apk" ]]; then
    bash alpine_envsetup.sh
elif [[ "$package" == "emerge" ]]; then
    bash gentoo_envsetup.sh
else
    bash ubuntu_envsetup.sh
fi

# Setting up the git config.
printf 'Setting Up  Git config.'
echo ''
printf 'Enter your github username.'
# asks for user input. so by using the function 'read' here . There is no need to add any credentials.
read username
sleep 1
git config --global user.name "$username"
echo 'Enter your registered github mail id.'
read mail
sleep 1
git config --global user.email "$mail"

#End of scripts.
