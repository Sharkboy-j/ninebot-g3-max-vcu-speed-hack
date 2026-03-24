@echo off
cd /d "%~dp0"
echo Programming reference USD (option bytes) for AT32F415...

openocd -s "%CD%" -s oocd\scripts ^
    -c "set CHIPNAME at32f415" ^
    -c "set CPUTAPID 0x2ba01477" ^
    -f oocd\scripts\interface\stlink.cfg ^
    -f oocd\scripts\target\at32.cfg ^
    -c "init" ^
    -c "reset halt" ^
    -c "flash probe 0" ^
    -c "source [find at32f415_usd_reference.tcl]" ^
    -c "program_at32f415_usd_reference" ^
    -c "reset halt" ^
    -c "exit"

echo.
echo Done. Compare with: xxd -g 1 -l 16 ob.bin after dump_image ob.bin 0x1FFFF800 0x10
pause
