#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "kardebayan3@gmail.com" && git config --global user.name "Debayan Kar"
rm -rf "${SOURCEDIR}"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"
export ALLOW_MISSING_DEPENDENCIES=true
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
repo sync --force-sync

git clone https://github.com/kardebayan/twrp_device_xiaomi_mi8937-new.git device/xiaomi/mi8937

cd bootable/recovery
git fetch https://gerrit.twrp.me/android_bootable_recovery refs/changes/33/5633/6 && git checkout FETCH_HEAD
cd ../..
cd system/vold
git fetch https://gerrit.twrp.me/android_system_vold refs/changes/45/5645/2 && git checkout FETCH_HEAD
cd ../..
cd vendor/twrp
git fetch https://gerrit.twrp.me/android_vendor_twrp refs/changes/57/5657/1 && git checkout FETCH_HEAD
cd ../../

. build/envsetup.sh
lunch twrp_mi8937-eng
mka clean
lunch twrp_mi8937-eng
mka recoveryimage

cd out/target/product/mi8937

curl -sL https://git.io/file-transfer | sh
./transfer wet recovery.img

exit 0
