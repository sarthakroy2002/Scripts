#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
rm -rf "${SOURCEDIR}"
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

repo init --depth=1 -u https://github.com/LineageOS/android.git -b lineage-20.0
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

cd frameworks/base
git fetch https://github.com/realme-mt6785-devs/android_frameworks_base
git cherry-pick d8a4c380212fd9fdf3e92c04578b8c0e14d8f1aa
git cherry-pick c21a0f11773774329c4094238d1e0a4adc160b81
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/Fix-brightness-slider-curve-for-some-devices-a12l.patch
patch -p1 <*.patch
cd "${SOURCEDIR}"

cd frameworks/av
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/11/17011/1
git cherry-pick FETCH_HEAD
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/99/16799/1
git cherry-pick FETCH_HEAD
cd "${SOURCEDIR}"

cd system/core && git fetch https://review.arrowos.net/ArrowOS/android_system_core refs/changes/93/17693/1 && git cherry-pick FETCH_HEAD && cd ../..

cd frameworks/opt/net/ims && git fetch https://github.com/AOSP-13-RMX2020/frameworks_opt_net_ims && git cherry-pick 0e8a88ecdbf05509f84bd136c63d56791dbf78c3^..5c6179402cd8a5fc29dbd789e59a5ddf5546c1b3 && cd ../../../.. 

cd packages/modules/Wifi && git fetch https://github.com/AOSP-13-RMX2020/packages_modules_Wifi && git cherry-pick 1315ccb757bd2d7c63b4815ab77e04535d2b7750^..6b341eefeb1127a97dc3b77a853e30ed7630be30 && cd ../../.. 

cd frameworks/opt/telephony && git fetch https://github.com/AOSP-13-RMX2020/frameworks_opt_telephony && git cherry-pick 3d7ef06b1370b98fc9893693a23b2f350a8d912d && cd ../../..

cd frameworks/base && git fetch https://github.com/ArrowOS/android_frameworks_base arrow-13.0 && git cherry-pick f627e89f23690ebf10ee46a0a3cdc456562ccb02 && git cherry-pick f5ef95dbb73ce6d0167dd085cbca11049919b8a4 && cd ../..

cd packages/modules/Bluetooth && git fetch https://review.arrowos.net/ArrowOS/android_packages_modules_Bluetooth refs/changes/43/18143/1 && git cherry-pick FETCH_HEAD && git fetch https://review.arrowos.net/ArrowOS/android_packages_modules_Bluetooth refs/changes/44/18144/1 && git cherry-pick FETCH_HEAD && cd ../../..

cd vendor/lineage
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/0001-Device-Specific-patches.patch
patch -p1 <*.patch
cd "${SOURCEDIR}"

git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020.git vendor/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/device_realme_RMX2020.git device/realme/RMX2020
git clone --depth=1 https://github.com/ArrowOS-Devices/android_kernel_realme_RMX2020 kernel/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020-ims vendor/realme/RMX2020-ims
git clone --depth=1 https://github.com/ArrowOS/android_device_mediatek_sepolicy_vndr -b arrow-13.0 device/mediatek/sepolicy_vndr
git clone https://github.com/sarthakroy2002/android_prebuilts_clang_host_linux-x86_clang-r437112 prebuilts/clang/host/linux-x86/clang-r437112

cd device/realme/RMX2020
mv arrow_RMX2020.mk lineage_RMX2020.mk
sed -i "s/arrow/lineage/" AndroidProducts.mk
sed -i "s/arrow/lineage/" lineage_RMX2020.mk
sed -i "s/common.mk/common_full_phone.mk/" lineage_RMX2020.mk
cd "${SOURCEDIR}"

. build/envsetup.sh
lunch lineage_RMX2020-userdebug
mka clean
lunch lineage_RMX2020-userdebug
mka bacon

cd out/target/product/RMX2020
curl -sL https://git.io/file-transfer | sh
./transfer wet *.zip

exit 0
