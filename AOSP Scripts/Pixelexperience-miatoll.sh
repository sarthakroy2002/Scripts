#!/usr/bin/env bash
BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

# Set-up Git username & emailID
read -p 'Enter your Git username: ' username
read -p 'Enter your Git email-ID: ' emailID
echo
git config --global user.name "$username"
git config --global user.email "$emailID"

rm -rf "${SOURCEDIR}"
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

#Initializing pixelexperience repo. in source dir.
echo "Initializing Pixelexperience repo. for android 13.0"
echo
read -p "Do you need shallow clone (i.e --depth=1), if yes input (Y/N)?" input
if [[$input = Y || $input = y]]; then
repo init -u https://github.com/PixelExperience/manifest -b thirteen --depth=1
fi
repo init -u https://github.com/PixelExperience/manifest -b thirteen
echo
#Syncing repo.
echo "Syncing repo. from the source"
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
echo
#Device Sources
echo "Downloading Device Tree"
git clone -b 12.1 https://github.com/userariii/android_device_xiaomi_miatoll.git device/xiaomi/miatoll
echo
#Starting the engine
. build/envsetup.sh #this will download all the necessary files from the device tree it self.
lunch aosp_miatoll-userdebug
mka bacon -j$(nproc --all)

exit 0