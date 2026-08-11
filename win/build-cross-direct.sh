#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Build the Windows artefacts on Linux without executing Windows programs.
#
# MINGW_ROOT must be a prepared MSYS2 UCRT64 sysroot. It is produced once on
# a native Windows/MSYS2 machine and then cached on the Linux builder. The
# per-commit work below is Linux-side: translations, Python package install,
# MinGW launcher compilation, NSIS, and MSIX packaging.

set -Eeuo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"
BUILD_ROOT="${GAJIM_BUILD_ROOT:-$REPO_ROOT/win/_build_root}"
MINGW_ROOT="${GAJIM_MINGW_ROOT:-$BUILD_ROOT/ucrt64}"
MINGW_DEV_ROOT="${GAJIM_MINGW_DEV_ROOT:-$MINGW_ROOT}"
PYTHON_VERSION="${GAJIM_WINDOWS_PYTHON_VERSION:-3.14}"
PACKAGE_DIR="$MINGW_ROOT/lib/python$PYTHON_VERSION/site-packages"

fail() {
    printf 'build-cross-direct: %s\n' "$*" >&2
    exit 1
}

require_file() {
    test -f "$1" || fail "required file is missing: $1"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "required command is missing: $1"
}

require_command curl
require_command gcc
require_command file
require_command makensis
require_command msgfmt
require_command objdump
require_command 7z
require_command rsvg-convert
require_command uv
require_file "$MINGW_ROOT/bin/python$PYTHON_VERSION.exe"
require_file "$MINGW_DEV_ROOT/include/python$PYTHON_VERSION/Python.h"
require_file "$MINGW_DEV_ROOT/lib/libpython$PYTHON_VERSION.dll.a"

mkdir -p "$PACKAGE_DIR" "$BUILD_ROOT"
cd "$REPO_ROOT"

echo "Using prepared MSYS2 UCRT64 sysroot: $MINGW_ROOT"
echo "Using build root: $BUILD_ROOT"

# win/build.sh does this in the Windows Python interpreter. The operation is
# platform-independent, so run it with the checked-out Linux environment.
uv run python make.py build --dist=win

# Install only Gajim itself. Runtime dependencies (GTK, GStreamer, Python
# extension modules and Windows-only packages) are already in the prepared
# UCRT64 sysroot. This avoids putting Linux .so wheels into site-packages.
uv pip install --target "$PACKAGE_DIR" --no-deps --no-build-isolation .

QL_VERSION="${GAJIM_VERSION:-$(sed -n 's/^__version__ = ["'"']\([^"'"']*\)["'"'].*/\1/p' gajim/__init__.py)}"
test -n "$QL_VERSION" || fail "could not determine Gajim version"
QL_VERSION_DESC="${GAJIM_VERSION_DESC:-$QL_VERSION}"
echo "Determined ProductVersion: $QL_VERSION_DESC"

# Build the Windows launchers directly with MinGW. The source is the same
# launcher used by win/build.sh; only the compiler invocation is changed.
export CC="${GAJIM_WINDOWS_CC:-x86_64-w64-mingw32-gcc}"
export WINDRES="${GAJIM_WINDOWS_WINDRES:-x86_64-w64-mingw32-windres}"
export GAJIM_CROSS_CFLAGS="-I$MINGW_DEV_ROOT/include/python$PYTHON_VERSION"
export GAJIM_CROSS_LIBS="-L$MINGW_DEV_ROOT/lib -lpython$PYTHON_VERSION"
test -x "$(command -v "$CC")" || fail "cross compiler is missing: $CC"
test -x "$(command -v "$WINDRES")" || fail "cross resource compiler is missing: $WINDRES"

"$DIR/misc/create_launcher.py" "$QL_VERSION" "$MINGW_ROOT/bin"

# Keep the same spelling dictionaries and application icons as the upstream
# Windows build. Cache the archive between runs when a build root is reused.
SPELLER_ZIP="$BUILD_ROOT/speller_dicts.zip"
if [ ! -s "$SPELLER_ZIP" ]; then
    curl -fL -o "$SPELLER_ZIP" \
        https://gajim.org/downloads/snap/win/build/speller_dicts.zip
fi
7z x -aoa -o"$MINGW_ROOT/share" "$SPELLER_ZIP" >/dev/null

rm -rf "$MINGW_ROOT/share/icons/hicolor"
cp -a gajim/data/icons/hicolor "$MINGW_ROOT/share/icons/"

# These cache files are data files, not Windows executables. Build them with
# Linux-side GLib tools when available; an absent cache is harmless.
if command -v gtk4-update-icon-cache >/dev/null 2>&1; then
    gtk4-update-icon-cache --force "$MINGW_ROOT/share/icons/hicolor" || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
    glib-compile-schemas "$MINGW_ROOT/share/glib-2.0/schemas" || true
fi

# The native script runs compileall and depcheck inside Windows Python. The
# former is optional bytecode and the latter loads Windows GI libraries, so
# neither is safe to execute directly on Linux. objdump still gives us a
# useful static check that the generated launchers are PE amd64 binaries.
file "$MINGW_ROOT/bin/Gajim.exe" "$MINGW_ROOT/bin/Gajim-Debug.exe"
objdump -f "$MINGW_ROOT/bin/Gajim.exe" | grep -q 'pei-x86-64' || \
    fail "Gajim.exe is not a PE amd64 executable"

cd "$BUILD_ROOT"
# The existing NSIS scripts expect the runtime tree at BUILD_ROOT/ucrt64.
# Keep the large prepared sysroot in its own cache when requested, but expose
# it at the path those scripts already use.
if [ "$MINGW_ROOT" != "$BUILD_ROOT/ucrt64" ]; then
    if [ -e "$BUILD_ROOT/ucrt64" ] && [ ! -L "$BUILD_ROOT/ucrt64" ]; then
        fail "$BUILD_ROOT/ucrt64 exists and is not a symlink"
    fi
    ln -sfn "$MINGW_ROOT" "$BUILD_ROOT/ucrt64"
fi
makensis -NOCD -DVERSION="$QL_VERSION_DESC" -DARCH=x86_64 \
    -DPREFIX=ucrt64 "$DIR/misc/gajim.nsi"
makensis -NOCD -DVERSION="$QL_VERSION_DESC" -DARCH=x86_64 \
    -DPREFIX=ucrt64 "$DIR/misc/gajim-portable.nsi"

"$DIR/build-msix-direct.sh" \
    --build-root "$BUILD_ROOT" \
    --mingw-root "$MINGW_ROOT" \
    --version "$QL_VERSION"

mkdir -p "$REPO_ROOT/ci-artifacts"
cp -f "$BUILD_ROOT/Gajim.exe" "$REPO_ROOT/ci-artifacts/"
cp -f "$BUILD_ROOT/Gajim-Portable.exe" "$REPO_ROOT/ci-artifacts/"
cp -f "$BUILD_ROOT/Gajim.msix" "$REPO_ROOT/ci-artifacts/"

echo "Windows artefacts written to $REPO_ROOT/ci-artifacts"
