#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

curl https://rclone.org/install.sh | sudo bash
git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
rm -rf "${SOURCEDIR}"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"
export ALLOW_MISSING_DEPENDENCIES=true
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
repo sync --force-sync

git clone https://github.com/sarthakroy2002/android_recovery_realme_RMX2020 device/realme/RMX2020

. build/envsetup.sh
lunch twrp_RMX2020-userdebug
mka clean
lunch twrp_RMX2020-userdebug
mka bacon

cd out/target/product/RMX2020
wget https://gist.githubusercontent.com/noobyysauraj/8a0a66cc3fd3f5a513a4eee3f5625b38/raw/a079327aa326cf916df6704d28778f81566a0b82/rclone.conf
mkdir $HOME/.config/rclone/
mv rclone.conf $HOME/.config/rclone/
rclone -P copy recovery.img oned:/MY_BOMT_STUFFS/sarthak/TWRP

exit 0
