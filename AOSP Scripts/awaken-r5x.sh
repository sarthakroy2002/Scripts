#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/awaken"

git config --global user.email "mishrabiswajit660@gmail.com" && git config --global user.name "COSMOS"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

# Sync Source
repo init -u https://github.com/Project-Awaken/android_manifest -b 12.1
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all)

# Source Patches
cd frameworks/base
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/Fix-brightness-slider-curve-for-some-devices -a12l.patch
patch -p1 <*.patch
cd "${SOURCEDIR}"

# Sync Trees
git clone --depth=1 https://github.com/mishrabiswajit/device_realme_r5x device/realme/r5x
git clone --depth=1 https://github.com/mishrabiswajit/vendor_realme_r5x vendor/realme/r5x
git clone --depth=1 https://github.com/mishrabiswajit/kernel_realme_r5x kernel/realme/r5x

# Start Build
source build/envsetup.sh
lunch awaken_r5x-userdebug
make bacon -j$(nproc --all)

# Upload
cd out/target/product/r5x
curl -sL https://git.io/file-transfer | sh
./transfer wet Awaken*.zip
