#!/usr/bin/env bash
# Runs the distilled first-person example end to end (activates the venv,
# then calls infer_distilled.py on the bundled suburban_street_6blocks sample).
# See DISTILLED_INFERENCE.md for the full model (infer.py) equivalent.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

VENV_DIR="${VENV_DIR:-.venv}"
if [[ -f "$VENV_DIR/bin/activate" ]]; then
    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
else
    echo "No venv found at $VENV_DIR. Run ./setup_env.sh first." >&2
    exit 1
fi

CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}" python infer_distilled.py \
    --config configs/infer_distilled_6blocks.yaml \
    --checkpoint checkpoints/distilled-first-person.safetensors \
    --image samples/distilled/suburban_street_6blocks/input.png \
    --camera samples/distilled/suburban_street_6blocks/camera.npz \
    --caption samples/distilled/suburban_street_6blocks/caption.json \
    --output result.mp4

echo "Done. Output: $REPO_DIR/result.mp4"
