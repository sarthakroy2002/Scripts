#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "kardebayan3@gmail.com" && git config --global user.name "Debayan Kar"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init -u https://github.com/ArrowOS/android_manifest.git -b arrow-12.1
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

git clone --depth=1 https://github.com/ArrowOS-Devices/android_device_10or_G.git -b arrow-12.1 device/10or/G
git clone --depth=1 https://github.com/ArrowOS-Devices/android_vendor_10or_G.git -b arrow-12.1 vendor/10or/G
git clone --depth=1 https://github.com/Jebaitedneko/android_kernel_msm89xx.git kernel/10or/G

source build/envsetup.sh
lunch arrow_G-user
m bacon

cd out/target/product/G
curl -sL https://git.io/file-transfer | sh
./transfer wet Arrow*.zip

exit 0
