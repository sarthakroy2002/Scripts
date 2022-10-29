#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/crdroid"

git config --global user.email "amritokarmokar5i@gmail.com" && git config --global user.name "Amritorock"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

# Sync Source
repo init --depth=1 -u repo init -u https://github.com/crdroidandroid/android.git -b 12.1
repo sync  --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all)

# Source Patches (Optional)
cd frameworks/base
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/Fix-brightness-slider-curve-for-some-devices -a12l.patch
patch -p1 <*.patch
cd "${SOURCEDIR}"

# Sync Trees
git clone --depth=1 https://github.com/Amritorock/android_device_realme_r5x -b 12.1 device/realme/r5x
git clone --depth=1 https://github.com/Amritorock/vendor_realme_r5x -b Trinket vendor/realme/r5x
git clone --depth=1 https://github.com/Amritorock/kernel_realme_r5x -b Chisato kernel/realme/r5x

# Start Build
source build/envsetup.sh
lunch lineage_r5x-user
make bacon

# Upload
cd out/target/product/r5x
curl -sL https://git.io/file-transfer | sh
./transfer wet crDroid*.zip
