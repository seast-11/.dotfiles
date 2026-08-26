#!/usr/bin/env bash
# Install/compile tree-sitter parsers for Neovim 0.12+
# Uses the tree-sitter CLI to build parsers from source.
# Target directory: $PARSER_DIR (default: ~/.local/share/nvim/site/parser)
#
# Usage: ./install_parsers.sh [--langs "go,lua,rust" ...]
#        ./install_parsers.sh                    # install all parsers
#        ./install_parsers.sh --langs "go,rust"  # only go and rust
#
# Depends on: git, cc/gcc, tree-sitter (>= 0.20)
#
# Notes:
#   Many grammars have moved out of the tree-sitter org. This script
#   tracks their current homes (tree-sitter-grammars org, third-party).
#   If a grammar fails to clone, check GitHub for the current location.

set -euo pipefail

PARSER_DIR="${PARSER_DIR:-"${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/parser"}"
BUILD_DIR="${BUILD_DIR:-/tmp/tree-sitter-build}"

# ── Parser specs ──────────────────────────────────────────
# Format: <org>/<grammar-repo>:<so-name>:<subdir>
#   org/grepo       — GitHub org and repo to clone
#   so-name         — filename of the compiled parser (e.g. "go" -> go.so)
#   subdir          — (optional) subdirectory within repo to build from

PARSERS=(
  "tree-sitter/tree-sitter-bash:bash"
  "tree-sitter/tree-sitter-c:c"
  "tree-sitter/tree-sitter-c-sharp:c_sharp"
  "tree-sitter/tree-sitter-css:css"
  "tree-sitter/tree-sitter-go:go"
  "tree-sitter/tree-sitter-html:html"
  "tree-sitter/tree-sitter-json:json"
  "tree-sitter-grammars/tree-sitter-lua:lua"
  "tree-sitter-grammars/tree-sitter-markdown:markdown:tree-sitter-markdown"
  "tree-sitter-grammars/tree-sitter-markdown:markdown_inline:tree-sitter-markdown-inline"
  "tree-sitter-grammars/tree-sitter-query:query"
  "tree-sitter/tree-sitter-regex:regex"
  "tree-sitter/tree-sitter-rust:rust"
  "tree-sitter-grammars/tree-sitter-svelte:svelte"
  "tree-sitter-grammars/tree-sitter-vim:vim"
  "neovim/tree-sitter-vimdoc:vimdoc"
  "tree-sitter-grammars/tree-sitter-yaml:yaml"
)

# ── Helper ─────────────────────────────────────────────────
log()  { printf "\033[1;32m  %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m  %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m  %s\033[0m\n" "$*"; }

check_deps() {
  local missing=0
  for cmd in cc git tree-sitter; do
    if ! command -v "$cmd" &>/dev/null; then
      err "Missing: $cmd"
      missing=1
    fi
  done
  if [[ $missing -eq 1 ]]; then
    err "Install missing dependencies and re-run."
    exit 1
  fi
}

# ── Build one parser ──────────────────────────────────────
build_parser() {
  local spec="$1"
  # parse <org/repoorigin>:<soname>[:<subdir>]
  local orgrepo="${spec%%:*}"
  local rest="${spec#*:}"
  local soname="${rest%%:*}"
  local subdir=""
  if [[ "$rest" == *:* ]]; then
    subdir="${rest#*:}"
  fi

  local repo_name="${orgrepo#*/}"  # e.g. tree-sitter-go
  local src_dir="$BUILD_DIR/$repo_name"
  local out="$PARSER_DIR/$soname.so"

  if [[ -f "$out" ]]; then
    log "  $soname — already installed, skipping"
    return 0
  fi

  log "  $soname — cloning $orgrepo"
  rm -rf "$src_dir"
  GIT_TERMINAL_PROMPT=0 git clone --depth 1 --quiet "https://github.com/$orgrepo.git" "$src_dir" 2>/dev/null || {
    warn "  $soname — clone failed, skipping"
    return 1
  }

  local build_dir="$src_dir"
  if [[ -n "$subdir" ]]; then
    build_dir="$src_dir/$subdir"
  fi

  pushd "$build_dir" &>/dev/null

  log "  $soname — building"
  local tmp_out="$BUILD_DIR/$soname.so"
  tree-sitter build -o "$tmp_out" 2>/dev/null || {
    warn "  $soname — build failed, skipping"
    popd &>/dev/null || true
    rm -rf "$src_dir"
    return 1
  }

  install -m 755 "$tmp_out" "$out"
  log "  $soname — installed to $out"

  popd &>/dev/null || true
  rm -rf "$src_dir"
}

# ── Main ───────────────────────────────────────────────────
check_deps

mkdir -p "$PARSER_DIR" "$BUILD_DIR"

SELECTED=()
if [[ "${#}" -gt 0 && "$1" == "--langs" ]]; then
  shift
  IFS=',' read -ra LANGS <<< "$1"
  for lang in "${LANGS[@]}"; do
    SELECTED+=("$lang")
  done
else
  SELECTED=("${PARSERS[@]}")
fi

log "Installing parsers to: $PARSER_DIR"
log ""

for entry in "${SELECTED[@]}"; do
  build_parser "$entry"
done

log ""
log "Done."
log "Neovim will pick up parsers from: $PARSER_DIR"
