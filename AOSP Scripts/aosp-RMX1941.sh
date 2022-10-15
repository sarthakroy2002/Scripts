#!/usr/bin/env bash
  
  rm -rf /cache/*
  
  BASE_DIR="$(pwd)"
  SOURCEDIR="${BASE_DIR}/work"
  
  git config --global user.email "ok.ano0s6090@gmail.com" && git config --global user.name "ok-ano0s"
  df -h
  mkdir -p "${SOURCEDIR}"
  cd "${SOURCEDIR}"
  
  repo init -u https://github.com/PixelExperience/manifest -b twelve
  repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
  
  rm -rf external/selinux
  git clone https://github.com/CipherOS/android_external_selinux -b twelve-L external/selinux
  
  cd frameworks/opt/net/ims
  git remote add pick https://github.com/AOSP-12-RMX2020/frameworks_opt_net_ims
  git fetch pick
  git cherry-pick 4f35ccb8bf0362c31bf5f074bcb7070da660412a^..3fe1cb7b6b2673adfce2b9232dfaf81375398efb
  cd ../../../..
  
  cd packages/modules/Wifi
  git remote add pick https://github.com/AOSP-12-RMX2020/packages_modules_Wifi
  git fetch pick
  git cherry-pick c6e404695bc451a9667f4893501ef8fe78e1a0b7^..90fc3f6781171dc27fed16b60575f9ea62f02e7a
  cd ../../..
  
  cd frameworks/opt/telephony
  git remote add pick https://github.com/phhusson/platform_frameworks_opt_telephony
  git fetch pick
  git cherry-pick 6f116d4cdb716072261ecfe532da527182f6dad6
  cd ../../..
  
  cd frameworks/base
  wget https://raw.githubusercontent.com/sarthakroy2002/random-stuff/main/Patches/Fix-brightness-slider-curve-for-some-devices-a12l.patch
  patch -p1 < *.patch
  cd ../..
  
  cd "${SOURCEDIR}"
  
  git clone https://github.com/ok-ano0s/android_device_realme_RMX1941 device/realme/RMX1941
  git clone --depth=1 https://github.com/ok-ano0s/android_vendor_realme_RMX1941.git vendor/realme/RMX1941
  git clone --depth=1 https://github.com/P-Salik/android_kernel_realme_karashi.git kernel/realme/RMX1941
  git clone https://github.com/Realme-G70-Series/android_packages_apps_RealmeParts packages/apps/RealmeParts
  git clone https://github.com/Realme-G70-Series/android_packages_apps_RealmeDirac packages/apps/RealmeDirac
  git clone https://github.com/ok-ano0s/android_vendor_realme_RMX1941-ims vendor/realme/RMX1941-ims
  git clone https://github.com/ArrowOS/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr
  
  source build/envsetup.sh
  lunch aosp_RMX1941-userdebug
  mka bacon
  
  cd out/target/product/RMX1941
  curl -sL https://git.io/file-transfer | sh
  ./transfer wet Pixel*.zip
  
  exit 0