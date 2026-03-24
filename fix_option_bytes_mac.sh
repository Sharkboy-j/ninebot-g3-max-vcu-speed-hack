#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENOCD_BIN="${SCRIPT_DIR}/.local/openocd-artery/bin/openocd"

if [[ -x "${OPENOCD_BIN}" ]]; then
  OPENOCD="${OPENOCD_BIN}"
else
  OPENOCD="openocd"
fi

echo "Programming reference USD (option bytes) for AT32F415..."

"${OPENOCD}" \
  -s "${SCRIPT_DIR}" \
  -s "${SCRIPT_DIR}/oocd/scripts" \
  -c "set CHIPNAME at32f415" \
  -c "set CPUTAPID 0x2ba01477" \
  -f "${SCRIPT_DIR}/oocd/scripts/interface/stlink.cfg" \
  -f "${SCRIPT_DIR}/oocd/scripts/target/at32.cfg" \
  -c "init" \
  -c "reset halt" \
  -c "flash probe 0" \
  -c "source [find at32f415_usd_reference.tcl]" \
  -c "program_at32f415_usd_reference" \
  -c "reset halt" \
  -c "exit"

echo
echo "Check raw OB: dump_image ob.bin 0x1FFFF800 0x10, then xxd -g 1 -l 16 ob.bin"
