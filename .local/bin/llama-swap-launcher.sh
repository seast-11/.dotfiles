#!/usr/bin/env bash
#
# llama-swap lazy-starts each model backend on its first request, so "starting
# all servers" really just means: make sure llama-swap itself is up and
# healthy. This script does that, then optionally pre-warms one default model
# so pi's very first request in a new session doesn't stall on a cold load.
#
# Env overrides: LLAMA_SWAP_BIN, LLAMA_SWAP_CONFIG, DEFAULT_MODEL, LOG_FILE

set -euo pipefail

LLAMA_SWAP_BIN="${LLAMA_SWAP_BIN:-$HOME/.local/bin/llama-swap}"
LLAMA_SWAP_CONFIG="${LLAMA_SWAP_CONFIG:-$HOME/.config/llama-swap/llama-swap-config.yaml}"
LLAMA_SWAP_HOST="127.0.0.1"
LLAMA_SWAP_PORT="8080"
LLAMA_SWAP_URL="http://${LLAMA_SWAP_HOST}:${LLAMA_SWAP_PORT}"
LOG_FILE="${LOG_FILE:-/data/logs/llama-swap/llama-swap-$(date +%Y%m%d-%H%M%S).log}"

# Pick whichever model you actually start most pi sessions with.
# Leave empty (DEFAULT_MODEL="") to skip pre-warming entirely.
DEFAULT_MODEL="${DEFAULT_MODEL:-DeepSeek-V4-Flash-0731}"
is_up() {
  curl -fsS "${LLAMA_SWAP_URL}/health" >/dev/null 2>&1
}
echo "🔎 Checking llama-swap..."
if is_up; then
  echo "✅ llama-swap already running at ${LLAMA_SWAP_URL}"
else
  if [[ ! -x "$LLAMA_SWAP_BIN" ]]; then
    echo "❌ llama-swap binary not found/executable at: $LLAMA_SWAP_BIN"
    echo "   Set LLAMA_SWAP_BIN or fix the path in this script."
    exit 1
  fi
  if [[ ! -f "$LLAMA_SWAP_CONFIG" ]]; then
    echo "❌ config not found at: $LLAMA_SWAP_CONFIG"
    echo "   Set LLAMA_SWAP_CONFIG or fix the path in this script."
    exit 1
  fi
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "🚀 Starting llama-swap in foreground (Ctrl+C to stop)..."
  echo "   Logging to ${LOG_FILE}"
  echo
  # Tee this shell's stdout/stderr to both the terminal and the log file,
  # THEN exec llama-swap so it inherits those already-redirected file
  # descriptors. exec (the second one) still replaces this shell process
  # with llama-swap, so Ctrl+C behavior is unchanged — the rest of the
  # script (pre-warm etc.) still won't execute after this point. If you
  # need pre-warming, start first in background, then run this script
  # again after the server is already up.
  exec > >(tee -a "$LOG_FILE") 2>&1
  exec "$LLAMA_SWAP_BIN" \
    --config "$LLAMA_SWAP_CONFIG" \
    --listen "${LLAMA_SWAP_HOST}:${LLAMA_SWAP_PORT}" \
    "$@"
fi
if [[ -n "$DEFAULT_MODEL" ]]; then
  echo "🔥 Pre-warming default model: ${DEFAULT_MODEL} (this triggers llama-swap to load it)"
  if curl -fsS "${LLAMA_SWAP_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d "{\"model\": \"${DEFAULT_MODEL}\", \"messages\": [{\"role\": \"user\", \"content\": \"hi\"}], \"max_tokens\": 1}" \
      > /dev/null; then
    echo "✅ ${DEFAULT_MODEL} loaded and warm"
  else
    echo "⚠️  Pre-warm request failed — check that \"${DEFAULT_MODEL}\" matches a model key in your llama-swap config"
  fi
fi
echo
echo "pi is good to go → point it at ${LLAMA_SWAP_URL}/v1"
