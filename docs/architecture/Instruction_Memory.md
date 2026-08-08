# Instruction Memory Architecture

## 1. Overview

The Instruction Memory is a read-only memory (ROM) that stores the machine code instructions executed by the RV32I processor.

The Program Counter (PC) provides the instruction address, and the Instruction Memory returns the corresponding 32-bit instruction. During simulation, the memory contents are initialized using a hexadecimal program file loaded through the `$readmemh()` system task.

The Instruction Memory performs only read operations and does not support writes during normal processor execution.

---

# 2. Features

- Parameterized data width
- Parameterized memory depth
- Read-only memory implementation
- Asynchronous read interface
- Program initialization using `$readmemh()`
- Word-aligned address translation
- Synthesizable RTL

---

# 3. Module Interface

| Signal | Direction | Width | Description |
|---------|-----------|------:|-------------|
| address | Input | DATA_WIDTH | Program Counter address |
| instruction | Output | DATA_WIDTH | Instruction located at the specified address |

---

# 4. Internal Architecture

The Instruction Memory is implemented as an array of 32-bit words.

```verilog
reg [DATA_WIDTH-1:0] instruction_mem [0:MEM_DEPTH-1];
```

Each memory location stores one RV32I instruction.

---

# 5. Program Initialization

The instruction memory is initialized during simulation using

```verilog
initial begin
    $readmemh(INIT_FILE, instruction_mem);
end
```

The hexadecimal program file is automatically loaded before simulation begins.

---

# 6. Address Translation

The Program Counter is byte-addressed, while the instruction memory is organized as 32-bit words.

Therefore,

| PC Address | Memory Index |
|------------|--------------|
| 0x00000000 | 0 |
| 0x00000004 | 1 |
| 0x00000008 | 2 |
| 0x0000000C | 3 |

The conversion is performed by ignoring the least significant two bits.

```verilog
word_address = address[DATA_WIDTH-1:2];
```

This effectively divides the byte address by four.

---

# 7. Read Operation

Instruction fetch is performed asynchronously.

```verilog
assign instruction = instruction_mem[word_address];
```

Whenever the Program Counter changes, the instruction output updates immediately.

---

# 8. Design Decisions

## Read-Only Memory

The instruction memory does not contain a write interface because program instructions remain constant during execution.

---

## Word Addressing

The lower two bits of the Program Counter are discarded because every RV32I instruction occupies four bytes.

---

## Parameterized Initialization

The program file is provided through the `INIT_FILE` parameter, allowing different software programs to be tested without modifying the RTL.

---

# 9. Verification Status

Verification Status: **PASSED**

The module successfully loaded program data and returned the correct instruction for each tested Program Counter value.

---

# 10. Conclusion

The Instruction Memory provides a simple and reusable ROM interface for the Instruction Fetch stage. The module is fully synthesizable and forms the connection between the Program Counter and the Instruction Decode stage.