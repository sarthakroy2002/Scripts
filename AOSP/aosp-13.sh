#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"
git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init --depth=1 --no-repo-verify -u https://android.googlesource.com/platform/manifest -b android-13.0.0_r6 -g default,-mips,-darwin,-notdefault
repo sync -c --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune -j$(nproc --all)

cd system/core
git fetch https://review.arrowos.net/ArrowOS/android_system_core refs/changes/83/16483/1 && git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"

cd packages/modules/Bluetooth && git fetch https://review.arrowos.net/ArrowOS/android_packages_modules_Bluetooth refs/changes/43/18143/1 && git cherry-pick FETCH_HEAD && git fetch https://review.arrowos.net/ArrowOS/android_packages_modules_Bluetooth refs/changes/44/18144/1 && git cherry-pick FETCH_HEAD && cd "${SOURCEDIR}"

cd frameworks/opt/net/ims && git fetch https://github.com/AOSP-13-RMX2020/frameworks_opt_net_ims && git cherry-pick 0e8a88ecdbf05509f84bd136c63d56791dbf78c3^..5c6179402cd8a5fc29dbd789e59a5ddf5546c1b3 && cd "${SOURCEDIR}"

cd packages/modules/Wifi && git fetch https://github.com/AOSP-13-RMX2020/packages_modules_Wifi && git cherry-pick 1315ccb757bd2d7c63b4815ab77e04535d2b7750^..6b341eefeb1127a97dc3b77a853e30ed7630be30 && cd "${SOURCEDIR}"

cd frameworks/opt/telephony && git fetch https://github.com/AOSP-13-RMX2020/frameworks_opt_telephony && git cherry-pick 3d7ef06b1370b98fc9893693a23b2f350a8d912d && cd "${SOURCEDIR}"

cd frameworks/base && git fetch https://github.com/ArrowOS/android_frameworks_base arrow-13.0 && git cherry-pick f627e89f23690ebf10ee46a0a3cdc456562ccb02 && git cherry-pick f5ef95dbb73ce6d0167dd085cbca11049919b8a4 && cd "${SOURCEDIR}"

cd frameworks/base && git fetch https://review.arrowos.net/ArrowOS/android_frameworks_base refs/changes/88/17688/1 && git cherry-pick FETCH_HEAD && cd "${SOURCEDIR}"

rm -rf bootable/recovery
rm -rf build/soong
rm -rf build/make
rm -rf vendor/extensions

git clone --depth=1 https://github.com/AOSP-13-RMX2020/platform_build build/make
git clone --depth=1 https://github.com/AOSP-13-RMX2020/platform_build_soong build/soong
git clone --depth=1 https://github.com/AOSP-13-RMX2020/platform_bootable_recovery bootable/recovery
git clone --depth=1 https://github.com/AOSP-13-RMX2020/platform_vendor_extensions vendor/extensions
git clone --depth=1 https://github.com/sarthakroy2002/android_prebuilts_clang_host_linux-x86_clang-r437112 prebuilts/clang/host/linux-x86/clang-r437112

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
