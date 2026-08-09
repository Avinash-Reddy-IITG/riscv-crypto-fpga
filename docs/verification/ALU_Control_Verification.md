# ALU Control Unit Verification Report

## 1. Objective

The objective of this verification is to confirm that the ALU Control Unit correctly translates `ALUOp`, `funct3`, and `funct7` into the corresponding internal ALU operation code.

The verification specifically checks the operation decoding required by RV32I R-Type and I-Type ALU instructions.

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
tb/core/alu_control_tb.v
```

The testbench applies combinations of:

```text
ALUOp
funct3
funct7
```

and compares the generated `alu_control` value against the expected ALU operation.

---

## 4. Signals Verified

| Signal | Description |
|---|---|
| `ALUOp` | Operation class from Main Control Unit |
| `funct3` | RISC-V instruction function field |
| `funct7` | RISC-V instruction function field |
| `alu_control` | Internal 4-bit ALU operation |

---

## 5. Test Cases

### Address Calculation

| Test | Expected Operation | Result |
|---|---|---|
| Address Calculation | `ALU_ADD` | PASS |

### Branch Comparison

| Test | Expected Operation | Result |
|---|---|---|
| Branch Comparison | `ALU_SUB` | PASS |

### R-Type Operations

| Test | Expected Operation | Result |
|---|---|---|
| ADD | `ALU_ADD` | PASS |
| SUB | `ALU_SUB` | PASS |
| SLL | `ALU_SLL` | PASS |
| SLT | `ALU_SLT` | PASS |
| SLTU | `ALU_SLTU` | PASS |
| XOR | `ALU_XOR` | PASS |
| SRL | `ALU_SRL` | PASS |
| SRA | `ALU_SRA` | PASS |
| OR | `ALU_OR` | PASS |
| AND | `ALU_AND` | PASS |

### I-Type Operations

| Test | Expected Operation | Result |
|---|---|---|
| ADDI | `ALU_ADD` | PASS |
| SLTI | `ALU_SLT` | PASS |
| SLTIU | `ALU_SLTU` | PASS |
| XORI | `ALU_XOR` | PASS |
| ORI | `ALU_OR` | PASS |
| ANDI | `ALU_AND` | PASS |
| SLLI | `ALU_SLL` | PASS |
| SRLI | `ALU_SRL` | PASS |
| SRAI | `ALU_SRA` | PASS |

### Invalid Control Input

| Test | Expected Operation | Result |
|---|---|---|
| Invalid `ALUOp` | `ALU_ADD` | PASS |

---

## 6. Special Verification Cases

### ADD vs SUB

The testbench explicitly verifies that the ALU Control Unit distinguishes:

```text
ADD:
funct3 = 000
funct7 = 0000000

SUB:
funct3 = 000
funct7 = 0100000
```

Results:

```text
ADD -> ALU_ADD
SUB -> ALU_SUB
```

Both tests passed.

### SRL vs SRA

The testbench also verifies:

```text
SRL:
funct3 = 101
funct7 = 0000000

SRA:
funct3 = 101
funct7 = 0100000
```

Results:

```text
SRL -> ALU_SRL
SRA -> ALU_SRA
```

Both tests passed.

These tests are particularly important because the two instruction pairs share the same `funct3` value.

---

## 7. Verification Results

Total tests:

```text
22
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

## 8. Waveform Verification

The generated VCD file is:

```text
sim/alu_control/alu_control.vcd
```

The waveform can be inspected using GTKWave.

The following signals can be observed:

```text
ALUOp
funct3
funct7
alu_control
```

The waveform confirms that the ALU control output changes combinationally in response to the input control fields.

---

## 9. Verification Summary

```text
=================================================
ALU Control Unit Verification
=================================================

Tests  : 22
Errors : 0

Result : ALL TESTS PASSED
```

---

## 10. Conclusion

The ALU Control Unit successfully passed all 22 directed verification tests with zero errors.

The verification confirms correct decoding of:

- Address calculations
- Branch comparison control
- All supported R-Type ALU operations
- All supported I-Type ALU operations
- ADD/SUB distinction
- SRL/SRA distinction
- Invalid `ALUOp` handling

The ALU Control Unit is verified and ready for integration with the existing ALU and processor datapath.
