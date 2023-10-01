#!/usr/bin/env bash

# Dependencies
deps() {
	echo "Cloning dependencies"

	if [ ! -d "clang" ]; then
			mkdir clang && cd clang
            sudo apt install libelf-dev libarchive-tools
            bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S
            bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) --patch=glibc
			ls
			cd ..
			KBUILD_COMPILER_STRING="Neutron Clang"
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
DEVICE="Realme 6/7/Narzo 30 (Realme Wasabi/RM6785)"
export DEVICE
CODENAME="RM6785"
export CODENAME
DEFCONFIG="wasabi_defconfig"
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

# sticker plox
sticker() {
	curl -s -X POST https://api.telegram.org/bot"${token}"/sendSticker \
		-d sticker="CAACAgQAAxkBAAED3JFiApkFOuZg8zt0-WNrfEGwrvoRuAACAQoAAoEcoFINevKyLXEDhSME" \
		-d chat_id="${chat_id}"
}
# Send info plox channel
sendinfo() {
	tg "
• neOliT CI Build •
*Building on*: \`Github actions\`
*Date*: \`${DATE}\`
*Device*: \`${DEVICE} (${CODENAME})\`
*Last Commit*: [${COMMIT_HASH}](${REPO}/commit/${COMMIT_HASH})
*Compiler*: \`${KBUILD_COMPILER_STRING}\`
*Build Status*: \`${STATUS}\`"
}
# Push kernel to channel
push() {
	cd AnyKernel || exit 1
	ZIP=$(echo *.zip)
	tgs "${ZIP}" "Build took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s). | For *${DEVICE} (${CODENAME})* | ${KBUILD_COMPILER_STRING}"
}
# Find Error
finderr() {
	curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
		-d chat_id="$chat_id" \
		-d "disable_web_page_preview=true" \
		-d "parse_mode=markdown" \
		-d sticker="CAACAgIAAxkBAAED3JViAplqY4fom_JEexpe31DcwVZ4ogAC1BAAAiHvsEs7bOVKQsl_OiME" \
		-d text="Build throw an error(s)"
	exit 1
}
# Compile plox
compile() {

	if [ -d "out" ]; then
		rm -rf out && mkdir -p out
	fi

	make O=out ARCH="${ARCH}" "${DEFCONFIG}"

	make -j"${PROCS}" O=out \
			ARCH=$ARCH \
			CC="clang" \
			CROSS_COMPILE=aarch64-linux-gnu- \
			CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
            LLVM=1 \
			LD=ld.lld \
			AR=llvm-ar \
			NM=llvm-nm \
			OBJCOPY=llvm-objcopy \
			OBJDUMP=llvm-objdump \
			STRIP=llvm-strip \
			CONFIG_NO_ERROR_ON_MISMATCH=y

	if ! [ -a "$IMAGE" ]; then
		finderr
		exit 1
	fi
	
	git clone --depth=1 https://github.com/sarthakroy2002/AnyKernel3.git -b RMX2001 AnyKernel
	cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
zipping() {
	cd AnyKernel || exit 1
	zip -r9 neOliT-Test-OSS-KERNEL-"${CODENAME}"-"${DATE}".zip ./*
	cd ..
}

deps
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$((END - START))
push
