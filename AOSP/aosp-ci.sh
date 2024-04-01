#!/bin/bash

# Script Configuration. Adjust the variables as per your needs.
CONFIG_LUNCH=""                                  # (MANDATORY) Lunch command , you should not leave it empty device codename get pulled from the command! e.g. lineage_ysl-userdebug
CONFIG_TARGET="bacon"                                             # (MANDATORY) Compilation target. e.g. bacon or bootimage [Default is bacon!]
CONFIG_USE_BRUNCH="no"                                            # (MANDATORY) yes|no Set to yes if you need to use brunch to build else no for lunch and bacon
CONFIG_CHATID="-"                                    # Your telegram group/channel chatid
CONFIG_BOT_TOKEN="" # Your HTTP API bot token
CONFIG_AUTHOR=""                                           # The author of the build
CONFIG_GAPPS_FLAG=""                                   # The flag which is to be exported as true to make a GAPPs build
CONFIG_OFFICIAL_FLAG=""                             # The flag which is to be exported as true to make an official build
CONFIG_SYNC_JOBS=0                                               # How many jobs (CPU cores) to assign for the repo sync task.
CONFIG_COMPILE_JOBS=0                                            # How many jobs (CPU cores) to assign for the make task.

# Color Constants. Required variables for logging purposes.
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)
BOLD_GREEN=${BOLD}$(tput setaf 2)

VARIANT="Vanilla"

# Post Constants. Required variables for posting purposes.
DEVICE="$(sed -e "s/^.*_//" -e "s/-.*//" <<<"$CONFIG_LUNCH")"
ROM_NAME="$(sed "s#.*/##" <<<"$(pwd)")"
DATE=$(date +'%d-%m-%Y')
OUT="$(pwd)/out/target/product/$DEVICE"
UPLOAD_DIRECTORY="${CONFIG_AUTHOR}/${ROM_NAME}/${DATE}-TEST"

# CLI parameters. Fetch whatever input the user has provided.
while [[ $# -gt 0 ]]; do
    case $1 in
    -s | --sync)
        SYNC="1"
        ;;
    -c | --clean)
        CLEAN="1"
        ;;
    -g | --gapps)
        if [ -n "$CONFIG_GAPPS_FLAG" ]; then
            GAPPS="1"
            VARIANT="GAPPs"
        else
            echo -e "$RED\nERROR: Please specify the flag to export for GAPPs build in the configuration!!$RESET\n"
            exit 1
        fi
        ;;
    -o | --official)
        if [ -n "$CONFIG_OFFICIAL_FLAG" ]; then
            OFFICIAL="1"
        else
            echo -e "$RED\nERROR: Please specify the flag to export for official build in the configuration!!$RESET\n"
            exit 1
        fi
        ;;
    -p | --purge)
        rclone purge "oned:${UPLOAD_DIRECTORY}"
        exit 0
        ;;
    -h | --help)
        echo -e "\nNote: • You should specify all the mandatory variables in the script!
      • Just run './$0' for normal build
Usage: ./build_rom.sh [OPTION]
Example:
    ./$(basename $0) -s -c or ./$(basename $0) --sync --clean
Mandatory options:
    No option is mandatory!, just simply run the script without passing any parameter.
Options:
    -s, --sync            Sync sources before building.
    -c, --clean           Clean build directory before compilation.
    -g, --gapps           Build the GAPPs variant during compilation.
    -o, --official        Build the official variant during compilation.
    -p, --purge           Purges the specified upload directory for the index.\n"
        exit 1
        ;;
    *)
        echo -e "$RED\nUnknown parameter(s) passed: $1$RESET\n"
        exit 1
        ;;
    esac
    shift
done

# Configuration Checking. Exit the script if required variables aren't set.
if [[ $CONFIG_LUNCH == "" ]] || [[ $CONFIG_USE_BRUNCH == "" ]] || [[ $CONFIG_TARGET == "" ]]; then
    echo -e "$RED\nERROR: Please specify all of the mandatory variables!! Exiting now...$RESET\n"
    exit 1
fi

# Telegram Environment. Declare all of the related constants and functions.
export BOT_MESSAGE_URL="https://api.telegram.org/bot$CONFIG_BOT_TOKEN/sendMessage"
export BOT_EDIT_MESSAGE_URL="https://api.telegram.org/bot$CONFIG_BOT_TOKEN/editMessageText"
export BOT_FILE_URL="https://api.telegram.org/bot$CONFIG_BOT_TOKEN/sendDocument"

send_message() {
    local response=$(curl -s -X POST "$BOT_MESSAGE_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d "disable_web_page_preview=true" \
        -d text="$1")
    local message_id=$(echo "$response" | jq ".result | .message_id")
    echo "$message_id"
}

edit_message() {
    curl -s -X POST "$BOT_EDIT_MESSAGE_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d "message_id=$3" \
        -d text="$1"
}

send_file() {
    curl --progress-bar -F document=@"$1" "$BOT_FILE_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html"
}

upload_file() {
    RESPONSE=$(curl -T "$1" https://pixeldrain.com/api/file/)
    HASH=$(echo "$RESPONSE" | jq -r '.id')

    echo "https://pixeldrain.com/api/file/$HASH"
}

# Cleanup Files. Nuke all of the files from previous runs.
if [ -f "out/error.log" ]; then
    rm "out/error.log"
fi

if [ -f "log" ]; then
    rm "log"
fi

# Execute Parameters. Do the work if specified.
if [[ -n $SYNC ]]; then
    # Send a notification that the syncing process has started.

    sync_start_message="������ | <i>Syncing sources!!</i>
<b>• ROM:</b> <code>$ROM_NAME</code>
<b>• DEVICE:</b> <code>$DEVICE</code>
<b>• JOBS:</b> <code>$CONFIG_SYNC_JOBS Cores</code>
<b>• DIRECTORY:</b> <code>$(pwd)</code>"

    sync_message_id=$(send_message "$sync_start_message" "$CONFIG_CHATID")

    SYNC_START=$(TZ=Asia/Dhaka date +"%s")

    echo -e "$BOLD_GREEN\nStarting to sync sources now...$RESET\n"
    if ! repo sync -c --jobs-network=$CONFIG_SYNC_JOBS -j$CONFIG_SYNC_JOBS --jobs-checkout=$CONFIG_SYNC_JOBS --optimized-fetch --prune --force-sync --no-clone-bundle --no-tags; then
        echo -e "$RED\nInitial sync has failed!!$RESET" && echo -e "$BOLD_GREEN\nTrying to sync again with lesser arguments...$RESET\n"

        if ! repo sync -j$CONFIG_SYNC_JOBS; then
            echo -e "$RED\nSyncing has failed completely!$RESET" && echo -e "$BOLD_GREEN\nStarting the build now...$RESET\n"
        else
            SYNC_END=$(TZ=Asia/Dhaka date +"%s")
        fi
    else
        SYNC_END=$(TZ=Asia/Dhaka date +"%s")
    fi

    if [[ -n $SYNC_END ]]; then
        DIFFERENCE=$((SYNC_END - SYNC_START))
        MINUTES=$((($DIFFERENCE % 3600) / 60))
        SECONDS=$(((($DIFFERENCE % 3600) / 60) / 60))

        sync_finished_message="������ | <i>Sources synced!!</i>
<b>• ROM:</b> <code>$ROM_NAME</code>
<b>• DEVICE:</b> <code>$DEVICE</code>
<b>• JOBS:</b> <code>$CONFIG_SYNC_JOBS Cores</code>
<b>• DIRECTORY:</b> <code>$(pwd)</code>
<i>Syncing took $MINUTES minutes(s) and $SECONDS seconds(s)</i>"

        edit_message "$sync_finished_message" "$CONFIG_CHATID" "$sync_message_id"
    else
        sync_failed_message="������ | <i>Syncing sources failed!!</i>
    
<i>Trying to compile the ROM now...</i>"

        edit_message "$sync_failed_message" "$CONFIG_CHATID" "$sync_message_id"
    fi
fi

if [[ -n $CLEAN ]]; then
    echo -e "$BOLD_GREEN\nNuking the out directory now...$RESET\n"
    rm -rf "out"
fi

# Send a notification that the build process has started.

build_start_message="������ | <i>Compiling ROM...</i>
<b>• ROM:</b> <code>$ROM_NAME</code>
<b>• DEVICE:</b> <code>$DEVICE</code>
<b>• JOBS:</b> <code>$CONFIG_COMPILE_JOBS Cores</code>
<b>• TYPE:</b> <code>$([ -n "$OFFICIAL" ] && echo "Official" || echo "Unofficial")</code>
<b>• VARIANT:</b> <code>$VARIANT</code>"

build_message_id=$(send_message "$build_start_message" "$CONFIG_CHATID")

BUILD_START=$(TZ=Asia/Dhaka date +"%s")

# Start Compilation. Compile the ROM according to the configuration.
if [ "$CONFIG_USE_BRUNCH" == yes ]; then
    echo -e "$BOLD_GREEN\nSetting up the build environment...$RESET"
    source build/envsetup.sh

    echo -e "$BOLD_GREEN\nStarting to lunch '$DEVICE' now...$RESET"
    if [[ -n $CONFIG_GAPPS_FLAG ]]; then
        if [[ -n $GAPPS ]]; then
            export "${CONFIG_GAPPS_FLAG}=true"
        else
            export "${CONFIG_GAPPS_FLAG}=false"
        fi
    fi
    if [[ -n $CONFIG_OFFICIAL_FLAG ]]; then
        if [[ -n $OFFICIAL ]]; then
            export "${CONFIG_OFFICIAL_FLAG}=true"
        else
            export "${CONFIG_OFFICIAL_FLAG}=false"
        fi
    fi
    lunch "$CONFIG_LUNCH"

    if [ $? -eq 0 ]; then
        echo -e "$BOLD_GREEN\nStarting to build now...$RESET"
        brunch "$DEVICE"
    else
        echo -e "$RED\nFailed to lunch '$DEVICE'$RESET"

        build_failed_message="������ | <i>ROM compilation failed...</i>
    
<i>Failed at lunching $DEVICE...</i>"

        edit_message "$build_failed_message" "$CONFIG_CHATID" "$build_message_id"
        exit 1
    fi

else
    echo -e "$BOLD_GREEN\nSetting up the build environment...$RESET"
    source build/envsetup.sh

    echo -e "$BOLD_GREEN\nStarting to lunch '$DEVICE' now...$RESET"
    if [[ -n $CONFIG_GAPPS_FLAG ]]; then
        if [[ -n $GAPPS ]]; then
            export "${CONFIG_GAPPS_FLAG}=true"
        else
            export "${CONFIG_GAPPS_FLAG}=false"
        fi
    fi
    if [[ -n $CONFIG_OFFICIAL_FLAG ]]; then
        if [[ -n $OFFICIAL ]]; then
            export "${CONFIG_OFFICIAL_FLAG}=true"
        else
            export "${CONFIG_OFFICIAL_FLAG}=false"
        fi
    fi
    lunch "$CONFIG_LUNCH"

    if [ $? -eq 0 ]; then
        echo -e "$BOLD_GREEN\nStarting to build now...$RESET"
        m installclean -j$CONFIG_COMPILE_JOBS && m "$CONFIG_TARGET" -j$CONFIG_COMPILE_JOBS
    else
        echo -e "$RED\nFailed to lunch '$DEVICE'$RESET"

        build_failed_message="������ | <i>ROM compilation failed...</i>
    
<i>Failed at lunching $DEVICE...</i>"

        edit_message "$build_failed_message" "$CONFIG_CHATID" "$build_message_id"
        exit 1
    fi
fi

# Upload Build. Upload the output ROM ZIP file to the index.
BUILD_END=$(TZ=Asia/Dhaka date +"%s")
DIFFERENCE=$((BUILD_END - BUILD_START))
HOURS=$(($DIFFERENCE / 3600))
MINUTES=$((($DIFFERENCE % 3600) / 60))

if [ -s "out/error.log" ]; then
    # Send a notification that the build has failed.
    build_failed_message="������ | <i>ROM compilation failed...</i>
    
<i>Check out the log below!</i>"

    edit_message "$build_failed_message" "$CONFIG_CHATID" "$build_message_id"
    send_file "out/error.log" "$CONFIG_CHATID"
else
    ota_file=$(ls "$OUT"/*ota*.zip | tail -n -1)
    rm "$ota_file"
    zip_file=$(ls "$OUT"/*$DEVICE*.zip | tail -n -1)
    echo -e "$BOLD_GREEN\nStarting to upload the ZIP file now...$RESET\n"
    zip_file_url=$(upload_file "$zip_file")
    zip_file_md5sum=$(md5sum $zip_file | awk '{print $1}')
    zip_file_size=$(ls -sh $zip_file | awk '{print $1}')

    mv "$zip_file" ../ # Move the ZIP file to the parent directory for pushing to GitHub Releases later.

    build_finished_message="������ | <i>ROM compiled!!</i>
<b>• ROM:</b> <code>$ROM_NAME</code>
<b>• DEVICE:</b> <code>$DEVICE</code>
<b>• TYPE:</b> <code>$([ -n "$OFFICIAL" ] && echo "Official" || echo "Unofficial")</code>
<b>• VARIANT:</b> <code>$VARIANT</code>
<b>• SIZE:</b> <code>$zip_file_size</code>
<b>• MD5SUM:</b> <code>$zip_file_md5sum</code>
<b>• DOWNLOAD:</b> $zip_file_url
<i>Compilation took $HOURS hours(s) and $MINUTES minutes(s)</i>"

    edit_message "$build_finished_message" "$CONFIG_CHATID" "$build_message_id"
fi