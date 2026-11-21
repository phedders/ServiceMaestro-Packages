#!/usr/bin/env bash
set -euo pipefail

TAG="${1:?usage: build-site.sh <release-tag>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOWNLOADS="${DOWNLOADS:-$ROOT/downloads}"
SITE="${SITE:-$ROOT/site}"

shopt -s nullglob
debs=("$DOWNLOADS"/*.deb)
rpms=("$DOWNLOADS"/*.x86_64.rpm)

if [ ${#debs[@]} -eq 0 ]; then
  echo "No .deb files found in $DOWNLOADS" >&2
  exit 1
fi
if [ ${#rpms[@]} -eq 0 ]; then
  echo "No binary .rpm files found in $DOWNLOADS" >&2
  exit 1
fi

rm -rf "$SITE"
mkdir -p "$SITE/apt" "$SITE/rpm"
cp "${debs[@]}" "$SITE/apt/"
cp "${rpms[@]}" "$SITE/rpm/"

(
  cd "$SITE/apt"
  dpkg-scanpackages . /dev/null > Packages
  gzip -9c Packages > Packages.gz
  apt-ftparchive \
    -o APT::FTPArchive::Release::Origin="Service Maestro" \
    -o APT::FTPArchive::Release::Label="Service Maestro" \
    -o APT::FTPArchive::Release::Suite="stable" \
    -o APT::FTPArchive::Release::Codename="stable" \
    -o APT::FTPArchive::Release::Architectures="amd64" \
    -o APT::FTPArchive::Release::Components="main" \
    release . > Release
)

(
  cd "$SITE/rpm"
  createrepo_c --quiet .
)

(
  cd "$SITE"
  find apt rpm -type f ! -name SHA256SUMS -print0 |
    sort -z |
    xargs -0 sha256sum > SHA256SUMS
)

deb_list="$(cd "$SITE/apt" && printf '%s\n' *.deb | sort)"
rpm_list="$(cd "$SITE/rpm" && printf '%s\n' *.rpm | sort)"
built="$(date -u '+%Y-%m-%d %H:%M UTC')"

python3 - "$ROOT/index.template.html" "$SITE/index.html" "$TAG" "$built" "$deb_list" "$rpm_list" <<'PY'
import html
import sys
from pathlib import Path

template_path, output_path, tag, built, deb_list, rpm_list = sys.argv[1:]
template = Path(template_path).read_text(encoding="utf-8")


def file_items(value: str, folder: str) -> str:
    names = [name for name in value.splitlines() if name.strip()]
    if not names:
        return '<li class="muted">No packages found.</li>'
    return "\n".join(
        f'<li><a href="{folder}/{html.escape(name, quote=True)}">{html.escape(name)}</a></li>'
        for name in names
    )


output = (
    template.replace("{{TAG}}", html.escape(tag))
    .replace("{{BUILT}}", html.escape(built))
    .replace("{{DEB_LIST}}", file_items(deb_list, "apt"))
    .replace("{{RPM_LIST}}", file_items(rpm_list, "rpm"))
)
Path(output_path).write_text(output, encoding="utf-8")
PY

touch "$SITE/.nojekyll"
echo "Built package sites for $TAG in $SITE"
