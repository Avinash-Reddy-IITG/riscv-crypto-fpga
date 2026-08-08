# Main Control Unit Architecture

## 1. Overview

The Main Control Unit is a combinational logic block responsible for decoding the 7-bit opcode of an RV32I instruction and generating the control signals required to operate the processor datapath.

The Control Unit does not perform the actual arithmetic, memory operation, or branch comparison. Instead, it coordinates the processor blocks by generating control signals.

The module receives only the instruction opcode as its input.

## 2. Module Location

```text
rtl/core/control_unit.v
```

## 3. Features

- Opcode-based instruction classification
- Pure combinational implementation
- Supports the major RV32I instruction classes
- Generates datapath control signals
- Safe default state for unsupported opcodes
- Fully synthesizable RTL

## 4. Module Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `opcode` | Input | 7 bits | RV32I instruction opcode |
| `RegWrite` | Output | 1 bit | Enables register-file write |
| `MemRead` | Output | 1 bit | Enables data-memory read |
| `MemWrite` | Output | 1 bit | Enables data-memory write |
| `MemToReg` | Output | 1 bit | Selects memory data for write-back |
| `ALUSrc` | Output | 1 bit | Selects the ALU second operand |
| `Branch` | Output | 1 bit | Indicates conditional branch |
| `Jump` | Output | 1 bit | Indicates jump instruction |
| `ALUOp` | Output | 2 bits | Specifies the ALU operation class |

## 5. Control Signal Functions

### RegWrite

Controls whether a result is written into the register file.

```text
RegWrite = 1 -> Register write enabled
RegWrite = 0 -> Register write disabled
```

Examples include R-type ALU instructions, I-type ALU instructions, loads, and jumps that write a link register.

### MemRead

Indicates that the processor must read from Data Memory.

```text
MemRead = 1 -> Memory read enabled
```

Used by load instructions.

### MemWrite

Indicates that the processor must write to Data Memory.

```text
MemWrite = 1 -> Memory write enabled
```

Used by store instructions.

### MemToReg

Controls the source of data written back to the register file.

```text
MemToReg = 0 -> ALU/result path
MemToReg = 1 -> Data Memory
```

Used by load instructions.

### ALUSrc

Selects the second ALU operand.

```text
ALUSrc = 0 -> Register operand
ALUSrc = 1 -> Immediate operand
```

For example:

```text
ADD:
    ALUSrc = 0

ADDI:
    ALUSrc = 1
```

### Branch

Indicates that the current instruction is a conditional branch.

```text
Branch = 1
```

Used by BEQ, BNE, BLT, BGE, BLTU, and BGEU.

### Jump

Indicates a jump instruction.

```text
Jump = 1
```

Used by JAL and JALR.

## 6. ALUOp

`ALUOp` does not specify the exact ALU operation. It identifies the operation class that is passed to the ALU Control Unit.

| `ALUOp` | Meaning |
|---|---|
| `2'b00` | Address calculation |
| `2'b01` | Branch operation |
| `2'b10` | R-type / I-type ALU operation |

The exact operation is determined later by the ALU Control Unit using `funct3` and `funct7`.

## 7. Control Truth Table

| Instruction Class | RegWrite | MemRead | MemWrite | MemToReg | ALUSrc | Branch | Jump | ALUOp |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| R-Type | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `10` |
| I-Type ALU | 1 | 0 | 0 | 0 | 1 | 0 | 0 | `10` |
| Load | 1 | 1 | 0 | 1 | 1 | 0 | 0 | `00` |
| Store | 0 | 0 | 1 | 0 | 1 | 0 | 0 | `00` |
| Branch | 0 | 0 | 0 | 0 | 0 | 1 | 0 | `01` |
| LUI | 1 | 0 | 0 | 0 | 1 | 0 | 0 | `10` |
| AUIPC | 1 | 0 | 0 | 0 | 1 | 0 | 0 | `10` |
| JAL | 1 | 0 | 0 | 0 | 0 | 0 | 1 | `00` |
| JALR | 1 | 0 | 0 | 0 | 1 | 0 | 1 | `00` |

## 8. Instruction Classification

### R-Type

```text
Opcode = 0110011
```

Examples:

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

The exact ALU operation is determined by the ALU Control Unit.

### I-Type ALU

```text
Opcode = 0010011
```

Examples:

- ADDI
- SLTI
- SLTIU
- XORI
- ORI
- ANDI
- SLLI
- SRLI
- SRAI

### Load

```text
Opcode = 0000011
```

Examples:

- LB
- LH
- LW
- LBU
- LHU

### Store

```text
Opcode = 0100011
```

Examples:

- SB
- SH
- SW

### Branch

```text
Opcode = 1100011
```

Examples:

- BEQ
- BNE
- BLT
- BGE
- BLTU
- BGEU

### LUI

```text
Opcode = 0110111
```

### AUIPC

```text
Opcode = 0010111
```

### JAL

```text
Opcode = 1101111
```

### JALR

```text
Opcode = 1100111
```

## 9. Safe Default

Before decoding the opcode, all control signals are assigned safe values:

```text
RegWrite = 0
MemRead  = 0
MemWrite = 0
MemToReg = 0
ALUSrc   = 0
Branch   = 0
Jump     = 0
ALUOp    = 00
```

This prevents unintended operations and ensures that unsupported opcodes do not cause register or memory writes.

## 10. Architecture

```text
                 7-bit Opcode
                      |
                      v
              +---------------+
              | Main Control  |
              |     Unit      |
              +-------+-------+
                      |
       +--------------+--------------+
       |       |       |       |     |
       v       v       v       v     v
   RegWrite MemRead MemWrite ALUSrc Branch
       |
       +----> MemToReg
       |
       +----> Jump
       |
       +----> ALUOp
```

The generated signals are distributed throughout the processor datapath.

## 11. Relationship with ALU Control

The Main Control Unit and ALU Control Unit perform two levels of decoding.

```text
Instruction
     |
     | opcode
     v
Main Control Unit
     |
     | ALUOp
     v
ALU Control Unit
     |
     | funct3 + funct7
     v
Exact ALU Operation
```

For example, both ADD and SUB have the R-type opcode `0110011`. The Main Control Unit therefore identifies both as R-type ALU instructions. The ALU Control Unit then uses `funct3` and `funct7` to distinguish ADD from SUB and the other R-type operations.

## 12. Design Considerations

LUI and AUIPC are currently classified through the general control structure used by immediate operations. During complete datapath integration, these instructions require special handling:

```text
LUI   -> rd = immediate
AUIPC -> rd = PC + immediate
```

Similarly, JAL requires the processor to write `PC + 4` to `rd`, while JALR requires both a register-based target calculation and link-register write-back. These details will be finalized during datapath integration.

## 13. Verification Status

**PASSED**

The Main Control Unit was verified using a self-checking testbench covering all supported instruction classes and an unsupported opcode.

## 14. Conclusion

The Main Control Unit successfully decodes RV32I instruction opcodes and generates the corresponding processor control signals.

The module is ready for integration with the Register File, Immediate Generator, ALU, and subsequent datapath components.