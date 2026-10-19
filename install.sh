#!/usr/bin/env bash

set -euo pipefail

_PREFIX="/usr"
_LIB_DIR="$_PREFIX/lib/btrsd"
_BIN_DIR="$_PREFIX/bin"

echo "--> Installing btrsd backup system"

if [[ "$EUID" -ne 0 ]]; then

    echo "Run as root"
    exit 1

fi

# directories
install -dm755 "$_LIB_DIR"
install -dm755 /etc/btrsd
install -dm755 /var/log/btrsd
install -dm700 /var/lib/btrsd

# systemd
install -m644 systemd/*.service /etc/systemd/system/
install -m644 systemd/*.timer /etc/systemd/system/

# udev
install -m644 udev/*.rules /usr/lib/udev/rules.d/

# logrotate
install -m644 logrotate/usb-backup /etc/logrotate.d/

# conf
if [[ ! -f /etc/btrsd.conf ]]; then

    install -m600 conf/btrsd.conf /etc/btrsd.conf
    echo "--> Created /etc/btrsd.conf (edit required for target UUID)"

fi

# lib
install -m644 lib/btrsd-lib.sh "$_LIB_DIR/"

# system scripts
install -m755 scripts-system/*.sh "$_LIB_DIR/"

# manual scripts
install -m755 scripts-manual/*.sh "$_BIN_DIR/"

# reload
systemctl daemon-reexec
systemctl daemon-reload
udevadm control --reload

echo "--> Installation complete"
echo ""
echo "--> MANUAL CONFIG REQUIRED"
echo "--> Add UUID of target Btrfs USB device to /etc/btrsd.conf before use"
echo "--> Add UUID of target Btrfs USB device to /usr/lib/udev/rules.d/99-btrsd.rules before use"
echo "--> Then enable timer:"
echo "    systemctl enable --now btrsd-reminder.timer"
echo ""
echo "--> btrsd configuration:"
echo "      /etc/btrsd.conf (backup scripting config)"
echo "      /etc/systemd/system/btrsd-reminder.timer (backup schedule)"
echo "      /etc/logrotate.d/btrsd (logrotate config)"
