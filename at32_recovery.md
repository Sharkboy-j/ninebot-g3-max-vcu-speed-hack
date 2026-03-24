# AT32F415 Recovery Summary

Device did not boot.

Debug state:
- PC = 0xFFFFFFFE
- MSP = 0xFFFFFFFC

Indicates:
- invalid vector table
- empty flash
- or corrupted option bytes

---

## Flash Check

Flash was erased earlier.
Write test succeeded:

mww 0x0801FFFC 0xA5A5A5A5

→ Flash controller OK

---

## Option Bytes

BAD:
a5 5a f0 0f 00 ff 00 ff ...

GOOD:
a5 5a ff 00 ff 00 ff 00 ...

---

## Root Cause

Flash limitation:
1 → 0 allowed  
0 → 1 NOT allowed without erase

Example:
f0 = 11110000  
ff = 11111111

---

## Fix

1. Unlock flash
2. Unlock option bytes
3. Erase option bytes
4. Program correct values
5. Reset MCU