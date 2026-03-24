#!/usr/bin/env bash
set -euo pipefail

echo "Starting memory dump..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENOCD_BIN="${SCRIPT_DIR}/.local/openocd-artery/bin/openocd"

if [[ -x "${OPENOCD_BIN}" ]]; then
  OPENOCD="${OPENOCD_BIN}"
else
  OPENOCD="openocd"
fi

"${OPENOCD}" \
  -s "${SCRIPT_DIR}/oocd/scripts" \
  -c "set CHIPNAME at32f415" \
  -c "set CPUTAPID 0x2ba01477" \
  -f "${SCRIPT_DIR}/oocd/scripts/interface/stlink.cfg" \
  -f "${SCRIPT_DIR}/oocd/scripts/target/at32.cfg" \
  -c "init" \
  -c "reset halt" \
  -c "flash probe 0" \
  -c "reset halt" \
  -c "dump_image ${SCRIPT_DIR}/MEMORY_G3.bin 0x08000000 0x00020000" \
  -c "reset halt" \
  -c "exit"
