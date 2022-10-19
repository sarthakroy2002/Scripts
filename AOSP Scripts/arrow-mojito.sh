#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init -u https://github.com/ArrowOS/android_manifest.git -b arrow-13.0
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

cd vendor/arrow
git fetch https://review.arrowos.net/ArrowOS/android_vendor_arrow refs/changes/45/18945/1 && git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"

git clone --depth=1 https://github.com/Neternels/android_kernel_xiaomi_mojito kernel/xiaomi/mojito
git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-elf prebuilts/gcc/linux-x86/aarch64/aarch64-elf
git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_arm_arm-eabi prebuilts/gcc/linux-x86/arm/arm-eabi
git clone --depth=1 git@github.com:ArrowOS-Devices/android_device_xiaomi_mojito.git device/xiaomi/mojito
git clone --depth=1 git@github.com:ArrowOS-Devices/android_vendor_xiaomi_mojito.git vendor/xiaomi/mojito
git clone --depth=1 https://github.com/ArrowOS-Devices/android_hardware_xiaomi hardware/xiaomi 
git clone --depth=1 https://github.com/PixelExperience/packages_resources_devicesettings-custom packages/resources/devicesettings-custom

source build/envsetup.sh
lunch arrow_mojito-userdebug
m bacon

cd out/target/product/mojito
curl -sL https://git.io/file-transfer | sh
./transfer wet Arrow*.zip

exit 0
