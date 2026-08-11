# Forgejo Actions

The repository workflow in `.forgejo/workflows/ci.yml` uses the following
execution policy:

- Pull requests targeting `master` run Linux unit tests, Ruff, and codespell.
- Pushes to `master` build Linux packages, a Linux portable tarball and
  AppImage, a Flatpak bundle, the macOS application, and Windows installers.
- Tags matching `gajim-*` build all four artifacts and publish a Forgejo
  pre-release with the generated packages.
- `workflow_dispatch` runs the packaging jobs without publishing a release when
  `release_tag` is empty. Set `release_tag` to an existing `gajim-*` tag to
  republish that pre-release with the artifacts from the manual run.

Use a fork-specific tag such as `gajim-2.5.0.1-sommelier.1` for a patched
build. This creates a pre-release in the fork and does not claim to be an
upstream Gajim release.

The workflow targets the repository's NixOS host runner with the labels
`linux-amd64`, `flatpak-amd64`, and `windows-cross-amd64`. The last label is
also a Linux runner: it uses the local Nix shell, MinGW, NSIS, and `makemsix`
to build the Windows artefacts without Wine. It also targets a native
`macos-arm64` runner for the Apple Silicon application build.

The Linux pull request job runs the unit tests and static checks. The Linux
packaging job builds the metadata and publishes the Python source archive and
wheel as an artifact. The Flatpak job builds the bundle from the checked-out
commit, not from an unrelated upstream branch. For a matching tag, both are
attached to the Forgejo pre-release.

This runner cannot build the macOS application bundle. macOS builds require a
runner running macOS with the matching architecture. An ARM64 Linux runner,
such as an Orange Pi Zero 2W, can be used for Linux ARM64 jobs but cannot
produce a valid macOS `.app` or `.dmg` bundle.

The `macos-arm64` packaging job requires a native Apple Silicon macOS runner with
Homebrew available. It installs the GTK, GStreamer, and Python dependencies,
builds the current checkout, and publishes the generated `.dmg` as an
artifact. For a matching tag, the `.dmg` is also attached to the Forgejo
pre-release. The runner must be registered with the label `macos-arm64:host`.

The `windows-amd64-cross` packaging job uses a prepared MSYS2 UCRT64 sysroot.
Prepare it once on the Windows VM with the existing `win/build.sh`, export its
clean `C:\_build_root\ucrt64` directory as `GAJIM_MINGW_ROOT`. Also export the
uncleaned `C:\msys64\ucrt64` development tree as `GAJIM_MINGW_DEV_ROOT`; it
contains `Python.h` and `libpython*.dll.a` needed only to link the launcher.
Set these environment variables in the Linux Forgejo runner:

```yaml
runner:
  envs:
    GAJIM_NIX_SHELL: /home/sommelier/projects/gajim/nix/shell.nix
    GAJIM_BUILD_ROOT: /home/sommelier/forgejo-runner/cache/windows-build
    GAJIM_MINGW_ROOT: /home/sommelier/forgejo-runner/cache/msys2/ucrt64
    GAJIM_MINGW_DEV_ROOT: /home/sommelier/forgejo-runner/cache/msys2/ucrt64-dev
    UV_CACHE_DIR: /home/sommelier/forgejo-runner/cache/uv
    PIP_CACHE_DIR: /home/sommelier/forgejo-runner/cache/pip
    XDG_CACHE_HOME: /home/sommelier/forgejo-runner/cache/xdg
```

Register that runner with `windows-cross-amd64:host` in addition to the Linux
labels. The direct builder creates `Gajim.exe`, `Gajim-Portable.exe`, and
`Gajim.msix`. The MSIX is packed by Linux `makemsix`; it does not contain the
Windows SDK-generated `resources.pri`, bundle, or signature, so Store
certification must be verified separately.
