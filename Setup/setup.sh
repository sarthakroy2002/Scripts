# Detecting which System Package Manager is currently installed in system. 
# Thanks to StackOverflow Community for this Idea.
declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/debian_version]=apt
osInfo[/etc/SuSE-release]=zypper #No support for zypper Cunrently.

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        declare ${osInfo[$f]}="package"
    fi
done

if [ "package" == "arch" || "package" == "yum" ]
then
    bash arch_envsetup.sh
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