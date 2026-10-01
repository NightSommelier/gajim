#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== [1/5] Checking make.py build ==="
cd "$REPO_ROOT"
./make.py build

echo "=== [2/5] Running tests ==="
if command -v uv >/dev/null 2>&1; then
    uv run python -m pytest tests/common/test_client.py tests/common/test_styling.py -q
else
    PYTHONPATH=src python3 -m pytest tests/common/test_client.py tests/common/test_styling.py -q
fi

echo "=== [3/5] Checking linting & format ==="
if command -v uv >/dev/null 2>&1; then
    uv run ruff check src/
fi

echo "=== [4/5] Checking package build ==="
if command -v uv >/dev/null 2>&1; then
    uv build
fi

echo "=== [5/5] Checking release manifests ==="
test -f "$REPO_ROOT/flatpak/org.gajim.Gajim.yaml"
test -f "$REPO_ROOT/flatpak/org.gajim.Gajim.Devel.yaml"
test -f "$REPO_ROOT/flatpak/python3-modules.json"
test -f "$REPO_ROOT/mac/gajim.spec"
test -f "$REPO_ROOT/linux/gajim.spec"
test -f "$REPO_ROOT/win/_base.sh"

echo "=== All release readiness checks passed successfully! ==="
