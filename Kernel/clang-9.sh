
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=titan
export KBUILD_BUILD_USER="sarthakroy2002"
git clone --depth=1 https://github.com/sarthakroy2002/clang-r353983c1 clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 los-4.9-64
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 los-4.9-32

[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 rmx2020_defconfig

PATH="/tmp/kernel/clang/bin:${PATH}:/tmp/kernel/los-4.9-32/bin:${PATH}:/tmp/kernel/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="/tmp/kernel/los-4.9-64/bin/aarch64-linux-android-" \
                      CROSS_COMPILE_ARM32="/tmp/kernel/los-4.9-32/bin/arm-linux-androideabi-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
