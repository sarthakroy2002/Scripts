#!/usr/bin/env bash

# Dependencies
deps() {
    echo "Cloning dependencies"
    if [ ! -d "clang" ]; then
        wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-14.0.0_r2/clang-r487747c.tar.gz -O "aosp-clang.tar.gz"
        mkdir clang && tar -xf aosp-clang.tar.gz -C clang && rm -rf aosp-clang.tar.gz
        KBUILD_COMPILER_STRING="Clang 17.0.2 r487747c"
        PATH="${PWD}/clang/bin:${PATH}"
    fi
    sudo apt install -y ccache
    echo "Done"
}

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%Y%m%d-%H%M")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
CACHE=1
export CACHE
export KBUILD_COMPILER_STRING
ARCH=arm64
export ARCH
KBUILD_BUILD_HOST="neOliT"
export KBUILD_BUILD_HOST
KBUILD_BUILD_USER="sarthakroy2002"
export KBUILD_BUILD_USER
DEVICE="Realme C3/Narzo 10A (Realme Monet)"
export DEVICE
CODENAME="RMX2020"
export CODENAME
DEFCONFIG="RMX2020_defconfig"
export DEFCONFIG
COMMIT_HASH=$(git rev-parse --short HEAD)
export COMMIT_HASH
PROCS=$(nproc --all)
export PROCS
STATUS=BETA
export STATUS
source "${HOME}"/.bashrc && source "${HOME}"/.profile
if [ $CACHE = 1 ]; then
    ccache -M 100G
    export USE_CCACHE=1
fi
LC_ALL=C
export LC_ALL

tg() {
    curl -sX POST https://api.telegram.org/bot"${token}"/sendMessage -d chat_id="${chat_id}" -d parse_mode=Markdown -d disable_web_page_preview=true -d text="$1" &>/dev/null
}

tgs() {
    MD5=$(md5sum "$1" | cut -d' ' -f1)
    curl -fsSL -X POST -F document=@"$1" https://api.telegram.org/bot"${token}"/sendDocument \
        -F "chat_id=${chat_id}" \
        -F "parse_mode=Markdown" \
        -F "caption=$2 | *MD5*: \`$MD5\`"
}

# Sticker
sticker() {
    curl -s -X POST https://api.telegram.org/bot"${token}"/sendSticker \
        -d sticker="CAACAgUAAxkBAAEKwfdlVQiHDyeU33wu71hiEWMeemBHhAACTAUAAgjXqFdZ0rpx15brLTME" \
        -d chat_id="${chat_id}"
}

# Error Sticker
error_sticker() {
    curl -s -X POST https://api.telegram.org/bot"${token}"/sendSticker \
        -d sticker="CAACAgQAAxkBAAEKxCplVkvohpIHdto0Sq0FNnsjpiFN6AACQAoAAmfRmFBaWxhVsThPHDME" \
        -d chat_id="${chat_id}"
}

# Send Build Info
sendinfo() {
    tg "
• neOliT CI Build •
*Building on*: \`Github actions\`
*Date*: \`${DATE}\`
*Device*: \`${DEVICE} (${CODENAME})\`
*Branch*: \`$(git rev-parse --abbrev-ref HEAD)\`
*Last Commit*: [${COMMIT_HASH}](${REPO}/commit/${COMMIT_HASH})
*Compiler*: \`${KBUILD_COMPILER_STRING}\`
*Build Status*: \`${STATUS}\`"
    sticker
}

# Push kernel to channel
push() {
    cd AnyKernel || exit 1
    ZIP=$(echo *.zip)
    tgs "${ZIP}" "Build took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s). | For *${DEVICE} (${CODENAME})* | ${KBUILD_COMPILER_STRING}"
}

# Catch Error
finderr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d sticker="CAACAgIAAxkBAAED3JViAplqY4fom_JEexpe31DcwVZ4ogAC1BAAAiHvsEs7bOVKQsl_OiME" \
        -d text="Build throw an error(s)"
    error_sticker
    exit 1
}

# Compile
compile() {

    if [ -d "out" ]; then
        rm -rf out && mkdir -p out
    fi

    make O=out ARCH="${ARCH}" "${DEFCONFIG}"
    make -j"${PROCS}" O=out \
        ARCH=$ARCH \
        CC="clang" \
        LLVM=1 \
        CONFIG_NO_ERROR_ON_MISMATCH=y

    if ! [ -a "$IMAGE" ]; then
        finderr
        exit 1
    fi

    git clone --depth=1 https://github.com/sarthakroy2002/AnyKernel3.git AnyKernel
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
zipping() {
    cd AnyKernel || exit 1
    zip -r9 neOliT-Test-OSS-"${BRANCH}"-RUI2-KERNEL-"${CODENAME}"-"${DATE}".zip ./*
    cd ..
}

deps
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$((END - START))
push
