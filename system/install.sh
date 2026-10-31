#!/usr/bin/env bash
# Gece boot menu (GRUB), boot splash (Plymouth) and login screen (Plasma Login Manager).
# Needs root:  sudo ./system/install.sh [grub] [plymouth] [login]   (no arguments = all)
set -euo pipefail
cd "$(dirname "$0")"
[[ $EUID -eq 0 ]] || { echo "Run with sudo."; exit 1; }
# the desktop user's home, for copying the Inter font they installed
U="${SUDO_USER:-}"; [[ -z "$U" && -n "${PKEXEC_UID:-}" ]] && U="$(id -nu "$PKEXEC_UID")"
USER_HOME="$( [[ -n "$U" ]] && getent passwd "$U" | cut -d: -f6 || true)"
B="/root/gece-backup-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$B"
cp -a /etc/plymouth/plymouthd.conf "$B/" 2>/dev/null || true
PARTS="${*:-grub plymouth login}"
want() { [[ " $PARTS " == *" $1 "* ]]; }

set_grub() {  # set_grub KEY VALUE  in /etc/default/grub
    if grep -q "^$1=" /etc/default/grub; then sed -i "s|^$1=.*|$1=$2|" /etc/default/grub
    else echo "$1=$2" >> /etc/default/grub; fi
}

if want grub && [[ -f /etc/default/grub ]]; then
    GRUB_DIR=/boot/grub2; [[ -d $GRUB_DIR ]] || GRUB_DIR=/boot/grub
    cp -a /etc/default/grub "$B/default-grub"
    rm -rf "$GRUB_DIR/themes/gece"
    install -d "$GRUB_DIR/themes/gece/icons"
    install -m644 grub/gece/*.* "$GRUB_DIR/themes/gece/"
    install -m644 grub/gece/icons/* "$GRUB_DIR/themes/gece/icons/"
    set_grub GRUB_THEME "\"$GRUB_DIR/themes/gece/theme.txt\""
    set_grub GRUB_TERMINAL_OUTPUT '"gfxterm"'
    set_grub GRUB_GFXMODE '"1920x1080,auto"'
    set_grub GRUB_DISABLE_OS_PROBER false   # list Windows and other systems
    command -v grub2-editenv >/dev/null && grub2-editenv - unset menu_auto_hide  # always show the menu
    MKCONFIG=$(command -v grub2-mkconfig || command -v grub-mkconfig)
    "$MKCONFIG" -o "$GRUB_DIR/grub.cfg" 2>&1 | grep -i -E "found|theme|error" || true
    echo "Boot menu: Gece theme. Other systems found:"
    grep -o "^menuentry '[^']*'" "$GRUB_DIR/grub.cfg" | sed 's/^menuentry /  /' || echo "  (none)"
fi

if want plymouth && command -v plymouth-set-default-theme >/dev/null; then
    install -d /usr/share/plymouth/themes/gece
    install -m644 plymouth/gece/* /usr/share/plymouth/themes/gece/
    echo "Boot splash: rebuilding initramfs, this takes a minute..."
    plymouth-set-default-theme -R gece
fi

if want login && [[ -f /etc/plasmalogin.conf ]]; then
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
command -v restorecon >/dev/null && restorecon -R /usr/share/plymouth/themes/gece /boot/grub2/themes 2>/dev/null || true
echo "Backup of old settings: $B"
