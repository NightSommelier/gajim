# Forgejo Actions

The repository workflow in `.forgejo/workflows/ci.yml` uses the following
execution policy:

- Pull requests targeting `master` run Linux unit tests, Ruff, and codespell.
- Pushes to `master` build the Linux packages and the macOS application.
- Tags matching `gajim-*` build both platforms and publish a Forgejo
  pre-release with the generated packages.
- `workflow_dispatch` runs the packaging jobs without publishing a release when
  `release_tag` is empty. Set `release_tag` to an existing `gajim-*` tag to
  republish that pre-release with the artifacts from the manual run.

Use a fork-specific tag such as `gajim-2.5.0.1-sommelier.1` for a patched
build. This creates a pre-release in the fork and does not claim to be an
upstream Gajim release.

The workflow targets the `debian-latest` amd64 runner for Linux checks and
packages. It also targets a native `macos-arm64` runner for the Apple Silicon
application build.

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

Windows packaging is not part of this workflow yet. The repository's Windows
build requires a native Windows MSYS2 UCRT64 environment, NSIS, and MSIX tools;
it cannot run in the Debian container. Add a Windows self-hosted Forgejo runner
with a dedicated `windows-amd64` label before adding a Windows packaging job.
