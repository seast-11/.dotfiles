# ~/.config/zsh/env.zsh
#
# Environment variables and application configuration.

# --- Environment ---
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$PATH"

export MAIL=thunderbird
export TERM=alacritty
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

export BAT_THEME="Catppuccin Frappe"
export MANPAGER="bat -l man -p"

export GPG_TTY="$(tty)"

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/zsh/starship.toml"

# History / state files
export ZCALC_HISTFILE="$XDG_STATE_HOME/zsh/zcalc_history"
export DIRSTACKFILE="$XDG_STATE_HOME/zsh/dirs"

# less
mkdir -p "$XDG_STATE_HOME/less"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# readline
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

# --- fzf ---
# Env/opts only. The actual `source <(fzf --zsh)` call (which sets up
# ^R, ^T, alt-c) is deferred to zvm_after_init — zsh-vi-mode resets the
# keymap on init, so binding these before that point just gets wiped.

export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="❯ "
  --pointer="▶"
  --marker="✓"
  --preview-window=right:60%:wrap:border-left
  --preview "bat --color=always --style=plain,numbers --line-range=:500 {} 2>/dev/null"
'

export FZF_ALT_C_OPTS='
  --preview "eza --tree --level=2 --color=always {} 2>/dev/null"
'

zstyle ':fzf:*' zle-reset-prompt yes

# Make custom completion functions available.
fpath=(
  "$XDG_DATA_HOME/zsh/site-functions"
  $fpath
)

# --- zoxide (smarter cd) ---
eval "$(zoxide init --cmd cd zsh)"

# --- optional: pywal color sequences, uncomment if you use pywal ---
# if [[ $EUID -ne 0 && -r "$XDG_CACHE_HOME/wal/sequences" ]]; then
#   cat "$XDG_CACHE_HOME/wal/sequences"
# fi
