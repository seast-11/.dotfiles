#!/usr/bin/env bash
# Install formatters for conform.nvim
#
# Usage: ./install_formatters.sh
#
# Depends on:
#   - go          (for gofumpt)
#   - curl        (for stylua, shfmt)
#   - pipx        (for black — install via: pacman -S python-pipx)
#   - pacman      (for clang-format — only on Arch Linux)

set -euo pipefail

log()  { printf "\033[1;32m  %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m  %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m  %s\033[0m\n" "$*"; }

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

download_release() {
  local name="$1"
  local repo="$2"
  local arch_pattern="$3"

  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi

  log "  $name -- downloading latest release"

  local url
  url="$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
    | grep "browser_download_url" \
    | grep "$arch_pattern" \
    | grep -v "musl\|aarch64\|arm" \
    | head -1 \
    | cut -d'"' -f4)"

  if [[ -z "$url" ]]; then
    warn "  $name -- no release found for this architecture"
    return 1
  fi

  curl -sL "$url" -o "/tmp/$name.zip" 2>/dev/null || {
    warn "  $name -- download failed"
    return 1
  }

  rm -rf "/tmp/$name-extract"
  unzip -o "/tmp/$name.zip" -d "/tmp/$name-extract" 2>/dev/null || true

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
  local pattern="$3"

  if command -v "$name" &>/dev/null; then
    log "  $name -- already installed"
    return 0
  fi

  log "  $name -- downloading latest release"

  local url
  url="$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
    | grep "browser_download_url" \
    | grep "$pattern" \
    | grep -v "musl\|aarch64\|arm\|386" \
    | head -1 \
    | cut -d'"' -f4)"

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
  if ! command -v go &>/dev/null; then
    err "Missing: go (needed for gofumpt)"
    exit 1
  fi
  if ! command -v curl &>/dev/null; then
    err "Missing: curl (needed for downloads)"
    exit 1
  fi
  if ! command -v pipx &>/dev/null; then
    err "Missing: pipx (needed for black — install via: pacman -S python-pipx)"
    exit 1
  fi
}

check_deps

mkdir -p "$BIN"
export PATH="$BIN:$PATH"

log "Installing formatters"
log ""

install_via_go "gofumpt" "mvdan.cc/gofumpt"
download_release "stylua" "JohnnyMorganz/StyLua" "linux-x86_64.zip"
download_raw_binary "shfmt" "mvdan/sh" "linux_amd64"

install_via_pipx "black"
install_via_pacman "clang-format" "clang"

log ""
log "Done."
