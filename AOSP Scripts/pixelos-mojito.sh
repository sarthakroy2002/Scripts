#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init -u https://github.com/PixelOS-Pixelish/manifest.git -b thirteen --depth=1
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags


git clone --depth=1 https://github.com/PixelOS-Devices/device_xiaomi_mojito device/xiaomi/mojito
git clone --depth=1 https://github.com/PixelOS-Devices/vendor_xiaomi_mojito vendor/xiaomi/mojito

git clone --depth=1 https://github.com/PixelOS-Devices/kernel_xiaomi_mojito kernel/xiaomi/mojito
git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-elf prebuilts/gcc/linux-x86/aarch64/aarch64-elf -b 12.0.0
git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_arm_arm-eabi prebuilts/gcc/linux-x86/arm/arm-eabi -b 12.0.0

git clone --depth=1 https://github.com/ArrowOS-Devices/android_hardware_xiaomi hardware/xiaomi

source build/envsetup.sh
lunch aosp_mojito-userdebug

mka bacon

cd out/target/product/mojito
curl -sL https://git.io/file-transfer | sh
./transfer wet Pixel*.zip

exit 0
