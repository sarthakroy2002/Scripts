#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init -u https://github.com/ArrowOS/android_manifest.git -b arrow-13.1
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags

git clone https://github.com/ArrowOS-Devices/android_device_realme_RMX2020.git device/realme/RMX2020
git clone https://github.com/ArrowOS-Devices/android_vendor_realme_RMX2020.git vendor/realme/RMX2020
git clone https://github.com/ArrowOS-Devices/android_vendor_realme_RMX2020-ims.git vendor/realme/RMX2020-ims
git clone https://github.com/ArrowOS-Devices/android_kernel_realme_RMX2020.git kernel/realme/RMX2020
git clone https://github.com/LineageOS/android_packages_apps_Aperture.git packages/apps/Aperture
git clone https://github.com/ArrowOS-Devices/android_prebuilts_clang_host_linux-x86_clang-r437112.git prebuilts/clang/host/linux-x86/clang-r437112

source build/envsetup.sh

repopick -t thirteen-mtk-enhancements-arrow-13.1
repopick -t thirteen-ca
repopick 19999

lunch arrow_RMX2020-userdebug
m bacon
