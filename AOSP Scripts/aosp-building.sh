#!/usr/bin/env bash

echo 'Enter AOSP BRANCH:'
read AOSPBRANCH
repo init --depth=1 -u https://android.googlesource.com/platform/manifest -b $AOSPBRANCH
repo sync -c --force-sync -j8
git clone https://github.com/sarthakroy2002/vendor_realme_RMX2020 -b main vendor/realme/RMX2020
git clone https://github.com/sarthakroy2002/device_realme_RMX2020 -b main device/realme/RMX2020
git clone https://github.com/sarthakroy2002/device_realme_RMX2020-kernel -b main device/realme/RMX2020-kernel
git clone https://github.com/ArrowOS/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr
git clone https://github.com/ArrowOS/android_hardware_mediatek hardware/mediatek

. build/envsetup.sh
lunch RMX2020-userdebug
make otapackage
