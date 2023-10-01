### Currently Only for Distro's for which Pacman is the Package Manager thourgh this script.

# using setup script to install prerequisite packages using different package mangers .
source setup

# Generating and Adding SSH Key to Github.
printf 'Generating a new SSH key.'
echo ' '
printf 'Enter Your registered github mail id & tap enter again.'
read mailid
ssh-keygen -t ed25519 -C "$mailid"

printf 'Adding SSH key to the workstation.'
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
printf 'Added SSH key Successfully.'

# installing Pre-requisite packages.
if [ "package" == "arch" || "package" == "yum" ]; then
    sudo pacman -S xclip konsole --noconfirm
else
    sudo apt install xclip konsole -y
fi
# Using Xclip to copy the content inside the path.
xclip -sel clip <~/.ssh/id_ed25519.pub
printf 'SSH Key has been copied.'
echo ' '
sleep 1
printf 'to add it your github account. '
echo ''
printf 'Opening github.com'.
konsole --new-tab -e python -m webbrowser https://github.com/settings/ssh/new
sleep 1
echo ' '
printf 'enter creditals to login to your account if asked.'
sleep 1
printf 'after pasting the text , click on Add SSH key.'
read -r -p "Press Enter To Continue."
sleep 1
printf 'yay! you are successfully added.'
sleep 1
echo ' '
printf 'Now Testing The Connection.'
sleep 1
printf ''
ssh -T git@github.com

# Setting up the ssh id Done.
printf "Setting up the git config is Successful."
echo ' '
printf 'Enjoy Baking....'

# Removing Konsole from Debian based distro.
if [ "package" == "apt" ]; then
    sudo apt remove konsole -y
fi

# End of Script.
