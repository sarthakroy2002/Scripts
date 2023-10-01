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
repo sync -j8 --force-sync --no-clone-bundle --no-tags
repo sync --force-sync

git clone ${DT} device/${OEM}/${DEVICE}

. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_${DEVICE}-eng
mka clean
mka -j$(nproc) ${TARGET}
