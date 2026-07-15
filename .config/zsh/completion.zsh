# ~/.config/zsh/completion.zsh
#
# Completion system configuration.

# --- Completion system ---
autoload -Uz compinit

mkdir -p "$XDG_CACHE_HOME/zsh"
mkdir -p "$XDG_CACHE_HOME/zsh/compcache"

compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Include dotfiles in completion matches.
_comp_options+=(globdots)

# Completion menu.
zstyle ':completion:*' menu select

# Exact match first, then case-insensitive.
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-zA-Z}={A-Za-z}'

# Colored completion list.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Immediately accept exact matches.
zstyle ':completion:*' accept-exact '*(N)'

# Cache completion results.
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"

# Group formatting.
zstyle ':completion:*' group-name ''

# Verbose completion descriptions.
zstyle ':completion:*' verbose yes

# Cache descriptions.
zstyle ':completion:*:descriptions' format '[%d]'

# Nice process list for kill completion.
zstyle ':completion:*:*:*:*:processes' command \
  'ps -u $USER -o pid,%cpu,%mem,comm -w -w'

# Expand aliases during completion.
setopt COMPLETE_ALIASES
