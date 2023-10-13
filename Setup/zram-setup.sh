sudo apt install zram-config
sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab
sudo echo "zram" >> /etc/modules-load.d/zram.conf
sudo echo "options zram num_devices=1" >> /etc/modprobe.d/zram.conf
sudo echo '''KERNEL=="zram0", ATTR{disksize}="20480M",TAG+="systemd"''' >> /etc/udev/rules.d/99-zram.rules
sudo echo '''
[Unit]
Description=Swap with zram
After=multi-user.target
[Service]
Type=oneshot
RemainAfterExit=true
ExecStartPre=/sbin/mkswap /dev/zram0
ExecStart=/sbin/swapon /dev/zram0
ExecStop=/sbin/swapoff /dev/zram0
[Install]
WantedBy=multi-user.target''' >> /etc/systemd/system/zram.service
sudo systemctl enable zram
