
### Currently Only for Distro's for which Pacman is the Package Manager thourgh this script.
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
sudo pacman -S xclip konsole --noconfirm
xclip -sel clip <  ~/.ssh/id_ed25519.pub
printf 'SSH Key has been copied.'
echo ' '
sleep 1
printf 'to add it your github account. '
echo ''
printf 'Opening github.com'.
konsole --new-tab  -e python -m webbrowser https://github.com/settings/ssh/new
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

# Setting up the git config Done.
printf "Setting up the git config is Successful." 
echo ' '
printf 'Enjoy Baking....'