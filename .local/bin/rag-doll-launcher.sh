#!/usr/bin/env bash
# okf - pdf -> markdown converters, install + mood-based dispatch
# venvs live at /data/python/venvs/<tool_name>
#
# GPU is mandatory for any mood that runs neural inference. install() verifies
# torch.cuda.is_available() per-venv after installing your rocm torch build;
# if it's False, that venv is marked .gpu_unavailable and convert() refuses
# to run any mood backed by it. Nothing silently falls back to CPU.
#
# install() also prefetches every model weight upfront (needs network once).
# convert() runs fully offline after that.

set -euo pipefail

# gfx1151/Strix Halo tuning -- baked in so you never have to export these
# yourself. MIOPEN_DEBUG_DISABLE_AI_HEURISTICS is the same fix already in use
# for the llama.cpp/ds4 side of the stack (MIOpen's AI solver picker chooses
# bad/slow kernels on gfx1151 specifically). AOTRITON_ENABLE_EXPERIMENTAL
# turns on the mem-efficient/flash attention path instead of the slow math
# fallback that pytorch otherwise silently uses on rocm.
export MIOPEN_DEBUG_DISABLE_AI_HEURISTICS=1
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
# skip miopen's exhaustive GetSolutionsFallback search (the thing spamming
# "IsEnoughWorkspace" warnings on repeat) and just take a known-working
# solver immediately instead of re-searching on every single call.
export MIOPEN_FIND_MODE=FAST

VENV_BASE="${OKF_VENV_DIR:-/data/python/venvs}"
OKF_LLM_ENDPOINT="${OKF_LLM_ENDPOINT:-http://localhost:8080/v1}"
OKF_LLM_MODEL="${OKF_LLM_MODEL:-qwen3-vl-30b-a3b-instruct}"

usage() {
  cat <<EOF
okf - pdf to markdown, by mood

usage:
  okf install --torch-index <url>   (required -- your working rocm torch wheel index)
  okf convert <mood> <file.pdf> [outdir]
  okf moods

moods:
  lazy           pymupdf4llm      native-text pdf, no models, cpu is fine -- there's
                                   nothing to accelerate, it's just text extraction
  thorough       marker+llm       gpu (rocm). --use_llm correction pass via llama-swap
  archaeologist  marker+force-ocr gpu (rocm). old scanned datasheets, re-ocr everything
  rag            docling+easyocr  gpu (rocm). structured chunks -> chunks.json for the rag server

  scholar (mineru) is NOT included. its ocr stage is paddlepaddle, not pytorch --
  getting it onto rocm on gfx1151 needs nightly torch/rocm builds plus patched
  model code (see community thread: github.com/opendatalab/MinerU discussion
  "AMD RDNA ROCm vllm/pipeline backend" for the manual path). that's real work
  i can't verify sight-unseen, so it's out rather than shipping a fake gpu path.

env overrides:
  OKF_VENV_DIR     base directory for tool venvs (default: /data/python/venvs)
  OKF_LLM_ENDPOINT openai-compatible base url  (current: $OKF_LLM_ENDPOINT)
  OKF_LLM_MODEL    model alias in llama-swap   (current: $OKF_LLM_MODEL)

notes on network calls (why + what install() does about it):
  - marker (thorough/archaeologist) pulls its own layout/ocr/table/inline-math
    weights + a font from models.datalab.to -- Marker's own vendor (US-based),
    one-time-download-then-cache, same pattern as pulling a GGUF from HF once
    for llama.cpp. install() seeds this by constructing a real PdfConverter.
  - docling (rag) used to auto-select RapidOCR (pulls from modelscope.cn --
    genuinely china) then Tesseract (cpu-only, disqualified under the gpu
    requirement). now on EasyOCR: pytorch-native, gpu-capable, models come
    from Jaided's own host. install() seeds this with a real seeded convert()
    call, not docling-tools models download (that one's default set doesn't
    reliably match what StandardPdfPipeline actually requests at runtime --
    seen firsthand: it wanted docling-layout-heron, a mismatch with the older
    default bundle. only a real convert() call triggers the right downloads).
  - pymupdf4llm has no models -- nothing to fetch, nothing to block.
EOF
}

get_venv_path() {
  local mood="$1"
  local tool_name=""

  case "$mood" in
    lazy)          tool_name="pymupdf4llm" ;;
    thorough)      tool_name="marker-pdf" ;;
    archaeologist) tool_name="marker-pdf" ;;
    rag)           tool_name="docling" ;;
    *)
      echo "unknown mood: $mood (scholar/mineru is not available -- see 'okf moods')" >&2
      return 1
      ;;
  esac

  echo "$VENV_BASE/$tool_name"
}

# installs rocm torch into a venv and verifies cuda.is_available() actually
# returns true. on failure: marks the venv .gpu_unavailable and returns 1,
# but does not abort the whole install -- other tools still get set up.
ensure_gpu_torch() {
  local venv_path="$1"
  local torch_index="$2"
  local pip_bin="$venv_path/bin/pip"
  local py_bin="$venv_path/bin/python"

  echo "  -> installing rocm torch from: $torch_index"
  "$pip_bin" install --index-url "$torch_index" torch torchvision

  if "$py_bin" -c "import torch, sys; sys.exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
    rm -f "$venv_path/.gpu_unavailable"
    echo "  -> gpu confirmed: $("$py_bin" -c "import torch; print(torch.cuda.get_device_name(0))")"
    return 0
  else
    touch "$venv_path/.gpu_unavailable"
    echo "  -> WARNING: torch.cuda.is_available() is False in $venv_path"
    echo "     moods backed by this venv are disabled until this is fixed."
    return 1
  fi
}

install() {
  local torch_index=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --torch-index|-t) torch_index="$2"; shift 2 ;;
      *) echo "unknown install flag: $1" >&2; exit 1 ;;
    esac
  done

  if [[ -z "$torch_index" ]]; then
    echo "error: --torch-index <url> is required." >&2
    echo "pass whatever rocm torch wheel index/version you already use for" >&2
    echo "comfyui/ai-toolkit on this machine -- not guessing one here since a" >&2
    echo "wrong guess wastes your time worse than just asking for it." >&2
    exit 1
  fi

  echo "Installing tools to: $VENV_BASE"
  mkdir -p "$VENV_BASE"

  declare -A TOOLS
  TOOLS["pymupdf4llm"]='pymupdf4llm'
  TOOLS["marker-pdf"]='marker-pdf'
  TOOLS["docling"]='docling[easyocr]'

  for tool_name in "${!TOOLS[@]}"; do
    local venv_path="$VENV_BASE/$tool_name"
    local packages="${TOOLS[$tool_name]}"

    echo "----------------------------------------"
    echo "Setting up environment for: $tool_name"
    echo "Path: $venv_path"

    if [[ -d "$venv_path" ]]; then
      echo "  -> venv exists, will 86 it and do fresh creation!"
      rm -rf "$venv_path"
    fi
    mkdir -p "$(dirname "$venv_path")"
    python3.12 -m venv "$venv_path"

    local py_bin="$venv_path/bin/python"
    local pip_bin="$venv_path/bin/pip"

    "$py_bin" -m pip install --upgrade pip
    "$pip_bin" install wheel --quiet

    local gpu_ok=1
    if [[ "$tool_name" == "marker-pdf" || "$tool_name" == "docling" ]]; then
      ensure_gpu_torch "$venv_path" "$torch_index" || gpu_ok=0
    fi

    echo "Installing: $packages"
    "$pip_bin" install "$packages"

    if (( ! gpu_ok )); then
      echo "✗ $tool_name installed but GPU not confirmed -- its moods are disabled."
      continue
    fi

    echo "  -> prefetching models for $tool_name (network needed once, now)"
    case "$tool_name" in
      pymupdf4llm)
        echo "     (no models to fetch)"
        ;;

      marker-pdf)
        # create_model_dict() alone only grabs the ML weights -- it misses
        # GoNotoCurrent-Regular.ttf, which download_font() only fetches when
        # a real PdfConverter is constructed. build one for real here so
        # both the weights AND the font land in ~/.cache/datalab/ up front.
        "$py_bin" -c "
from marker.converters.pdf import PdfConverter
from marker.models import create_model_dict
PdfConverter(artifact_dict=create_model_dict())
print('marker models + font cached')
"
        ;;

      docling)
        # a real seeded convert() call, not docling-tools models download --
        # that command's default set doesn't reliably match what
        # StandardPdfPipeline actually requests at runtime. also runs
        # HybridChunker() for real -- its default tokenizer
        # (sentence-transformers/all-MiniLM-L6-v2) is a *separate* download
        # from anything the pipeline itself needs, and convert()'s runtime
        # HF_HUB_OFFLINE=1 will crash on it if it's never been cached.
        "$py_bin" -c "
import pypdfium2 as pdfium
from docling.document_converter import DocumentConverter, PdfFormatOption
from docling.datamodel.base_models import InputFormat
from docling.datamodel.pipeline_options import (
    PdfPipelineOptions, EasyOcrOptions, AcceleratorOptions, AcceleratorDevice,
)
from docling.chunking import HybridChunker

seed = '/tmp/okf-seed.pdf'
pdf = pdfium.PdfDocument.new()
pdf.new_page(200, 200)
pdf.save(seed)

pipeline_options = PdfPipelineOptions()
pipeline_options.do_ocr = True
pipeline_options.ocr_options = EasyOcrOptions(lang=['en'], use_gpu=True)
pipeline_options.accelerator_options = AcceleratorOptions(num_threads=16, device=AcceleratorDevice.CUDA)

converter = DocumentConverter(
    format_options={InputFormat.PDF: PdfFormatOption(pipeline_options=pipeline_options)}
)
doc = converter.convert(seed).document
list(HybridChunker().chunk(doc))
print('docling + easyocr + chunker tokenizer cached')
"
        ;;
    esac

    echo "✓ $tool_name environment ready (gpu confirmed, models cached, offline-capable)."
  done

  echo "----------------------------------------"
  echo "Installation Complete!"
  echo ""
  echo "Usage:"
  echo "  To convert a PDF, run: okf convert <mood> <file.pdf>"
  echo "  Check for any '.gpu_unavailable' markers above -- those tools' moods won't run."
  echo ""
  for tool in "${!TOOLS[@]}"; do
    echo "  source $VENV_BASE/$tool/bin/activate  # for $tool"
  done
}

convert() {
  local mood="${1:-}"
  local file="${2:-}"
  local outdir="${3:-}"

  if [[ -z "$mood" || -z "$file" ]]; then
    echo "usage: okf convert <mood> <file.pdf> [outdir]" >&2
    exit 1
  fi
  if [[ ! -f "$file" ]]; then
    echo "file not found: $file" >&2
    exit 1
  fi

  local venv_path
  venv_path=$(get_venv_path "$mood") || exit 1

  if [[ ! -d "$venv_path" ]]; then
    echo "Error: Environment for '$mood' not found at $venv_path." >&2
    echo "Run 'okf install --torch-index <url>' first." >&2
    exit 1
  fi

  if [[ -f "$venv_path/.gpu_unavailable" ]]; then
    echo "Error: '$mood' is disabled -- GPU acceleration could not be confirmed" >&2
    echo "for $venv_path during install. Re-run 'okf install --torch-index <url>'" >&2
    echo "with a working rocm index/version to enable it." >&2
    exit 1
  fi

  local base
  base="$(basename "${file%.*}")"
  outdir="${outdir:-./okf-out/$mood/$base}"
  mkdir -p "$outdir"

  local py_bin="$venv_path/bin/python"
  local tool_exe=""

  case "$mood" in
    lazy)       tool_exe="$py_bin" ;;
    thorough|archaeologist)
      tool_exe="$venv_path/bin/marker_single"
      if [[ ! -x "$tool_exe" ]]; then
        echo "Error: marker_single not found in $venv_path. Run 'okf install'." >&2
        exit 1
      fi
      ;;
    rag)        tool_exe="$py_bin" ;;
  esac

  echo "Running mood '$mood' using: $venv_path"

  case "$mood" in
    lazy)
      "$py_bin" - "$file" "$outdir" <<'PY'
import sys, pathlib
import pymupdf4llm
src, outdir = sys.argv[1], sys.argv[2]
md = pymupdf4llm.to_markdown(src)
pathlib.Path(outdir, "output.md").write_text(md)
PY
      ;;

    thorough)
      "$tool_exe" "$file" --output_dir "$outdir" \
        --use_llm --disable_image_extraction --max_table_rows 50 \
        --llm_service marker.services.openai.OpenAIService \
        --openai_base_url "$OKF_LLM_ENDPOINT" \
        --openai_model "$OKF_LLM_MODEL" \
        --openai_api_key none
      ;;

    archaeologist)
      "$tool_exe" "$file" --output_dir "$outdir" \
        --force_ocr --use_llm --redo_inline_math \
        --disable_image_extraction --max_table_rows 50 \
        --llm_service marker.services.openai.OpenAIService \
        --openai_base_url "$OKF_LLM_ENDPOINT" \
        --openai_model "$OKF_LLM_MODEL" \
        --openai_api_key none
      ;;

    rag)
      # HF_HUB_OFFLINE/TRANSFORMERS_OFFLINE: fail fast instead of retrying
      # network if a model somehow isn't cached, rather than hanging.
      HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
        "$py_bin" - "$file" "$outdir" <<'PY'
import sys, json, logging, pathlib
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")

from docling.document_converter import DocumentConverter, PdfFormatOption
from docling.datamodel.base_models import InputFormat
from docling.datamodel.pipeline_options import (
    PdfPipelineOptions, EasyOcrOptions, AcceleratorOptions, AcceleratorDevice,
)
from docling.chunking import HybridChunker

src, outdir = sys.argv[1], sys.argv[2]

pipeline_options = PdfPipelineOptions()
pipeline_options.do_ocr = True
# download_enabled=False: models were already cached by install(), this just
# guarantees no accidental network fetch is even attempted at runtime.
pipeline_options.ocr_options = EasyOcrOptions(lang=["en"], use_gpu=True, download_enabled=False)
pipeline_options.accelerator_options = AcceleratorOptions(num_threads=16, device=AcceleratorDevice.CUDA)

converter = DocumentConverter(
    format_options={InputFormat.PDF: PdfFormatOption(pipeline_options=pipeline_options)}
)
doc = converter.convert(src).document
pathlib.Path(outdir, "output.md").write_text(doc.export_to_markdown())

chunks = [
    {"text": c.text, "meta": c.meta.export_json_dict()}
    for c in HybridChunker().chunk(doc)
]
pathlib.Path(outdir, "chunks.json").write_text(json.dumps(chunks, indent=2))
PY
      ;;

    *)
      echo "unknown mood: $mood" >&2
      usage
      exit 1
      ;;
  esac

  echo "-> Output written to: $outdir"
}

LOG_FILE="/data/logs/rag-doll/rag-doll-$(date +%Y%m%d-%H%M%S).log"
mkdir -p /data/logs/rag-doll

# Redirect all output through tee to log file while still showing in terminal
exec > >(tee -a "$LOG_FILE") 2>&1

cmd="${1:-}"
[[ $# -gt 0 ]] && shift

case "$cmd" in
  install) install "$@" ;;
  convert) convert "$@" ;;
  moods|--moods) usage ;;
  *) usage ;;
esac
