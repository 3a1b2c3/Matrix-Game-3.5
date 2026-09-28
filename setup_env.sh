#!/usr/bin/env bash
# Sets up a Python venv for Matrix-Game-3.5 on Linux.
# Usage: ./setup_env.sh [cuda_tag]
#   cuda_tag defaults to cu128 (matches the CUDA 12.8 build tested in requirements.txt)
set -euo pipefail

CUDA_TAG="${1:-cu128}"
VENV_DIR="${VENV_DIR:-.venv}"

cd "$(dirname "$0")"

if ! command -v python3.10 >/dev/null 2>&1; then
    echo "python3.10 not found. Install Python 3.10 before running this script." >&2
    exit 1
fi

python3.10 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

pip install --upgrade pip

# 1) PyTorch matching your CUDA version
pip install torch torchvision --index-url "https://download.pytorch.org/whl/${CUDA_TAG}"

# 2) remaining dependencies
pip install -r requirements.txt

echo "Done. Activate with: source ${VENV_DIR}/bin/activate"
