# ~/.zshrc — plain zsh, no plugin manager. Everything sourced directly. Modular design.

# Bail immediately for non-interactive invocations (scp, some scripts).
[[ -o interactive ]] || return

source "$ZDOTDIR/env.zsh"
source "$ZDOTDIR/history.zsh"
source "$ZDOTDIR/completion.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/keybinds.zsh"
source "$ZDOTDIR/aliases.zsh"

fastfetch

eval "$(starship init zsh)"
