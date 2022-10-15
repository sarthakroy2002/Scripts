#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init --depth=1 -u https://github.com/PixelOS-Pixelish/manifest.git -b thirteen
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

source build/envsetup.sh
lunch aosp_RMX2020-userdebug
mka bacon

cd out/target/product/RMX2020
curl -sL https://git.io/file-transfer | sh
./transfer wet Pixel*.zip

exit 0
