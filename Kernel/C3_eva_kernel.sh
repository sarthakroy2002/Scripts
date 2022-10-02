#!/usr/bin/env bash

function compile() {

	source ~/.bashrc && source ~/.profile
	export LC_ALL=C && export USE_CCACHE=1
	ccache -M 100G
	git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_arm_arm-eabi gcc
	git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-elf gcc64
	export ARCH=arm64
	export KBUILD_BUILD_HOST=neolit
	export KBUILD_BUILD_USER="sarthakroy2002"

	[ -d "out" ] && rm -rf out || mkdir -p out

	PATH="${PWD}/gcc/bin:${PATH}:${PWD}/gcc64/bin:/usr/bin:$PATH" \
		make -j$(nproc --all) O=out \
		ARCH=arm64 \
		RMX2020_defconfig \
		CROSS_COMPILE_ARM32=arm-eabi- \
		CROSS_COMPILE=aarch64-elf- \
		LD=aarch64-elf-ld.lld \
		AR=llvm-ar \
		NM=llvm-nm \
		OBJCOPY=llvm-objcopy \
		OBJDUMP=llvm-objdump \
		CC=aarch64-elf-gcc \
		STRIP=llvm-strip \
		CONFIG_DEBUG_SECTION_MISMATCH=y
}

function zupload() {
	git clone --depth=1 https://github.com/sarthakroy2002/AnyKernel3.git AnyKernel
	cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
	cd AnyKernel
	zip -r9 Test-OSS-KERNEL-RMX2020-NEOLIT.zip *
	#curl --upload-file Test-OSS-KERNEL-RMX2020-NEOLIT.zip https://transfer.sh/
	curl -sL https://git.io/file-transfer | sh
	./transfer wet Test-OSS-KERNEL-RMX2020-NEOLIT.zip
}

compile
zupload
