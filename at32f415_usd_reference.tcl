# AT32F415: erase USD and program reference option bytes (16 bytes).
# Raw dump at 0x1FFFF800 should match:
#   a5 5a ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00
set _AT32_FB 0x40022000
set _AT32_STS 0x0C
set _AT32_KEY1 0x45670123
set _AT32_KEY2 0xCDEF89AB
set _USD_USDERS 0x220
set _USD_ERASE 0x260
set _USD_PROGRAM 0x210
set _USD_LOCK 0x80
set _USD_BASE 0x1FFFF800

proc _at32_flash_obf_clear {fb} {
	global _AT32_STS
	set addr [expr {$fb + $_AT32_STS}]
	for {set n 0} {$n < 50000} {incr n} {
		mem2array st 32 $addr 1
		set w $st(0)
		if {($w & 1) == 0} {
			return
		}
		sleep 1
	}
	echo "ERROR: flash wait timeout (OBF)"
	exit 1
}

proc _at32_unlock_flash {fb} {
	global _AT32_KEY1 _AT32_KEY2
	mww [expr {$fb + 0x04}] $_AT32_KEY1
	mww [expr {$fb + 0x04}] $_AT32_KEY2
}

proc _at32_unlock_usd {fb} {
	global _AT32_KEY1 _AT32_KEY2
	mww [expr {$fb + 0x08}] $_AT32_KEY1
	mww [expr {$fb + 0x08}] $_AT32_KEY2
}

proc program_at32f415_usd_reference {} {
	global _AT32_FB _USD_USDERS _USD_ERASE _USD_PROGRAM _USD_LOCK _USD_BASE

	_at32_unlock_flash $_AT32_FB
	_at32_unlock_usd $_AT32_FB
	mww [expr {$_AT32_FB + 0x10}] $_USD_USDERS
	mww [expr {$_AT32_FB + 0x10}] $_USD_ERASE
	_at32_flash_obf_clear $_AT32_FB

	_at32_unlock_flash $_AT32_FB
	_at32_unlock_usd $_AT32_FB
	mww [expr {$_AT32_FB + 0x10}] $_USD_PROGRAM

	mwh [expr {$_USD_BASE + 0x00}] 0x5AA5
	_at32_flash_obf_clear $_AT32_FB
	set i 2
	while {$i < 16} {
		mwh [expr {$_USD_BASE + $i}] 0x00FF
		_at32_flash_obf_clear $_AT32_FB
		incr i 2
	}

	mww [expr {$_AT32_FB + 0x10}] $_USD_LOCK
	echo "USD program (reference layout) finished."
}
