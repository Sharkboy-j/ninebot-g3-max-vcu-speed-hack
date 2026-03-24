#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FW_FILE="${SCRIPT_DIR}/MEMORY_G3.bin"
OPENOCD_BIN="${SCRIPT_DIR}/.local/openocd-artery/bin/openocd"

if [[ -x "${OPENOCD_BIN}" ]]; then
  OPENOCD="${OPENOCD_BIN}"
else
  OPENOCD="openocd"
fi

if [[ -f "${FW_FILE}" ]]; then
  "${OPENOCD}" \
    -s "${SCRIPT_DIR}/oocd/scripts" \
    -c "set CHIPNAME at32f415" \
    -c "set CPUTAPID 0x2ba01477" \
    -c "set WORKAREASIZE 0x4000" \
    -f "${SCRIPT_DIR}/oocd/scripts/interface/stlink.cfg" \
    -f "${SCRIPT_DIR}/oocd/scripts/target/at32.cfg" \
    -c "init" \
    -c "reset halt" \
    -c "flash probe 0" \
    -c "flash write_image erase ${FW_FILE} 0x08000000" \
    -c "reset halt" \
    -c "exit"
else
  echo "MEMORY_G3.bin missing."
  exit 1
fi
