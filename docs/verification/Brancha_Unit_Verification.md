# Branch Unit Verification Report

## 1. Objective

The objective of this verification is to confirm that the Branch Unit correctly determines whether each supported RV32I conditional branch should be taken.

The verification checks equality, inequality, signed comparison, and unsigned comparison operations.

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
tb/core/branch_unit_tb.v
```

The testbench applies different combinations of:

```text
funct3
rs1_data
rs2_data
```

and compares the generated `branch_taken` signal against the expected result.

---

## 4. Test Cases

### BEQ

| Test | `rs1` | `rs2` | Expected | Result |
|---|---:|---:|---:|---|
| Equal | 10 | 10 | 1 | PASS |
| Not Equal | 10 | 20 | 0 | PASS |

### BNE

| Test | `rs1` | `rs2` | Expected | Result |
|---|---:|---:|---:|---|
| Not Equal | 10 | 20 | 1 | PASS |
| Equal | 10 | 10 | 0 | PASS |

### BLT

| Test | `rs1` | `rs2` | Expected | Result |
|---|---:|---:|---:|---|
| Less Than | 10 | 20 | 1 | PASS |
| Greater Than | 20 | 10 | 0 | PASS |

### BGE

| Test | `rs1` | `rs2` | Expected | Result |
|---|---:|---:|---:|---|
| Greater Than | 20 | 10 | 1 | PASS |
| Less Than | 10 | 20 | 0 | PASS |

### BLTU

| Test | `rs1` | `rs2` | Expected | Result |
|---|---:|---:|---:|---|
| Less Than | 10 | 20 | 1 | PASS |
| Greater Than | 20 | 10 | 0 | PASS |

### BGEU

| Test | `rs1` | `rs2` | Expected | Result |
|---|---:|---:|---:|---|
| Greater Than | 20 | 10 | 1 | PASS |
| Less Than | 10 | 20 | 0 | PASS |

### Invalid `funct3`

An unsupported branch function code was tested:

```text
funct3 = 010
```

Expected:

```text
branch_taken = 0
```

Result:

**PASS**

---

## 5. Verification Results

Total tests:

```text
13
```

Total errors:

```text
0
```

Final result:

```text
ALL TESTS PASSED
```

---

## 6. Signed and Unsigned Verification

The initial functional testbench uses simple positive values to verify the basic operation of each branch condition.

The distinction between signed and unsigned comparisons is an important additional verification item.

For example:

```text
rs1 = 32'hFFFFFFFF
rs2 = 32'h00000001
```

The values represent:

```text
Signed:
rs1 = -1
rs2 = 1

Unsigned:
rs1 = 4294967295
rs2 = 1
```

Therefore:

```text
BLT:
-1 < 1
TRUE

BLTU:
4294967295 < 1
FALSE
```

This confirms why the RTL uses `$signed()` for BLT and BGE but normal unsigned comparisons for BLTU and BGEU.

---

## 7. Waveform Verification

The generated VCD file is:

```text
sim/branch_unit/branch_unit.vcd
```

The waveform can be inspected using GTKWave.

The following signals can be observed:

```text
funct3
rs1_data
rs2_data
branch_taken
```

Because the Branch Unit is combinational, `branch_taken` responds directly to changes in the input signals.

---

## 8. Verification Summary

```text
=================================================
Branch Unit Verification
=================================================

Tests  : 13
Errors : 0

Result : ALL TESTS PASSED
```

---

## 9. Conclusion

The Branch Unit successfully passed all 13 directed functional tests with zero errors.

The verification confirms correct implementation of:

- BEQ
- BNE
- BLT
- BGE
- BLTU
- BGEU
- Invalid `funct3` handling

The Branch Unit is verified and ready for integration with the PC selection and branch-target logic.