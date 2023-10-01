#!/bin/bash

# Defconfig
if [[ -z ${KERNEL_DEFCONFIG} ]]; then
    echo -n "Enter your kernel defconfig name: "
    read -r NAME
    CONFIG=${KERNEL_DEFCONFIG}
fi

echo "Cloning dependencies"
git clone --depth=1 https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-5484270 -b 9.0 clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc32

echo "Done"
KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64

make O=out ARCH=arm64 ${CONFIG}

# Compile plox
compile() {
    make -j$(nproc) O=out \
        ARCH=arm64 \
        CC=clang \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE=aarch64-linux-android- \
        CROSS_COMPILE_ARM32=arm-linux-androideabi- $1 $2 $3
}

function zupload() {
    git clone --depth=1 https://github.com/SakthivelNadar/AnyKernel3-2.git AnyKernel
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
    cd AnyKernel
    zip -r9 StormBreaker-r1.0-yogurt.zip *
    curl -sL https://git.io/file-transfer | sh
    ./transfer wet StormBreaker-r1.0-yogurt.zip
}

compile
zupload
