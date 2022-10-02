#!/usr/bin/env bash

# Dependencies
deps() {
	echo "Cloning dependencies"

	if [ ! -d "clang" ]; then
		if [ "${BRANCH}" = "R" ] || [ "${BRANCH}" = "arrow-13.0-llvm" ]; then
			mkdir clang && cd clang
			bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S=latest
			sudo apt install libelf-dev libarchive-tools
			bash -c "$(wget -O - https://gist.githubusercontent.com/dakkshesh07/240736992abf0ea6f0ee1d8acb57a400/raw/e97b505653b123b586fc09fda90c4076c8030732/patch-for-old-glibc.sh)"
			cd ..
			KBUILD_COMPILER_STRING="Neutron Clang"
		else
			git clone --depth=1 https://github.com/sarthakroy2002/android_prebuilts_clang_host_linux-x86_clang-r437112 clang
			KBUILD_COMPILER_STRING="Clang 14.0.0"

			if [ ! -d "los-4.9-64" ]; then
				git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 los-4.9-64
			fi

			if [ ! -d "los-4.9-32" ]; then
				git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 los-4.9-32
			fi
		fi
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
if [ "${BRANCH}" = "R" ]; then
	PATH="${PWD}/clang/bin:${PATH}"
else
	PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}"
fi
export KBUILD_COMPILER_STRING
ARCH=arm64
export ARCH
KBUILD_BUILD_HOST=neolit
export KBUILD_BUILD_HOST
KBUILD_BUILD_USER="sarthakroy2002"
export KBUILD_BUILD_USER
if [ "${BRANCH}" = "arrow-12.1" ]; then
	REPO_URL="https://github.com/ArrowOS-Devices/android_kernel_realme_RMX2020"
elif [ "${BRANCH}" = "arrow-13.0" ]; then
	REPO_URL="https://github.com/ArrowOS-Devices/android_kernel_realme_RMX2020"
else
	REPO_URL="https://github.com/sarthakroy2002/kernel_realme_RMX2020"
fi
export REPO_URL
DEVICE="Realme C3/Narzo 10A"
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

# sticker plox
sticker() {
	curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
		-d sticker="CAACAgQAAxkBAAED3JFiApkFOuZg8zt0-WNrfEGwrvoRuAACAQoAAoEcoFINevKyLXEDhSME" \
		-d chat_id="${chat_id}"
}
# Send info plox channel
sendinfo() {
	tg "
• NEOLIT CI Build •
*Building on*: \`Github actions\`
*Date*: \`${DATE}\`
*Device*: \`${DEVICE} (${CODENAME})\`
*Branch*: \`$(git rev-parse --abbrev-ref HEAD)\`
*Last Commit*: [${COMMIT_HASH}](${REPO_URL}/commit/${COMMIT_HASH})
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

	if [ "${BRANCH}" = "R" ] || [ "${BRANCH}" = "arrow-13.0-llvm" ]; then
		make -j"${PROCS}" O=out \
			ARCH=$ARCH \
			CC="clang" \
			CROSS_COMPILE=aarch64-linux-gnu- \
			CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
			LLVM=1 \
			LLVM_IAS=1 \
			LD=ld.lld \
			AR=llvm-ar \
			NM=llvm-nm \
			OBJCOPY=llvm-objcopy \
			OBJDUMP=llvm-objdump \
			STRIP=llvm-strip
		CONFIG_NO_ERROR_ON_MISMATCH=y
	else
		make -j"${PROCS}" O=out \
			ARCH=$ARCH \
			CC="clang" \
			CLANG_TRIPLE=aarch64-linux-gnu- \
			CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-android-" \
			CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-androideabi-" \
			CONFIG_NO_ERROR_ON_MISMATCH=y
	fi

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
	zip -r9 NEOLIT-Test-OSS-"${BRANCH}"-KERNEL-"${CODENAME}"-"${DATE}".zip ./*
	curl -sL https://git.io/file-transfer | sh
	./transfer wet NEOLIT-Test-OSS-"${BRANCH}"-KERNEL-"${CODENAME}"-"${DATE}".zip
	cd ..
}

deps
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$((END - START))
push
