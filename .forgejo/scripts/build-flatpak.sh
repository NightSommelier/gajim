#!/usr/bin/env bash

set -euo pipefail

manifest=.gajim-ci-flatpak.yaml
cp flatpak/org.gajim.Gajim.yaml "$manifest"
trap 'rm -f "$manifest"' EXIT

python3 - "$manifest" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
pattern = re.compile(
    r"      - type: git\n"
    r"        url: [^\n]+\n"
    r"        tag: [^\n]+"
)
text, count = pattern.subn("      - type: dir\n        path: .", text, count=1)
if count != 1:
    raise SystemExit("could not locate the Gajim source in the Flatpak manifest")
path.write_text(
    text.replace("path: app-overrides.json", "path: flatpak/app-overrides.json")
    .replace("path: farstream-make-4.3.patch", "path: flatpak/farstream-make-4.3.patch")
    .replace("- python3-modules.json", "- flatpak/python3-modules.json")
)
PY

flatpak --user remote-add --if-not-exists \
  flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak-builder --user --repo=flatpak_repo \
  --install-deps-from=flathub --force-clean \
  flatpak_build "$manifest"

mkdir -p ci-artifacts
flatpak build-bundle flatpak_repo ci-artifacts/gajim-flatpak.flatpak \
  org.gajim.Gajim \
  --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
test -s ci-artifacts/gajim-flatpak.flatpak
