# FPGA RISC-V SoC with Memory-Mapped SHA-256 Accelerator

**Version:** 1.0
**Author:** Avinash Reddy
**Target FPGA:** Digilent Basys-3 (Xilinx Artix-7 XC7A35T)
**Hardware Description Language:** Verilog HDL
**Development Environment:** Vivado, Icarus Verilog, GTKWave, VS Code

---

# 1. Project Overview

This project implements a modular **32-bit RV32I RISC-V System-on-Chip (SoC)** in Verilog HDL targeting the Xilinx Artix-7 FPGA on the Digilent Basys-3 development board.

The primary objective is to design a processor from the register-transfer level (RTL) upward, integrate it with memory-mapped peripherals, and demonstrate a complete FPGA-based computing system capable of executing software while accelerating cryptographic operations through dedicated hardware.

Unlike many academic FPGA projects that focus on isolated components, this project follows an engineering-oriented methodology by developing a complete digital system consisting of a pipelined processor, memory subsystem, communication peripherals, and a hardware cryptographic accelerator connected through a custom memory-mapped bus.

The project emphasizes clean RTL design, modular architecture, verification, documentation, and FPGA implementation practices similar to those used in professional hardware development.

---

# 2. Project Objectives

The project has the following primary objectives:

* Design a modular RV32I compliant 32-bit processor.
* Implement a five-stage pipelined CPU architecture.
* Develop a custom memory-mapped system bus.
* Integrate hardware peripherals into a unified SoC.
* Implement a dedicated SHA-256 hardware accelerator.
* Demonstrate processor-to-peripheral communication through memory-mapped I/O.
* Perform RTL verification for every functional module.
* Synthesize and implement the complete design on the Basys-3 FPGA.
* Document every stage of the design process using engineering-style specifications.

---

# 3. Motivation

Modern semiconductor companies expect digital design engineers to understand much more than writing Verilog modules. Engineers are expected to design complete systems involving processor architecture, memory interfaces, bus protocols, verification, timing analysis, FPGA implementation, and hardware/software integration.

This project was created to bridge the gap between classroom assignments and industrial RTL development by providing hands-on experience with the complete digital design workflow.

The project combines several important domains of digital hardware engineering:

* Processor Architecture
* RTL Design
* FPGA Design Flow
* Hardware Verification
* Cryptographic Hardware
* Memory-Mapped Peripheral Design
* System Integration
* Timing-Aware Design

---

# 4. High-Level System Architecture

The system consists of a custom RISC-V processor connected to multiple peripherals using a simple memory-mapped bus.

```text
                         +-----------------------------------+
                         |         RV32I CPU Core            |
                         |-----------------------------------|
                         | IF | ID | EX | MEM | WB Pipeline  |
                         +-----------------+-----------------+
                                           |
                                  Simple System Bus
                                           |
      +----------------+-------------------+--------------------+------------------+
      |                |                   |                    |                  |
      |                |                   |                    |                  |
+-------------+  +--------------+   +--------------+    +--------------+   +-------------+
| Instruction |  |   Data RAM   |   | SHA-256 Core |    | UART Module  |   | GPIO Module |
|   Memory    |  |              |   | Accelerator  |    |              |   | LED/Switch  |
+-------------+  +--------------+   +--------------+    +--------------+   +-------------+
```

---

# 5. Major Components

## 5.1 RV32I Processor

The processor serves as the computational core of the SoC.

Key features include:

* 32-bit datapath
* RV32I instruction set
* Five-stage pipeline
* Hazard detection
* Data forwarding
* Branch handling
* Register file
* Arithmetic Logic Unit (ALU)
* Immediate generation
* Control unit

---

## 5.2 Memory System

The processor follows a Harvard architecture with separate instruction and data memories.

Instruction Memory stores executable program code.

Data Memory stores variables, stack, and runtime data.

The separation of instruction and data memory simplifies pipeline implementation while allowing simultaneous instruction fetch and data access.

---

## 5.3 Memory-Mapped Bus

A lightweight custom bus connects the processor to all peripherals.

The bus supports:

* Address decoding
* Read operations
* Write operations
* Peripheral selection
* Ready signaling

The bus architecture has been intentionally kept simple while maintaining clean modular interfaces.

---

## 5.4 SHA-256 Hardware Accelerator

The SHA-256 accelerator performs cryptographic hash computation in dedicated hardware.

The accelerator is exposed as a memory-mapped peripheral, allowing software running on the processor to:

* Write message blocks
* Start hashing
* Poll status registers
* Read the computed digest

This closely resembles how hardware accelerators are integrated into commercial SoCs.

---

## 5.5 UART Peripheral

The UART module provides serial communication between the FPGA and a host computer.

It enables:

* Debugging
* Data transfer
* Future firmware interaction
* Console output

---

## 5.6 GPIO Peripheral

The GPIO module interfaces directly with on-board switches, LEDs, and other user I/O resources available on the Basys-3 board.

---

# 6. Processor Pipeline

The CPU follows the classical five-stage RISC-V pipeline.

```text
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

Each stage is implemented as an independent RTL module connected through explicit pipeline registers.

---

# 7. Development Methodology

The project follows an incremental hardware development approach.

1. System architecture specification
2. CPU microarchitecture specification
3. Interface specification
4. Individual RTL module development
5. Unit-level verification
6. CPU integration
7. Peripheral integration
8. FPGA implementation
9. Timing analysis
10. System validation

Each stage must be completed and verified before proceeding to the next.

---

# 8. Repository Organization

The repository is organized into clearly separated functional areas.

```text
rtl/            RTL source code
tb/             Testbenches
sim/            Simulation files
constraints/    FPGA constraints
firmware/       Software running on the processor
scripts/        Build automation
docs/           Design specifications
reports/        Synthesis and timing reports
images/         Figures and screenshots
```

This structure allows the project to scale while maintaining readability and modularity.

---

# 9. Verification Philosophy

Verification is treated as a first-class design activity rather than an afterthought.

Each RTL module is accompanied by an independent testbench.

Verification consists of:

* Functional simulation
* Waveform inspection
* Corner case testing
* Integration testing
* FPGA validation

A module is considered complete only after all verification objectives have been satisfied.

---

# 10. Design Principles

The following principles guide the implementation of every module:

* Modular RTL hierarchy
* Single responsibility per module
* Parameterized design where appropriate
* Consistent naming conventions
* Readable and maintainable code
* Comprehensive documentation
* Independent verification
* Incremental integration

---

# 11. Target Platform

| Item                 | Specification          |
| -------------------- | ---------------------- |
| FPGA Board           | Digilent Basys-3       |
| FPGA Device          | Xilinx Artix-7 XC7A35T |
| Clock Frequency      | 100 MHz                |
| HDL                  | Verilog                |
| Development Software | Vivado                 |
| Simulation           | Icarus Verilog         |
| Waveform Viewer      | GTKWave                |

---

# 12. Project Deliverables

Upon completion, the repository will include:

* Complete Verilog RTL implementation
* CPU pipeline implementation
* Memory subsystem
* SHA-256 hardware accelerator
* UART peripheral
* GPIO peripheral
* System bus
* Unit and integration testbenches
* Simulation waveforms
* FPGA synthesis reports
* Timing reports
* Resource utilization reports
* FPGA demonstration
* Complete engineering documentation

---

# 13. Future Extensions

The modular architecture enables future enhancements beyond the initial implementation.

Potential extensions include:

* Instruction and data caches
* AXI-Lite compatible bus
* Interrupt controller
* SPI peripheral
* I²C peripheral
* DMA controller
* AES hardware accelerator
* RISC-V compressed instruction support
* Branch prediction
* Performance counters
* Multi-core architecture

---

# 14. Intended Audience

This repository is intended for:

* FPGA developers
* RTL engineers
* Digital design students
* Hardware verification engineers
* Embedded systems developers
* Recruiters evaluating digital hardware projects
* Anyone interested in processor and SoC design

---

# 15. Conclusion

This project demonstrates the complete development lifecycle of a modern FPGA-based System-on-Chip, beginning with architectural specification and progressing through RTL implementation, verification, FPGA deployment, and documentation. By combining a pipelined RV32I processor with a memory-mapped SHA-256 hardware accelerator and a structured verification methodology, the project aims to showcase industry-relevant skills in digital design, processor architecture, hardware integration, and FPGA implementation.
