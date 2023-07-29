#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init -u https://github.com/ArrowOS/android_manifest.git -b arrow-13.1
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

git clone --depth=1 https://github.com/ArrowOS-Devices/android_device_xiaomi_mojito.git device/xiaomi/mojito
git clone --depth=1 https://github.com/ArrowOS-Devices/android_vendor_xiaomi_mojito.git vendor/xiaomi/mojito
git clone --depth=1 https://github.com/ArrowOS-Devices/android_kernel_xiaomi_mojito.git kernel/xiaomi/mojito
git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-elf.git prebuilts/gcc/linux-x86/aarch64/aarch64-elf
git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_arm_arm-eabi.git prebuilts/gcc/linux-x86/arm/arm-eabi
git clone --depth=1 https://github.com/sarthakroy2002/android_hardware_xiaomi.git hardware/xiaomi 

source build/envsetup.sh
lunch arrow_mojito-userdebug
m bacon
