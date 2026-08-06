# 05. Module Hierarchy

**Version:** 1.0

---

# 1. Introduction

This document defines the RTL hierarchy of the FPGA-based RV32I System-on-Chip (SoC). It specifies every major hardware module, its purpose, its relationship to other modules, and its position within the overall design hierarchy.

The primary objectives of this hierarchy are:

* Modular RTL organization
* Clear separation of responsibilities
* Simplified verification
* Incremental implementation
* Scalable architecture

Each module is designed to perform a single well-defined function and communicate only through documented interfaces.

---

# 2. Top-Level Design Hierarchy

The complete RTL hierarchy is organized as follows:

```text id="zpw0fj"
top
│
├── core
├── memory
├── bus
├── crypto
├── peripherals
└── common
```

Each subsystem is developed and verified independently before full system integration.

---

# 3. Complete RTL Hierarchy

```text id="pbxvfa"
top
│
├── cpu_top
│   ├── pc
│   ├── instruction_fetch
│   ├── instruction_decode
│   ├── execute
│   ├── memory_stage
│   ├── writeback
│   │
│   ├── register_file
│   ├── alu
│   ├── control_unit
│   ├── immediate_generator
│   ├── branch_unit
│   │
│   ├── forwarding_unit
│   ├── hazard_detection
│   │
│   └── pipeline_registers
│       ├── if_id
│       ├── id_ex
│       ├── ex_mem
│       └── mem_wb
│
├── instruction_memory
├── data_memory
│
├── bus_controller
├── address_decoder
│
├── sha256_top
│   ├── message_scheduler
│   ├── compression_core
│   ├── round_function
│   └── constants_rom
│
├── uart_top
│   ├── uart_tx
│   └── uart_rx
│
├── gpio
│
└── clock_reset
```

---

# 4. Core Processor Modules

The processor subsystem contains all logic required to execute RV32I instructions.

| Module               | Description                                |
| -------------------- | ------------------------------------------ |
| `cpu_top`            | Integrates the complete processor pipeline |
| `pc`                 | Program Counter                            |
| `instruction_fetch`  | Fetches instructions                       |
| `instruction_decode` | Decodes instruction fields                 |
| `execute`            | Performs arithmetic and branch operations  |
| `memory_stage`       | Interfaces with memory and peripherals     |
| `writeback`          | Writes results into the register file      |

These modules together implement the five-stage pipeline.

---

# 5. Processor Functional Units

These modules perform dedicated processing tasks.

| Module                | Responsibility                      |
| --------------------- | ----------------------------------- |
| `register_file`       | 32 × 32-bit architectural registers |
| `alu`                 | Arithmetic and logical operations   |
| `control_unit`        | Generates processor control signals |
| `immediate_generator` | Generates sign-extended immediates  |
| `branch_unit`         | Evaluates branch conditions         |

Each functional unit is independently verified before processor integration.

---

# 6. Pipeline Register Modules

Pipeline registers isolate the five execution stages.

| Module   | Stores                         |
| -------- | ------------------------------ |
| `if_id`  | Fetch → Decode information     |
| `id_ex`  | Decode → Execute information   |
| `ex_mem` | Execute → Memory information   |
| `mem_wb` | Memory → Writeback information |

These modules are purely sequential and contain no combinational decision logic.

---

# 7. Pipeline Control Modules

The following modules maintain correct pipeline operation.

| Module             | Purpose                                          |
| ------------------ | ------------------------------------------------ |
| `forwarding_unit`  | Resolves data hazards through operand forwarding |
| `hazard_detection` | Detects hazards requiring pipeline stalls        |

These modules coordinate pipeline execution without modifying the datapath.

---

# 8. Memory Subsystem

The memory subsystem provides storage for instructions and runtime data.

| Module               | Function                       |
| -------------------- | ------------------------------ |
| `instruction_memory` | Stores executable instructions |
| `data_memory`        | Stores variables and stack     |

Instruction and data memories are physically separated in accordance with the Harvard architecture.

---

# 9. Bus Subsystem

The bus subsystem connects the CPU with all peripherals.

| Module            | Function                                   |
| ----------------- | ------------------------------------------ |
| `bus_controller`  | Manages bus transactions                   |
| `address_decoder` | Selects target peripheral based on address |

The processor is the only bus master.

---

# 10. SHA-256 Accelerator

The cryptographic subsystem performs hardware SHA-256 hashing.

| Module              | Responsibility                   |
| ------------------- | -------------------------------- |
| `sha256_top`        | Top-level accelerator            |
| `message_scheduler` | Generates message schedule words |
| `compression_core`  | Performs compression rounds      |
| `round_function`    | Implements one SHA-256 round     |
| `constants_rom`     | Stores SHA-256 constants         |

The accelerator is accessed through memory-mapped registers.

---

# 11. UART Subsystem

The UART subsystem provides serial communication.

| Module     | Responsibility     |
| ---------- | ------------------ |
| `uart_top` | UART integration   |
| `uart_tx`  | Serial transmitter |
| `uart_rx`  | Serial receiver    |

---

# 12. GPIO Subsystem

The GPIO module interfaces with user I/O devices.

Responsibilities include:

* LED control
* Switch input
* Future button support

---

# 13. Clock and Reset

The `clock_reset` module distributes the system clock and synchronous reset to every subsystem.

Future versions may extend this module with clock division or reset synchronization if required.

---

# 14. Dependency Graph

RTL implementation follows the dependency order shown below.

```text id="s0pbux"
Common Utilities
        │
        ▼
Register File
        │
        ▼
ALU
        │
        ▼
Immediate Generator
        │
        ▼
Control Unit
        │
        ▼
Pipeline Registers
        │
        ▼
Pipeline Control
        │
        ▼
CPU Integration
        │
        ▼
Memory
        │
        ▼
Bus
        │
        ▼
Peripherals
        │
        ▼
Top-Level Integration
```

This sequence minimizes integration risk and enables continuous verification throughout development.

---

# 15. Verification Strategy

Each module progresses through the following stages:

1. RTL implementation
2. Unit testbench
3. Functional simulation
4. Waveform inspection
5. Bug correction
6. Module sign-off
7. Integration testing

No module is integrated until it has passed unit-level verification.

---

# 16. Naming Conventions

The following conventions are used throughout the RTL hierarchy:

* One module per Verilog file.
* File name matches module name.
* Lowercase names with underscores.
* One clearly defined responsibility per module.
* No duplicated functionality.

This consistency simplifies navigation and long-term maintenance.

---

# 17. Future Expansion

The hierarchy has been designed to support additional modules without restructuring the existing design.

Potential future modules include:

* Cache Controller
* Interrupt Controller
* Timer
* SPI Controller
* I²C Controller
* DMA Engine
* Performance Counter
* Debug Interface
* RV32M Multiply/Divide Unit

These modules can be integrated alongside the existing hierarchy while preserving subsystem boundaries.

---

# 18. Summary

This document defines the complete RTL organization of the FPGA-based RV32I SoC. By partitioning the design into independent, reusable modules with clearly defined responsibilities, the hierarchy supports incremental development, straightforward verification, and scalable system integration.

The next document, **06_Interface_Specification.md**, builds upon this hierarchy by defining the exact ports, signal widths, naming conventions, and interface contracts for every module in the design.
