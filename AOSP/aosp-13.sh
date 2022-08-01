#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"
git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"
export ALLOW_MISSING_DEPENDENCIES=true
repo init -u https://android.googlesource.com/platform/manifest -b android-13.0.0_r2
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

cd system/core 
git fetch https://review.arrowos.net/ArrowOS/android_system_core refs/changes/83/16483/1 && git cherry-pick FETCH_HEAD
cd ../..

rm -rf bootable/recovery
rm -rf build/soong
rm -rf build/make
rm -rf vendor/extensions

git clone https://github.com/AOSP-13-RMX2020/platform_build build/make
git clone https://github.com/AOSP-13-RMX2020/platform_build_soong build/soong
git clone https://github.com/AOSP-13-RMX2020/platform_bootable_recovery bootable/recovery
git clone https://github.com/AOSP-13-RMX2020/platform_vendor_extensions vendor/extensions

git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020.git -b arrow-13.0-rmui1 vendor/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/device_realme_RMX2020.git -b AOSP.MASTER device/realme/RMX2020
git clone --depth=1 https://github.com/ArrowOS/android_device_mediatek_sepolicy_vndr -b arrow-12.1 device/mediatek/sepolicy_vndr
git clone --depth=1 https://github.com/sarthakroy2002/kernel_mediatek_common-headers kernel/mediatek/common-headers
git clone --depth=1 https://github.com/LineageOS/android_packages_resources_devicesettings packages/resources/devicesettings 

source build/envsetup.sh
lunch RMX2020-eng
make otapackage

cd out/target/product/RMX2020
curl -sL https://git.io/file-transfer | sh
./transfer wet *.zip

exit 0
