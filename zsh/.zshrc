# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History 
HISTSIZE=110000
SAVEHIST=100000
HISTFILE=~/.cache/zshhistory

# colors
autoload -U colors && colors	      # colors
autoload -U compinit && compinit    # basic completion
autoload -U compinit colors zcalc   # theming
 
# Custom Variables
export EDITOR=vim

# load paths
[ -f "$HOME/.config/zsh/pathrc" ] && source "$HOME/.config/zsh/pathrc"
# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/zsh/aliasrc" ] && source "$HOME/.config/zsh/aliasrc"
# Load options 
[ -f "$HOME/.config/zsh/optionrc" ] && source "$HOME/.config/zsh/optionrc"

# Basic auto/tab complete:
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' menu select
zmodload zsh/complist
autoload -Uz compinit
compinit
_comp_options+=(globdots)               # Include hidden files.

#plugins
# source ~/.config/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source ~/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 

# you need more POWER!
source ~/.config/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme

# custom binds 
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down
bindkey '^ ' autosuggest-accept
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
# bindkey -M vicmd '^[[A' history-substring-search-up 
# bindkey -M vicmd '^[OA' history-substring-search-up 
# bindkey -M vicmd '^[[B' history-substring-search-down
# bindkey -M vicmd '^[OB' history-substring-search-down
# bindkey -M viins '^[[A' history-substring-search-up 
# bindkey -M viins '^[OA' history-substring-search-up 
# bindkey -M viins '^[[B' history-substring-search-down 
# bindkey -M viins '^[OB' history-substring-search-down

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

neofetch
