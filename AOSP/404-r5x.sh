#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

# Repo Sync
repo init -u https://github.com/P-404/android_manifest -b shinka
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

# Clone Device Trees
git clone --depth=1 https://github.com/p404-r5x/android_device_realme_r5x -b shinka device/realme/r5x
git clone --depth=1 https://github.com/p404-r5x/android_kernel_realme_r5x -b shinka kernel/realme/r5x
git clone --depth=1 https://github.com/p404-r5x/android_vendor_realme_r5x -b shinka vendor/realme/r5x

# Clone HALs
git clone --depth=1 https://github.com/p404-r5x/android_hardware_qcom_audio -b arrow-12.1-caf-sm8150 vendor/qcom/opensource/audio-hal/primary-hal
git clone --depth=1 https://github.com/p404-r5x/android_hardware_qcom_display -b arrow-12.1-caf-sm8150 hardware/qcom/display
git clone --depth=1 https://github.com/p404-r5x/android_hardware_qcom_media -b arrow-12.1-caf-sm8150 hardware/qcom/media

# Let's Cook it
source build/envsetup.sh
lunch p404_r5x-userdebug
make bacon

# Upload
cd out/target/product/r5x
curl -sL https://git.io/file-transfer | sh
./transfer wet project-404*.zip

exit
