#!/usr/bin/env bash
# Sets up a Python venv for Matrix-Game-3.5.
# Usage: ./setup_env.sh [cuda_tag]
#   cuda_tag defaults to cu128 (matches the CUDA 12.8 build tested in requirements.txt)
# On Windows, run from Git Bash/WSL or use setup_env.ps1.
set -euo pipefail

CUDA_TAG="${1:-cu128}"
VENV_DIR="${VENV_DIR:-.venv}"
PYTHON_BIN="${PYTHON_BIN:-}"
PYTHON_ARGS=()
ACTIVATE_SCRIPT=""

cd "$(dirname "$0")"

if [[ "${OS:-}" == "Windows_NT" || "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    ACTIVATE_SCRIPT="$VENV_DIR/Scripts/activate"
else
    ACTIVATE_SCRIPT="$VENV_DIR/bin/activate"
fi

if [[ -z "$PYTHON_BIN" ]]; then
    if [[ "${OS:-}" == "Windows_NT" || "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        if command -v py >/dev/null 2>&1; then
            PYTHON_BIN="py"
            PYTHON_ARGS=(-3.10)
        fi
    fi

    if [[ -z "$PYTHON_BIN" ]]; then
        for candidate in python3.10 python3 python; do
            if command -v "$candidate" >/dev/null 2>&1; then
                PYTHON_BIN="$candidate"
                break
            fi
        done
    fi
fi

if [[ -z "$PYTHON_BIN" ]]; then
    echo "No usable Python interpreter found. Set PYTHON_BIN or install Python 3.10+." >&2
    exit 1
fi

if [[ "$PYTHON_BIN" == "py" ]]; then
    if ! "$PYTHON_BIN" "${PYTHON_ARGS[@]}" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
        echo "$PYTHON_BIN must be Python 3.10 or newer." >&2
        exit 1
    fi
else
    if ! "$PYTHON_BIN" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
        echo "$PYTHON_BIN must be Python 3.10 or newer." >&2
        exit 1
    fi
fi

echo "Using $PYTHON_BIN ($($PYTHON_BIN ${PYTHON_ARGS[@]} --version 2>&1))"

if [[ "$PYTHON_BIN" == "py" ]]; then
    "$PYTHON_BIN" "${PYTHON_ARGS[@]}" -m venv "$VENV_DIR"
else
    "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

if [[ ! -f "$ACTIVATE_SCRIPT" ]]; then
    echo "Virtual environment was not created at $VENV_DIR." >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$ACTIVATE_SCRIPT"

python -m pip install --upgrade pip

# 1) PyTorch matching your CUDA version
python -m pip install torch torchvision --index-url "https://download.pytorch.org/whl/${CUDA_TAG}"

# 2) remaining dependencies
python -m pip install -r requirements.txt

echo "Done. Activate with: source ${ACTIVATE_SCRIPT}"

