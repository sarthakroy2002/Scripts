#!/bin/bash

# User Defined Stuff

folder="$home/user/workspace"
rom_name="Bliss"*.zip
gapps_command="WITH_GAPPS"
with_gapps="yes"
build_type="userdebug"
device_codename="RMX1801"
use_brunch="bacon"
OUT_PATH="$folder/out/target/product/${device_codename}"
lunch="blissify"
user=""
tg_username=""


# Default you can change it

ccache_location="/home2/user/ccache"

# Make Clean , options uncomment  to chose
# make_clean="yes"
# make_clean="no"
# make_clean="installclean"

# Rom being built

ROM=${OUT_PATH}/${rom_name}

# Folder specifity
cd "$folder"

# Time to build

if [ -d ${ccache_location} ]
then
        echo "Ccache folder  exists."
else
        sudo chmod -R 777 ${ccache_location}
        echo "Made Ccache Folder "
fi
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_DIR=${ccache_location}
ccache -M 75G
export TARGET_FLOS=true

source build/envsetup.sh

if [ "$with_gapps" = "yes" ];
then
export "$gapps_command"=true
export WITH_GMS=true
fi

if [ "$with_gapps" = "no" ];
then
export "$gapps_command"=false
fi



# Clean build

if [ "$make_clean" = "yes" ];
then
rm -rf out
echo -e "Clean Build";
fi

if [ "$make_clean" = "installclean" ];
then
rm -rf ${OUT_PATH}
echo -e "Install Clean";
fi

rm -rf ${OUT_PATH}/*.zip
lunch ${lunch}_${device_codename}-${build_type}



# Build Options

START=$(date +%s)
if [ "$use_brunch" = "yes" ];
then
brunch ${device_codename}
fi

if [ "$use_brunch" = "no" ];
then
make  ${lunch} -j$(nproc --all)
fi

if [ "$use_brunch" = "bacon" ];
then
make bacon

fi

END=$(date +%s)
TIME=$(echo $((${END}-${START})) | awk '{print int($1/60)" Minutes and "int($1%60)" Seconds"}')
