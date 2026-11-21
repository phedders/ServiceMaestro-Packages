# Service Maestro package repositories

Static APT and DNF repositories for [Service Maestro](https://github.com/phedders/ServiceMaestro), published with GitHub Pages.

- Site: https://phedders.github.io/ServiceMaestro-Packages/
- APT repository: https://phedders.github.io/ServiceMaestro-Packages/apt/
- DNF repository: https://phedders.github.io/ServiceMaestro-Packages/rpm/

The `gh-pages` branch is the published site. The
[`Publish package repositories`](https://github.com/phedders/ServiceMaestro/blob/main/.github/workflows/packages-pages.yml)
workflow in the main Service Maestro repository downloads the latest public
release assets and builds:

- a flat APT repository containing the CLI and server `.deb` packages;
- a `createrepo_c` RPM repository containing the server x86_64 package;
- `SHA256SUMS` for every published file;
- an install-instructions page.

## Updating

The workflow runs automatically after a successful **Release packages** run and can
also be started manually. An optional release tag can be supplied; leaving it blank
uses the latest release.

```sh
gh workflow run packages-pages.yml --repo phedders/ServiceMaestro
```

## Local build

```sh
mkdir -p downloads
gh release download --repo phedders/ServiceMaestro --dir downloads \
  --pattern 'service-maestro-cli_*.deb' \
  --pattern 'service-maestro-server_*_amd64.deb' \
  --pattern 'service-maestro-server-*.x86_64.rpm'
./scripts/build-site.sh v0.2.0
```

The generated `site/` directory is not committed; it is published to the `gh-pages` branch by the workflow.

## Signing

The repositories are currently unsigned, so the instructions use `[trusted=yes]` for APT and `gpgcheck=0` for DNF. Add a signing key and sign `Release`/`InRelease` and RPMs before treating the repositories as trusted for production use.
