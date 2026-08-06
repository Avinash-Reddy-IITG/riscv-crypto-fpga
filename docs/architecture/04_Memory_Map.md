# 04. Memory Map

**Version:** 1.0

---

# 1. Introduction

This document defines the memory organization of the FPGA-based RV32I System-on-Chip (SoC). It specifies the complete processor address space, memory regions, peripheral allocation, register maps, and address decoding rules.

The memory map provides the interface between software executing on the processor and the underlying hardware peripherals. All communication between the CPU and peripherals is performed through memory-mapped I/O.

This document serves as the authoritative reference for RTL development, firmware development, verification, and future system expansion.

---

# 2. Memory Organization

The processor implements a 32-bit address space.

Memory is divided into two categories:

* Instruction Memory
* Memory-Mapped Data Space

The instruction memory stores executable program code, while the data space contains RAM and peripheral registers.

---

# 3. Global Memory Map

| Address Range                 | Size  | Region              | Description          |
| ----------------------------- | ----- | ------------------- | -------------------- |
| `0x0000_0000` – `0x0000_3FFF` | 16 KB | Instruction Memory  | Program storage      |
| `0x1000_0000` – `0x1000_3FFF` | 16 KB | Data Memory         | Runtime data         |
| `0x2000_0000` – `0x2000_0FFF` | 4 KB  | SHA-256 Accelerator | Cryptographic engine |
| `0x3000_0000` – `0x3000_0FFF` | 4 KB  | UART Peripheral     | Serial communication |
| `0x4000_0000` – `0x4000_0FFF` | 4 KB  | GPIO Peripheral     | LEDs and switches    |
| `0x5000_0000` – `0x5000_0FFF` | 4 KB  | Reserved            | Future peripherals   |

All peripheral base addresses are aligned on 4 KB boundaries to simplify address decoding and support future expansion.

---

# 4. Instruction Memory

**Base Address**

```
0x0000_0000
```

**Size**

```
16 KB
```

**Purpose**

Stores executable RV32I instructions.

**Access Permissions**

| Operation | Supported           |
| --------- | ------------------- |
| Read      | Yes                 |
| Write     | Initialization Only |
| Execute   | Yes                 |

Instruction memory is accessed exclusively by the Instruction Fetch stage.

---

# 5. Data Memory

**Base Address**

```
0x1000_0000
```

**Size**

```
16 KB
```

**Purpose**

Stores:

* Global variables
* Stack
* Temporary data
* Firmware buffers

**Access Permissions**

| Operation | Supported |
| --------- | --------- |
| Read      | Yes       |
| Write     | Yes       |
| Execute   | No        |

---

# 6. SHA-256 Accelerator Address Space

**Base Address**

```
0x2000_0000
```

The SHA-256 accelerator appears to software as a collection of memory-mapped registers.

## Register Map

| Offset  | Address       | Register | Access | Description     |
| ------- | ------------- | -------- | ------ | --------------- |
| `0x000` | `0x2000_0000` | CONTROL  | R/W    | Start, Reset    |
| `0x004` | `0x2000_0004` | STATUS   | R      | Busy, Done      |
| `0x008` | `0x2000_0008` | MSG0     | W      | Message Word 0  |
| `0x00C` | `0x2000_000C` | MSG1     | W      | Message Word 1  |
| ...     | ...           | ...      | ...    | ...             |
| `0x044` | `0x2000_0044` | MSG15    | W      | Message Word 15 |
| `0x048` | `0x2000_0048` | HASH0    | R      | Digest Word 0   |
| `0x04C` | `0x2000_004C` | HASH1    | R      | Digest Word 1   |
| ...     | ...           | ...      | ...    | ...             |
| `0x064` | `0x2000_0064` | HASH7    | R      | Digest Word 7   |

Unused addresses within the 4 KB region are reserved for future extensions.

---

# 7. UART Address Space

**Base Address**

```
0x3000_0000
```

## Register Map

| Offset  | Address       | Register | Access | Description        |
| ------- | ------------- | -------- | ------ | ------------------ |
| `0x000` | `0x3000_0000` | TX_DATA  | W      | Transmit byte      |
| `0x004` | `0x3000_0004` | RX_DATA  | R      | Receive byte       |
| `0x008` | `0x3000_0008` | STATUS   | R      | UART status flags  |
| `0x00C` | `0x3000_000C` | CONTROL  | R/W    | UART configuration |

Future UART features may extend this register set while remaining within the allocated address region.

---

# 8. GPIO Address Space

**Base Address**

```
0x4000_0000
```

## Register Map

| Offset  | Address       | Register  | Access | Description        |
| ------- | ------------- | --------- | ------ | ------------------ |
| `0x000` | `0x4000_0000` | LED_OUT   | R/W    | Drive onboard LEDs |
| `0x004` | `0x4000_0004` | SWITCH_IN | R      | Read switch states |

Additional GPIO functionality (buttons, seven-segment displays, external headers) may be added in future revisions.

---

# 9. Reserved Address Space

The address range beginning at `0x5000_0000` is reserved for future peripherals.

Potential additions include:

* Timer
* SPI Controller
* I²C Controller
* PWM Generator
* Interrupt Controller
* DMA Engine
* Performance Counters

Reserving address space now avoids future changes to the overall memory organization.

---

# 10. Address Alignment

The following alignment rules apply:

* Peripheral base addresses shall be aligned to 4 KB boundaries.
* Registers shall be aligned to 32-bit word boundaries.
* Consecutive registers shall be spaced by 4 bytes.

These rules simplify hardware address decoding and improve software readability.

---

# 11. Address Decoding

Peripheral selection is determined by comparing the upper address bits against each peripheral's base address.

Only one peripheral may respond to any given address.

The address decoder generates a unique select signal for each peripheral.

This approach minimizes hardware complexity and ensures deterministic bus behavior.

---

# 12. Access Rules

All memory-mapped transactions follow these rules:

* Reads return the current register value.
* Writes update writable registers.
* Writes to read-only registers are ignored.
* Reads from undefined addresses return zero.
* Undefined writes have no effect.

These conventions simplify firmware development and verification.

---

# 13. Example Software Access

Example sequence for computing a SHA-256 digest:

1. Write sixteen 32-bit message words to `MSG0`–`MSG15`.
2. Set the START bit in the `CONTROL` register.
3. Poll the `STATUS` register until the DONE bit is asserted.
4. Read `HASH0`–`HASH7` to retrieve the 256-bit digest.

No dedicated CPU instructions are required; all interaction occurs through standard load and store operations.

---

# 14. Design Considerations

The memory map has been designed to:

* Minimize address decoder complexity.
* Provide clear separation between memories and peripherals.
* Support straightforward firmware development.
* Enable future expansion without architectural changes.
* Maintain compatibility with the custom memory-mapped bus.

---

# 15. Summary

This memory map defines the complete address space of the FPGA-based RV32I SoC. By assigning fixed address regions to memory and peripherals, it establishes a stable hardware/software interface that guides RTL implementation, firmware development, and system verification.

Future peripherals can be incorporated by allocating new address regions while preserving the existing address map, ensuring long-term scalability and maintainability.
