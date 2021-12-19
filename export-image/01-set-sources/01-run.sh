#!/bin/bash -e

rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
find "${ROOTFS_DIR}/var/lib/apt/lists/" -type f -delete
on_chroot << EOF
apt-get update
apt-get clean
EOF

rm -f "$PROOTFS_DIR}/etc/xdg/autostart/pprompt.desktop"
rm -f "$PROOTFS_DIR}/etc/xdg/autostart/piwiz.desktop"
