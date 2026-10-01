# Gajim [![Build and release packages](https://github.com/NightSommelier/gajim/actions/workflows/build-release.yml/badge.svg?branch=master)](https://github.com/NightSommelier/gajim/actions/workflows/build-release.yml) [![License: GPL v3](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](COPYING) [![Latest Release](https://img.shields.io/github/v/release/NightSommelier/gajim?include_prereleases&label=release)](https://github.com/NightSommelier/gajim/releases)

A fully-featured, extensible XMPP chat client built with Python and GTK4.

> [!NOTE]
> [Українська версія документації доступна у файлі README_UK.md](README_UK.md).

Gajim aims to be an easy-to-use and fully-featured XMPP client. Chat with friends or family, securely share encrypted images and files, record voice messages, and participate in multi-user group chats with OMEMO end-to-end encryption.

This maintained development fork provides multi-platform release pipelines, modern GNOME Platform 51 Flatpak packages, Apple Silicon macOS DMG images, Windows NSIS/MSIX bundles, Linux portable AppImages, and resilient network connectivity fallbacks.

---

## Key Features & Fork Highlights

- **Modern Upstream Baseline (v2.6.0)**: Built on the official Gajim 2.6.0 release featuring standard `src/` layout, Python 3.12+ compatibility, and `httpx2` asynchronous HTTP engine.
- **End-to-End Encryption**: State-of-the-art OMEMO encryption powered by `omemo-dr`, with additional OpenPGP and PGP support.
- **Network Resilience**: Custom connectivity guards ([`check_client_connectivity`](src/gajim/common/client_connectivity.py)) ensuring automatic reachability verification and graceful reconnection across diverse network topologies.
- **Enhanced Message Formatting**: Refined message input styling, formatting marker toggling, and whitespace preservation in chat views.
- **Multi-Platform Distribution Suite**:
  - **Linux**: Single-bundle Flatpak, standalone AppImage, and portable `.tar.zst` archive.
  - **Windows**: Native UCRT64 MSYS2 setup installer and Windows Store MSIX application package.
  - **macOS**: Isolated virtualenv-based bundling for Apple Silicon (`arm64`, macOS 15+) producing ready-to-run `.dmg` disk images.
- **Automated CI/CD with SHA-256 Checksums**: Every release builds all target packages in parallel on GitHub Actions with standalone cryptographic checksum verification files.

---

## Downloads

Official multi-platform binaries from our automated release pipeline:

| Platform | Format / Package | Architecture | Checksum |
| :--- | :--- | :--- | :--- |
| **Windows** | [Gajim.exe](https://github.com/NightSommelier/gajim/releases/latest/download/Gajim.exe) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/Gajim.exe.sha256) |
| **Windows Store** | [Gajim.msixbundle](https://github.com/NightSommelier/gajim/releases/latest/download/Gajim.msixbundle) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/Gajim.msixbundle.sha256) |
| **Linux (Portable)** | [gajim-linux-amd64-portable.tar.zst](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-linux-amd64-portable.tar.zst) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-linux-amd64-portable.tar.zst.sha256) |
| **Linux (AppImage)** | [gajim-linux-amd64.AppImage](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-linux-amd64.AppImage) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-linux-amd64.AppImage.sha256) |
| **Linux (Flatpak)** | [gajim-flatpak.flatpak](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-flatpak.flatpak) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-flatpak.flatpak.sha256) |
| **macOS** | [Gajim.dmg](https://github.com/NightSommelier/gajim/releases/latest) | Apple Silicon (arm64) | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest) |

For past builds and changelogs, visit [GitHub Releases](https://github.com/NightSommelier/gajim/releases).

---

## Repository Structure & Documentation Map

```text
gajim/
├── src/gajim/              # Application sources (common, GTK4 UI, plugins, data)
├── tests/                  # Unit and integration test suite
├── linux/                  # Linux AppImage, PyInstaller, and portable packaging scripts
├── mac/                    # macOS bundle scripts, gajim.spec, and helper tools
├── win/                    # Windows MSYS2 build scripts, NSIS definitions, and MSIX packaging
├── flatpak/                # Flatpak manifests (GNOME 51 platform) and dependency definitions
└── .github/workflows/      # Automated multi-platform CI/CD and release pipelines
```

- [**FORK.md**](FORK.md): Architectural boundaries, upstream synchronization baseline, and fork features.
- [**CONTRIBUTING.md**](CONTRIBUTING.md): Git commit message standards, pre-commit setup, and pull request guidelines.
- [**SECURITY.md**](SECURITY.md): Vulnerability reporting policy, security contacts, and scope.
- [**mac/README.md**](mac/README.md): Detailed macOS packaging and local developer environment guide.
- [**win/README.md**](win/README.md): MSYS2 UCRT64 build instructions and MSIX registration details.
- [**flatpak/README.md**](flatpak/README.md): Flatpak installation, plugins, and custom CA certificates.

---

## Requirements

### Runtime Requirements

- [Python](https://www.python.org/) (>=3.12)
- [Gtk4](https://gitlab.gnome.org/GNOME/gtk) (>=4.17.5)
- [libadwaita](https://gitlab.gnome.org/GNOME/libadwaita) (>=1.7.0)
- [PyGObject](https://pypi.org/project/PyGObject/) (>=3.53.0)
- [pycairo](https://pypi.org/project/pycairo/)
- [cairo](https://gitlab.freedesktop.org/cairo/cairo) (>=1.16.0)
- [Pango](https://gitlab.gnome.org/GNOME/pango) (>=1.50.0)
- [GLib](https://gitlab.gnome.org/GNOME/glib) (>=2.80.0)
- [GtkSourceView5](https://gitlab.gnome.org/GNOME/gtksourceview)
- [libspelling](https://gitlab.gnome.org/GNOME/libspelling)
- [GStreamer](https://gitlab.freedesktop.org/gstreamer/gstreamer) and `gst-plugins-base`
- [nbxmpp](https://pypi.org/project/nbxmpp/) (>=7.4.0)
- [omemo-dr](https://gitlab.com/gajim/omemo-dr) (>=1.2.0)
- [cryptography](https://pypi.org/project/cryptography/) (>=43.0.0)
- [httpx2](https://pypi.org/project/httpx2/) & [h2](https://pypi.org/project/h2/)
- [Pillow](https://pypi.org/project/Pillow/) (>=9.1.0)
- [SQLAlchemy](https://pypi.org/project/SQLAlchemy/) (>=2.0.0)
- [sqlite](https://www.sqlite.org/) (>=3.35.0)
- [keyring](https://pypi.org/project/keyring/)
- [truststore](https://pypi.org/project/truststore/)
- [qrcode](https://pypi.org/project/qrcode/) (>=7.3.1)
- [emoji](https://pypi.org/project/emoji/) (>=2.6.0)

---

## Local Development & Building

The easiest way to develop locally is using [uv](https://docs.astral.sh/uv/) and Nix:

```bash
# Enter reproducible environment
nix-shell .github/nix/shell.nix

# Synchronize dependencies
uv sync

# Run tests
uv run python -m pytest tests/common/test_client.py tests/common/test_styling.py

# Lint & Format
uv run ruff check src/
uv run ruff format --check src/

# Build package wheel
uv build
```

To run Gajim in development mode:
```bash
uv run gajim --user-profile dev
```

---

## Releases & Packaging

Every push of a `gajim-*` tag automatically triggers the [Multi-Platform Release Pipeline](.github/workflows/build-release.yml). All packages are compiled in parallel in clean virtual environments and published to GitHub Releases accompanied by individual SHA-256 verification files.

(C) 2003-2026 The Gajim Team & Contributors  
[https://gajim.org](https://gajim.org)
