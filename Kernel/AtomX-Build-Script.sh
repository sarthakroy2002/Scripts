#!/usr/bin/env bash

#########################    CONFIGURATION    ##############################

# User details
KBUILD_USER="$USER"
KBUILD_HOST=$(uname -n)

############################################################################

########################   DIRECTORY PATHS   ###############################

# Kernel Directory
KERNEL_DIR=$(pwd)

# Propriatary Directory (default paths may not work!)
PRO_PATH="$KERNEL_DIR/.."

# Toolchain Directory
TLDR="$PRO_PATH/toolchains"

# Anykernel Directories
AK3_DIR="$PRO_PATH/AnyKernel3"
AKVDR="$AK3_DIR/modules/vendor/lib/modules"
AKVRD="$AK3_DIR/vendor_ramdisk/lib/modules"

# Device Tree Blob Directory
DTB_PATH="$KERNEL_DIR/work/arch/arm64/boot/dts/vendor/qcom"

############################################################################

###############################   COLORS   #################################

R='\033[1;31m'
G='\033[1;32m'
B='\033[1;34m'
W='\033[1;37m'

############################################################################

################################   MISC   ##################################

# functions
error() {
    echo -e ""
    echo -e "$R ${FUNCNAME[0]}: $W" "$@"
    echo -e ""
    exit 1
}

success() {
    echo -e ""
    echo -e "$G ${FUNCNAME[1]}: $W" "$@"
    echo -e ""
    exit 0
}

inform() {
    echo -e ""
    echo -e "$B ${FUNCNAME[1]}: $W" "$@" "$G"
    echo -e ""
}

muke() {
    if [[ -z $COMPILER || -z $COMPILER32 ]]; then
        error "Compiler is missing"
    fi
    if [[ $LOG != 1 ]]; then
        make "${MAKE_ARGS[@]}" "$@"
    else
        make "$@" "${MAKE_ARGS[@]}" 2>&1 | tee log.txt
    fi
}

usage() {
    inform " ./AtomX.sh <arg>
		--compiler   Sets the compiler to be used.
		--compiler32 Sets the 32bit compiler to be used,
					 (defaults to clang).
		--device     Sets the device for kernel build.
		--clean      Clean up build directory before running build,
					 (default behaviour is incremental).
		--dtbs       Builds dtbs, dtbo & dtbo.img.
		--dtb_zip    Builds flashable zip with dtbs, dtbo.
		--obj        Builds specified objects.
		--regen      Regenerates defconfig (savedefconfig).
		--log        Builds logs saved to log.txt in current dir.
		--silence    Silence shell output of Kbuild".
    exit 2
}

############################################################################

compiler_setup() {
    ############################  COMPILER SETUP  ##############################
    # default to clang
    CC='clang'
    C_PATH="$TLDR/$CC"
    LLVM_PATH="$C_PATH/bin"
    if [[ $COMPILER == gcc ]]; then
        # Just override the existing declarations
        CC='aarch64-elf-gcc'
        C_PATH="$TLDR/gcc-arm64"
    fi

    C_NAME=$("$LLVM_PATH"/$CC --version | head -n 1 | perl -pe 's/\(http.*?\)//gs')
    if [[ $COMPILER32 == "gcc" ]]; then
        MAKE_ARGS+=("CC_COMPAT=$TLDR/gcc-arm/bin/arm-eabi-gcc" "CROSS_COMPILE_COMPAT=$TLDR/gcc-arm/bin/arm-eabi-")
        C_NAME_32=$($(echo "${MAKE_ARGS[@]}" | sed s/' '/'\n'/g | grep CC_COMPAT | cut -c 11-) --version | head -n 1)
    else
        MAKE_ARGS+=("CROSS_COMPILE_COMPAT=arm-linux-gnueabi-")
        C_NAME_32="$C_NAME"
    fi

    MAKE_ARGS+=("O=work"
        "ARCH=arm64"
        "DTC_EXT=$(which dtc)"
        "LLVM=$LLVM_PATH"
        "HOSTLD=ld.lld" "CC=$CC"
        "PATH=$C_PATH/bin:$PATH"
        "KBUILD_BUILD_USER=$KBUILD_USER"
        "KBUILD_BUILD_HOST=$KBUILD_HOST"
        "CROSS_COMPILE=aarch64-linux-gnu-"
        "LD_LIBRARY_PATH=$C_PATH/lib:$LD_LIBRARY_PATH")
    ############################################################################
}

config_generator() {
    #########################  .config GENERATOR  ############################
    if [[ -z $CODENAME ]]; then
        error 'Codename not present connot proceed'
        exit 1
    fi

    DFCF="vendor/${CODENAME}-${SUFFIX}_defconfig"
    if [[ ! -f arch/arm64/configs/$DFCF ]]; then
        inform "Generating defconfig"

        export "${MAKE_ARGS[@]}" "TARGET_BUILD_VARIANT=user"

        bash scripts/gki/generate_defconfig.sh "${CODENAME}-${SUFFIX}_defconfig"
        muke vendor/"${CODENAME}"-"${SUFFIX}"_defconfig vendor/lahaina_QGKI.config
    else
        inform "Generating .config"

        # Make .config
        muke "$DFCF"
    fi
    if [[ $TEST == "1" ]]; then
        ./scripts/config --file work/.config -d CONFIG_LTO_CLANG
        ./scripts/config --file work/.config -d CONFIG_HEADERS_INSTALL
    fi
    ############################################################################
}

config_regenerator() {
    ########################  DEFCONFIG REGENERATOR  ###########################
    config_generator

    inform "Regenerating defconfig"

    muke savedefconfig

    cat work/defconfig >arch/arm64/configs/"$DFCF"

    success "Regeneration completed"
    ############################################################################
}

obj_builder() {
    ##############################  OBJ BUILD  #################################
    if [[ $OBJ == "" ]]; then
        error "obj not defined"
    fi

    config_generator

    inform "Building $OBJ"
    if [[ $OBJ =~ "defconfig" ]]; then
        muke "$OBJ"
    else
        muke -j"$(nproc)" INSTALL_HDR_PATH="headers" "$OBJ"
    fi
    if [[ $TEST == "1" ]]; then
        rm -rf arch/arm64/configs/vendor/lahaina-qgki_defconfig
    fi
    if [[ $DTB_ZIP != "1" ]]; then
        exit 0
    fi
    ############################################################################
}

dtb_zip() {
    ##############################  DTB BUILD  #################################
    obj_builder
    source work/.config
    if [[ ! -d $AK3_DIR ]]; then
        error 'Anykernel not present cannot zip'
    fi
    if [[ ! -d "$KERNEL_DIR/out" ]]; then
        mkdir "$KERNEL_DIR"/out
    fi
    cp "$DTB_PATH"/*.dtb "$AK3_DIR"/dtb
    cp "$DTB_PATH"/*.img "$AK3_DIR"/
    cd "$AK3_DIR" || exit
    make zip VERSION="$(echo "$CONFIG_LOCALVERSION" | cut -c 8-)-dtbs-only"
    cp ./*-signed.zip "$KERNEL_DIR"/out
    make clean
    cd "$KERNEL_DIR" || exit
    success "dtbs zip built"
    ############################################################################
}

kernel_builder() {
    ##################################  BUILD  #################################
    if [[ $BUILD == "clean" ]]; then
        inform "Cleaning work directory, please wait...."
        muke -s clean mrproper distclean
    fi

    config_generator

    # Build Start
    BUILD_START=$(date +"%s")

    source work/.config
    MOD_NAME="$(muke kernelrelease -s)"
    KERNEL_VERSION=$(echo "$MOD_NAME" | cut -c -7)

    inform "
	*************Build Triggered*************
	Date: $(date +"%Y-%m-%d %H:%M")
	Linux Version: $KERNEL_VERSION
	Kernel Name: $MOD_NAME
	Device: $DEVICENAME
	Codename: $CODENAME
	Compiler: $C_NAME
	Compiler_32: $C_NAME_32
	"

    # Compile
    muke -j"$(nproc)"

    if [[ $CONFIG_MODULES == "y" ]]; then
        muke -j"$(nproc)" \
            'modules_install' \
            INSTALL_MOD_STRIP=1 \
            INSTALL_MOD_PATH="modules"
    fi

    # Build End
    BUILD_END=$(date +"%s")

    DIFF=$(("$BUILD_END" - "$BUILD_START"))

    zipper
    ############################################################################
}

zipper() {
    ####################################  ZIP  #################################
    TARGET="$(muke image_name -s)"

    if [[ ! -f $KERNEL_DIR/work/$TARGET ]]; then
        error 'Kernel image not found'
    fi
    if [[ ! -d $AK3_DIR ]]; then
        error 'Anykernel not present cannot zip'
    fi
    if [[ ! -d "$KERNEL_DIR/out" ]]; then
        mkdir "$KERNEL_DIR"/out
    fi

    # Making sure everything is ok before making zip
    cd "$AK3_DIR" || exit
    make clean
    cd "$KERNEL_DIR" || exit

    cp "$KERNEL_DIR"/work/"$TARGET" "$AK3_DIR"
    cp "$DTB_PATH"/*.dtb "$AK3_DIR"/dtb
    cp "$DTB_PATH"/*.img "$AK3_DIR"/
    if [[ $CONFIG_MODULES == "y" ]]; then
        MOD_PATH="work/modules/lib/modules/$MOD_NAME"
        sed -i 's/\(kernel\/[^: ]*\/\)\([^: ]*\.ko\)/\/vendor\/lib\/modules\/\2/g' "$MOD_PATH"/modules.dep
        sed -i 's/.*\///g' "$MOD_PATH"/modules.order
        if [[ $DRM_VENDOR_MODULE == "1" ]]; then
            DRM_AS_MODULE=1
            if [ ! -d "$AK3_DIR"/vendor_ramdisk/lib/modules/ ]; then
                VENDOR_RAMDISK_CREATE=1
                mkdir -p "$AK3_DIR"/vendor_ramdisk/lib/modules/
            fi
            mv "$(find "$MOD_PATH" -name 'msm_drm.ko')" "$AKVRD"
            grep drm "$MOD_PATH/modules.alias" >"$AKVRD"/modules.alias
            grep drm "$MOD_PATH/modules.dep" | sed 's/^........//' >"$AKVRD"/modules.dep
            grep drm "$MOD_PATH/modules.softdep" >"$AKVRD"/modules.softdep
            grep drm "$MOD_PATH/modules.order" >"$AKVRD"/modules.load
            sed -i s/split_boot/dump_boot/g "$AK3_DIR"/anykernel.sh
        fi
        cp $(find "$MOD_PATH" -name '*.ko') "$AKVDR"/
        cp "$MOD_PATH"/modules.{alias,dep,softdep} "$AKVDR"/
        cp "$MOD_PATH"/modules.order "$AKVDR"/modules.load
    fi

    LAST_COMMIT=$(git show -s --format=%s)
    LAST_HASH=$(git rev-parse --short HEAD)

    cd "$AK3_DIR" || exit

    make zip VERSION="$(echo "$CONFIG_LOCALVERSION" | cut -c 8-)"
    if [ "$DRM_AS_MODULE" = "1" ]; then
        if [ "$VENDOR_RAMDISK_CREATE" = "1" ]; then
            rm -rf "$AK3_DIR"/vendor_ramdisk/
        fi
        sed -i s/'dump_boot; # skip unpack'/'split_boot; # skip unpack'/g "$AK3_DIR"/anykernel.sh
    fi

    inform "
	*************AtomX-Kernel*************
	Linux Version: $KERNEL_VERSION
	CI: $KBUILD_HOST
	Core count: $(nproc)
	Compiler: $C_NAME
	Compiler_32: $C_NAME_32
	Device: $DEVICENAME
	Codename: $CODENAME
	Build Date: $(date +"%Y-%m-%d %H:%M")
	Build Type: $BUILD_TYPE

	-----------last commit details-----------
	Last commit (name): $LAST_COMMIT

	Last commit (hash): $LAST_HASH
	"

    cp ./*-signed.zip "$KERNEL_DIR"/out

    make clean

    cd "$KERNEL_DIR" || exit

    success "build completed in $((DIFF / 60)).$((DIFF % 60)) mins"

    ############################################################################
}

###############################  COMMAND_MODE  ##############################
if [[ -z $* ]]; then
    usage
fi
if [[ $* =~ "--log" ]]; then
    LOG=1
fi
if [[ $* =~ "--silence" ]]; then
    MAKE_ARGS+=("-s")
fi
for arg in "$@"; do
    case "${arg}" in
        "--compiler="*)
            COMPILER=${arg#*=}
            COMPILER=${COMPILER,,}
            if [[ -z $COMPILER ]]; then
                usage
                break
            fi
            ;&
        "--compiler32="*)
            COMPILER32=${arg#*=}
            COMPILER32=${COMPILER32,,}
            if [[ -z $COMPILER32 ]]; then
                COMPILER32="clang"
            fi
            compiler_setup
            ;;
        "--device="*)
            CODE_NAME=${arg#*=}
            case $CODE_NAME in
                lisa)
                    DEVICENAME='Xiaomi 11 lite 5G NE'
                    CODENAME='lisa'
                    SUFFIX='qgki'
                    TARGET='Image'
                    ;;
                *)
                    error 'device not supported'
                    ;;
            esac
            ;;
        "--clean")
            BUILD='clean'
            ;;
        "--test")
            TEST='1'
            CODENAME=lahaina
            ;;
        "--dtb_zip")
            DTB_ZIP=1
            ;&
        "--dtbs")
            OBJ=dtbs
            dtb_zip
            ;;
        "--obj="*)
            OBJ=${arg#*=}
            obj_builder
            ;;
        "--regen")
            config_regenerator
            ;;
    esac
done
############################################################################

kernel_builder
