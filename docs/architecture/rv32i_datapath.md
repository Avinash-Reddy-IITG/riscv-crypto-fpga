# RV32I Datapath

## 1. Overview

The RV32I datapath is the central data-processing section of the RISC-V processor. It connects the previously developed processor modules and provides the hardware required to execute RV32I instructions.

The datapath integrates the following modules:

- Register File
- Immediate Generator
- ALU
- ALU Control Unit
- Branch Unit
- Data Memory
- Next-PC Unit
- Write-Back Unit
- Main Control Unit

The current implementation follows a single-cycle datapath organization. An instruction is processed through the required combinational logic during one processor cycle, while architectural state such as registers and memory is updated on the clock edge.

The target FPGA platform is the Xilinx Artix-7 based Basys-3 development board.

---

## 2. Datapath Architecture

The datapath connects the major processor components as follows:

```text
                         Instruction
                              |
              +---------------+---------------+
              |                               |
              v                               v
       Main Control Unit             Immediate Generator
              |                               |
              v                               v
       Control Signals                   Immediate
              |                               |
              +---------------+---------------+
                              |
                              v
                       Register File
                       /           \
                      /             \
                 rs1_data         rs2_data
                    |                 |
                    v                 |
                ALU-A MUX             |
                 / | \                |
                /  |  \               |
              rs1 PC   0              |
                \  |  /               |
                 \ | /                |
                  \|/                 |
                   v                  |
                  ALU <---------------+
                   ^
                   |
               ALU-B MUX
                /       \
             rs2       Immediate
                   |
                   v
              ALU Result
               /      \
              /        \
             v          v
       Data Memory    Write-Back
             |            ^
             |            |
             +------------+
                          |
                          v
                         rd
```

The PC-selection path operates in parallel with the datapath:

```text
                         PC
                          |
             +------------+------------+
             |            |            |
             v            v            v
           PC+4     Branch Target   JAL Target
                          |
                          |
                      JALR Target
                          |
                          v
                    Next-PC Unit
                          |
                          v
                       next_pc
```

---

## 3. Instruction Field Extraction

The datapath extracts the following fields from the 32-bit instruction:

```verilog
opcode   = instruction[6:0];
rd_addr  = instruction[11:7];
funct3   = instruction[14:12];
rs1_addr = instruction[19:15];
rs2_addr = instruction[24:20];
funct7   = instruction[31:25];
```

The opcode is used by the Main Control Unit and datapath routing logic.

The `funct3` and `funct7` fields are used by the ALU Control Unit and Branch Unit where applicable.

---

## 4. Register File Integration

The Register File provides two asynchronous read ports and one synchronous write port.

The datapath supplies:

```text
rs1_addr
rs2_addr
rd_addr
rd_data
RegWrite
```

The Register File provides:

```text
rs1_data
rs2_data
```

The two read values are used as ALU operands, branch operands, and store data.

Register `x0` is hardwired to zero according to the RISC-V specification.

---

## 5. Immediate Generator

The Immediate Generator converts the instruction into a 32-bit immediate value.

The following instruction formats are supported:

| Format | Instructions |
|---|---|
| I-Type | ADDI, loads, JALR, etc. |
| S-Type | SB, SH, SW |
| B-Type | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| U-Type | LUI, AUIPC |
| J-Type | JAL |

The generated immediate is used by the ALU or PC-target generation logic depending on the instruction.

---

## 6. ALU Operand Selection

### 6.1 ALU Operand A

The ALU-A multiplexer supports three sources:

```text
00 -> rs1_data
01 -> PC
10 -> 0
```

The selection is based on the instruction opcode.

Normal ALU instructions use:

```text
ALU A = rs1_data
```

AUIPC uses:

```text
ALU A = PC
```

LUI uses:

```text
ALU A = 0
```

This allows the existing ADD operation in the ALU to implement both LUI and AUIPC.

### 6.2 ALU Operand B

The ALU-B multiplexer is controlled by `ALUSrc`:

```text
ALUSrc = 0 -> rs2_data
ALUSrc = 1 -> immediate
```

For R-type instructions:

```text
ALU A = rs1_data
ALU B = rs2_data
```

For I-type instructions:

```text
ALU A = rs1_data
ALU B = immediate
```

Load and store instructions also use the immediate as the second ALU operand to calculate the effective memory address.

---

## 7. ALU Integration

The ALU supports:

- ADD
- SUB
- AND
- OR
- XOR
- SLL
- SRL
- SRA
- SLT
- SLTU
- PASS_B

The ALU operation is selected by the 4-bit `alu_control` signal.

The ALU Control Unit converts:

```text
ALUOp
funct3
funct7
```

into the required ALU operation.

The ALU also generates a zero flag.

---

## 8. Data Memory Integration

The Data Memory is byte-addressable and uses little-endian organization.

The ALU result is used as the memory address:

```text
address = ALU result
```

For store operations:

```text
write_data = rs2_data
mem_write  = MemWrite
```

For load operations:

```text
mem_read = MemRead
```

The `funct3` field is passed to the Data Memory because it determines the memory operation size and signedness.

Supported load operations:

- LB
- LBU
- LH
- LHU
- LW

Supported store operations:

- SB
- SH
- SW

---

## 9. Branch Unit

The Branch Unit receives:

```text
rs1_data
rs2_data
funct3
```

and generates:

```text
branch_taken
```

Supported branches are:

| funct3 | Instruction | Condition |
|---|---|---|
| 000 | BEQ | rs1 == rs2 |
| 001 | BNE | rs1 != rs2 |
| 100 | BLT | signed rs1 < signed rs2 |
| 101 | BGE | signed rs1 >= signed rs2 |
| 110 | BLTU | unsigned rs1 < rs2 |
| 111 | BGEU | unsigned rs1 >= rs2 |

The Branch Unit determines only whether the branch condition is satisfied. It does not calculate the branch target.

---

## 10. PC Target Generation

The datapath generates the following PC targets.

### Sequential Execution

```text
PC + 4
```

### Conditional Branch

```text
PC + B-type immediate
```

### JAL

```text
PC + J-type immediate
```

### JALR

```text
rs1 + I-type immediate
```

For JALR, bit 0 of the resulting address is cleared as required by the RISC-V ISA:

```text
jalr_target = (rs1 + immediate) & ~1
```

---

## 11. Next-PC Selection

The Next-PC Unit uses a two-bit `pc_src` signal:

```text
00 -> PC + 4
01 -> Conditional branch
10 -> JAL
11 -> JALR
```

The datapath determines `pc_src` from the instruction opcode.

For branch instructions, `branch_taken` determines whether the branch target or PC + 4 is selected.

---

## 12. Write-Back Path

The write-back unit supports three sources:

```text
00 -> ALU result
01 -> Data Memory
10 -> PC + 4
```

ALU instructions write:

```text
rd = ALU result
```

Load instructions write:

```text
rd = memory data
```

JAL and JALR write:

```text
rd = PC + 4
```

This provides the required return address for jump instructions.

---

## 13. Main Control Integration

The Main Control Unit decodes the instruction opcode and generates:

```text
RegWrite
MemRead
MemWrite
MemToReg
ALUSrc
Branch
Jump
ALUOp
```

These signals control the datapath.

The ALU Control Unit then converts `ALUOp`, `funct3`, and `funct7` into the specific ALU operation.

---

# 14. Difficulties Encountered During Development

Integration of the individual modules revealed several issues. These problems demonstrated the importance of integration-level verification after individual module verification.

## 14.1 Data Memory Interface Mismatch

### Problem

The Data Memory requires `funct3` to identify the type of load or store operation.

For example:

```text
000 -> LB
001 -> LH
010 -> LW
100 -> LBU
101 -> LHU
```

Initially, the datapath did not connect `funct3` to the Data Memory.

The `LW` test therefore failed:

```text
Expected x7 = 0000001E
Got      x7 = 00000000
```

### Diagnosis

The ALU correctly calculated the memory address and the store operation worked. However, the Data Memory did not receive the `funct3` field required to identify LW.

### Solution

The datapath Data Memory instantiation was modified to include:

```verilog
.funct3(funct3)
```

After this correction, the LW test passed.

---

## 14.2 Apparent Branch Failure

### Problem

Initially both BEQ and BNE tests failed.

This appeared to indicate a problem in the Branch Unit or Next-PC Unit.

### Diagnosis

The branch instructions were executed after the failed LW instruction.

Therefore:

```text
x3 = 30
x7 = 0
```

instead of:

```text
x3 = 30
x7 = 30
```

For BEQ:

```text
30 == 0 -> false
```

For BNE:

```text
30 != 0 -> true
```

The Branch Unit and Next-PC Unit were therefore behaving correctly.

### Solution

After fixing the Data Memory interface, LW correctly loaded x7 with 30.

The BEQ and BNE tests then passed without changing the Branch Unit or Next-PC Unit.

This demonstrated that an apparent control-path error can sometimes be caused by incorrect data generated by an earlier datapath stage.

---

## 14.3 LUI and AUIPC ALU Control Problem

### Problem

LUI and AUIPC initially failed.

LUI produced:

```text
Expected = 12345000
Got      = 00000000
```

AUIPC produced:

```text
Expected = 00001100
Got      = 00000100
```

The Immediate Generator was checked and found to produce the correct U-type immediate.

### Diagnosis

A temporary debug output for LUI showed:

```text
RegWrite    = 1
ALUSrc      = 1
ALUOp       = 10
Immediate   = 12345000
ALU A       = 00000000
ALU B       = 12345000
ALU Control = 0110
ALU Result  = 00000000
```

ALU Control value `0110` corresponds to SRL rather than ADD.

The problem was that LUI and AUIPC are U-type instructions and do not contain meaningful `funct3` or `funct7` fields.

When `ALUOp` was set to `10`, the ALU Control Unit interpreted the unused `funct3` bits and selected an incorrect ALU operation.

### Solution

The Main Control Unit was changed so that:

```text
LUI   -> ALUOp = 00
AUIPC -> ALUOp = 00
```

`ALUOp = 00` selects ADD.

Therefore:

```text
LUI:
0 + immediate = immediate
```

and:

```text
AUIPC:
PC + immediate
```

No new ALU operation was required.

---

## 14.4 Module Interface Mismatch

### Problem

During integration, an incorrect signal named `branch_enable` was initially connected to the Branch Unit.

The verified Branch Unit did not contain this port.

This produced an elaboration error during compilation.

### Diagnosis

The actual Branch Unit interface was checked.

Its output was:

```text
branch_taken
```

and it did not require a `branch_enable` input.

### Solution

The datapath was modified to match the existing verified Branch Unit interface rather than modifying the Branch Unit.

This preserved the previously verified module.

---

# 15. Verification Methodology

The integrated datapath was tested using a Verilog instruction-level testbench.

The testbench provides actual RV32I instruction encodings rather than directly forcing internal datapath signals.

Instruction encoding functions were implemented for:

- R-Type
- I-Type
- S-Type
- B-Type
- U-Type
- J-Type

The verification therefore tests the interaction between the control logic and datapath rather than testing only individual internal signals.

---

## 16. Test Cases

The following 16 tests were used for the final datapath verification:

| Test | Instruction / Operation | Result |
|---|---|---|
| 1 | ADDI x1, x0, 10 | PASS |
| 2 | ADDI x2, x0, 20 | PASS |
| 3 | ADD x3, x1, x2 | PASS |
| 4 | SUB x4, x2, x1 | PASS |
| 5 | AND x5, x1, x2 | PASS |
| 6 | OR x6, x1, x2 | PASS |
| 7 | SW x3, 0(x0) | PASS |
| 8 | LW x7, 0(x0) | PASS |
| 9 | BEQ taken | PASS |
| 10 | BNE not taken | PASS |
| 11 | JAL target | PASS |
| 12 | JAL return address | PASS |
| 13 | JALR target | PASS |
| 14 | JALR return address | PASS |
| 15 | LUI x10, 0x12345 | PASS |
| 16 | AUIPC x11, 0x1 | PASS |

The testbench also verifies that register `x0` remains hardwired to zero.

---

# 17. Final Verification Result

After correcting the integration issues, all 16 targeted tests passed.

```text
=================================================
              VERIFICATION SUMMARY
=================================================

Tests  : 16
Errors : 0

***********************************************
*                                             *
*       ALL DATAPATH TESTS PASSED!           *
*                                             *
***********************************************
```

Final verification status:

```text
Tests Passed : 16
Tests Failed : 0
Pass Rate    : 100%
```

---

# 18. Lessons Learned

Several important lessons were learned during the integration process.

## 18.1 Individual modules can pass while integration fails

A module can work correctly in isolation while the complete processor fails because of an incorrect interface or control connection.

Therefore, module-level verification must be followed by integration-level verification.

## 18.2 Trace errors backward

The initial branch failures appeared to indicate a branch-control problem.

Tracing the operands backward revealed that the branch inputs were incorrect because of a previous load failure.

The actual problem was therefore in the Data Memory interface.

## 18.3 Instruction formats must be considered during control decoding

Not every instruction format contains meaningful `funct3` and `funct7` fields.

U-type instructions such as LUI and AUIPC require special handling because interpreting their unused fields can result in an incorrect ALU operation.

## 18.4 Reuse existing hardware

LUI and AUIPC were implemented using the existing ADD operation:

```text
LUI   = 0 + immediate
AUIPC = PC + immediate
```

This avoids unnecessary ALU operations and keeps the control logic simpler.

---

# 19. Files Associated With the Datapath

Main datapath:

```text
rtl/core/rv32i_datapath.v
```

Integration testbench:

```text
tb/core/rv32i_datapath_tb.v
```

Supporting modules:

```text
rtl/common/register_file.v
rtl/core/immediate_generator.v
rtl/core/alu.v
rtl/core/branch_unit.v
rtl/core/data_memory.v
rtl/core/next_pc.v
rtl/core/write_back.v
rtl/core/control_unit.v
rtl/core/alu_control.v
```

---

# 20. Current Status

**Module:** RV32I Datapath

**Implementation:** Complete

**Integration:** Complete

**Verification:** Complete

**Tests:** 16

**Passed:** 16

**Failed:** 0

**Pass Rate:** 100%

**Status:** VERIFIED