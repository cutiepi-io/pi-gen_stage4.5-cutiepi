#!/bin/bash -e

on_chroot <<EOF
for GRP in video input render; do
  adduser $FIRST_USER_NAME \$GRP
done
EOF

install -m 644 files/backlight.rules 		"${ROOTFS_DIR}/etc/udev/rules.d/"

install -m 644 files/dt-blob.bin 		"${ROOTFS_DIR}/boot/"
install -m 644 files/*.dtbo 			"${ROOTFS_DIR}/boot/overlays/"

install -m 755 files/cutoff 			"${ROOTFS_DIR}/usr/lib/systemd/system-shutdown/"
install -m 644 files/cutiepi-shell.desktop	"${ROOTFS_DIR}/etc/xdg/autostart/"
install -m 755 files/cutiepi-shell 		"${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/cutiepi-mcuproxy.desktop	"${ROOTFS_DIR}/etc/xdg/autostart/"
install -m 755 files/cutiepi-mcuproxy 		"${ROOTFS_DIR}/usr/local/bin/"

tar xvpf files/cutiepi-shell.tgz -C 		"${ROOTFS_DIR}/opt/"
tar xvpf files/gtk-vkb-helper.tgz -C		"${ROOTFS_DIR}/"
tar xvpf files/qml-plugins.tgz -C		"${ROOTFS_DIR}/"
cp files/*.deb					"${ROOTFS_DIR}/tmp"

on_chroot <<EOF
dpkg -i /tmp/*.deb
EOF

rm -f "${ROOTFS_DIR}/tmp/*.deb"

on_chroot <<EOF
apt-mark hold libqt5virtualkeyboard5 qtvirtualkeyboard-plugin
EOF

tar xvpf files/panel-config.tgz -C 		"${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"
tar xvpf files/dconf-config.tgz -C 		"${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"

on_chroot <<EOF
chown $FIRST_USER_NAME:$FIRST_USER_NAME -R /home/$FIRST_USER_NAME/.config/
cp /usr/share/applications/connman-gtk.desktop /etc/xdg/autostart/
EOF

tar xvpf files/rdp-wallpaper-extra.tgz -C	"${ROOTFS_DIR}/"

on_chroot <<EOF
chown $FIRST_USER_NAME:$FIRST_USER_NAME -R /opt/cutiepi-shell/
EOF

rm -f "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
rm -f "${ROOTFS_DIR}/etc/xdg/autostart/pprompt.desktop"
rm -f "${ROOTFS_DIR}/etc/xdg/autostart/piwiz.desktop"

sed -i 's/console=serial0,115200 //'		"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/quiet //'				"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/splash //'				"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/ignore-serial-consoles/ignore-serial-consoles video=HDMI-A-2:D video=DSI-1:800x1280@60/'	"${ROOTFS_DIR}/boot/cmdline.txt"
