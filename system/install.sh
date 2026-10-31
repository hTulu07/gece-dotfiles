#!/usr/bin/env bash
# Gece boot splash (Plymouth) and login screen (Plasma Login Manager).
# Needs root:  sudo ./system/install.sh
set -euo pipefail
cd "$(dirname "$0")"
[[ $EUID -eq 0 ]] || { echo "Run with sudo."; exit 1; }
# the desktop user's home, for copying the Inter font they installed
U="${SUDO_USER:-}"; [[ -z "$U" && -n "${PKEXEC_UID:-}" ]] && U="$(id -nu "$PKEXEC_UID")"
USER_HOME="$( [[ -n "$U" ]] && getent passwd "$U" | cut -d: -f6 || true)"
B="/root/gece-backup-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$B"
cp -a /etc/plymouth/plymouthd.conf "$B/" 2>/dev/null || true

if command -v plymouth-set-default-theme >/dev/null; then
    install -d /usr/share/plymouth/themes/gece
    install -m644 plymouth/gece/* /usr/share/plymouth/themes/gece/
    echo "Boot splash: rebuilding initramfs, this takes a minute..."
    plymouth-set-default-theme -R gece
fi

if [[ -f /etc/plasmalogin.conf ]]; then
    cp -a /etc/plasmalogin.conf "$B/"
    install -d -o plasmalogin -g plasmalogin /var/lib/plasmalogin/wallpapers /var/lib/plasmalogin/.config
    install -m644 -o plasmalogin -g plasmalogin ../wallpapers/gece.png /var/lib/plasmalogin/wallpapers/gece.png
    install -m644 -o plasmalogin -g plasmalogin plasmalogin/kdeglobals /var/lib/plasmalogin/.config/kdeglobals
    if [[ -d "$USER_HOME/.local/share/fonts/Inter" ]]; then
        install -d /usr/local/share/fonts/Inter
        install -m644 "$USER_HOME"/.local/share/fonts/Inter/*.ttf /usr/local/share/fonts/Inter/
        fc-cache -f /usr/local/share/fonts >/dev/null
    fi
    if grep -q '^Image=' /etc/plasmalogin.conf; then
        sed -i 's|^Image=.*|Image=file:///var/lib/plasmalogin/wallpapers/gece.png|' /etc/plasmalogin.conf
    else
        printf '\n[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///var/lib/plasmalogin/wallpapers/gece.png\n' >> /etc/plasmalogin.conf
    fi
    restorecon -R /var/lib/plasmalogin /usr/local/share/fonts 2>/dev/null || true
    echo "Login screen: Gece wallpaper and colors"
fi
command -v restorecon >/dev/null && restorecon -R /usr/share/plymouth/themes/gece 2>/dev/null || true
echo "Backup of old settings: $B"
