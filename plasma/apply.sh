#!/usr/bin/env bash
# Applies the Gece look to KDE Plasma 6: colors, window frames, icons,
# wallpaper, kitty as terminal and the bottom bar.
set -uo pipefail
cd "$(dirname "$0")"
WALL="$HOME/Pictures/Wallpapers/gece.png"
kw() { kwriteconfig6 "$@"; }

echo "Applying Plasma look:"
plasma-apply-colorscheme Gece >/dev/null && echo "  colors: Gece"

kw --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kw --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__Gece-Classic
kw --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft M
kw --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight IAX
qdbus-qt6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1
echo "  window frames: Gece Classic"

if [[ -d "$HOME/.local/share/icons/Papirus-Dark" || -d /usr/share/icons/Papirus-Dark ]]; then
    /usr/libexec/plasma-changeicons Papirus-Dark >/dev/null 2>&1 && echo "  icons: Papirus-Dark"
else
    echo "  icons: Papirus-Dark not installed, skipped (sudo dnf install papirus-icon-theme)"
fi

plasma-apply-wallpaperimage "$WALL" >/dev/null && echo "  wallpaper"
kw --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General \
   --key Image "file://$WALL"

if command -v kitty >/dev/null; then
    kw --file kdeglobals --group General --key TerminalApplication kitty
    kw --file kdeglobals --group General --key TerminalService kitty.desktop
    kw --file kglobalshortcutsrc --group services --group org.kde.konsole.desktop --key _launch none
    kw --file kglobalshortcutsrc --group services --group kitty.desktop --key _launch Ctrl+Alt+T
    # make the shortcut live now (otherwise it only works after the next login)
    A='["kitty.desktop","_launch","kitty","Launch"]'
    gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel \
        --method org.kde.KGlobalAccel.doRegister "$A" >/dev/null 2>&1
    gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel \
        --method org.kde.KGlobalAccel.setShortcut "$A" "[201326676]" 6 >/dev/null 2>&1
    echo "  terminal: kitty (Ctrl+Alt+T)"
fi

# Gece Control widget, used by the bottom bar
W="$HOME/.local/share/plasma/plasmoids/org.gece.kontrol"
if [[ ! -e "$W" ]] && command -v git >/dev/null; then
    git clone -q https://github.com/hTulu07/gece-control "$HOME/.local/src/gece-control" 2>/dev/null &&
        mkdir -p "$(dirname "$W")" && ln -s "$HOME/.local/src/gece-control/package" "$W" &&
        echo "  widget: Gece Control"
fi

if [[ "${GECE_KEEP_PANELS:-}" != 1 ]]; then
    qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat layout.js)" >/dev/null &&
        echo "  bottom bar (set GECE_KEEP_PANELS=1 to keep your own panels)"
fi
