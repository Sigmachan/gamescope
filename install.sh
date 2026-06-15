#!/usr/bin/env bash
#
# install.sh — one-shot build + install for wayscope (the gamescope fork).
#
# Builds the current checkout with meson/ninja and installs system-wide,
# plus the `wayscope` launcher into /usr/bin. Idempotent: re-run anytime.
#
#   ./install.sh            # build + install to /usr (needs sudo for install step)
#   PREFIX=~/.local ./install.sh   # user-local install, no sudo
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-/usr}"
BUILD="${BUILD:-build}"

cd "$REPO"

echo ">> wayscope: configuring (prefix=$PREFIX)"
if [ -d "$BUILD" ]; then
    meson setup "$BUILD" --reconfigure --prefix="$PREFIX" -Dbuildtype=release
else
    meson setup "$BUILD" --prefix="$PREFIX" -Dbuildtype=release
fi

echo ">> wayscope: building"
ninja -C "$BUILD"

echo ">> wayscope: installing to $PREFIX"
if [ -w "$PREFIX" ]; then
    meson install -C "$BUILD"
    install -Dm755 contrib/wayscope "$PREFIX/bin/wayscope"
    ln -sf wayscope "$PREFIX/bin/gamescope-launch"
else
    sudo meson install -C "$BUILD"
    sudo install -Dm755 contrib/wayscope "$PREFIX/bin/wayscope"
    sudo ln -sf wayscope "$PREFIX/bin/gamescope-launch"
fi

echo
echo ">> done. binaries: gamescope, gamescopectl, gamescopereaper, gamescopestream"
echo ">> launcher:  wayscope %command%   (Steam launch option)"
echo ">> the gamescope binary name is kept for Steam / WSI-layer compatibility."
