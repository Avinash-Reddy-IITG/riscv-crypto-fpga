# 03. Bus Specification

**Version:** 1.0

---

# 1. Introduction

This document specifies the system bus architecture used throughout the FPGA-based RISC-V System-on-Chip (SoC). The bus provides the communication infrastructure between the processor core and all memory-mapped peripherals.

The primary objectives of the bus architecture are simplicity, modularity, scalability, and ease of verification. Rather than implementing a standard protocol such as AXI4-Lite or Wishbone, the project adopts a lightweight custom memory-mapped bus that captures the essential concepts of on-chip communication while remaining practical for implementation within the project timeline.

---

# 2. Design Objectives

The system bus has been designed to satisfy the following objectives:

* Provide a unified communication interface.
* Support memory-mapped I/O.
* Minimize hardware complexity.
* Enable modular peripheral integration.
* Simplify verification.
* Allow future migration to standardized bus protocols.

---

# 3. Bus Topology

The architecture follows a **single-master, multiple-slave** topology.

```text
                    +----------------------+
                    |     RV32I CPU        |
                    |    Bus Master        |
                    +----------+-----------+
                               |
                      Simple Memory Bus
                               |
      +------------+-----------+------------+------------+
      |            |           |            |            |
      |            |           |            |            |
+------------+ +------------+ +------------+ +------------+ +------------+
| Instruction| | Data RAM   | | SHA-256    | | UART       | | GPIO       |
| Memory     | |            | | Accelerator| | Peripheral | | Peripheral |
+------------+ +------------+ +------------+ +------------+ +------------+
```

Only the CPU initiates transactions. All other components operate as bus slaves.

---

# 4. Bus Master

The RV32I processor is the sole bus master.

Responsibilities include:

* Generating memory addresses.
* Initiating read transactions.
* Initiating write transactions.
* Receiving returned data.
* Controlling transaction timing.

Only one transaction may be active at any given time.

---

# 5. Bus Slaves

Each peripheral occupies a unique address range and responds only to transactions targeting its assigned region.

Current slave devices include:

| Peripheral          | Function                 |
| ------------------- | ------------------------ |
| Instruction Memory  | Program storage          |
| Data Memory         | Runtime storage          |
| SHA-256 Accelerator | Cryptographic processing |
| UART                | Serial communication     |
| GPIO                | General-purpose I/O      |

Additional peripherals may be integrated by allocating a new address range and extending the address decoder.

---

# 6. Bus Signals

The processor communicates with all slave devices using the following signals.

| Signal         | Width | Direction      | Description                      |
| -------------- | ----: | -------------- | -------------------------------- |
| `address`      |    32 | Master → Slave | Target address                   |
| `write_data`   |    32 | Master → Slave | Data written to slave            |
| `read_data`    |    32 | Slave → Master | Data returned by slave           |
| `read_enable`  |     1 | Master → Slave | Initiates read transaction       |
| `write_enable` |     1 | Master → Slave | Initiates write transaction      |
| `ready`        |     1 | Slave → Master | Indicates transaction completion |

These signals form the common interface implemented by every memory-mapped peripheral.

---

# 7. Address Decoding

Address decoding determines which slave device responds to a given transaction.

Each peripheral occupies a unique, non-overlapping address range.

The address decoder compares the incoming address against predefined base addresses and activates exactly one slave select signal.

At most one slave may respond during any transaction.

---

# 8. Memory Map

| Address Range               | Peripheral          |
| --------------------------- | ------------------- |
| `0x0000_0000 – 0x0000_3FFF` | Instruction Memory  |
| `0x1000_0000 – 0x1000_3FFF` | Data Memory         |
| `0x2000_0000 – 0x2000_00FF` | SHA-256 Accelerator |
| `0x3000_0000 – 0x3000_00FF` | UART                |
| `0x4000_0000 – 0x4000_00FF` | GPIO                |
| `0x5000_0000 – 0x5000_00FF` | Reserved            |

The address map is intentionally sparse to simplify decoding logic and accommodate future expansion.

---

# 9. Read Transaction

A read transaction proceeds as follows:

1. CPU places the target address on the address bus.
2. CPU asserts `read_enable`.
3. Address decoder selects the appropriate slave.
4. Selected slave places data on the `read_data` bus.
5. Slave asserts `ready`.
6. CPU captures the returned data.
7. Transaction completes.

---

# 10. Write Transaction

A write transaction proceeds as follows:

1. CPU places the target address on the address bus.
2. CPU places write data on the `write_data` bus.
3. CPU asserts `write_enable`.
4. Address decoder activates the selected slave.
5. Slave stores the incoming data.
6. Slave asserts `ready`.
7. Transaction completes.

---

# 11. Memory-Mapped Peripheral Access

Peripherals are accessed using standard load and store instructions.

For example, software may write to the SHA-256 control register using a store instruction and later read the status register using a load instruction.

No special processor instructions are required, simplifying both hardware and software.

---

# 12. Bus Timing

All bus transfers are synchronous with the system clock.

Version 1 assumes that all slave devices respond within a single clock cycle.

Future versions may introduce wait-state support for slower peripherals through the existing `ready` signal.

---

# 13. Scalability

The bus architecture has been designed to support additional peripherals with minimal modification.

Adding a new peripheral requires:

1. Allocating a new address range.
2. Updating the address decoder.
3. Connecting the peripheral to the common bus interface.

No changes to the processor core are required.

---

# 14. Design Trade-Offs

| Design Decision                | Rationale                       |
| ------------------------------ | ------------------------------- |
| Single Bus Master              | Simplifies arbitration logic    |
| Memory-Mapped I/O              | Uniform software interface      |
| Custom Bus Protocol            | Lower implementation complexity |
| Sparse Address Map             | Simple address decoding         |
| Single Outstanding Transaction | Easier verification             |

---

# 15. Future Enhancements

The current bus architecture provides a foundation for future expansion.

Potential enhancements include:

* AXI4-Lite compatibility
* Wishbone compatibility
* Multiple bus masters
* DMA controller support
* Burst transactions
* Byte-enable signals
* Peripheral interrupts
* Bus error detection
* Wait-state insertion
* Bus performance counters

These enhancements can be incorporated without altering the overall SoC organization.

---

# 16. Summary

The custom memory-mapped bus serves as the communication backbone of the FPGA-based RISC-V SoC. Its lightweight design provides a consistent interface between the processor and peripherals while remaining simple to implement, verify, and extend. The architecture balances educational clarity with engineering realism, providing a scalable foundation for future hardware enhancements.
