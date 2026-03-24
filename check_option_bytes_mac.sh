#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENOCD_BIN="${SCRIPT_DIR}/.local/openocd-artery/bin/openocd"
REF_BIN="${SCRIPT_DIR}/option_bytes_reference.bin"

if [[ -x "${OPENOCD_BIN}" ]]; then
  OPENOCD="${OPENOCD_BIN}"
else
  OPENOCD="openocd"
fi

if [[ ! -f "${REF_BIN}" ]]; then
  echo "Missing ${REF_BIN}"
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "${TMP}"' EXIT

"${OPENOCD}" \
  -s "${SCRIPT_DIR}/oocd/scripts" \
  -c "set CHIPNAME at32f415" \
  -c "set CPUTAPID 0x2ba01477" \
  -f "${SCRIPT_DIR}/oocd/scripts/interface/stlink.cfg" \
  -f "${SCRIPT_DIR}/oocd/scripts/target/at32.cfg" \
  -c "init" \
  -c "reset halt" \
  -c "dump_image ${TMP} 0x1FFFF800 0x10" \
  -c "reset halt" \
  -c "exit"

if cmp -s "${TMP}" "${REF_BIN}"; then
  echo "OK: option bytes at 0x1FFFF800 match reference (16 bytes)."
  exit 0
fi

echo "FAIL: option bytes differ."
echo "Expected:"
xxd -g 1 -l 16 "${REF_BIN}"
echo "Got:"
xxd -g 1 -l 16 "${TMP}"
exit 1
