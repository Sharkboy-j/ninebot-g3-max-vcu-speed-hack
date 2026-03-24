@echo off
IF EXIST MEMORY_G3.bin (
	openocd -s oocd/scripts -c "set CHIPNAME at32f415" -c "set CPUTAPID 0x2ba01477" -c "set WORKAREASIZE 0x4000" -f oocd/scripts/interface/stlink.cfg -f oocd/scripts/target/at32.cfg -c "init" -c "reset halt" -c "flash probe 0" -c "flash write_image erase MEMORY_G3.bin 0x08000000" -c "reset halt" -c "exit"
) ELSE (
	echo MEMORY_G3.bin missing.
)
pause