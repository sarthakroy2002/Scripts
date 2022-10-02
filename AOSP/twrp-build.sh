#!/usr/bin/env bash


repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
repo sync --force-sync

git clone https://github.com/sarthakroy2002/android_recovery_realme_RMX2020 device/realme/RMX2020

cd bootable/recovery
git fetch https://gerrit.twrp.me/android_bootable_recovery refs/changes/05/5405/21 && git cherry-pick FETCH_HEAD
git fetch https://gerrit.twrp.me/android_bootable_recovery refs/changes/39/5639/1 && git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"
cd system/vold
git fetch https://gerrit.twrp.me/android_system_vold refs/changes/40/5540/4 && git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"

. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_RMX2020-eng
mka clean
lunch twrp_RMX2020-eng
mka recoveryimage

cd out/target/product/RMX2020

curl -sL https://git.io/file-transfer | sh
./transfer wet recovery.img
