# Gajim Fork Record

> [!NOTE]
> [Українська версія документації доступна у файлі FORK_UK.md](FORK_UK.md).

## Status

This repository is the maintained development fork for **Gajim**. It incorporates targeted platform stability enhancements, multi-platform release pipelines (Flatpak, Linux AppImage/portable, Windows MSIX/installer, macOS DMG), and custom messaging behavior while preserving full compatibility with upstream Gajim.

## Upstream Baseline

- Upstream repository: `https://gitlab.com/gajim/gajim.git` (`upstream`)
- Upstream releases mirror: `https://dev.gajim.org/gajim/gajim.git`
- Current upstream release baseline: **Gajim 2.6.0**
- Layout: Modern Python `src/` layout (`src/gajim/`) and standard `tests/` test tree
- Upstream merge: Commit `444b9b4b4 Merge upstream changes from gitlab.com/gajim/gajim (v2.6.0)`

Upstream synchronizations are fetched directly from `gitlab.com/gajim/gajim.git`, reviewed, conflict-resolved against fork-specific components, and verified with local build and test suites.

## Fork Enhancements & Architectural Boundaries

1. **Connectivity Resilience**:
   - `src/gajim/common/client_connectivity.py`: Provides reachability fallback when running against legacy or modified `nbxmpp` client runtimes without raising unhandled connection exceptions.
2. **Formatting & Markers**:
   - `src/gajim/common/styling.py`, `src/gajim/gtk/message_input.py`, `src/gajim/gtk/conversation/plain_widget.py`: Refined inline message styling, marker hiding, and whitespace preservation.
3. **Multi-Platform Packaging & Release Pipelines**:
   - **Linux**: Standalone AppImage via `linuxdeploy`/`appimagetool` and portable `tar.zst` (`linux/build-portable.sh`, `linux/gajim.spec`).
   - **Flatpak**: Automated standalone Flatpak single-file bundle generation using GNOME 51 platform and modular `python3-modules.json` (`.forgejo/scripts/build-flatpak.sh`, `flatpak/`).
   - **Windows**: Automated MSYS2 UCRT64 build producing standalone NSIS installers and modern MSIX application packages (`win/build.sh`, `win/_base.sh`).
   - **macOS**: Isolated virtualenv-based bundling for Apple Silicon (`arm64`, macOS 15+) generating notarization-ready DMG images (`mac/gajim-macos-helper.sh`, `mac/gajim.spec`).
4. **CI/CD Automation & GitHub Releases**:
   - Centralized release workflow ([`.github/workflows/build-release.yml`](.github/workflows/build-release.yml)) building packages across Linux, Flatpak, Windows, and macOS with cryptographic SHA-256 checksums and automated GitHub Release publishing.

## Branching & Release Policy

- **`master`**: Primary development branch. Must remain stable and buildable across all target platforms.
- **`gajim-*` tags**: Release tags (e.g., `gajim-2.6.0.1-sommelier.1`) trigger automated multi-platform build and publication of release packages and checksums.

## Local Development Environment

Reproducible Nix development environment provided via `shell.nix`:
```bash
nix-shell .github/nix/shell.nix
uv sync
uv run python -m pytest tests/common/test_client.py tests/common/test_styling.py
uv run ruff check src/
uv build
```
