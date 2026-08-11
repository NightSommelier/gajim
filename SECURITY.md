# Security policy

## Reporting a vulnerability

Please do not publish security-sensitive details, credentials, private keys,
or a working exploit in a public issue. Use this repository's **Security** tab
and create a private vulnerability report instead.

Repository maintainers must enable GitHub private vulnerability reporting in
the repository settings for this channel to be available. If it is unavailable,
open a minimal public issue asking for a private contact channel; do not add
technical vulnerability details to that issue.

Include the affected revision or release tag, platform, reproduction steps,
impact, and any suggested mitigation. Reports are handled on a best-effort
basis; no response-time promise is made by this fork.

## Scope

The supported development branch is `master` and this fork's `gajim-*` release
tags. Upstream Gajim components may also need to be reported to the upstream
project through its own security process.

Do not treat unsigned CI artifacts, development pre-releases, or the presence
of a GitHub release as a security guarantee. Verify checksums and signatures
where applicable before installation.
