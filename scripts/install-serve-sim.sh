#!/bin/sh
# Installs serve-sim 0.1.49 for herdr-sim into
#   ~/.local/share/herdr-sim/serve-sim-0.1.49/
#     package/        the npm tarball, unpacked (entry: package/dist/serve-sim.js)
#     node_modules/   its runtime dependency (ws), from scripts/serve-sim/package-lock.json
#
# The tarball's sha512 must match SERVE_SIM_INTEGRITY below, which is the npm
# registry's dist.integrity for serve-sim@0.1.49. The lockfile pins ws by its
# integrity too. No package scripts run (no npx, npm ci --ignore-scripts).
#
# Usage: scripts/install-serve-sim.sh [path/to/serve-sim-0.1.49.tgz]
# Without a path it downloads the tarball from the npm registry.
set -eu

VERSION=0.1.49
SERVE_SIM_INTEGRITY="sha512-Q2SC29YDY30+qrfNA7Auv4etGqe++FYT3bionmpnKi3kd1xgisI/ohSyrrLqD9N5UsBMXjITcVecxMCQAV5sgg=="
TARBALL_URL="https://registry.npmjs.org/serve-sim/-/serve-sim-$VERSION.tgz"
# The mod reads from this same folder (mods/herdr-sim/serve-sim.js).
DEST="$HOME/.local/share/herdr-sim/serve-sim-$VERSION"

repo_scripts=$(cd "$(dirname "$0")" && pwd)
command -v npm >/dev/null || { echo "npm is needed to install serve-sim's dependency." >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if [ $# -gt 0 ]; then
  cp "$1" "$work/serve-sim.tgz"
else
  curl -fsSL "$TARBALL_URL" -o "$work/serve-sim.tgz"
fi

actual="sha512-$(openssl dgst -sha512 -binary "$work/serve-sim.tgz" | base64 | tr -d '\n')"
if [ "$actual" != "$SERVE_SIM_INTEGRITY" ]; then
  echo "serve-sim-$VERSION.tgz does not match the pinned hash." >&2
  echo "  expected $SERVE_SIM_INTEGRITY" >&2
  echo "  got      $actual" >&2
  exit 1
fi
echo "serve-sim $VERSION: tarball hash OK"

# Build the folder next to its final place, then swap it in.
mkdir -p "$(dirname "$DEST")"
stage=$(mktemp -d "$DEST.new.XXXXXX")
trap 'rm -rf "$work" "$stage"' EXIT
tar -xzf "$work/serve-sim.tgz" -C "$stage"
[ -f "$stage/package/dist/serve-sim.js" ] || { echo "The tarball has no package/dist/serve-sim.js." >&2; exit 1; }
cp "$repo_scripts/serve-sim/package.json" "$repo_scripts/serve-sim/package-lock.json" "$stage/"
(cd "$stage" && npm ci --ignore-scripts --no-audit --no-fund --omit=dev)

rm -rf "$DEST"
mv "$stage" "$DEST"
echo "serve-sim $VERSION installed in $DEST"
