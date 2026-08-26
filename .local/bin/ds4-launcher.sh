#!/usr/bin/env bash

set -euo pipefail

# ── STRIX DS4 INFERENCE ENGINE (DeepSeek-V4 only) ──────────────────────
DATA="/data"
MODELS_DIR="$DATA/models/llm"
DS4_BIN="$DATA/ds4/ds4-server"
THREADS=16
BATCH_SIZE=2048
U_BATCH_SIZE=512
MODEL_FOLDER="DeepSeek-V4"
CTX=262144
USE_MMAP=0
TARGET_DIR="$MODELS_DIR/$MODEL_FOLDER"

# ── MODEL RESOLUTION ────────────────────────────────────────────────────────
echo "=== 🔥 DS4 INFERENCE ENGINE ==="
echo "------------------------------------------"
echo "DeepSeek-V4 (DS4 ROCm)"
echo "------------------------------------------"
MODEL_PATH=$(find "$TARGET_DIR" -maxdepth 3 -type f \
  \( -name "*merged*.gguf" -o -name "*.gguf" \) \
  ! -name "*mmproj*" | sort | head -n 1)
if [[ -z "$MODEL_PATH" || ! -f "$MODEL_PATH" ]]; then
  echo "❌ Model not found in $TARGET_DIR"
  exit 1
fi
MODEL_NAME=$(basename "$MODEL_PATH")
# ── DS4 BACKEND ─────────────────────────────────────────────────────────────
echo "\n🔥 DS4 backend (DeepSeek-V4)"
echo "📐 ctx=$CTX"

# LOG_FILE="/data/logs/ds4/ds4-$(date +%Y%m%d-%H%M%S).log"
# mkdir -p /data/logs/ds4

exec "$DS4_BIN" \
  -m "$MODEL_PATH" \
  -c "$CTX" \
  --host 127.0.0.1 \
  --port 8000 \
  --kv-disk-dir "${DS4_KV_DIR:-/tmp/ds4-kv}" \
  --kv-disk-space-mb "${DS4_KV_SPACE_MB:-8192}" \
#  --trace "$LOG_FILE"
