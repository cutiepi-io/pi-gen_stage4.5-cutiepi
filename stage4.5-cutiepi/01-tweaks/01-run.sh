#!/bin/bash -e

on_chroot <<EOF
for GRP in video input render; do
  adduser $FIRST_USER_NAME \$GRP
done
EOF

# for backlight control 
install -m 644 files/backlight.rules 		"${ROOTFS_DIR}/etc/udev/rules.d/"

install -m 644 files/dt-blob.bin 		"${ROOTFS_DIR}/boot/"

# temporary hack before we upstream the driver and overlay 
install -m 644 files/*.dtbo 			"${ROOTFS_DIR}/boot/overlays/"
tar xvpf files/linux-5.10.74-v8+.tgz -C 	"${ROOTFS_DIR}/lib/modules/"
install -m 644 files/kernel8.img		"${ROOTFS_DIR}/boot/"

# binary for cutiepi shell 
install -m 755 files/cutoff 			"${ROOTFS_DIR}/usr/lib/systemd/system-shutdown/"
install -m 644 files/cutiepi-shell.desktop	"${ROOTFS_DIR}/etc/xdg/autostart/"
install -m 755 files/cutiepi-shell 		"${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/cutiepi-mcuproxy.desktop	"${ROOTFS_DIR}/etc/xdg/autostart/"
install -m 755 files/cutiepi-mcuproxy 		"${ROOTFS_DIR}/usr/local/bin/"

tar xvpf files/cutiepi-shell.tgz -C 		"${ROOTFS_DIR}/opt/"

# qml dependency for cutiepi shell 
tar xvpf files/qml-plugins.tgz -C		"${ROOTFS_DIR}/"
cp files/*.deb					"${ROOTFS_DIR}/tmp"

on_chroot <<EOF
dpkg -i /tmp/*.deb
EOF

rm -f "${ROOTFS_DIR}/tmp/*.deb"

# temporary hack before we upstream the driver 
on_chroot <<EOF
apt-mark hold raspberrypi-bootloader raspberrypi-kernel libqt5virtualkeyboard5
EOF

# wall papers
tar xvpf files/rdp-wallpaper-extra.tgz -C	"${ROOTFS_DIR}/"

# setting default orientation lock 
tar xvpf files/dot-dconf.tgz -C 		"${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"
on_chroot <<EOF
chown $FIRST_USER_NAME:$FIRST_USER_NAME -R /home/$FIRST_USER_NAME/.config/
EOF

# opt for connman connection manager 
rm -f "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"

# free serial0 for muc 
sed -i 's/console=serial0,115200 //'		"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/quiet //'				"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/splash //'				"${ROOTFS_DIR}/boot/cmdline.txt"