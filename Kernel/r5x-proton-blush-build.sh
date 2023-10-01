#!bin/bash

# Install Required Packages
sudo apt install make bison bc libncurses5-dev tmate git python3-pip curl build-essential zip unzip -y

#Working Directory
WORK_DIR=~/

#cloning
if [ -d $WORK_DIR/Anykernel ]; then
    echo "Anykernel Directory Already Exists"
else
    git clone --depth=1 https://github.com/JaswantTeja/AnyKernel3 -b main $WORK_DIR/Anykernel
fi
if [ -d $WORK_DIR/kernel ]; then
    echo "kernel dir exists"
    echo "Pulling recent changes"
    cd $WORK_DIR/kernel && git pull
    cd ../
else
    git clone --depth=1 https://github.com/JaswantTeja/kernel_realme_r5x -b twelve $WORK_DIR/kernel
fi
if [ -d $WORK_DIR/toolchains/proton-clang ]; then
    echo "clang dir exists"
else
    mkdir $WORK_DIR/toolchains
    cd $WORK_DIR/toolchains
    git clone https://github.com/kdrag0n/proton-clang.git --depth=1 -b master proton-clang
fi
cd $WORK_DIR/kernel

# Info
DEVICE="Realme 5 Series (r5x)"
DATE=$(TZ=GMT-5:30 date +%d'-'%m'-'%y'_'%I':'%M)
VERSION=$(make kernelversion)
DISTRO=$(source /etc/os-release && echo $NAME)
CORES=$(nproc --all)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT_LOG=$(git log --oneline -n 1)
COMPILER=$($WORK_DIR/toolchains/proton-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

BUILD_START=$(date +"%s")
export ARCH=arm64
export SUBARCH=arm64
export PATH="$HOME/toolchains/proton-clang/bin:$PATH"
cd $WORK_DIR/kernel
make clean && make mrproper
make O=out r5x_defconfig
make -j$(nproc --all) O=out \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    CC=clang | tee log.txt

# Zipping Into Flashable Zip with AnyKernel
if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
    cp out/arch/arm64/boot/Image.gz-dtb $WORK_DIR/Anykernel
    cd $WORK_DIR/Anykernel
    zip -r9 Blush-r5x-$DATE.zip * -x .git README.md */placeholder
    cp $WORK_DIR/Anykernel/Blush-$DATE.zip $WORK_DIR/
    rm $WORK_DIR/Anykernel/Image.gz-dtb
    rm $WORK_DIR/Anykernel/Blush-$DATE.zip
    BUILD_END=$(date +"%s")
    DIFF=$((BUILD_END - BUILD_START))

fi
