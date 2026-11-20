#!/usr/bin/env bash
# Build the locally patched i3 RPM (no tab/stack strip, borders kept).
#
#   ./build.sh --deps          # first run: install BuildRequires too (sudo)
#   ./build.sh                 # VERSION=4.25.1 DISTREL=1.fc44 TAB=2
#   TAB=3 ./build.sh           # same source, newer local release
#   DISTREL=1.fc43 ./build.sh  # different Fedora release
#
# Requires: rpm-build, rpmdevtools, curl, patch (sudo dnf install -y ...).
#
# The SRPM is re-installed with --replacepkgs on every run, so the spec and
# sources are always fresh; the two local patches and the spec diff are applied
# from this directory afterwards.
set -euo pipefail

WITH_DEPS=0
[ "${1:-}" = "--deps" ] && WITH_DEPS=1

VERSION="${VERSION:-4.25.1}"
DISTREL="${DISTREL:-1.fc44}"
TAB="${TAB:-2}"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="${WORK:-$HOME/rpmbuild}"
srpm="i3-${VERSION}-${DISTREL}.src.rpm"
url="https://kojipkgs.fedoraproject.org/packages/i3/${VERSION}/${DISTREL}/src/${srpm}"

for cmd in rpmbuild rpmdev-setuptree curl patch; do
    command -v "$cmd" >/dev/null || {
        echo "missing: $cmd (sudo dnf install -y rpm-build rpmdevtools curl patch)" >&2
        exit 1
    }
done

[ -d "$work/SPECS" ] || rpmdev-setuptree

echo "==> fetching $srpm"
curl -fsSL -o "$work/SRPMS/$srpm" "$url"

echo "==> installing SRPM into $work"
rpm -i --replacepkgs "$work/SRPMS/$srpm"

if [ "$WITH_DEPS" = 1 ]; then
    echo "==> installing build dependencies (sudo)"
    sudo dnf builddep -y "$work/SPECS/i3.spec"
fi

echo "==> applying local patches"
cp "$here"/0002-hide-tab-strip.patch "$here"/0003-no-strip-keep-border.patch "$work/SOURCES/"
patch -p1 -d "$work/SPECS" < "$here/spec-changes.diff"
sed -i "s/^Release:.*/Release:        ${DISTREL}.tab${TAB}/" "$work/SPECS/i3.spec"

echo "==> building (Release ${DISTREL}.tab${TAB})"
rpmbuild -ba "$work/SPECS/i3.spec"

cat <<EOF

Done. Install with:

  sudo dnf install -y \\
    "$work/RPMS/x86_64/i3-${VERSION}-${DISTREL}.tab${TAB}.x86_64.rpm" \\
    "$work/RPMS/noarch/i3-config-${VERSION}-${DISTREL}.tab${TAB}.noarch.rpm"
  sudo dnf versionlock add i3 i3-config
  i3-msg restart
EOF
