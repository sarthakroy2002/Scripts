#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init -u https://github.com/ArrowOS/android_manifest.git -b arrow-12.1
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

cd frameworks/base
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_base refs/changes/46/16646/1 && git cherry-pick FETCH_HEAD
cd ../..

cd system/core
git fetch https://review.arrowos.net/ArrowOS/android_system_core refs/changes/00/16200/1 && git cherry-pick FETCH_HEAD
cd ../..

cd frameworks/av
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/11/17011/1
git cherry-pick FETCH_HEAD
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/99/16799/1
git cherry-pick FETCH_HEAD
cd ../..

git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020.git vendor/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/device_realme_RMX2020.git device/realme/RMX2020
git clone --depth=1 https://github.com/ArrowOS-Devices/android_kernel_realme_RMX2020 kernel/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020-ims -b twelve-rmui1 vendor/realme/RMX2020-ims

source build/envsetup.sh
lunch arrow_RMX2020-userdebug
m bacon

cd out/target/product/RMX2020
curl -sL https://git.io/file-transfer | sh
./transfer wet Arrow*.zip

exit 0
