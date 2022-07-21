#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
rm -rf "${SOURCEDIR}"
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"
export ALLOW_MISSING_DEPENDENCIES=true
repo init --depth=1 -u https://github.com/LineageOS/android.git -b lineage-19.1
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

cd frameworks/base
git fetch https://github.com/realme-mt6785-devs/android_frameworks_base
git cherry-pick d8a4c380212fd9fdf3e92c04578b8c0e14d8f1aa
git cherry-pick c21a0f11773774329c4094238d1e0a4adc160b81
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/Fix-brightness-slider-curve-for-some-devices-a12l.patch
patch -p1 < *.patch
cd ../..

cd frameworks/av
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/11/17011/1
git cherry-pick FETCH_HEAD
git fetch https://review.arrowos.net/ArrowOS/android_frameworks_av refs/changes/99/16799/1
git cherry-pick FETCH_HEAD
cd ../..

cd system/core
git fetch https://review.arrowos.net/ArrowOS/android_system_core refs/changes/00/16200/1
git cherry-pick FETCH_HEAD
cd ../..

cd frameworks/opt/net/ims
git fetch https://github.com/AOSP-12-RMX2020/frameworks_opt_net_ims
git cherry-pick 4f35ccb8bf0362c31bf5f074bcb7070da660412a^..3fe1cb7b6b2673adfce2b9232dfaf81375398efb 
cd ../../../..

cd packages/modules/Wifi
git fetch https://github.com/AOSP-12-RMX2020/packages_modules_Wifi
git cherry-pick c6e404695bc451a9667f4893501ef8fe78e1a0b7^..90fc3f6781171dc27fed16b60575f9ea62f02e7a
cd ../../..

cd frameworks/opt/telephony
git fetch https://github.com/phhusson/platform_frameworks_opt_telephony android-12.0.0_r26-phh
git cherry-pick 6f116d4cdb716072261ecfe532da527182f6dad6
cd ../../..

cd vendor/lineage
wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/0001-Device-Specific-patches.patch
patch -p1 < *.patch
cd ../..

git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020.git vendor/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/device_realme_RMX2020.git device/realme/RMX2020
git clone --depth=1 https://github.com/ArrowOS-Devices/android_kernel_realme_RMX2020 kernel/realme/RMX2020
git clone --depth=1 https://github.com/sarthakroy2002/vendor_realme_RMX2020-ims -b twelve-rmui1 vendor/realme/RMX2020-ims
git clone --depth=1 https://github.com/ArrowOS/android_device_mediatek_sepolicy_vndr -b arrow-12.1 device/mediatek/sepolicy_vndr

cd device/realme/RMX2020
mv arrow_RMX2020.mk lineage_RMX2020.mk
sed -i "s/arrow/lineage/" AndroidProducts.mk 
sed -i "s/arrow/lineage/" lineage_RMX2020.mk
sed -i "s/common.mk/common_full_phone.mk/" lineage_RMX2020.mk
cd ../../..

. build/envsetup.sh
lunch lineage_RMX2020-userdebug
mka clean
lunch lineage_RMX2020-userdebug
mka bacon

cd out/target/product/RMX2020
curl -sL https://git.io/file-transfer | sh
./transfer wet *.zip

exit 0
