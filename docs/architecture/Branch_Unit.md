# Branch Unit Architecture

## 1. Overview

The Branch Unit is a combinational logic block responsible for determining whether an RV32I conditional branch condition is satisfied.

The unit receives the `funct3` field of the instruction and the two register operands, `rs1_data` and `rs2_data`. It compares the operands according to the branch type and generates the `branch_taken` signal.

The Branch Unit only determines whether a branch condition is satisfied. It does not calculate the branch target address and does not modify the Program Counter.

---

## 2. Module Location

```text
rtl/core/branch_unit.v
```

---

## 3. Features

- Pure combinational implementation
- Supports all six RV32I conditional branch instructions
- Supports signed comparisons
- Supports unsigned comparisons
- Separate equality and inequality comparisons
- Parameterized data width
- Safe default behavior for unsupported `funct3` values
- Fully synthesizable RTL

---

## 4. Module Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `funct3` | Input | 3 bits | Identifies the branch condition |
| `rs1_data` | Input | `DATA_WIDTH` | First register operand |
| `rs2_data` | Input | `DATA_WIDTH` | Second register operand |
| `branch_taken` | Output | 1 bit | Indicates whether the branch condition is satisfied |

The default `DATA_WIDTH` is 32 bits for RV32I.

---

## 5. Branch Instruction Encoding

All conditional branch instructions use:

```text
Opcode = 1100011
```

The `funct3` field identifies the specific branch operation.

| `funct3` | Instruction | Condition |
|---|---|---|
| `000` | BEQ | `rs1 == rs2` |
| `001` | BNE | `rs1 != rs2` |
| `100` | BLT | Signed `rs1 < rs2` |
| `101` | BGE | Signed `rs1 >= rs2` |
| `110` | BLTU | Unsigned `rs1 < rs2` |
| `111` | BGEU | Unsigned `rs1 >= rs2` |

Unsupported `funct3` values result in:

```text
branch_taken = 0
```

---

## 6. BEQ

BEQ stands for Branch if Equal.

```assembly
beq rs1, rs2, offset
```

The branch is taken when:

```text
rs1_data == rs2_data
```

Example:

```text
rs1 = 10
rs2 = 10

10 == 10
```

Therefore:

```text
branch_taken = 1
```

---

## 7. BNE

BNE stands for Branch if Not Equal.

```assembly
bne rs1, rs2, offset
```

The branch is taken when:

```text
rs1_data != rs2_data
```

Example:

```text
rs1 = 10
rs2 = 20

10 != 20
```

Therefore:

```text
branch_taken = 1
```

---

## 8. Signed Comparisons

### BLT

BLT stands for Branch if Less Than.

```assembly
blt rs1, rs2, offset
```

The comparison is signed:

```text
$signed(rs1_data) < $signed(rs2_data)
```

### BGE

BGE stands for Branch if Greater Than or Equal.

```assembly
bge rs1, rs2, offset
```

The comparison is signed:

```text
$signed(rs1_data) >= $signed(rs2_data)
```

The `$signed()` conversion is important because Verilog vectors are unsigned unless their signedness is explicitly specified.

---

## 9. Unsigned Comparisons

### BLTU

BLTU stands for Branch if Less Than Unsigned.

```assembly
bltu rs1, rs2, offset
```

The comparison is:

```text
rs1_data < rs2_data
```

### BGEU

BGEU stands for Branch if Greater Than or Equal Unsigned.

```assembly
bgeu rs1, rs2, offset
```

The comparison is:

```text
rs1_data >= rs2_data
```

The operands are treated as unsigned vectors.

---

## 10. Signed vs Unsigned Example

Consider:

```text
rs1_data = 32'hFFFFFFFF
rs2_data = 32'h00000001
```

As signed 32-bit values:

```text
rs1 = -1
rs2 = 1
```

Therefore:

```text
-1 < 1
```

is true.

So:

```text
BLT -> branch_taken = 1
```

As unsigned values:

```text
rs1 = 4294967295
rs2 = 1
```

Therefore:

```text
4294967295 < 1
```

is false.

So:

```text
BLTU -> branch_taken = 0
```

The bit patterns are identical; only their interpretation changes.

---

## 11. Architecture

```text
                    Instruction
                         |
                         |
                       funct3
                         |
                         v
                 +---------------+
                 |  Branch Unit  |
                 +-------+-------+
                         |
                 branch_taken
                         |
                         v
                  PC Selection
                         |
             +-----------+-----------+
             |                       |
           PC + 4          PC + branch_immediate
```

The Branch Unit does not calculate the branch target.

---

## 12. Branch Target Separation

The Branch Unit only produces:

```text
branch_taken
```

The branch immediate is generated separately by the Immediate Generator.

The eventual datapath will therefore contain:

```text
Instruction
     |
     +----> Immediate Generator
     |             |
     |             v
     |       branch_immediate
     |
     +----> Register File
                   |
             rs1_data / rs2_data
                   |
                   v
             Branch Unit
                   |
             branch_taken
                   |
                   v
              PC Selection
```

This separation keeps the Branch Unit focused only on condition evaluation.

---

## 13. Safe Default

The Branch Unit initializes:

```text
branch_taken = 0
```

before decoding `funct3`.

Unsupported values therefore do not accidentally cause a branch.

---

## 14. Design Considerations

The following comparison types are deliberately separated:

```text
Equality:
rs1_data == rs2_data

Signed:
$signed(rs1_data) < $signed(rs2_data)
$signed(rs1_data) >= $signed(rs2_data)

Unsigned:
rs1_data < rs2_data
rs1_data >= rs2_data
```

This ensures correct RV32I behavior for negative values and values with the most-significant bit set.

---

## 15. Verification Status

**PASSED**

The Branch Unit was verified using a self-checking testbench.

A total of 13 basic directed test cases were executed:

```text
Tests  : 13
Errors : 0
```

All six branch conditions and an invalid `funct3` case passed.

---

## 16. Conclusion

The Branch Unit successfully evaluates the six RV32I conditional branch conditions and produces the correct `branch_taken` signal.

The unit is ready for integration with the Program Counter and branch-target datapath.