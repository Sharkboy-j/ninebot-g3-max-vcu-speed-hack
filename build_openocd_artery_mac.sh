#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/ArteryTek/openocd.git}"
BUILD_ROOT="${2:-$HOME/src}"
INSTALL_PREFIX="${3:-/usr/local}"

echo "Using repo: ${REPO_URL}"
echo "Using build root: ${BUILD_ROOT}"
echo "Using install prefix: ${INSTALL_PREFIX}"

mkdir -p "${BUILD_ROOT}"
SRC_DIR="${BUILD_ROOT}/openocd-artery"

require_cmd() {
  local cmd="$1"
  local hint="$2"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing dependency: ${cmd}"
    echo "Install hint: ${hint}"
    exit 1
  fi
}

require_cmd git "xcode-select --install"
require_cmd make "xcode-select --install"
require_cmd autoconf "brew install autoconf automake libtool pkg-config"
require_cmd automake "brew install autoconf automake libtool pkg-config"
require_cmd pkg-config "brew install autoconf automake libtool pkg-config"

if ! pkg-config --exists libusb-1.0; then
  echo "Missing dependency: libusb-1.0"
  echo "Install hint: brew install libusb"
  exit 1
fi

if ! pkg-config --exists hidapi; then
  echo "Missing dependency: hidapi"
  echo "Install hint: brew install hidapi"
  exit 1
fi

if [[ -d "${SRC_DIR}" ]]; then
  echo "Source directory exists, updating..."
  git -C "${SRC_DIR}" pull --ff-only
else
  git clone "${REPO_URL}" "${SRC_DIR}"
fi

cd "${SRC_DIR}"

if [[ -x "./bootstrap" ]]; then
  ./bootstrap
fi

./configure \
  --prefix="${INSTALL_PREFIX}" \
  --enable-stlink \
  --disable-werror

make -j"$(sysctl -n hw.ncpu)"
make install

echo
echo "Build completed."
echo "openocd binary: ${INSTALL_PREFIX}/bin/openocd"
echo "Check version with: ${INSTALL_PREFIX}/bin/openocd --version"
