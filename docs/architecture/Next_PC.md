# Next-PC Selection Unit Architecture

## 1. Overview

The Next-PC Selection Unit determines the address of the instruction that will be executed during the next processor cycle.

The module is a purely combinational block. It does not contain a register. The actual Program Counter register is implemented separately in:

```text
rtl/core/program_counter.v
```

The Next-PC unit selects between:

- Sequential execution (`PC + 4`)
- Conditional branch target
- JAL target
- JALR target

---

## 2. Module Location

```text
rtl/core/next_pc.v
```

---

## 3. PC Sources

The `pc_src` control signal determines the type of PC update.

| `pc_src` | Source | Description |
|---|---|---|
| `00` | `PC + 4` | Normal sequential execution |
| `01` | Branch | Conditional branch |
| `10` | JAL | Unconditional PC-relative jump |
| `11` | JALR | Register-based indirect jump |

---

## 4. Module Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `pc` | Input | 32 | Current program counter |
| `branch_target` | Input | 32 | Pre-calculated branch target |
| `jal_target` | Input | 32 | Pre-calculated JAL target |
| `jalr_target` | Input | 32 | Pre-calculated JALR target |
| `branch_taken` | Input | 1 | Indicates whether a conditional branch is taken |
| `pc_src` | Input | 2 | Selects the PC source |
| `next_pc` | Output | 32 | PC value for the next cycle |

---

## 5. Normal Sequential Execution

For most instructions, execution proceeds to the next sequential instruction.

Since each RV32I instruction is 32 bits:

```text
32 bits = 4 bytes
```

the normal next PC is:

```text
PC + 4
```

For example:

```text
PC      = 0x00000100
Next PC = 0x00000104
```

This is selected using:

```text
pc_src = 00
```

---

## 6. Conditional Branch

Conditional branch instructions include:

```text
BEQ
BNE
BLT
BGE
BLTU
BGEU
```

The Branch Unit determines whether the condition is satisfied.

If:

```text
branch_taken = 0
```

the processor continues normally:

```text
next_pc = PC + 4
```

If:

```text
branch_taken = 1
```

the processor uses:

```text
next_pc = branch_target
```

The branch target is calculated elsewhere in the processor datapath.

The Next-PC unit only selects the result.

---

## 7. JAL

JAL is an unconditional PC-relative jump.

For:

```assembly
jal rd, offset
```

the target address is:

```text
PC + JAL immediate
```

The calculated target is supplied to the Next-PC unit through:

```text
jal_target
```

When:

```text
pc_src = 10
```

the module selects:

```text
next_pc = jal_target
```

JAL also requires `PC + 4` to be written to `rd`. That write-back operation is handled elsewhere in the datapath and is not part of this module.

---

## 8. JALR

JALR is an indirect jump.

For:

```assembly
jalr rd, offset(rs1)
```

the target is calculated using:

```text
rs1 + immediate
```

with the least significant address bit cleared according to the RISC-V specification.

The resulting target is supplied through:

```text
jalr_target
```

When:

```text
pc_src = 11
```

the Next-PC unit selects:

```text
next_pc = jalr_target
```

The `JALR` target calculation itself is outside this module.

---

## 9. Architecture

The Next-PC unit is positioned between the target-generation logic and the Program Counter.

```text
                    Current PC
                        |
                        v
                 +-------------+
                 |   PC + 4    |
                 +------+------+
                        |
                        |
Branch Target ----------+
                        |
JAL Target -------------+
                        |
JALR Target ------------+
                        |
                        v
                +----------------+
                |    Next-PC     |
                |    Selection   |
                |      MUX       |
                +-------+--------+
                        |
                     next_pc
                        |
                        v
                +---------------+
                | Program       |
                | Counter       |
                +---------------+
```

The target values are calculated outside the Next-PC module.

This keeps the module responsible only for PC-source selection.

---

## 10. Branch Selection

The branch selection requires both:

```text
pc_src = 01
```

and:

```text
branch_taken = 1
```

If `pc_src` selects the branch path but `branch_taken` is low, the processor continues with:

```text
PC + 4
```

Therefore:

```text
pc_src = 01
branch_taken = 0
```

produces:

```text
next_pc = PC + 4
```

while:

```text
pc_src = 01
branch_taken = 1
```

produces:

```text
next_pc = branch_target
```

---

## 11. Combinational Design

The Next-PC unit uses combinational logic.

It does not contain:

```verilog
always @(posedge clk)
```

because it does not store state.

The Program Counter is responsible for storing the selected value.

The relationship is:

```text
Next-PC Logic
     |
     | next_pc
     v
Program Counter
     |
     | PC
     v
Next instruction
```

---

## 12. Separation of Responsibilities

The design deliberately separates three tasks.

### Program Counter

Stores:

```text
PC
```

### Target Generation

Calculates:

```text
PC + branch_immediate
PC + JAL_immediate
rs1 + JALR_immediate
```

### Next-PC Selection

Selects one of the calculated values:

```text
PC + 4
branch_target
jal_target
jalr_target
```

This modular design simplifies both verification and later CPU integration.

---

## 13. Parameterization

The module contains:

```verilog
parameter DATA_WIDTH = 32
```

The default value is 32 because the processor is an RV32I implementation.

The `DATA_WIDTH` parameter allows the module to be reused with other datapath widths if required.

---

## 14. Verification Status

**PASSED**

The Next-PC Selection Unit was verified using a self-checking testbench.

The testbench contained 10 directed test cases covering:

- Sequential `PC + 4`
- Branch not taken
- Branch taken
- JAL target selection
- JALR target selection
- Backward branch
- JAL to a lower address
- JALR target selection
- Ignoring a branch target when the branch is not taken

Verification result:

```text
Tests  : 10
Errors : 0
```

---

## 15. Conclusion

The Next-PC Selection Unit correctly selects the appropriate next program-counter value for sequential execution, conditional branches, JAL, and JALR.

The module is fully combinational and is ready to be integrated with the Program Counter and the remaining processor datapath.
