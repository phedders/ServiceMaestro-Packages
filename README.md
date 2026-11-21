# Service Maestro package repositories

Static APT and DNF repositories for [Service Maestro](https://github.com/phedders/ServiceMaestro), published with GitHub Pages.

- Site: https://phedders.github.io/ServiceMaestro-Packages/
- APT repository: https://phedders.github.io/ServiceMaestro-Packages/apt/
- DNF repository: https://phedders.github.io/ServiceMaestro-Packages/rpm/

The Pages workflow downloads the latest public Service Maestro release assets and builds:

- a flat APT repository containing the CLI and server `.deb` packages;
- a `createrepo_c` RPM repository containing the server x86_64 package;
- `SHA256SUMS` for every published file;
- an install-instructions page.

## Updating

The workflow runs on a daily schedule, on pushes to `main`, and can be started manually with **Actions → Build package repositories → Run workflow**. An optional release tag can be supplied; leaving it blank uses the latest release.

```sh
gh workflow run pages.yml --repo phedders/ServiceMaestro-Packages
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

The generated `site/` directory is not committed; GitHub Pages deploys it as an artifact.

## Signing

The repositories are currently unsigned, so the instructions use `[trusted=yes]` for APT and `gpgcheck=0` for DNF. Add a signing key and sign `Release`/`InRelease` and RPMs before treating the repositories as trusted for production use.
