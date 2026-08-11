#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only

set -Eeuo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"
BUILD_ROOT=""
MINGW_ROOT=""
VERSION=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --build-root) BUILD_ROOT="$2"; shift 2 ;;
        --mingw-root) MINGW_ROOT="$2"; shift 2 ;;
        --version) VERSION="$2"; shift 2 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
done

test -n "$BUILD_ROOT" || { echo "--build-root is required" >&2; exit 2; }
test -n "$MINGW_ROOT" || { echo "--mingw-root is required" >&2; exit 2; }
test -n "$VERSION" || { echo "--version is required" >&2; exit 2; }
command -v makemsix >/dev/null 2>&1 || { echo "makemsix is required" >&2; exit 1; }
command -v rsvg-convert >/dev/null 2>&1 || { echo "rsvg-convert is required" >&2; exit 1; }

VERSION_NO_BUILD="${VERSION%%+*}"
IFS=. read -r -a VERSION_PARTS <<< "$VERSION_NO_BUILD"
while [ "${#VERSION_PARTS[@]}" -lt 4 ]; do
    VERSION_PARTS+=(0)
done
MSIX_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.${VERSION_PARTS[2]}.${VERSION_PARTS[3]}"

WORK="$BUILD_ROOT/msix-linux"
STAGE="$WORK/stage"
PACKAGE="$BUILD_ROOT/Gajim.msix"
rm -rf "$WORK" "$PACKAGE"
mkdir -p "$STAGE/assets"

# MSYS2 files are copied as regular files so the package does not contain
# Linux symlinks when the sysroot came from a tar export.
cp -aL "$MINGW_ROOT"/. "$STAGE/"

ICON="$REPO_ROOT/gajim/data/icons/hicolor/scalable/apps/gajim.svg"
for size in 44 50 150; do
    rsvg-convert -w "$size" -h "$size" \
        -o "$STAGE/gajim${size}x${size}.png" "$ICON"
done
for size in 44 50 150; do
    for scale in 100 125 150 200 400; do
        scaled_size=$(( (size * scale + 50) / 100 ))
        rsvg-convert -w "$scaled_size" -h "$scaled_size" \
            -o "$STAGE/assets/gajim${size}x${size}.scale-${scale}.png" "$ICON"
    done
done
for size in 16 24 32 48 256; do
    rsvg-convert -w "$size" -h "$size" \
        -o "$STAGE/assets/gajim44x44.targetsize-${size}.png" "$ICON"
    cp "$STAGE/assets/gajim44x44.targetsize-${size}.png" \
        "$STAGE/assets/gajim44x44.targetsize-${size}_altform-unplated.png"
    cp "$STAGE/assets/gajim44x44.targetsize-${size}.png" \
        "$STAGE/assets/gajim44x44.targetsize-${size}_altform-lightunplated.png"
done

sed "s/QL_VERSION/$MSIX_VERSION/" "$DIR/misc/appxmanifest.xml" \
    > "$STAGE/AppxManifest.xml"

# makemsix is the cross-platform MSIX packer. It does not implement the
# Windows SDK makepri resource compiler, so this creates an installable MSIX
# with ordinary manifest resources. Microsoft Store certification remains a
# separate validation step; a bundle/signature is not fabricated here.
makemsix pack -d "$STAGE" -p "$PACKAGE"

test -s "$PACKAGE"
echo "Created $PACKAGE"
