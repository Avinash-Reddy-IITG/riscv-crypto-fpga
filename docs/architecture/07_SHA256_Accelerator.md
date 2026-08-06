# 07. SHA-256 Hardware Accelerator

**Version:** 1.0

---

# 1. Introduction

This document specifies the architecture and operation of the SHA-256 Hardware Accelerator integrated into the FPGA-based RV32I System-on-Chip (SoC).

The accelerator implements the SHA-256 cryptographic hash algorithm defined in **FIPS 180-4** and provides a memory-mapped hardware interface that allows software executing on the RISC-V processor to perform hash computations efficiently.

Rather than implementing the algorithm entirely in software, the accelerator performs the computationally intensive compression function directly in hardware, reducing processor workload and demonstrating hardware/software co-design principles.

---

# 2. Design Objectives

The SHA-256 accelerator has been designed with the following objectives:

* Full compliance with the SHA-256 algorithm.
* Modular RTL implementation.
* Memory-mapped processor interface.
* Independent verification.
* FPGA-friendly architecture.
* Reusable IP design.
* Easy integration into future SoCs.

---

# 3. Functional Overview

The accelerator accepts one 512-bit message block, performs SHA-256 processing, and produces a 256-bit digest.

The processor communicates with the accelerator exclusively through memory-mapped registers.

The accelerator operates independently once computation has started.

---

# 4. High-Level Architecture

```text id="hmd3wg"
                   CPU
                    │
            Memory-Mapped Bus
                    │
      +-------------------------------+
      |      SHA-256 Accelerator      |
      +---------------+---------------+
                      │
      +---------------+---------------+
      |                               |
+-------------+              +----------------+
| Register    |              | Control Unit   |
| Interface   |              +----------------+
+-------------+                       │
                                      ▼
                           +----------------------+
                           | Message Scheduler    |
                           +----------------------+
                                      │
                                      ▼
                           +----------------------+
                           | Compression Engine   |
                           +----------------------+
                                      │
                                      ▼
                           +----------------------+
                           | Hash Registers       |
                           +----------------------+
```

---

# 5. Internal Modules

The accelerator is partitioned into the following RTL modules:

| Module              | Purpose                              |
| ------------------- | ------------------------------------ |
| `sha256_top`        | Top-level integration                |
| `control_unit`      | Controls accelerator operation       |
| `message_scheduler` | Generates W[0:63] words              |
| `compression_core`  | Performs SHA-256 rounds              |
| `round_function`    | Executes one compression round       |
| `constants_rom`     | Stores SHA-256 constants             |
| `hash_registers`    | Stores intermediate and final digest |

Each module is independently verifiable.

---

# 6. Processor Interface

The accelerator is accessed as a memory-mapped peripheral.

The CPU interacts with it using standard RV32I load and store instructions.

No custom instructions or ISA extensions are required.

---

# 7. Register Map

| Offset          | Register      | Access | Description           |
| --------------- | ------------- | ------ | --------------------- |
| `0x000`         | CONTROL       | R/W    | Start, reset          |
| `0x004`         | STATUS        | R      | Busy, Done            |
| `0x008`–`0x044` | MESSAGE[0:15] | W      | 512-bit message block |
| `0x048`–`0x064` | HASH[0:7]     | R      | 256-bit digest        |
| `0x068`         | VERSION       | R      | Accelerator revision  |

The register definitions are consistent with the system Memory Map specification.

---

# 8. Software Programming Model

The processor uses the following sequence to compute a hash:

1. Write sixteen 32-bit words into the MESSAGE registers.
2. Set the START bit in the CONTROL register.
3. Poll the STATUS register until DONE is asserted.
4. Read HASH0–HASH7 to retrieve the digest.

This simple interface minimizes software complexity while keeping the hardware independent of the processor pipeline.

---

# 9. Internal Data Flow

The SHA-256 computation proceeds through the following stages:

```text id="okj2bp"
Message Registers
        │
        ▼
Message Scheduler
        │
        ▼
Compression Engine
        │
        ▼
Working Registers
        │
        ▼
Hash Registers
        │
        ▼
CPU Read Interface
```

The Control Unit coordinates progression through each stage.

---

# 10. Accelerator State Machine

The accelerator operates using a simple finite-state machine.

```text id="gg0e2v"
        IDLE
          │
   START Command
          ▼
   LOAD MESSAGE
          ▼
    INITIALIZE
          ▼
   PROCESS ROUNDS
          ▼
   UPDATE HASH
          ▼
      DONE
          │
   START Command
          ▼
        IDLE
```

The accelerator remains in the IDLE state until software initiates a new operation.

---

# 11. Timing Characteristics

| Operation        | Latency     |
| ---------------- | ----------- |
| Register Read    | 1 Cycle     |
| Register Write   | 1 Cycle     |
| Hash Computation | Multi-cycle |
| Digest Read      | 1 Cycle     |

The exact computation latency depends on the implementation architecture and operating frequency.

---

# 12. Verification Strategy

The accelerator shall be verified using:

* FIPS 180-4 SHA-256 test vectors.
* Known-answer tests.
* Consecutive hashing operations.
* Reset behavior.
* Invalid register accesses.
* Busy/Done transitions.

Simulation results shall be compared against software-generated SHA-256 digests.

---

# 13. Resource Considerations

The accelerator has been designed with FPGA implementation in mind.

Primary hardware resources include:

* Registers
* LUTs
* Combinational logic
* Constant ROM
* Control state machine

No DSP blocks or external memory are required for Version 1.

---

# 14. Design Trade-Offs

| Design Decision             | Rationale                          |
| --------------------------- | ---------------------------------- |
| Memory-Mapped Interface     | Simplifies CPU integration         |
| Single Message Block        | Reduces implementation complexity  |
| Modular Architecture        | Improves verification and reuse    |
| Dedicated Hardware          | Demonstrates hardware acceleration |
| Standard Register Interface | Simplifies firmware development    |

---

# 15. Future Enhancements

The architecture supports future improvements, including:

* Streaming message interface
* Multi-block hashing
* DMA support
* Interrupt generation
* SHA-224 compatibility
* SHA-512 accelerator
* AXI-Lite interface wrapper
* Configurable pipelining
* Higher throughput implementations

These enhancements can be incorporated without redesigning the processor or system bus.

---

# 16. Summary

The SHA-256 Hardware Accelerator provides a reusable cryptographic IP core for the FPGA-based RV32I SoC. Its modular architecture, memory-mapped interface, and standards-compliant operation demonstrate practical hardware acceleration and hardware/software co-design while remaining straightforward to implement and verify within the scope of this project.
