# 01. System Architecture

**Version:** 1.0

---

# 1. Introduction

This document defines the overall architecture of the FPGA-based System-on-Chip (SoC). It describes the organization of the processor, memory subsystem, peripherals, interconnect, clocking strategy, reset architecture, and data flow.

The objective of this document is to provide a complete architectural blueprint that guides RTL implementation while maintaining modularity, scalability, and ease of verification.

---

# 2. Design Objectives

The system architecture has been designed with the following goals:

* Modular RTL implementation
* Clean separation of functional blocks
* Memory-mapped peripheral communication
* Easy FPGA implementation
* Incremental development
* Independent verification of every subsystem
* Scalability for future peripherals
* Maintainability

---

# 3. High-Level System Block Diagram

```text
                         +--------------------------------------+
                         |          RV32I CPU Core              |
                         |--------------------------------------|
                         | IF | ID | EX | MEM | WB Pipeline     |
                         +------------------+-------------------+
                                            |
                                   System Memory Bus
                                            |
         +----------------+-----------------+-----------------+----------------+
         |                |                 |                 |                |
         |                |                 |                 |                |
 +---------------+ +---------------+ +---------------+ +---------------+ +---------------+
 | Instruction   | |   Data RAM    | | SHA-256 Core  | | UART          | | GPIO          |
 | Memory        | |               | | Accelerator   | | Peripheral    | | Peripheral    |
 +---------------+ +---------------+ +---------------+ +---------------+ +---------------+
```

---

# 4. Architectural Philosophy

The design follows a modular SoC architecture in which every major functional block is implemented as an independent RTL module.

Each subsystem communicates only through well-defined interfaces. No module directly accesses another module's internal signals.

This design philosophy provides:

* Independent development
* Easier debugging
* Simplified verification
* Scalability
* Improved readability

---

# 5. Top-Level Architecture

The complete SoC consists of the following subsystems:

| Subsystem           | Purpose                       |
| ------------------- | ----------------------------- |
| RV32I CPU           | Instruction execution         |
| Instruction Memory  | Stores program code           |
| Data Memory         | Stores runtime data           |
| System Bus          | Connects all peripherals      |
| SHA-256 Accelerator | Hardware cryptographic engine |
| UART                | Serial communication          |
| GPIO                | External user interface       |
| Clock & Reset       | System synchronization        |

---

# 6. CPU Subsystem

The CPU acts as the master of the entire SoC.

Responsibilities include:

* Fetching instructions
* Decoding instructions
* Executing arithmetic and logical operations
* Reading and writing memory
* Controlling peripherals through memory-mapped registers
* Handling program flow

The processor initiates every transaction on the system bus.

---

# 7. Memory Organization

The processor follows a Harvard architecture.

Two physically separate memories are implemented:

## Instruction Memory

Stores executable instructions.

Characteristics:

* Read-only during execution
* Accessed only by the Instruction Fetch stage
* Independent of Data Memory

---

## Data Memory

Stores:

* Variables
* Stack
* Runtime data
* Peripheral data

Supports both read and write operations.

---

# 8. System Bus

The System Bus provides communication between the CPU and every peripheral.

Unlike standardized buses such as AXI or Wishbone, this project implements a lightweight custom memory-mapped bus optimized for educational and research purposes.

Each transaction contains:

* Address
* Write Data
* Read Data
* Read Enable
* Write Enable
* Ready Signal

Only one slave responds to a transaction based on address decoding.

---

# 9. Memory-Mapped Peripheral Architecture

Peripherals are accessed through dedicated address regions.

The CPU interacts with peripherals exactly as it would with memory.

Advantages:

* Uniform programming model
* Simple decoder logic
* Easy peripheral expansion
* Industry-inspired architecture

---

# 10. Memory Map

| Address Range           | Peripheral          |
| ----------------------- | ------------------- |
| 0x00000000 – 0x00003FFF | Instruction Memory  |
| 0x10000000 – 0x10003FFF | Data Memory         |
| 0x20000000 – 0x200000FF | SHA-256 Accelerator |
| 0x30000000 – 0x300000FF | UART                |
| 0x40000000 – 0x400000FF | GPIO                |
| 0x50000000 – 0x500000FF | Reserved            |

Future peripherals can be added without modifying the processor architecture.

---

# 11. Data Flow

Instruction execution proceeds through the following sequence:

1. Program Counter generates the instruction address.
2. Instruction Memory returns the instruction.
3. CPU decodes the instruction.
4. Register operands are fetched.
5. ALU executes the required operation.
6. Memory or peripheral access occurs if required.
7. Results are written back to the Register File.

The CPU remains the only master controlling system transactions.

---

# 12. Peripheral Communication

The CPU communicates with peripherals through simple load and store instructions.

Example:

```
SW x5, 0(x10)
```

may write to a SHA-256 control register if `x10` contains the accelerator's base address.

Similarly,

```
LW x6, 4(x10)
```

may read the accelerator status register.

No dedicated instructions are required.

---

# 13. Clock Architecture

The entire SoC operates within a single synchronous clock domain.

Clock source:

* Basys-3 onboard oscillator
* 100 MHz

All sequential logic shares the same clock.

Benefits:

* No clock-domain crossing
* Simplified timing analysis
* Easier verification

---

# 14. Reset Strategy

A synchronous active-high reset is used across all modules.

Reset initializes:

* Program Counter
* Pipeline Registers
* Register File
* Control Logic
* Peripheral State Machines

This ensures deterministic startup behavior.

---

# 15. Scalability

The architecture has been designed for future expansion.

Potential additions include:

* Timer
* SPI
* I²C
* PWM
* DMA Controller
* Interrupt Controller
* Performance Counters
* AES Accelerator
* Cache Memory

These additions require only:

1. Address allocation
2. Address decoder update
3. Peripheral connection

No CPU redesign is necessary.

---

# 16. Design Assumptions

The current architecture assumes:

* Single processor core
* Single clock domain
* Little-endian memory organization
* RV32I instruction set
* No virtual memory
* No cache hierarchy
* No operating system
* Bare-metal firmware execution

These assumptions reduce implementation complexity while preserving architectural clarity.

---

# 17. Architectural Trade-Offs

| Decision             | Reason                                |
| -------------------- | ------------------------------------- |
| Harvard Architecture | Simplifies pipeline implementation    |
| Memory-Mapped I/O    | Uniform peripheral interface          |
| Custom Bus           | Lower complexity than AXI/Wishbone    |
| Single Clock Domain  | Simplifies timing closure             |
| Modular RTL          | Easier verification and maintenance   |
| Pipeline Design      | Higher throughput and interview value |

---

# 18. System Interfaces

The architecture exposes three major interface classes:

### Memory Interfaces

* Instruction Memory
* Data Memory

### Peripheral Interfaces

* SHA-256
* UART
* GPIO

### System Interfaces

* Clock
* Reset

Each interface is defined in detail in the Interface Specification document.

---

# 19. Dependency Graph

The implementation order follows subsystem dependencies.

```
Clock & Reset
      │
      ▼
CPU Core
      │
      ▼
Instruction Memory
      │
      ▼
Data Memory
      │
      ▼
System Bus
      │
      ▼
Peripherals
      │
      ▼
Top-Level Integration
```

This minimizes integration risk and enables progressive verification.

---

# 20. Summary

This document defines the complete organization of the FPGA-based System-on-Chip. It establishes the communication model, memory organization, subsystem responsibilities, and architectural constraints that govern the implementation of every RTL module.

All subsequent design documents—including the CPU Microarchitecture, Bus Specification, Interface Specification, and Verification Plan—are derived from the architectural decisions presented here.
