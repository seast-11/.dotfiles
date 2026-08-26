#!/usr/bin/env bash
# Install LSP servers for Neovim
#
# Usage: ./install_lsps.sh
#
# Depends on:
#   - go          (for gopls, golangci-lint-langserver)
#   - npm         (for bash-language-server, pyright, yaml-language-server)
#   - curl / jq   (for GitHub release downloads, if needed)
#   - pacman      (optional — for clangd, though it's already installed)

set -euo pipefail

log()  { printf "\033[1;32m  %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m  %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m  %s\033[0m\n" "$*"; }

BIN="${BIN_DIR:-$HOME/.local/bin}"

# ── Helper installers ────────────────────────────────────

install_via_go() {
  local name="$1"
  local path="$2"
  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi
  log "  $name -- installing via go"
  go install "$path@latest" 2>/dev/null || {
    warn "  $name -- go install failed"
    return 1
  }
  log "  $name -- installed"
}

install_via_npm() {
  local name="$1"
  local pkg="${2:-$1}"
  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi
  log "  $name -- installing via npm"
  npm install --prefix "$HOME/.local" -g "$pkg" 2>/dev/null || {
    warn "  $name -- npm install failed"
    return 1
  }
  log "  $name -- installed"
}

install_via_pipx() {
  local name="$1"
  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi
  log "  $name -- installing via pipx"
  pipx install "$name" 2>/dev/null || {
    warn "  $name -- pipx install failed"
    return 1
  }
  log "  $name -- installed"
}

install_via_github_release() {
  local name="$1"
  local repo="$2"
  local pattern="$3"
  local extract_subdir="${4:-}"

  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi

  log "  $name -- downloading latest release from $repo"

  local url
  url="$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
    | jq -r '.assets[] | select(.name | contains("'"$pattern"'")) | .browser_download_url' \
    | head -1)"

  if [[ -z "$url" ]]; then
    warn "  $name -- no release found for $pattern"
    return 1
  fi

  curl -sL "$url" -o "/tmp/$name.tar.gz" 2>/dev/null || {
    warn "  $name -- download failed"
    return 1
  }

  rm -rf "/tmp/$name-extract"
  mkdir "/tmp/$name-extract"
  tar -xzf "/tmp/$name.tar.gz" -C "/tmp/$name-extract" 2>/dev/null || true

  local src_dir="/tmp/$name-extract"
  if [[ -n "$extract_subdir" ]]; then
    src_dir="/tmp/$name-extract/$extract_subdir"
  fi

  local bin
  bin="$(find "$src_dir" -maxdepth 3 -type f -name "$name" 2>/dev/null | head -1)"

  if [[ -n "$bin" ]]; then
    install -m 755 "$bin" "$BIN/$name"
    log "  $name -- installed to $BIN/$name"
  else
    warn "  $name -- binary not found in archive"
    return 1
  fi
}

install_lua_language_server() {
  local name="lua-language-server"
  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi

  log "  $name -- downloading latest release from LuaLS/lua-language-server"

  local url
  url="$(curl -s "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest" \
    | jq -r '.assets[] | select(.name | contains("linux-x64")) | .browser_download_url' \
    | head -1)"

  if [[ -z "$url" ]]; then
    warn "  $name -- no release found"
    return 1
  fi

  curl -sL "$url" -o "/tmp/$name.tar.gz" 2>/dev/null || {
    warn "  $name -- download failed"
    return 1
  }

  rm -rf "/tmp/$name-extract"
  mkdir "/tmp/$name-extract"
  tar -xzf "/tmp/$name.tar.gz" -C "/tmp/$name-extract" 2>/dev/null || true

  # lua-language-server ships as a full directory: bin/lua-language-server + bin/main.lua + scripts/
  # Extract everything to a permanent home
  local target_dir="$HOME/.local/share/lua-language-server"
  rm -rf "$target_dir"
  mkdir -p "$target_dir"
  mv /tmp/$name-extract/* "$target_dir" 2>/dev/null || true

  # Symlink the binary into BIN
  if [[ -f "$target_dir/bin/lua-language-server" ]]; then
    ln -sf "$target_dir/bin/lua-language-server" "$BIN/lua-language-server"
    log "  $name -- installed to $BIN/$name (extracted to $target_dir)"
  else
    warn "  $name -- binary not found in archive"
    return 1
  fi
}

# ── Dependency check ─────────────────────────────────────

check_deps() {
  local missing=0
  if ! command -v go &>/dev/null; then
    err "Missing: go (needed for gopls and golangci-lint-langserver)"
    missing=1
  fi
  if ! command -v npm &>/dev/null; then
    err "Missing: npm (needed for bash-language-server, pyright, yaml-language-server)"
    missing=1
  fi
  if ! command -v jq &>/dev/null; then
    err "Missing: jq (needed for GitHub release downloads — install via: pacman -S jq)"
    missing=1
  fi
  if [[ $missing -gt 0 ]]; then
    exit 1
  fi
}

# ── Main ──────────────────────────────────────────────────

check_deps

mkdir -p "$BIN"

# Ensure both go bin and local bin are in PATH for verification
export PATH="$BIN:$(go env GOPATH 2>/dev/null || echo "$HOME/go")/bin:$PATH"

log ""
log "╔══════════════════════════════════════════════════╗"
log "║  Installing LSP Servers for Neovim              ║"
log "╚══════════════════════════════════════════════════╝"
log ""

# ── 1. bash-language-server ───────────────────────────────
log "── bash-language-server ───────────────────────────────"
install_via_npm "bash-language-server" "bash-language-server"

# ── 2. gopls ──────────────────────────────────────────────
log "── gopls ──────────────────────────────────────────────"
install_via_go "gopls" "golang.org/x/tools/gopls"

# ── 3. golangci-lint-langserver ───────────────────────────
log "── golangci-lint-langserver ───────────────────────────"
install_via_go "golangci-lint-langserver" "github.com/nametake/golangci-lint-langserver"

# ── 4. pyright ────────────────────────────────────────────
log "── pyright (pyright-langserver) ───────────────────────"
install_via_npm "pyright-langserver" "pyright"

# ── 5. yaml-language-server ───────────────────────────────
log "── yaml-language-server ───────────────────────────────"
install_via_npm "yaml-language-server" "yaml-language-server"

# ── 6. lua-language-server ────────────────────────────────
log "── lua-language-server ────────────────────────────────"
install_lua_language_server

log ""
log "── Verification ──────────────────────────────────────"
log ""
for cmd in bash-language-server gopls golangci-lint-langserver pyright-langserver yaml-language-server lua-language-server; do
  if command -v "$cmd" &>/dev/null; then
    log "  ✅ $cmd -- installed at $(command -v "$cmd")"
  else
    warn "  ❌ $cmd -- NOT FOUND"
  fi
done

log ""
log "Done. All LSP servers installed."
log ""
log "Note: clangd is already provided by the 'clang' pacman package."
log "      If clangd is missing, install it with:"
log "        sudo pacman -S clang"
