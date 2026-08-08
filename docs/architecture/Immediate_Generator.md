# Immediate Generator Architecture

## 1. Overview

The Immediate Generator is a combinational module responsible for extracting and generating the 32-bit immediate operand from a 32-bit RV32I instruction.

Since different instruction formats encode immediate values in different bit positions, the Immediate Generator reconstructs the immediate based on the instruction opcode and performs sign extension whenever required.

The generated immediate is later used by the ALU, Branch Unit, and Data Memory address generation.

---

# 2. Features

- Parameterized data width
- Pure combinational implementation
- Supports all RV32I immediate formats
- Automatic sign extension
- Opcode-based decoding
- Fully synthesizable RTL

---

# 3. Module Interface

| Signal | Direction | Width | Description |
|---------|-----------|------:|-------------|
| instruction | Input | DATA_WIDTH | 32-bit RV32I instruction |
| immediate | Output | DATA_WIDTH | Generated 32-bit immediate |

---

# 4. Supported Instruction Formats

The Immediate Generator supports the following instruction formats.

| Format | Instructions |
|---------|--------------|
| I-Type | ADDI, ANDI, ORI, XORI, LW, JALR |
| S-Type | SB, SH, SW |
| B-Type | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| U-Type | LUI, AUIPC |
| J-Type | JAL |

R-Type instructions do not contain an immediate and therefore generate a default value.

---

# 5. Immediate Generation

## I-Type

Immediate field

```
instruction[31:20]
```

Sign extension

```
{{20{instruction[31]}}, instruction[31:20]}
```

---

## S-Type

Immediate reconstruction

```
instruction[31:25]
instruction[11:7]
```

---

## B-Type

Immediate reconstruction

```
instruction[31]
instruction[7]
instruction[30:25]
instruction[11:8]
0
```

The least significant bit is always zero because branch targets are aligned.

---

## U-Type

Upper immediate

```
instruction[31:12]
```

Lower twelve bits are filled with zeros.

---

## J-Type

Immediate reconstruction

```
instruction[31]
instruction[19:12]
instruction[20]
instruction[30:21]
0
```

The least significant bit is always zero because jump targets are aligned.

---

# 6. RTL Architecture

```
              32-bit Instruction
                     │
                     ▼
             Extract Opcode
                     │
                     ▼
               case(opcode)
                     │
      ┌──────────────┼──────────────┐
      ▼              ▼              ▼
    I-Type        S-Type        B-Type
      │              │              │
      └──────────────┼──────────────┘
                     ▼
                32-bit Immediate
```

---

# 7. Design Decisions

## Opcode-Based Decoding

The instruction opcode determines which immediate format is reconstructed.

---

## Sign Extension

Signed immediates are automatically extended to 32 bits before being sent to the ALU.

---

## Pure Combinational Logic

The Immediate Generator contains no sequential logic and produces the output immediately after the instruction changes.

---

# 8. Verification Status

Verification Status: **PASSED**

All supported instruction formats were successfully verified using directed self-checking simulations.

---

# 9. Conclusion

The Immediate Generator correctly reconstructs immediate operands for every supported RV32I instruction format. The module forms an essential part of the Instruction Decode stage and supplies operands for arithmetic, branching, memory addressing, and jump operations.