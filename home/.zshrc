eval "$(starship init zsh)"
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="$HOME/.local/bin:$PATH"
# API keys and other private exports live here (not in git)
[[ -r ~/.config/zsh/secrets.zsh ]] && source ~/.config/zsh/secrets.zsh
source ~/.config/zsh/gece.zsh
