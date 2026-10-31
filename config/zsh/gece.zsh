# ── Gece shell setup ─────────────────────────────────────────────────
# Sourced once from ~/.zshrc. Every tool is optional: missing ones are skipped.

# guard: sourcing this file twice must not run anything twice
[[ -n $GECE_LOADED ]] && return
GECE_LOADED=1
export _ZO_DOCTOR=0

# history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_all_dups hist_ignore_space hist_reduce_blanks
setopt auto_cd interactive_comments no_beep

# completion: menu, case-insensitive, colored
autoload -Uz compinit && compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{#56647a}── %d ──%f'
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^H' backward-kill-word

# colors for plugins loaded in .zshrc
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#56647a'
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#7aa8ff'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7aa8ff'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#7aa8ff'
ZSH_HIGHLIGHT_STYLES[function]='fg=#7aa8ff'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a9c6ff,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ef6b73'
ZSH_HIGHLIGHT_STYLES[path]='fg=#d8e0ea,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#7fd1a0'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#7fd1a0'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#56647a,italic'

# modern replacements
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -l --group-directories-first --icons=auto --git'
  alias la='eza -la --group-directories-first --icons=auto --git'
  alias tree='eza --tree --icons=auto --git-ignore'
fi
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain' && export BAT_THEME=ansi
command -v lazygit >/dev/null && alias lg='lazygit'

if command -v fzf >/dev/null; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border rounded \
    --color=bg+:#18202b,bg:-1,fg:#d8e0ea,hl:#7aa8ff,fg+:#eef3fa,hl+:#a9c6ff \
    --color=border:#263142,prompt:#7aa8ff,pointer:#7aa8ff,marker:#7fd1a0,info:#56647a,spinner:#7aa8ff"
  command -v fd >/dev/null && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude bin --exclude obj'
fi

# ── projects ─────────────────────────────────────────────────────────
PROJECTS=~/Projects

# proj [query] — fuzzy-jump into a project
proj() {
  local d
  if command -v fzf >/dev/null; then
    d=$(find $PROJECTS -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort |
        fzf --query="$1" --select-1 --prompt='project ❯ ' \
            --preview "ls -1 $PROJECTS/{} | head -20")
  else
    d=$1
  fi
  [[ -n $d ]] && cd "$PROJECTS/$d"
}

# newcs <Name> [template] — new C# project in ~/Projects, opened in VS Code
newcs() {
  [[ -z $1 ]] && { echo "usage: newcs <Name> [console|classlib|webapi|xunit]"; return 1; }
  dotnet new "${2:-console}" -n "$1" -o "$PROJECTS/$1" && cd "$PROJECTS/$1" && git init -q &&
    dotnet new gitignore >/dev/null && code .
}

# newpy <name> — new Python project with a venv
newpy() {
  [[ -z $1 ]] && { echo "usage: newpy <name>"; return 1; }
  mkdir -p "$PROJECTS/$1" && cd "$PROJECTS/$1" && python3 -m venv .venv &&
    source .venv/bin/activate && touch main.py && git init -q && code .
}

# newc <name> — new C project with a Makefile
newc() {
  [[ -z $1 ]] && { echo "usage: newc <name>"; return 1; }
  mkdir -p "$PROJECTS/$1" && cd "$PROJECTS/$1" || return
  printf '#include <stdio.h>\n\nint main(void) {\n    printf("hello, world\\n");\n    return 0;\n}\n' > main.c
  printf 'CFLAGS = -Wall -Wextra -g\n\n%s: main.c\n\t$(CC) $(CFLAGS) -o $@ $^\n\nrun: %s\n\t./%s\n\nclean:\n\trm -f %s\n' "$1" "$1" "$1" "$1" > Makefile
  printf '%s\n' "$1" > .gitignore
  git init -q && code .
}

# ── small tools ──────────────────────────────────────────────────────
mkcd()  { mkdir -p "$1" && cd "$1"; }
serve() { python3 -m http.server "${1:-8000}"; }              # share this folder on :8000
ports() { ss -tulpn 2>/dev/null | sed 1d | awk '{print $1, $5, $7}' | column -t; }
cheat() { curl -s "cheat.sh/$1"; }                            # cheat tar, cheat python/list
weather() { curl -s "wttr.in/${1:-Istanbul}?0"; }
tip()   { shuf -n1 ~/.config/zsh/tips.txt; }                  # random tip from the list

# git
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --graph --pretty=format:"%C(#7aa8ff)%h%Creset %s %C(#56647a)· %cr · %an%Creset%C(#e8c96f)%d%Creset" -20'
alias gd='git diff'

# dotnet
alias dr='dotnet run'
alias db='dotnet build'
alias dw='dotnet watch run'
alias dt='dotnet test'
alias dc='dotnet clean'

# misc
alias c='code .'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear && fastfetch'
alias update='sudo dnf upgrade --refresh && flatpak update -y'

# zoxide last, so its hook sits after everything else
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

# greeting: once per terminal window, not in VS Code / nested shells
if [[ -o interactive && $TERM_PROGRAM != vscode && $SHLVL -le 1 ]] && command -v fastfetch >/dev/null; then
  fastfetch
fi
