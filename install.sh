#!/usr/bin/env bash
# Installs the Gece dotfiles for the current user (no root needed).
#   ./install.sh              link configs, then apply the Plasma look
#   ./install.sh --no-plasma  only link configs (terminal, shell, Zen)
# Existing files are moved to ~/.dotfiles-backup-<date> first.
set -euo pipefail
cd "$(dirname "$0")"
REPO="$PWD"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

link() {  # link <file in repo> <target>
    local src="$REPO/$1" dst="$2"
    [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]] && return
    if [[ -e "$dst" || -L "$dst" ]]; then
        mkdir -p "$BACKUP/$(dirname "${dst#$HOME/}")"
        mv "$dst" "$BACKUP/${dst#$HOME/}"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  $dst"
}

echo "Linking configs:"
link home/.zshrc                   "$HOME/.zshrc"
for f in kitty/kitty.conf kitty/gece.conf zsh/gece.zsh zsh/tips.txt starship.toml \
         fastfetch/config.jsonc btop/themes/gece.theme; do
    link "config/$f" "$HOME/.config/$f"
done
link share/color-schemes/Gece.colors          "$HOME/.local/share/color-schemes/Gece.colors"
link share/aurorae/themes/Gece-Classic        "$HOME/.local/share/aurorae/themes/Gece-Classic"
link share/konsole/Gece.profile               "$HOME/.local/share/konsole/Gece.profile"
link share/konsole/Gece.colorscheme           "$HOME/.local/share/konsole/Gece.colorscheme"

mkdir -p "$HOME/Pictures/Wallpapers"
cp -n wallpapers/gece.png "$HOME/Pictures/Wallpapers/gece.png"

# Zen Browser (Flatpak): copy the theme into every profile
for prof in "$HOME"/.var/app/app.zen_browser.zen/.zen/*.Default*/; do
    [[ -d "$prof" ]] || continue
    mkdir -p "$prof/chrome"
    cp zen/user.js "$prof/"
    cp zen/chrome/*.css "$prof/chrome/"
    echo "  Zen profile: $prof"
done

[[ -d "$BACKUP" ]] && echo "Old files saved in $BACKUP"

if [[ "${1:-}" != "--no-plasma" ]] && command -v plasmashell >/dev/null; then
    ./plasma/apply.sh
fi

cat <<MSG

Done. Open a new terminal to see the shell setup.
Missing tools?   sudo dnf install \$(grep -v '^#' packages.txt)
Boot menu, splash, login: sudo ./system/install.sh
MSG
