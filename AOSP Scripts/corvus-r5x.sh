#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/corvus"

git config --global user.email "mizdrake7@gmail.com" && git config --global user.name "MAdMiZ"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

# Sync Source
repo init -u https://github.com/Corvus-AOSP/android_manifest.git -b 13
repo sync -j$(nproc --all) --force-sync --no-tags --no-clone-bundle

# Sync Trees
git clone https://github.com/CorvusRom-Devices/device_realme_r5x -b 13-wip device/realme/r5x
git clone https://github.com/CorvusRom-Devices/vendor_realme_r5x vendor/realme/r5x
git clone https://github.com/mizdrake7/Graveyard_r5x vendor/realme/r5x

# Start Build
source build/envsetup.sh
lunch corvus_r5x-user
make corvus

# Upload
cd out/target/product/r5x
curl -sL https://git.io/file-transfer | sh
./transfer wet Corvus*.zip
