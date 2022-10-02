#!/bin/bash

# Build info.
LUNCH="" # (MANDATORY) Lunch command , you should not leave it empty device codename get pulled from the command! e.g. lineage_ysl-userdebug
MAKE_TARGET="bacon" # (MANDATORY) Compilation target. e.g. bacon or bootimage [Default is bacon!]
USE_BRUNCH="" # (MANDATORY) yes|no Set to yes if you need to use brunch to build else no for lunch and bacon
CHATID="" # Your telegram group/channel chatid
API_BOT="" # Your HTTP API bot token

# Colour setup
red=$(tput setaf 1)
grn=$(tput setaf 2)
ylw=$(tput setaf 3)
txtbld=$(tput bold)
txtrst=$(tput sgr0)
bldgrn=${txtbld}$(tput setaf 2)

DEVICE="$(sed -e "s/^.*_//" -e "s/-.*//" <<< "$LUNCH")"
ROM_NAME="$(sed -e "s/_.*//" <<< "$LUNCH")"
OUT="$(pwd)/out/target/product/$DEVICE"
ERROR_LOG="out/error.log"

# Parameters
while [[ $# -gt 0 ]]
do

case $1 in
    -s|--sync)
    SYNC="1"
    ;;
    -c|--clean)
    CLEAN="1"
    ;;
    -i|--installclean)
    INSTALLCLEAN="1"
    ;;
    -h|--help)
    echo -e "\nNote: • You should specify all the mandatory variables in the script!
      • Just run './$0' for normal build
Usage: ./build_rom.sh [OPTION]
Example:
    ./$0 -s -c or ./$0 --sync --clean

Mandatory options:
    No option is mandatory!, just simply run the script without passing any parameter.

Options:
    -s, --sync            Sync sources before building.
    -c, --clean           Clean build directory before compilation
    -i, --installclean    Make installclean.\n"
    exit 1
    ;;
    *) echo -e "$red\nUnknown parameter passed: $1$txtrst\n"
    exit 1
    ;;
esac
shift
done

# Exit if mandatory variables are not specified
if [[ $LUNCH == "" ]] || [[ $USE_BRUNCH == "" ]] || [[ $MAKE_TARGET == "" ]]; then
	echo -e "$red\nBRUH: Specify all mandatory variables! Exiting...$txtrst\n"
	exit 1
fi

# Setup Telegram Env
export BOT_MSG_URL="https://api.telegram.org/bot$API_BOT/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$API_BOT/sendDocument"

message() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html"
}

# Setup we.tl
up(){
	curl -sL https://git.io/file-transfer | sh
	./transfer wet $1 | tee -a upload.log
}

# Clean old logs if found
if [ -f "$ERROR_LOG" ]; then
	rm "$ERROR_LOG"
fi

if [ -f log.txt ]; then
	rm log.txt
fi

if [ -f upload.log ]; then
	rm upload.log
fi

# Do if specified
if [[ -n $SYNC ]]; then
	echo -e "$bldgrn\nSyncing sources...$txtrst\n"
	if ! repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all); then
	echo -e "$red\nSyncing failed!$txtrst" && echo -e "$bldgrn\nStarting build...$txtrst\n"
	fi
fi

if [[ -n $CLEAN ]]; then
	echo -e "$bldgrn\nClearing out directory...$txtrst\n"
	rm -rf out
fi

if [[ -n $INSTALLCLEAN ]]; then
	echo -e "$bldgrn\nMaking installclean...$txtrst\n"
	. build/envsetup.sh && make installclean
fi

# Send build start message on tg
read -r -d '' start <<EOT
<b>Build status: Started</b>

<b>Rom:</b> <code>$ROM_NAME</code>
<b>Device:</b> <code>$DEVICE</code>
<b>Source directory:</b> <code>$(pwd)</code>
<b>Make target:</b> <code>$MAKE_TARGET</code>
EOT

message "$start" "$CHATID"

START=$(TZ=Asia/Kolkata date +"%s")

# Build
if [ "$USE_BRUNCH" == yes ]; then
	echo -e "$bldgrn\nSetting up build environment...$txtrst"
        source build/envsetup.sh

	echo -e "$bldgrn\nLunching $DEVICE...$txtrst"
        lunch "$LUNCH"

	 if [ $? -eq 0 ]; then
                echo -e "$bldgrn\nStarting build...$txtrst"
                brunch "$DEVICE" | tee log.txt
        else
                echo -e "$bldgrn\nLunching $DEVICE failed...$txtrst"
                message "<b>Build status: Failed</b>%0A%0A<b>Failed at lunching $DEVICE!</b>" "$CHATID"
                exit 1
        fi

else
	echo -e "$bldgrn\nSetting up build environment...$txtrst"
        source build/envsetup.sh

	echo -e "$bldgrn\nLunching $DEVICE...$txtrst"
        lunch "$LUNCH"

	if [ $? -eq 0 ]; then
		echo -e "$bldgrn\nStarting build...$txtrst"
	        make "$MAKE_TARGET" | tee log.txt
	else
		echo -e "$bldgrn\nLunching $DEVICE failed...$txtrst"
		message "<b>Build status: Failed</b>%0A%0A<b>Failed at lunching $DEVICE!</b>" "$CHATID"
		exit 1
	fi
fi

# Upload Build
END=$(TZ=Asia/Kolkata date +"%s")
DIFF=$(( END - START ))
HOURS=$(($DIFF / 3600 ))
MINS=$((($DIFF % 3600) / 60))

if [ -s out/error.log ]; then
	read -r -d '' failed <<EOT
	<b>Build status: Failed</b>%0A%0ACheck log below!
EOT
	message "$failed" "$CHATID"
	error "$ERROR_LOG" "$CHATID"

else
	if [[ $MAKE_TARGET == bacon ]]; then
		ZIP_PATH=$(ls "$OUT"/*2022*.zip | grep -vE 'ota|OTA' | tail -n -1)
		echo -e "$bldgrn\nUploading zip...$txtrst\n"
		zip=$(up $ZIP_PATH)
		filename="$(basename $ZIP_PATH)"
		md5sum=$(md5sum $ZIP_PATH | awk '{print $1}')
		size=$(ls -sh $ZIP_PATH | awk '{print $1}')
		url=$(cat upload.log | grep 'Download' | awk '{ print $3 }')

		read -r -d '' final <<EOT
		<b>Build status: Completed</b>%0A<b>Time elapsed:</b> <i>$HOURS hours and $MINS minutes</i>%0A%0A<b>Size:</b> <code>$size</code>%0A<b>MD5:</b> <code>$md5sum</code>%0A<b>Download:</b> <a href="$url">${filename}</a>
EOT
		message "$final" "$CHATID"
		error "log.txt" "$CHATID"

	else
		message "<b>Build status: Completed</b>%0A<b>Time elapsed:</b> <i>$HOURS hours and $MINS minutes</i>%0A%0A<b>$MAKE_TARGET compiled successfully!</b>" "$CHATID"
		error "log.txt" "$CHATID"
	fi
fi
