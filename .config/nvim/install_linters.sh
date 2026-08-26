#!/usr/bin/env bash
# Install linters for nvim-lint
#
# Usage: ./install_linters.sh
#
# Depends on:
#   - go          (for golangci-lint)
#   - pipx        (for ruff — install via: pacman -S python-pipx)
#   - curl        (for downloads)
#   - jq          (for parsing GitHub API)
#   - pacman      (for cppcheck — only on Arch Linux)

set -euo pipefail

log() { printf "\033[1;32m  %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m  %s\033[0m\n" "$*"; }
err() { printf "\033[1;31m  %s\033[0m\n" "$*"; }

BIN="${BIN_DIR:-$HOME/.local/bin}"

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

install_via_pacman() {
  local name="$1"
  local pkg="$2"
  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi
  if ! command -v pacman &>/dev/null; then
    warn "  $name -- pacman not available, skipping"
    return 1
  fi
  log "  $name -- installing via pacman"
  sudo pacman -S --noconfirm "$pkg" 2>/dev/null || {
    warn "  $name -- pacman install failed"
    return 1
  }
  log "  $name -- installed"
}

download_targz_binary() {
  local name="$1"
  local repo="$2"
  local arch_filter="$3"

  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi

  log "  $name -- downloading latest release"

  local url
  url="$(curl -s "https://api.github.com/repos/$repo/releases/latest" |
    jq -r ".assets[] | select(.name | contains(\"$arch_filter\")) | .browser_download_url" |
    head -1)"

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

  local bin
  bin="$(find "/tmp/$name-extract" -maxdepth 2 -type f -name "$name" 2>/dev/null | head -1)"

  if [[ -n "$bin" ]]; then
    install -m 755 "$bin" "$BIN/$name"
    log "  $name -- installed to $BIN/$name"
  else
    warn "  $name -- binary not found in archive"
    return 1
  fi
}

download_raw_binary() {
  local name="$1"
  local repo="$2"
  local arch_filter="$3"

  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi

  log "  $name -- downloading latest release"

  local url
  url="$(curl -s "https://api.github.com/repos/$repo/releases/latest" |
    jq -r ".assets[] | select(.name | contains(\"$arch_filter\")) | .browser_download_url" |
    head -1)"

  if [[ -z "$url" ]]; then
    warn "  $name -- no release found"
    return 1
  fi

  curl -sL "$url" -o "/tmp/$name" 2>/dev/null || {
    warn "  $name -- download failed"
    return 1
  }

  install -m 755 "/tmp/$name" "$BIN/$name"
  log "  $name -- installed to $BIN/$name"
}

check_deps() {
  local missing=0
  if ! command -v curl &>/dev/null; then
    err "Missing: curl"
    missing=1
  fi
  if ! command -v jq &>/dev/null; then
    err "Missing: jq (install via: pacman -S jq)"
    missing=1
  fi
  if ! command -v pipx &>/dev/null; then
    err "Missing: pipx (needed for ruff — install via: pacman -S python-pipx)"
    missing=1
  fi
  if [[ $missing -gt 0 ]]; then
    exit 1
  fi
}

check_deps

mkdir -p "$BIN"
export PATH="$BIN:$PATH"

log "Installing linters"
log ""

download_targz_binary "shellcheck" "koalaman/shellcheck" "linux.x86_64.tar.gz"
download_raw_binary "luacheck" "lunarmodules/luacheck" "luacheck"
install_via_pipx "ruff"
install_via_pacman "cppcheck" "cppcheck"

log ""
log "Done."
