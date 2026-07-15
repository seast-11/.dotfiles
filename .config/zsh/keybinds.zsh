# ~/.config/zsh/keybinds.zsh
#
# zsh-vi-mode configuration and custom keybindings.

# ---------------------------------------------------------
# zsh-vi-mode configuration (must be set before the plugin is sourced)
# ---------------------------------------------------------

# Cursor shape per vi mode. ZVM_CURSOR_BEAM/ZVM_CURSOR_BLOCK are
# constants defined *by* zsh-vi-mode itself, so they don't exist yet at
# this point in the file — referencing them in a plain top-level
# assignment here would just evaluate to empty. zvm_config() is the
# hook the plugin documents and auto-invokes internally, at the point
# in its own init where these constants are actually defined, so it's
# the only place this can correctly go.
function zvm_config() {
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

  # Off. Lazy keybindings defers all vicmd/visual bindkey setup to the
  # first ESC press, which is a separate reset window from the one
  # zvm_after_init already deals with below — anything bound to vicmd
  # in zvm_after_init would be a candidate for getting silently
  # overwritten the first time you hit ESC. Disabling this means
  # there's exactly one reset to account for.
  # ZVM_LAZY_KEYBINDINGS=false
}

# Disable command mode line highlight.
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

# ---------------------------------------------------------
# zsh-vi-mode customizations
# ---------------------------------------------------------

# zsh-vi-mode resets bindings on initialization. Everything that must
# survive that reset — custom bindkeys, cursor shape (above), and
# fzf's own keybindings — lives in this ONE hook.

zvm_after_init() {
  # Faster ESC -> normal mode transition
  KEYTIMEOUT=1

  local keymap
  for keymap in viins vicmd; do
    # Ctrl+Right / Ctrl+Left word movement
    bindkey -M $keymap '^[[1;5C' forward-word
    bindkey -M $keymap '^[[1;5D' backward-word

    # History substring search
    bindkey -M $keymap '^[[A' history-substring-search-up
    bindkey -M $keymap '^[[B' history-substring-search-down

    # Home / End / Delete
    bindkey -M $keymap '^[[H' beginning-of-line
    bindkey -M $keymap '^[[F' end-of-line
    bindkey -M $keymap '^[[3~' delete-char
  done

  # Accept autosuggestion (insert mode only)
  bindkey -M viins '^ ' autosuggest-accept

  # Edit current command in $EDITOR
  autoload -Uz edit-command-line
  zle -N edit-command-line

  for keymap in viins vicmd; do
    bindkey -M $keymap '^X^E' edit-command-line
  done

  # fzf keybindings (^R, ^T, Alt-C)
  source <(fzf --zsh)
}
