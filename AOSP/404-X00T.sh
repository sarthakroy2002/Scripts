#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init -u https://github.com/P-404/android_manifest -b shinka
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

# Device Trees
git clone https://github.com/P404-Devices/device_asus_X00T --depth=1 -b shinka device/asus/X00T
git clone https://github.com/P404-Devices/vendor_asus --depth=1 -b shinka vendor/asus
git clone https://github.com/P404-Devices/kernel_asus_sdm660 --depth=1 -b shinka kernel/asus/sdm660

#HALs
git clone https://github.com/Project404-android-asus-sdm660/hardware_qcom_display -b shinka --depth=1 hardware/qcom/display
git clone https://github.com/Project404-android-asus-sdm660/hardware_qcom_media -b shinka --depth=1 hardware/qcom/media
git clone https://github.com/Project404-android-asus-sdm660/vendor_qcom_opensource_audio-hal_primary-hal -b shinka --depth=1 vendor/qcom/opensource/audio-hal/primary-hal

# Let's Cook it
source build/envsetup.sh

lunch p404_X00T-userdebug

make bacon

#Upload
cd out/target/product/X00T
curl -sL https://git.io/file-transfer | sh
./transfer wet project-404*.zip

exit
