# 02. CPU Microarchitecture

**Version:** 1.0

---

# 1. Introduction

This document specifies the internal microarchitecture of the RV32I processor implemented in this project. It defines the processor organization, execution pipeline, datapath, control path, execution model, and interactions between the processor's functional units.

Unlike the System Architecture document, which describes the organization of the complete System-on-Chip (SoC), this document focuses exclusively on the processor core.

The processor is designed as a modular five-stage pipelined implementation of the RV32I base integer instruction set architecture (ISA). The design emphasizes clarity, modularity, extensibility, and efficient FPGA implementation while remaining suitable for educational and professional study.

---

# 2. Design Objectives

The CPU has been designed with the following objectives:

* Full support for the RV32I Base Integer ISA.
* Five-stage pipelined execution.
* Modular RTL organization.
* Separate datapath and control logic.
* Independent verification of all functional units.
* Clean interface to memory-mapped peripherals.
* FPGA-friendly implementation.
* Scalable architecture for future extensions.

The design intentionally avoids unnecessary complexity such as speculative execution, superscalar execution, out-of-order scheduling, or branch prediction in order to maintain implementation clarity.

---

# 3. Processor Specifications

| Parameter           | Value            |
| ------------------- | ---------------- |
| ISA                 | RV32I            |
| Data Width          | 32 bits          |
| Address Width       | 32 bits          |
| Register Count      | 32               |
| Register Width      | 32 bits          |
| Pipeline Depth      | 5 stages         |
| Endianness          | Little Endian    |
| Clock Domain        | Single           |
| Clock Frequency     | 100 MHz (Target) |
| Memory Architecture | Harvard          |
| Execution Model     | In-order         |

---

# 4. Supported Instruction Set

The processor implements the complete RV32I Base Integer Instruction Set.

## Arithmetic

* ADD
* ADDI
* SUB

## Logical

* AND
* OR
* XOR
* ANDI
* ORI
* XORI

## Shift

* SLL
* SRL
* SRA
* SLLI
* SRLI
* SRAI

## Comparison

* SLT
* SLTU
* SLTI
* SLTIU

## Upper Immediate

* LUI
* AUIPC

## Memory

* LW
* SW

## Control Flow

* BEQ
* BNE
* BLT
* BGE
* BLTU
* BGEU
* JAL
* JALR

Support for byte and half-word memory operations may be introduced as a future enhancement without requiring changes to the processor pipeline.

---

# 5. Architectural Overview

The processor follows a classic five-stage pipelined organization.

```text id="1jnmzx"
Instruction Fetch
        │
        ▼
Instruction Decode
        │
        ▼
Execute
        │
        ▼
Memory Access
        │
        ▼
Write Back
```

Instructions advance through the pipeline on every clock cycle under normal operating conditions. Pipeline hazards are resolved using forwarding, stalling, and pipeline flushing mechanisms.

---

# 6. Execution Model

The processor executes instructions using an in-order execution model.

Characteristics:

* One instruction issued per cycle.
* One instruction committed per cycle (ideal case).
* No speculative execution.
* No out-of-order execution.
* No instruction reordering.

This execution model simplifies verification and provides deterministic processor behavior.

---

# 7. Harvard Architecture

The processor employs a Harvard memory architecture with independent instruction and data memories.

Advantages include:

* Simultaneous instruction fetch and data access.
* Elimination of instruction/data memory contention.
* Simplified pipeline control.
* Improved throughput.

The processor communicates with both memories through independent interfaces.

---

# 8. Pipeline Organization

The processor pipeline consists of five stages.

## Instruction Fetch (IF)

Responsibilities:

* Read Program Counter.
* Fetch instruction.
* Calculate PC + 4.
* Select next program counter.

Outputs:

* Instruction
* PC
* PC + 4

---

## Instruction Decode (ID)

Responsibilities:

* Decode instruction.
* Read Register File.
* Generate Immediate.
* Generate Control Signals.
* Detect hazards.

Outputs:

* Source operands
* Immediate value
* Destination register
* Control signals

---

## Execute (EX)

Responsibilities:

* Arithmetic operations.
* Logical operations.
* Branch comparison.
* Branch target calculation.
* Effective address generation.
* Forwarding selection.

Outputs:

* ALU result
* Branch decision
* Store data

---

## Memory Access (MEM)

Responsibilities:

* Load operations.
* Store operations.
* Peripheral accesses.
* Memory-mapped register communication.

Outputs:

* Memory data
* Status information

---

## Write Back (WB)

Responsibilities:

* Select final write-back source.
* Update destination register.

Possible write-back sources:

* ALU Result
* Memory Data
* PC + 4

---

# 9. Pipeline Timing

Under ideal conditions:

* One instruction enters the pipeline every cycle.
* One instruction completes every cycle after pipeline fill.

```text id="vjlwmc"
Cycle

1   IF

2   ID   IF

3   EX   ID   IF

4   MEM  EX   ID   IF

5   WB   MEM  EX   ID   IF
```

Pipeline stalls occur only when data or control hazards cannot be resolved through forwarding.

---

# 10. CPU Datapath Overview

The datapath forms the computational backbone of the processor.

Primary components include:

* Program Counter
* Instruction Memory Interface
* Register File
* Immediate Generator
* ALU
* Branch Comparator
* Pipeline Registers
* Data Memory Interface
* Write Back Multiplexer

The datapath is intentionally separated from the control path to simplify debugging and verification.

---

# 11. Control Path Overview

The control path generates all signals required for instruction execution.

Major control signals include:

* RegWrite
* MemRead
* MemWrite
* MemToReg
* ALUSrc
* Branch
* Jump
* ALUOp
* PCSelect

The Control Unit derives these signals directly from the decoded instruction fields.

---

# 12. Functional Units

The CPU consists of the following functional units:

| Unit                  | Function                           |
| --------------------- | ---------------------------------- |
| Program Counter       | Tracks instruction address         |
| Instruction Fetch     | Fetches instructions               |
| Instruction Decoder   | Decodes instruction fields         |
| Register File         | Stores architectural registers     |
| Immediate Generator   | Generates sign-extended immediates |
| ALU                   | Arithmetic and logical operations  |
| Branch Unit           | Evaluates branch conditions        |
| Hazard Detection Unit | Detects pipeline hazards           |
| Forwarding Unit       | Resolves data dependencies         |
| Pipeline Registers    | Transfer stage information         |

Each functional unit is implemented as an independent RTL module with clearly defined interfaces.

---

# 13. Processor States

The processor does not implement a centralized finite-state machine for instruction execution.

Instead, instruction progress is determined by the movement of instructions through the pipeline stages.

Global pipeline control is achieved through:

* Stall signals.
* Flush signals.
* Forwarding control.
* Branch control.

This distributed control model improves scalability and aligns with common pipelined CPU designs.

---

# 14. Clocking Strategy

All sequential logic operates within a single synchronous clock domain.

Characteristics:

* Rising-edge triggered flip-flops.
* Single system clock.
* No asynchronous clock domains.
* No clock gating in Version 1.

This strategy simplifies timing analysis and FPGA implementation.

---

# 15. Reset Strategy

A synchronous active-high reset initializes:

* Program Counter.
* Pipeline Registers.
* Register File control logic.
* Pipeline control logic.

Instruction and data memories retain their initialized contents unless explicitly rewritten.

---

# 16. Design Constraints

The following constraints apply to Version 1:

* Single-core processor.
* RV32I ISA only.
* No caches.
* No interrupts.
* No exceptions.
* No branch prediction.
* No virtual memory.
* No MMU.
* No operating system support.

These limitations intentionally reduce implementation complexity while preserving architectural clarity.

---

# 17. Scalability

The microarchitecture has been designed to accommodate future enhancements.

Potential additions include:

* Instruction Cache
* Data Cache
* Interrupt Controller
* CSR Support
* Machine Mode
* Multiply/Divide Extension (RV32M)
* Branch Prediction
* Performance Counters
* Debug Interface

The modular organization minimizes redesign effort when introducing these features.

---

# 18. Summary

This document establishes the complete microarchitectural organization of the RV32I processor. It defines the execution model, pipeline organization, datapath, control path, and processor constraints that guide all subsequent RTL implementation.

The following documents provide detailed specifications for individual subsystems, including the system bus, interface definitions, SHA-256 accelerator, and verification methodology.
