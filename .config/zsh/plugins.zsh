ZPLUGINDIR="$XDG_DATA_HOME/zsh/plugins"

_zplugin_load() {
  local repo="$1"
  local plugin="$2"
  local plugin_path="${ZPLUGINDIR}/${plugin}"
  local plugin_file

  # Clone if missing
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${plugin}..."

    git clone --depth=1 \
      "https://github.com/${repo}/${plugin}" \
      "$plugin_path" \
      || {
        echo "ERROR: failed to install ${plugin}" >&2
        return 1
      }
  fi

  # Find plugin entrypoint automatically. Prefer the canonical
  # *.plugin.zsh entrypoint; only fall back to a bare *.zsh file if no
  # .plugin.zsh exists. (Checking both patterns in a single find with
  # `head -n1`, as before, is non-deterministic whenever a repo ships
  # both — jeffreytse/zsh-vi-mode does, for example. Harmless there
  # since its .plugin.zsh is just a wrapper that sources the .zsh file,
  # but not something to rely on in general.)
  plugin_file=$(find "$plugin_path" -maxdepth 1 -type f -name "*.plugin.zsh" | head -n 1)
  if [[ -z "$plugin_file" ]]; then
    plugin_file=$(find "$plugin_path" -maxdepth 1 -type f -name "*.zsh" | head -n 1)
  fi

  if [[ -z "$plugin_file" ]]; then
    echo "WARNING: no Zsh plugin file found for ${plugin}" >&2
    return 1
  fi

  source "$plugin_file"
}

zplugin-update() {
  local dir

  for dir in "${ZPLUGINDIR}"/*/; do
    [[ -d "$dir/.git" ]] || continue

    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

# --- Plugins ---
# fzf-tab must load before zsh-autosuggestions/history-substring-search:
# it needs to wrap completion widgets before other plugins wrap zle
# widgets. zsh-vi-mode loads after those, since it resets the keymap on
# init. fast-syntax-highlighting always loads absolute last.
_zplugin_load Aloxaf fzf-tab
_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load jeffreytse zsh-vi-mode

# Must load last
_zplugin_load zdharma-continuum fast-syntax-highlighting

# fzf-tab (interactive Tab completion) after plugin loads
#

# Switch completion groups with , and .
zstyle ':fzf-tab:*' switch-group ',' '.'

# Enable ANSI color codes in fzf-tab's preview/group-header input.
# (fzf itself is already case-insensitive/smart-case by default —
# --ansi is unrelated to case sensitivity, it's just color passthrough.)
zstyle ':fzf-tab:*' fzf-flags --ansi

# Preview directories.
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  '(eza --tree --level=2 --color=always $realpath || ls -la $realpath) 2>/dev/null'

# Preview files.
zstyle ':fzf-tab:complete:*' fzf-preview \
  'bat --color=always --style=plain,numbers --line-range=:500 {} 2>/dev/null || eza --tree --color=always {} 2>/dev/null'

# --- zoxide (smarter cd) ---
eval "$(zoxide init zsh)"

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
  # there's exactly one reset to account for, so one hook is correct,
  # not just simpler. Trade-off is a marginally slower first prompt
  # (this feature exists mainly for "open shell, run one command and
  # exit" use, not a five-plugin interactive setup like this one).
  #ZVM_LAZY_KEYBINDINGS=false
}

# ---------------------------------------------------------
# zsh-vi-mode customizations
# ---------------------------------------------------------

# zsh-vi-mode resets bindings on initialization. Everything that must
# survive that reset — custom bindkeys, cursor shape (above), and
# fzf's own keybindings — lives in this ONE hook. With
# ZVM_LAZY_KEYBINDINGS off (see zvm_config above), there's no separate
# deferred vicmd/visual setup step to fight with, so a single hook is
# correct, not just simpler.
#
# FIX: bindkey with no -M flag only binds into whichever keymap is
# active when this hook fires (viins, since that's what `main` aliases
# to after `bindkey -v`). That silently left vicmd (normal mode)
# without these bindings. Word movement, history substring search,
# edit-command-line, and Home/End/Delete are all useful in both modes,
# so they're bound explicitly in both. autosuggest-accept stays
# viins-only — suggestions only render while typing, so vicmd has
# nothing to accept.

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

  # Accept autosuggestion (insert mode only — nothing to accept in vicmd)
  bindkey -M viins '^ ' autosuggest-accept

  # Edit current command in $EDITOR
  autoload -Uz edit-command-line
  zle -N edit-command-line
  for keymap in viins vicmd; do
    bindkey -M $keymap '^x^e' edit-command-line
  done

  # fzf keybindings (^R, ^T, alt-c) — sourced here, after the keymap
  # reset above, so they actually stick.
  source <(fzf --zsh)
}
