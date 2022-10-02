#!/usr/bin/env bash

# Define Variables
DEVICE="RMX2020"
DT="https://github.com/sarthakroy2002/android_recovery_realme_RMX2020.git"
OEM="realme"
TW_BRANCH="12.1"
TARGET=(
	recoveryimage
)

repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-${TW_BRANCH}
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags
repo sync --force-sync

git clone ${DT} device/${OEM}/${DEVICE}

cd bootable/recovery
git fetch https://gerrit.twrp.me/android_bootable_recovery refs/changes/05/5405/21 && git cherry-pick FETCH_HEAD
git fetch https://gerrit.twrp.me/android_bootable_recovery refs/changes/39/5639/1 && git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"
cd system/vold
git fetch https://gerrit.twrp.me/android_system_vold refs/changes/40/5540/4 && git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"

. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_${DEVICE}-eng
mka clean
mka -j$(nproc) ${TARGET}

cd ${OUT}

curl -sL https://git.io/file-transfer | sh
./transfer wet recovery.img

