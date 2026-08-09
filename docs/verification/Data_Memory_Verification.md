# Data Memory Verification Report

## 1. Objective

The objective of this verification is to confirm that the RV32I Data Memory correctly performs all supported load and store operations.

The verification also checks byte ordering, signed and unsigned load extension, memory isolation, and memory control signals.

---

## 2. Verification Environment

### Simulation Tools

- Icarus Verilog
- GTKWave

### Verification Method

- Directed testing
- Self-checking testbench
- Automatic PASS/FAIL reporting
- Error counting
- VCD waveform generation

---

## 3. Testbench

Testbench location:

```text
tb/core/data_memory_full_tb.v
```

The testbench applies combinations of:

```text
funct3
address
write_data
mem_read
mem_write
```

and compares the resulting `read_data` with the expected value.

---

## 4. Test Coverage

The verification covers:

```text
Loads:
✓ LB
✓ LBU
✓ LH
✓ LHU
✓ LW

Stores:
✓ SB
✓ SH
✓ SW

Additional behavior:
✓ Little-endian ordering
✓ Multiple memory locations
✓ Read disabled
✓ Write disabled
✓ Existing data preservation
```

---

## 5. Word Store and Load

The first test stores:

```text
0x12345678
```

at:

```text
0x00000010
```

using `SW`.

The expected memory layout is:

```text
Address       Data
--------------------
0x10          78
0x11          56
0x12          34
0x13          12
```

An `LW` from address `0x10` must reconstruct:

```text
0x12345678
```

The test passed.

---

## 6. Little-Endian Verification

The internal byte locations were explicitly checked after the word store.

Expected:

```text
memory[0x10] = 0x78
memory[0x11] = 0x56
memory[0x12] = 0x34
memory[0x13] = 0x12
```

The test confirmed the correct little-endian representation.

Result:

```text
PASS
```

---

## 7. Byte Store and Loads

A byte value of:

```text
0xFF
```

was stored using `SB`.

### LB

The signed load was expected to produce:

```text
0xFFFFFFFF
```

because:

```text
0xFF = -1
```

Result:

```text
PASS
```

### LBU

The unsigned load was expected to produce:

```text
0x000000FF
```

Result:

```text
PASS
```

This verifies the difference between sign extension and zero extension.

---

## 8. Halfword Store and Loads

The halfword:

```text
0x80FF
```

was stored using `SH`.

The expected little-endian representation was:

```text
Address       Data
--------------------
0x30          FF
0x31          80
```

### LH

The signed result was expected to be:

```text
0xFFFF80FF
```

Result:

```text
PASS
```

### LHU

The unsigned result was expected to be:

```text
0x000080FF
```

Result:

```text
PASS
```

---

## 9. Second Memory Location

A second word:

```text
0xAABBCCDD
```

was stored at:

```text
0x00000040
```

The word was subsequently loaded and compared against the expected value.

Result:

```text
PASS
```

This also verifies that separate memory locations can hold independent values.

---

## 10. Memory Preservation

After writing to multiple memory locations, the original value:

```text
0x12345678
```

at address:

```text
0x10
```

was read again.

The original value was preserved.

Result:

```text
PASS
```

---

## 11. Read Enable Verification

The testbench disabled the read operation:

```text
mem_read = 0
```

The expected output was:

```text
read_data = 0
```

Result:

```text
PASS
```

---

## 12. Write Enable Verification

The testbench attempted to overwrite an existing memory location while:

```text
mem_write = 0
```

The original memory value remained unchanged.

Result:

```text
PASS
```

This confirms that writes occur only when the memory write control signal is asserted.

---

## 13. Verification Summary

```text
=================================================
Full Data Memory Verification
=================================================

Result: ALL TESTS PASSED
Errors: 0
```

The complete testbench verified the required load/store functionality and memory behavior without errors.

---

## 14. Waveform

The generated waveform is:

```text
sim/data_memory/data_memory_full.vcd
```

The waveform can be opened using GTKWave.

Relevant signals include:

```text
clk
rst
mem_read
mem_write
funct3
address
write_data
read_data
```

The internal memory array can also be inspected during simulation.

---

## 15. Conclusion

The RV32I Data Memory successfully passed the complete functional verification.

The implementation correctly handles:

- Byte stores
- Halfword stores
- Word stores
- Signed byte loads
- Unsigned byte loads
- Signed halfword loads
- Unsigned halfword loads
- Word loads
- Little-endian storage
- Memory read/write enables
- Independent memory locations

The Data Memory is therefore ready for integration with the RV32I processor datapath.