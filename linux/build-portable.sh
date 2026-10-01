#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only

set -Eeuo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"
OUT_DIR="${GAJIM_OUTPUT_DIR:-$REPO_ROOT/ci-artifacts}"
WORK_DIR="$REPO_ROOT/.linux-portable"
APP_DIR="$WORK_DIR/AppDir"

command -v uv >/dev/null 2>&1 || { echo "uv is required" >&2; exit 1; }
command -v linuxdeploy >/dev/null 2>&1 || { echo "linuxdeploy is required" >&2; exit 1; }
command -v appimagetool >/dev/null 2>&1 || { echo "appimagetool is required" >&2; exit 1; }
command -v zstd >/dev/null 2>&1 || { echo "zstd is required" >&2; exit 1; }
command -v g++ >/dev/null 2>&1 || { echo "g++ is required" >&2; exit 1; }

cd "$REPO_ROOT"
uv run python make.py build --dist=unix
uv run --with pyinstaller pyinstaller --clean --noconfirm linux/gajim.spec

test -x "$REPO_ROOT/dist/Gajim/Gajim"
mkdir -p "$OUT_DIR" "$APP_DIR/usr/lib/gajim" "$APP_DIR/usr/bin" \
    "$APP_DIR/usr/share/applications" \
    "$APP_DIR/usr/share/icons/hicolor/scalable/apps"
rm -rf "$APP_DIR/usr/lib/gajim"/*
rm -f "$APP_DIR/AppRun" "$APP_DIR/org.gajim.Gajim.desktop" \
    "$APP_DIR/org.gajim.Gajim.svg"
cp -a "$REPO_ROOT/dist/Gajim"/. "$APP_DIR/usr/lib/gajim/"
ln -sfn ../lib/gajim/Gajim "$APP_DIR/usr/bin/gajim"

sed 's/^Exec=.*/Exec=gajim %u/; s/^Icon=.*/Icon=org.gajim.Gajim/' \
    "$REPO_ROOT/dist/metadata/org.gajim.Gajim.desktop" \
    > "$APP_DIR/usr/share/applications/org.gajim.Gajim.desktop"
if [ -f "$REPO_ROOT/src/gajim/data/icons/hicolor/scalable/apps/gajim.svg" ]; then
    cp "$REPO_ROOT/src/gajim/data/icons/hicolor/scalable/apps/gajim.svg" \
        "$APP_DIR/usr/share/icons/hicolor/scalable/apps/org.gajim.Gajim.svg"
else
    cp "$REPO_ROOT/gajim/data/icons/hicolor/scalable/apps/gajim.svg" \
        "$APP_DIR/usr/share/icons/hicolor/scalable/apps/org.gajim.Gajim.svg"
fi

# linuxdeploy performs dependency deployment and creates AppRun. Its optional
# AppImage output plugin is not included by the Nix package, so appimagetool
# creates the final image from the prepared AppDir.
rm -f "$OUT_DIR/gajim-linux-amd64.AppImage"
LIBSTDCXX="$(g++ -print-file-name=libstdc++.so.6)"
test -f "$LIBSTDCXX"
NIX_LIBRARY_PATH=""
for flag in ${NIX_LDFLAGS:-}; do
    case "$flag" in
        -L/*) NIX_LIBRARY_PATH="${NIX_LIBRARY_PATH:+$NIX_LIBRARY_PATH:}${flag#-L}" ;;
    esac
done
DEPLOY_LD_LIBRARY_PATH="$(dirname "$LIBSTDCXX"):$APP_DIR/usr/lib/gajim:$APP_DIR/usr/lib/gajim/_internal"
DEPLOY_LD_LIBRARY_PATH="${DEPLOY_LD_LIBRARY_PATH}${NIX_LIBRARY_PATH:+:$NIX_LIBRARY_PATH}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
set +e
LD_LIBRARY_PATH="$DEPLOY_LD_LIBRARY_PATH" \
linuxdeploy --appdir "$APP_DIR" \
    --desktop-file "$APP_DIR/usr/share/applications/org.gajim.Gajim.desktop" \
    --icon-file "$APP_DIR/usr/share/icons/hicolor/scalable/apps/org.gajim.Gajim.svg"
LINUXDEPLOY_STATUS=$?
set -e
if (( LINUXDEPLOY_STATUS != 0 )); then
    if (( LINUXDEPLOY_STATUS == 139 )) && test -x "$APP_DIR/AppRun"; then
        echo "linuxdeploy completed deployment but crashed during final cleanup; continuing with the validated AppDir" >&2
    else
        echo "linuxdeploy failed with status $LINUXDEPLOY_STATUS" >&2
        exit "$LINUXDEPLOY_STATUS"
    fi
fi
test -x "$APP_DIR/AppRun"

ARCH=x86_64 appimagetool "$APP_DIR" "$OUT_DIR/gajim-linux-amd64.AppImage"

tar --zstd -cf "$OUT_DIR/gajim-linux-amd64-portable.tar.zst" -C "$REPO_ROOT/dist" Gajim
test -s "$OUT_DIR/gajim-linux-amd64.AppImage"
test -s "$OUT_DIR/gajim-linux-amd64-portable.tar.zst"
printf 'Created Linux artefacts in %s\n' "$OUT_DIR"
