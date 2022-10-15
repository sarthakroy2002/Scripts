#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "udaycoc40@gmail.com" && git config --global user.name "UdayRocker"
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init --depth=1 -u https://github.com/CipherOS/android_manifest.git -b twelve-L
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

cd frameworks/base
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/Fix-brightness-slider-curve-for-some-devices -a12l.patch
patch -p1 <*.patch
cd "${SOURCEDIR}"

cd frameworks/av
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/11/17011/1
git cherry-pick FETCH_HEAD
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/99/16799/1
git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"

git clone --depth=1 https://github.com/UdayRocker/device_realme_RM6785
git clone --depth=1 https://github.com/UdayRocker/vendor-realme-RM6785
git clone --depth=1 https://github.com/realme-mt6785-devs/android_kernel_realme_mt6785

. build/envsetup.sh
export CIPHER_GAPPS=FALSE
lunch cipher_RM6785-userdebug
mka bacon

cd out/target/product/RM6785
curl -sL https://git.io/file-transfer | sh
./transfer wet *.zip

cd "${SOURCEDIR}"

cd vendor/cipher/build/tools
CURRDATE="date +%d_%b_%Y_%H-%M-%p"
bash ota.sh RM6785 >OTA_"${CURRDATE}".txt
curl -sL https://git.io/file-transfer | sh
./transfer wet *.txt

cd "${SOURCEDIR}"

echo '==========='
echo 'Gapps build'
echo '==========='

. build/envsetup.sh
export CIPHER_GAPPS=true
mka installclean
lunch cipher_RM6785-userdebug
mka bacon

cd out/target/product/RM6785
curl -sL https://git.io/file-transfer | sh
./transfer wet *.zip

cd "${SOURCEDIR}"
cd vendor/cipher/build/tools
CURRDATE="date +%d_%b_%Y_%H-%M-%p"
bash ota.sh RM6785 >OTA_"${CURRDATE}".txt
curl -sL https://git.io/file-transfer | sh
./transfer wet *.txt

exit 0
