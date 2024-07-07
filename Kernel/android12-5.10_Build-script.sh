mkdir kernel
cd kernel
repo init -u https://android.googlesource.com/kernel/manifest.git -b common-android12-5.10-lts --depth=1
repo sync --force-sync
ln -s common/build.config.gki.aarch64 build.config
cd common
git fetch https://github.com/PQEnablers-Devices/android_kernel_mediatek_5.10 690af439252ed79b1ecfd41cac7c95cf14e81c5a
git cherry-pick 88387bb803d881312cc24d97b680ccf8bcabd4de^..690af439252ed79b1ecfd41cac7c95cf14e81c5a
sed -i "s|Image.lz4|Image.gz|g" build.config.gki.aarch64
wget https://gist.githubusercontent.com/sarthakroy2002/4e1c6bc5b5745168f1d47f4eb1bb25d6/raw/1a70b2aa9c401262de2dad03f8231b3f03d5325d/uncommitted.patch
patch -p1 < uncommitted.patch
cd ..
echo "Compile starting..."
bash build/build.sh
echo "Compilied..."
git clone https://github.com/sarthakroy2002/AnyKernel3 -b android12-5.10 
cp -r out/android12-5.10/dist/Image.gz AnyKernel3
cd AnyKernel3
zip -r9 android12-5.10-AnyKernel3.zip ./*
