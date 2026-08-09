# Data Memory Architecture

## 1. Overview

The Data Memory is responsible for storing and retrieving data during program execution.

It provides the memory interface required by RV32I load and store instructions.

The implementation is:

- 32-bit data path
- Byte-addressable
- Little-endian
- Parameterized memory depth
- Synchronous writes
- Combinational reads
- Supports all RV32I basic load/store widths

---

## 2. Module Location

```text
rtl/core/data_memory.v
```

---

## 3. Supported Instructions

### Load Instructions

| Instruction | `funct3` | Size | Extension |
|---|---|---:|---|
| LB | `000` | 8 bits | Sign extension |
| LH | `001` | 16 bits | Sign extension |
| LW | `010` | 32 bits | None |
| LBU | `100` | 8 bits | Zero extension |
| LHU | `101` | 16 bits | Zero extension |

### Store Instructions

| Instruction | `funct3` | Size |
|---|---|---:|
| SB | `000` | 8 bits |
| SH | `001` | 16 bits |
| SW | `010` | 32 bits |

---

## 4. Module Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | System clock |
| `rst` | Input | 1 | Memory reset |
| `mem_read` | Input | 1 | Enables a memory read |
| `mem_write` | Input | 1 | Enables a memory write |
| `funct3` | Input | 3 | Determines memory access type |
| `address` | Input | 32 | Byte address |
| `write_data` | Input | 32 | Data supplied for stores |
| `read_data` | Output | 32 | Data returned by loads |

---

## 5. Byte-Addressable Memory

RV32I uses byte addressing.

Each memory location in the implementation stores one byte:

```text
memory[address] = 8 bits
```

A 32-bit word therefore occupies four consecutive memory addresses.

For example:

```text
Address       Byte
--------------------
0x1000        XX
0x1001        XX
0x1002        XX
0x1003        XX
```

Together these four bytes represent one 32-bit word.

---

## 6. Little-Endian Representation

The memory follows little-endian byte ordering.

For example, storing:

```text
0x12345678
```

starting at address:

```text
0x1000
```

produces:

```text
Address       Data
--------------------
0x1000        78
0x1001        56
0x1002        34
0x1003        12
```

The least significant byte is stored at the lowest memory address.

---

## 7. Store Operations

### SB

`SB` stores the lowest 8 bits of `write_data`.

For:

```text
write_data = 0x12345678
```

the stored byte is:

```text
0x78
```

Only one memory location is modified.

---

### SH

`SH` stores the lowest 16 bits.

For:

```text
write_data = 0x12345678
```

the stored bytes are:

```text
Address + 0 -> 78
Address + 1 -> 56
```

---

### SW

`SW` stores all 32 bits.

For:

```text
write_data = 0x12345678
```

the memory becomes:

```text
Address + 0 -> 78
Address + 1 -> 56
Address + 2 -> 34
Address + 3 -> 12
```

---

## 8. Load Operations

### LB

`LB` loads one byte and sign-extends it to 32 bits.

For:

```text
memory[address] = 0xFF
```

the result is:

```text
read_data = 0xFFFFFFFF
```

because `0xFF` represents `-1` as a signed 8-bit value.

---

### LBU

`LBU` loads one byte and zero-extends it.

For:

```text
memory[address] = 0xFF
```

the result is:

```text
read_data = 0x000000FF
```

---

### LH

`LH` loads two bytes and sign-extends the resulting 16-bit value.

For:

```text
memory[address]     = 0xFF
memory[address + 1] = 0x80
```

the resulting halfword is:

```text
0x80FF
```

Since bit 15 is set, the result becomes:

```text
0xFFFF80FF
```

---

### LHU

`LHU` performs the same 16-bit memory read but zero-extends the result:

```text
0x80FF
```

becomes:

```text
0x000080FF
```

---

### LW

`LW` reads four consecutive bytes and reconstructs the 32-bit value.

For:

```text
Address       Data
--------------------
0x1000        78
0x1001        56
0x1002        34
0x1003        12
```

the result is:

```text
read_data = 0x12345678
```

---

## 9. Memory Control

The memory uses two control signals.

### `mem_write`

When:

```text
mem_write = 1
```

a store operation occurs at the next active clock edge.

The exact store size is determined by `funct3`.

### `mem_read`

When:

```text
mem_read = 1
```

the requested data is continuously presented on `read_data`.

When:

```text
mem_read = 0
```

the module drives:

```text
read_data = 0
```

---

## 10. Clocking

Writes are synchronous.

The memory is updated on:

```verilog
posedge clk
```

This ensures that store operations occur at a defined clock edge.

Reads are implemented as combinational logic, allowing the selected memory data to appear without a separate clock edge.

---

## 11. Memory Size

The memory size is derived from:

```verilog
localparam MEMORY_SIZE = (1 << ADDR_WIDTH);
```

With:

```text
ADDR_WIDTH = 10
```

the memory contains:

```text
2^10 = 1024
```

byte locations.

Therefore the default memory capacity is:

```text
1024 bytes = 1 KB
```

The CPU still generates a 32-bit address; the lower `ADDR_WIDTH` bits select the location within this simulation memory.

---

## 12. Signed and Unsigned Loads

The distinction between signed and unsigned loads is handled during the load operation.

### Signed

```text
LB
LH
```

These replicate the sign bit into the upper bits of the 32-bit result.

### Unsigned

```text
LBU
LHU
```

These fill the upper bits with zeros.

Example:

```text
8-bit value = 0xFF
```

Signed:

```text
LB  -> 0xFFFFFFFF
```

Unsigned:

```text
LBU -> 0x000000FF
```

---

## 13. Alignment

The current implementation assumes naturally aligned accesses for multi-byte operations.

Examples:

```text
LW @ 0x00    valid
LW @ 0x04    valid
LW @ 0x08    valid

LH @ 0x00    valid
LH @ 0x02    valid
LH @ 0x04    valid
```

Explicit misaligned-access handling is outside the current implementation.

---

## 14. Architecture

The Data Memory is connected to the processor datapath as follows:

```text
                 Register File
                 /           \
              rs1             rs2
               |               |
               |               |
               v               |
          +-----------+        |
 immediate ->   ALU   |        |
          +-----+-----+        |
                |              |
             address           |
                |              |
                v              v
             +---------------------+
             |     Data Memory     |
             |                     |
             |   address           |
             |   write_data        |
             |   mem_read          |
             |   mem_write         |
             |   funct3            |
             +----------+----------+
                        |
                    read_data
                        |
                        v
                   Write Back
```

The ALU generates the effective memory address:

```text
effective_address = rs1 + immediate
```

For stores, `rs2` supplies the data written into memory.

For loads, the memory supplies data that eventually reaches the write-back stage.

---

## 15. Design Decisions

### Byte-Addressable Storage

The internal memory is implemented as:

```verilog
reg [7:0] memory [0:MEMORY_SIZE-1];
```

This allows direct support for byte, halfword, and word accesses.

### Little Endian

The lowest-addressed byte contains the least significant byte of a multi-byte value.

### Separate Read and Write Logic

Writes are sequential and reads are combinational.

This makes the behavior straightforward to simulate and provides a clean interface for later processor integration.

### Access Type From `funct3`

The `funct3` field determines the required access width and signedness.

No separate width-control signal is required at this stage.

---

## 16. Verification Status

**PASSED**

The complete Data Memory implementation was tested using a self-checking testbench.

The verification covered:

- SB
- SH
- SW
- LB
- LBU
- LH
- LHU
- LW
- Little-endian ordering
- Multiple memory locations
- Read enable behavior
- Write enable behavior
- Preservation of existing memory contents

All tests passed with zero errors.

---

## 17. Conclusion

The Data Memory successfully implements the required RV32I load and store operations using a byte-addressable, little-endian memory architecture.

Signed and unsigned load extension is correctly handled, and byte, halfword, and word accesses are supported.

The module is ready for integration with the processor datapath and load/store control logic.