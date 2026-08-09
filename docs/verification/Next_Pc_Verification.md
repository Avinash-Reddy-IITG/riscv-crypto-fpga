# Next-PC Selection Unit Verification

## 1. Objective

The objective of this verification is to confirm that the Next-PC Selection Unit correctly selects the next program-counter value for all supported PC update paths.

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
tb/core/next_pc_tb.v
```

The testbench directly applies input combinations because the Next-PC module is purely combinational and does not require a clock.

---

## 4. Test Coverage

The following cases were tested:

| Test | `pc_src` | `branch_taken` | Expected Result |
|---|---|---:|---|
| Sequential PC | `00` | X | `PC + 4` |
| Sequential PC at another address | `00` | X | `PC + 4` |
| Branch not taken | `01` | `0` | `PC + 4` |
| Branch taken | `01` | `1` | Branch target |
| JAL | `10` | X | JAL target |
| JALR | `11` | X | JALR target |
| Backward branch | `01` | `1` | Lower branch target |
| Backward JAL | `10` | X | Lower JAL target |
| JALR target | `11` | X | JALR target |
| Branch target ignored | `01` | `0` | `PC + 4` |

---

## 5. Sequential Execution Test

For:

```text
PC = 0x00000100
pc_src = 00
```

the expected result is:

```text
next_pc = 0x00000104
```

The test passed.

A second sequential address was also tested:

```text
PC = 0x00001000
```

with:

```text
next_pc = 0x00001004
```

The test passed.

---

## 6. Branch Tests

### Branch Not Taken

Inputs:

```text
PC            = 0x00000200
branch_target = 0x00000240
branch_taken  = 0
pc_src        = 01
```

Expected:

```text
next_pc = 0x00000204
```

Result:

```text
PASS
```

### Branch Taken

Inputs:

```text
PC            = 0x00000200
branch_target = 0x00000240
branch_taken  = 1
pc_src        = 01
```

Expected:

```text
next_pc = 0x00000240
```

Result:

```text
PASS
```

---

## 7. JAL Test

The test supplied:

```text
PC         = 0x00000300
jal_target = 0x00001000
pc_src     = 10
```

Expected:

```text
next_pc = 0x00001000
```

Result:

```text
PASS
```

---

## 8. JALR Test

The test supplied:

```text
PC          = 0x00000400
jalr_target = 0x00002000
pc_src      = 11
```

Expected:

```text
next_pc = 0x00002000
```

Result:

```text
PASS
```

---

## 9. Backward Target Tests

The testbench also verifies that jump and branch targets are not assumed to be greater than the current PC.

Example:

```text
PC            = 0x00001000
branch_target = 0x00000F00
branch_taken  = 1
```

Expected:

```text
next_pc = 0x00000F00
```

The test passed.

A JAL target below the current PC was also tested successfully.

---

## 10. Branch Target Rejection

The testbench verifies that a branch target is ignored when the branch condition is false.

Example:

```text
branch_target = 0xDEADBEEF
branch_taken  = 0
```

The expected result is still:

```text
next_pc = PC + 4
```

This test passed.

---

## 11. Verification Summary

```text
=================================================
Next-PC Unit Verification
=================================================

Tests  : 10
Errors : 0

Result : ALL TESTS PASSED
```

---

## 12. Waveform

The generated waveform is:

```text
sim/next_pc/next_pc.vcd
```

It can be opened using GTKWave.

Important signals include:

```text
pc
branch_target
jal_target
jalr_target
branch_taken
pc_src
next_pc
```

---

## 13. Conclusion

The Next-PC Selection Unit successfully passed all 10 directed test cases with zero errors.

The verification confirms correct selection for:

- Sequential execution
- Taken branches
- Not-taken branches
- JAL
- JALR
- Backward branch targets
- Backward jump targets

The module is ready for integration into the complete RV32I processor datapath.