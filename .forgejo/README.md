# Forgejo Actions

The repository workflow in `.forgejo/workflows/ci.yml` targets the
`debian-latest` amd64 runner. It runs the unit tests and static checks, builds
the metadata, and publishes the Python source archive and wheel as an artifact.

This runner cannot build the macOS application bundle. macOS builds require a
runner running macOS with the matching architecture. An ARM64 Linux runner,
such as an Orange Pi Zero 2W, can be used for Linux ARM64 jobs but cannot
produce a valid macOS `.app` or `.dmg` bundle.
