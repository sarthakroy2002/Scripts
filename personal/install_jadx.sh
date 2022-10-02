# techyminati <sinha.aryan03@gmail.com>
sudo apt install -y zip
JADX_VERSION=$(curl -s "https://api.github.com/repos/skylot/jadx/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo jadx.zip "https://github.com/skylot/jadx/releases/latest/download/jadx-${JADX_VERSION}.zip"
unzip jadx.zip -d jadx-temp
sudo mkdir -p /opt/jadx/bin
sudo mv jadx-temp/bin/jadx /opt/jadx/bin
sudo mv jadx-temp/bin/jadx-gui /opt/jadx/bin
sudo mv jadx-temp/lib /opt/jadx
echo 'export PATH=$PATH:/opt/jadx/bin' | sudo tee -a /etc/profile
source /etc/profile
echo "Done"
jadx --version
# Cleanup
rm -rf jadx.zip
rm -rf jadx-temp
