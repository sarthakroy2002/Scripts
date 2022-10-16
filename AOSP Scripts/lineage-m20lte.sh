#!/usr/bin/env bash

rm -rf /cache/*

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/work"

git config --global user.email "sarthakroy2002@gmail.com" && git config --global user.name "Sarthak Roy"
df -h
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

# Repo Sync
repo init -u https://github.com/LineageOS/android.git -b lineage-20.0
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

# Clone Device Trees
git clone https://github.com/riceDroid-universal7885/android_device_samsung_m20lte device/samsung/m20lte -b lineage-20
git clone https://github.com/SamarV-121/android_device_samsung_m20lte-kernel device/samsung/m20lte-kernel
git clone https://github.com/riceDroid-universal7885/android_device_samsung_universal7904-common device/samsung/universal7904-common -b lineage-20
git clone https://github.com/riceDroid-universal7885/android_kernel_samsung_universal7904 kernel/samsung/universal7904 -b lineage-20
git clone --depth=1 https://github.com/SamarV-121/proprietary_vendor_samsung vendor/samsung -b lineage-20 

# Clone Samsung Specific Repo
rm -rf hardware/samsung ; git clone https://github.com/riceDroid-universal7885/android_hardware_samsung hardware/samsung
git clone https://github.com/LineageOS/android_hardware_samsung_nfc hardware/samsung/nfc
git clone https://github.com/LineageOS/android_hardware_samsung_slsi_libbt hardware/samsung_slsi/libbt -b lineage-20
git clone https://github.com/LineageOS/android_hardware_samsung_slsi_scsc_wifibt_wifi_hal hardware/samsung_slsi/scsc_wifibt/wifi_hal -b lineage-20
git clone https://github.com/LineageOS/android_hardware_samsung_slsi_scsc_wifibt_wpa_supplicant_lib hardware/samsung_slsi/scsc_wifibt/wpa_supplicant_lib -b lineage-20
git clone https://github.com/LineageOS/android_device_samsung_slsi_sepolicy device/samsung_slsi/sepolicy -b lineage-20

# Let's Cook it
source build/envsetup.sh
lunch lineage_m20lte-userdebug
make bacon

# Upload
cd out/target/product/m20lte
curl -sL https://git.io/file-transfer | sh
./transfer wet lineage*.zip

exit
