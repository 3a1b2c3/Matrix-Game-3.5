#!/usr/bin/env bash
# Downloads Matrix-Game-3.5 checkpoints (base and/or distilled) plus shared
# dependencies (Wan2.2-TI2V-5B, Depth-Anything-3) into checkpoints/.
#
# Usage: ./download_models.sh [base|distilled|all]
#   base      - Matrix-Game-3.5-Base + shared deps
#   distilled - Matrix-Game-3.5-Distilled + shared deps
#   all       - both (default)
set -euo pipefail

MODE="${1:-all}"
VENV_DIR="${VENV_DIR:-.venv}"
cd "$(dirname "$0")"

if [ -f "$VENV_DIR/bin/activate" ]; then
    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
elif ! command -v hf >/dev/null 2>&1; then
    echo "No venv found at $VENV_DIR and no 'hf' on PATH. Run ./setup_env.sh first." >&2
    exit 1
fi

pip install -U "huggingface_hub<2.0" >/dev/null  # transformers requires <2.0

mkdir -p checkpoints

download_base() {
    hf download RiemannDynamics/Matrix-Game-3.5-Base --local-dir checkpoints/Matrix-Game-3.5-Base
    ln -sf Matrix-Game-3.5-Base/first-person.safetensors checkpoints/first-person.safetensors
    ln -sf Matrix-Game-3.5-Base/third-person.safetensors checkpoints/third-person.safetensors
}

download_distilled() {
    hf download RiemannDynamics/Matrix-Game-3.5-Distilled --local-dir checkpoints/Matrix-Game-3.5-Distilled
    ln -sf Matrix-Game-3.5-Distilled/first-person.safetensors checkpoints/distilled-first-person.safetensors
}

download_shared() {
    hf download Wan-AI/Wan2.2-TI2V-5B --exclude "assets/*" --exclude "examples/*" --local-dir checkpoints/Wan2.2-TI2V-5B
    hf download depth-anything/DA3NESTED-GIANT-LARGE-1.1 --local-dir checkpoints/DA3NESTED-GIANT-LARGE-1.1
}

case "$MODE" in
    base)
        download_base
        download_shared
        ;;
    distilled)
        download_distilled
        download_shared
        ;;
    all)
        download_base
        download_distilled
        download_shared
        ;;
    *)
        echo "Unknown mode: $MODE (expected base|distilled|all)" >&2
        exit 1
        ;;
esac

echo "Done. Checkpoints under checkpoints/"
