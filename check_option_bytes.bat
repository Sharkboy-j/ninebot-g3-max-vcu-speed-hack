@echo off
cd /d "%~dp0"

set "READ=ob_read.bin"
if not exist option_bytes_reference.bin (
  echo Missing option_bytes_reference.bin
  exit /b 1
)

openocd -s oocd\scripts ^
    -c "set CHIPNAME at32f415" ^
    -c "set CPUTAPID 0x2ba01477" ^
    -f oocd\scripts\interface\stlink.cfg ^
    -f oocd\scripts\target\at32.cfg ^
    -c "init" ^
    -c "reset halt" ^
    -c "dump_image %READ% 0x1FFFF800 0x10" ^
    -c "reset halt" ^
    -c "exit"

fc /b "%READ%" option_bytes_reference.bin >nul 2>&1
if errorlevel 1 (
  echo FAIL: option bytes differ. Dump file left as %READ% for inspection.
  echo Expected first 16 bytes: a5 5a ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00
  exit /b 1
)

del "%READ%" 2>nul
echo OK: option bytes at 0x1FFFF800 match reference (16 bytes).
exit /b 0
