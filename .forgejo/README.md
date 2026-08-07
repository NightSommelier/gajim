# Forgejo Actions

The repository workflow in `.forgejo/workflows/ci.yml` uses the following
execution policy:

- Pull requests targeting `master` run Linux unit tests, Ruff, and codespell.
- Pushes to `master` build the Linux packages, macOS application, and Windows
  installers.
- Tags matching `gajim-*` build all three targets and publish a Forgejo
  pre-release with the generated packages.
- `workflow_dispatch` runs the packaging jobs without publishing a release when
  `release_tag` is empty. Set `release_tag` to an existing `gajim-*` tag to
  republish that pre-release with the artifacts from the manual run.

Use a fork-specific tag such as `gajim-2.5.0.1-sommelier.1` for a patched
build. This creates a pre-release in the fork and does not claim to be an
upstream Gajim release.

The workflow targets the `debian-latest` amd64 runner for Linux checks and
packages. It also targets a native `macos-arm64` runner for the Apple Silicon
application build and a native Windows runner labelled `windows-amd64`.

The Linux pull request job runs the unit tests and static checks. The Linux
packaging job builds the metadata and publishes the Python source archive and
wheel as an artifact and, for a matching tag, as release assets.

This runner cannot build the macOS application bundle. macOS builds require a
runner running macOS with the matching architecture. An ARM64 Linux runner,
such as an Orange Pi Zero 2W, can be used for Linux ARM64 jobs but cannot
produce a valid macOS `.app` or `.dmg` bundle.

The `macos-arm64` packaging job requires a native Apple Silicon macOS runner with
Homebrew available. It installs the GTK, GStreamer, and Python dependencies,
builds the current checkout, and publishes the generated `.dmg` as an
artifact. For a matching tag, the `.dmg` is also attached to the Forgejo
pre-release. The runner must be registered with the label `macos-arm64:host`.

The `windows-amd64` packaging job requires a native Windows VM with MSYS2
UCRT64, NSIS, and Windows SDK MSIX tools. It runs `win/build.sh`, uploads
`Gajim.exe`, `Gajim-Portable.exe`, and `Gajim.msixbundle`, and attaches them to
matching Forgejo pre-releases. The Windows runner must be repository-scoped,
registered with the label `windows-amd64:host`, and kept online before a tag or
manual release run. The Windows Forgejo Runner binary is community-built, so
the VM remains isolated and is used only for this trusted repository. The build
root is configurable through `GAJIM_BUILD_ROOT`; the workflow uses `/c/_build_root`
(`C:\_build_root`) and copies the resulting installers back into the checkout
for artifact upload.
