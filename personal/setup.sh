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