#!/usr/bin/env bash

set -euo pipefail

_PREFIX="/usr"
_LIB_DIR="$_PREFIX/lib/btrsd"
_BIN_DIR="$_PREFIX/bin"

echo "--> Uninstalling btrsd backup system"

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root"
    exit 1
fi

echo "--> Stopping and disabling systemd units"

systemctl stop btrsd-main.service 2>/dev/null || true
systemctl stop btrsd-reminder.service 2>/dev/null || true
systemctl stop btrsd-reminder.timer 2>/dev/null || true

systemctl disable btrsd-reminder.timer 2>/dev/null || true

echo "--> Removing systemd unit files"

rm -f /etc/systemd/system/btrsd-main.service
rm -f /etc/systemd/system/btrsd-reminder.service
rm -f /etc/systemd/system/btrsd-reminder.timer

echo "--> Removing logrotate config"

rm -f /etc/logrotate.d/btrsd

echo "--> Removing library and scripts"

rm -rf "$_LIB_DIR"

rm -f "$_BIN_DIR"/btrsd-*.sh

echo ""
read -rp "--> Remove udev rule? [y/N]: " _REMOVE_UDEV

if [[ "$_REMOVE_UDEV" =~ ^[Yy]$ ]]; then

    echo "--> Removing udev rule"
    rm -f /usr/lib/udev/rules.d/99-btrsd.rules

else

    echo "--> Preserving udev rule"

fi

echo ""
read -rp "--> Remove configuration and state data? [y/N]: " _REMOVE_DATA

if [[ "$_REMOVE_DATA" =~ ^[Yy]$ ]]; then

    echo "--> Removing /etc/btrsd.conf"
    rm -f /etc/btrsd.conf

    echo "--> Removing /var/lib/btrsd"
    rm -rf /var/lib/btrsd

    echo "--> Removing /var/log/btrsd"
    rm -rf /var/log/btrsd

else

    echo "--> Preserving configuration and state data"

fi

echo "--> Reloading systemd and udev"

systemctl daemon-reexec
systemctl daemon-reload
udevadm control --reload

echo ""
echo "--> Uninstallation complete"
