y#!/usr/bin/env bash

echo 'Enter AOSP BRANCH:'
read AOSPBRANCH
repo init --depth=1 --no-repo-verify -u https://android.googlesource.com/platform/manifest -b $AOSPBRANCH -g default,-mips,-darwin,-notdefault
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all)
git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020 -b android-12.0L vendor/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/device_realme_RMX2020 -b android-12.0L device/realme/RMX2020
git clone --depth=1 https://github.com/ArrowOS/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr
git clone --depth=1 https://github.com/sarthakroy2002/kernel_mediatek_common-headers kernel/mediatek/common-headers
git clone --depth=1 https://github.com/sarthakroy2002/vendor_extras vendor/extras
curl -sL https://git.io/file-transfer | sh

. build/envsetup.sh
lunch RMX2020-userdebug
make otapackage
