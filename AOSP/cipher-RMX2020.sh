#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

curl https://rclone.org/install.sh | sudo bash
git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
rm -rf /builds/sarthakroy2002/boldbomt/work
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"
export ALLOW_MISSING_DEPENDENCIES=true
repo init --depth=1 -u https://github.com/CipherOS/android_manifest.git -b twelve-L
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

cd frameworks/base
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/Fix-brightness-slider-curve-for-some-devices-a12l.patch
patch -p1 < *.patch
cd ../..

cd frameworks/av
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/11/17011/1
git cherry-pick FETCH_HEAD
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/99/16799/1
git cherry-pick FETCH_HEAD
cd ../..

git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020.git vendor/realme/RMX2020
git clone --depth=1 https://github.com/CipherOS-Devices/device_realme_RMX2020.git device/realme/RMX2020
git clone --depth=1 https://github.com/ArrowOS-Devices/android_kernel_realme_RMX2020 kernel/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020-ims -b twelve-rmui1 vendor/realme/RMX2020-ims

. build/envsetup.sh
export CIPHER_GAPPS=true
lunch cipher_RMX2020-userdebug
mka clean
lunch cipher_RMX2020-userdebug
mka bacon

cd out/target/product/RMX2020
wget https://gist.githubusercontent.com/noobyysauraj/8a0a66cc3fd3f5a513a4eee3f5625b38/raw/a079327aa326cf916df6704d28778f81566a0b82/rclone.conf
mkdir $HOME/.config/rclone/
mv rclone.conf $HOME/.config/rclone/
rclone -P copy CipherOS*OFFICIAL*.zip oned:/MY_BOMT_STUFFS/sarthak/CipherOS

cd ../../../..
cd vendor/cipher/build/tools
CURRDATE="date +%d_%b_%Y_%H-%M-%p"
bash ota.sh RMX2020 > OTA_"${CURRDATE}".txt
rclone -P copy OTA_"${CURRDATE}".txt oned:/MY_BOMT_STUFFS/sarthak/CipherOS

exit 0
