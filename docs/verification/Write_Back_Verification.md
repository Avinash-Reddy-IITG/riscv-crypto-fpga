# Write-Back Unit Verification

## 1. Objective

The objective of this verification is to confirm that the Write-Back Unit correctly selects the value that will be written to the destination register.

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
tb/core/write_back_tb.v
```

Because the Write-Back Unit is purely combinational, no clock is required.

The testbench changes `wb_src` and checks the resulting `rd_data`.

---

## 4. Test Cases

| Test | `wb_src` | Expected Output |
|---|---|---|
| ALU result | `00` | `alu_result` |
| Memory data | `01` | `memory_data` |
| PC + 4 | `10` | `pc_plus_4` |
| Reserved | `11` | `0` |

---

## 5. ALU Result Test

The testbench applies:

```text
alu_result = 0x12345678
```

and selects:

```text
wb_src = 00
```

Expected:

```text
rd_data = 0x12345678
```

Result:

```text
PASS
```

---

## 6. Memory Data Test

The testbench applies:

```text
memory_data = 0xAABBCCDD
```

and selects:

```text
wb_src = 01
```

Expected:

```text
rd_data = 0xAABBCCDD
```

Result:

```text
PASS
```

---

## 7. PC + 4 Test

The testbench applies:

```text
pc_plus_4 = 0x00000104
```

and selects:

```text
wb_src = 10
```

Expected:

```text
rd_data = 0x00000104
```

Result:

```text
PASS
```

This verifies the path required by JAL and JALR.

---

## 8. Reserved Selection Test

The testbench selects:

```text
wb_src = 11
```

The expected result is:

```text
rd_data = 0x00000000
```

Result:

```text
PASS
```

This confirms deterministic behavior for the currently unused control value.

---

## 9. Verification Summary

```text
=================================================
Write-Back Unit Verification
=================================================

Tests  : 4
Errors : 0

Result : ALL TESTS PASSED
```

All four directed tests passed successfully.

---

## 10. Waveform

The generated waveform is:

```text
sim/write_back/write_back.vcd
```

It can be opened using GTKWave.

Relevant signals include:

```text
alu_result
memory_data
pc_plus_4
wb_src
rd_data
```

---

## 11. Conclusion

The Write-Back Unit successfully passed all four verification cases with zero errors.

The verified paths are:

```text
ALU result  ──┐
Memory data ──┼──> Write-Back MUX ──> rd_data
PC + 4 ───────┘
```

The module is ready for integration with the Register File and the complete RV32I processor datapath.