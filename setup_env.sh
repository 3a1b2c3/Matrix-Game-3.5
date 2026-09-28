#!/usr/bin/env bash
# Sets up a Python venv for Matrix-Game-3.5 on Linux.
# Usage: ./setup_env.sh [cuda_tag]
#   cuda_tag defaults to cu128 (matches the CUDA 12.8 build tested in requirements.txt)
set -euo pipefail

CUDA_TAG="${1:-cu128}"
VENV_DIR="${VENV_DIR:-.venv}"
PYTHON_BIN="${PYTHON_BIN:-}"

cd "$(dirname "$0")"

if [[ -z "$PYTHON_BIN" ]]; then
    for candidate in python3.10 python3 python; do
        if command -v "$candidate" >/dev/null 2>&1; then
            PYTHON_BIN="$candidate"
            break
        fi
    done
fi

if [[ -z "$PYTHON_BIN" ]]; then
    echo "No usable Python interpreter found. Set PYTHON_BIN or install Python 3.10+." >&2
    exit 1
fi

if ! "$PYTHON_BIN" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
    echo "$PYTHON_BIN must be Python 3.10 or newer." >&2
    exit 1
fi

echo "Using $PYTHON_BIN ($($PYTHON_BIN --version 2>&1))"

"$PYTHON_BIN" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

pip install --upgrade pip

# 1) PyTorch matching your CUDA version
pip install torch torchvision --index-url "https://download.pytorch.org/whl/${CUDA_TAG}"

# 2) remaining dependencies
pip install -r requirements.txt

echo "Done. Activate with: source ${VENV_DIR}/bin/activate"
