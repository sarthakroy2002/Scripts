#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init --depth=1 --no-repo-verify -u https://github.com/CipherOS/android_manifest.git -b twelve -g default,-mips,-darwin,-notdefault
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all)

cd frameworks/base
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/Fix-brightness-slider-curve-for-some-devices-a12l.patch
patch -p1 <*.patch
cd "${SOURCEDIR}"

cd frameworks/av
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/11/17011/1
git cherry-pick FETCH_HEAD
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/99/16799/1
git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"

git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020.git vendor/realme/RMX2020
git clone --depth=1 https://github.com/CipherOS-Devices/device_realme_RMX2020.git device/realme/RMX2020
git clone --depth=1 https://github.com/ArrowOS-Devices/android_kernel_realme_RMX2020 kernel/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020-ims -b twelve-rmui1 vendor/realme/RMX2020-ims

. build/envsetup.sh
export CIPHER_GAPPS=false
lunch cipher_RMX2020-userdebug
mka bacon

cd out/target/product/RMX2020
curl -sL https://git.io/file-transfer | sh
./transfer wet *.zip

cd "${SOURCEDIR}"

cd vendor/cipher/build/tools
CURRDATE="date +%d_%b_%Y_%H-%M-%p"
bash ota.sh RMX2020 >OTA_"${CURRDATE}".txt
curl -sL https://git.io/file-transfer | sh
./transfer wet *.txt

cd "${SOURCEDIR}"

echo '==========='
echo 'Gapps build'
echo '==========='

. build/envsetup.sh
export CIPHER_GAPPS=true
mka installclean
lunch cipher_RMX2020-userdebug
mka bacon

cd out/target/product/RMX2020
curl -sL https://git.io/file-transfer | sh
./transfer wet *.zip

cd "${SOURCEDIR}"
cd vendor/cipher/build/tools
CURRDATE="date +%d_%b_%Y_%H-%M-%p"
bash ota.sh RMX2020 >OTA_"${CURRDATE}".txt
curl -sL https://git.io/file-transfer | sh
./transfer wet *.txt

exit 0
