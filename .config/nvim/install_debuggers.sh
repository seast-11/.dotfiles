#!/usr/bin/env bash
# Install debuggers for Neovim DAP
#
# Usage: ./install_debuggers.sh
#
# Depends on:
#   - go   (for dlv)
#   - pipx (for debugpy)
#   - gdb  (system package — install via pacman/sudo)

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

# ── Main ──────────────────────────────────────────────────

mkdir -p "$BIN"

export PATH="$BIN:$(go env GOPATH 2>/dev/null || echo "$HOME/go")/bin:$PATH"

log ""
log "╔══════════════════════════════════════════════════╗"
log "║  Installing Debuggers for Neovim DAP            ║"
log "╚══════════════════════════════════════════════════╝"
log ""

log "── dlv (Delve) ────────────────────────────────────────"
install_via_go "dlv" "github.com/go-delve/delve/cmd/dlv"

log ""
log "── debugpy (Python DAP adapter) ───────────────────────"
# debugpy provides the debugpy-adapter binary used by nvim-dap
install_via_pipx "debugpy"

log ""
log "── Verification ──────────────────────────────────────"
log ""
for cmd in dlv debugpy-adapter gdb; do
  if command -v "$cmd" &>/dev/null; then
    log "  ✅ $cmd -- installed at $(command -v "$cmd")"
  else
    warn "  ❌ $cmd -- NOT FOUND"
  fi
done

log ""
log "── PATH Check ──────────────────────────────────────"
log ""
local_bin="$HOME/go/bin"
if [[ ":$PATH:" != *":$local_bin:"* ]]; then
  warn "  ⚠  $local_bin is not in your PATH."
  warn "     Add this to your shell config (e.g. ~/.bashrc):"
  warn "        export PATH=\"\$HOME/go/bin:\$PATH\""
fi

local_bin="$HOME/.local/bin"
if [[ ":$PATH:" != *":$local_bin:"* ]]; then
  warn "  ⚠  $local_bin is not in your PATH."
  warn "     Add this to your shell config (e.g. ~/.bashrc):"
  warn "        export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

log ""
log "Done. All debuggers installed."
