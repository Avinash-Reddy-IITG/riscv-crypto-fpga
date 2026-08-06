# 06. Interface Specification

**Version:** 1.0

---

# 1. Introduction

This document defines the interface contracts for every RTL module within the FPGA-based RV32I System-on-Chip (SoC).

Its purpose is to ensure that independently developed modules can be integrated without ambiguity. Every module shall conform to the conventions, signal definitions, and interface rules specified in this document.

The Interface Specification serves as the primary reference during RTL implementation, integration, and verification.

---

# 2. Design Philosophy

Every RTL module shall:

* Perform a single well-defined function.
* Expose only the signals required for its operation.
* Hide all internal implementation details.
* Use synchronous logic unless otherwise specified.
* Follow common naming conventions.
* Be independently synthesizable.
* Be independently verifiable.

---

# 3. Global Signal Naming Convention

The following naming rules apply to every module.

| Signal Type  | Convention            | Example       |
| ------------ | --------------------- | ------------- |
| Clock        | `clk`                 | `clk`         |
| Reset        | `rst`                 | `rst`         |
| Input        | Descriptive lowercase | `instruction` |
| Output       | Descriptive lowercase | `alu_result`  |
| Enable       | `_en` suffix          | `write_en`    |
| Valid        | `_valid` suffix       | `data_valid`  |
| Ready        | `_ready` suffix       | `bus_ready`   |
| Write Enable | `_we`                 | `mem_we`      |
| Read Enable  | `_re`                 | `mem_re`      |
| Address      | `_addr`               | `bus_addr`    |
| Data Input   | `_wdata`              | `bus_wdata`   |
| Data Output  | `_rdata`              | `bus_rdata`   |

Signal names shall remain consistent across every subsystem.

---

# 4. Clock Convention

All sequential modules operate from a single global clock.

| Parameter     | Value   |
| ------------- | ------- |
| Clock Signal  | `clk`   |
| Edge          | Rising  |
| Frequency     | 100 MHz |
| Clock Domains | 1       |

Clock gating shall not be implemented in Version 1.

---

# 5. Reset Convention

All modules use a synchronous active-high reset.

Rules:

* Reset sampled on the rising edge.
* Outputs initialized to known values.
* State machines return to their initial state.
* Pipeline registers cleared.
* No asynchronous reset logic.

---

# 6. Bus Width Conventions

| Signal           |   Width |
| ---------------- | ------: |
| Address          | 32 bits |
| Data             | 32 bits |
| Instruction      | 32 bits |
| Register Address |  5 bits |
| Opcode           |  7 bits |
| funct3           |  3 bits |
| funct7           |  7 bits |
| Immediate        | 32 bits |

These widths remain constant throughout the design.

---

# 7. Parameter Convention

Every configurable module shall expose parameters using upper-case names.

Example:

```verilog
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 32;
parameter DEPTH = 1024;
```

Hard-coded constants should be avoided unless they are architectural requirements.

---

# 8. Module Header Convention

Every RTL module shall begin with a standardized header.

```verilog
module module_name #(
    parameter DATA_WIDTH = 32
)(
    input  wire                     clk,
    input  wire                     rst,

    ...
);
```

The ordering of ports shall remain consistent across the project.

---

# 9. Port Ordering Standard

Ports shall always appear in the following order:

1. Clock
2. Reset
3. Control Inputs
4. Data Inputs
5. Address Inputs
6. Status Outputs
7. Data Outputs

Maintaining this order improves readability and consistency.

---

# 10. Interface Documentation Standard

Every module shall document:

* Purpose
* Parameters
* Inputs
* Outputs
* Dependencies
* Timing assumptions
* Reset behavior
* Verification status

This documentation shall accompany the RTL implementation.

---

# 11. Common Bus Interface

Every memory-mapped peripheral shall implement the following logical interface:

| Signal      | Width | Direction | Description          |
| ----------- | ----: | --------- | -------------------- |
| `bus_addr`  |    32 | Input     | Bus address          |
| `bus_wdata` |    32 | Input     | Write data           |
| `bus_rdata` |    32 | Output    | Read data            |
| `bus_we`    |     1 | Input     | Write enable         |
| `bus_re`    |     1 | Input     | Read enable          |
| `bus_ready` |     1 | Output    | Transaction complete |

This interface shall be reused across all peripherals to ensure uniform integration.

---

# 12. Coding Conventions

The following coding conventions apply to every RTL module:

* One module per file.
* One primary function per module.
* Non-blocking assignments (`<=`) for sequential logic.
* Blocking assignments (`=`) for combinational logic.
* Explicit default assignments in combinational blocks.
* No inferred latches.
* No implicit nets.
* Meaningful signal names.
* Consistent indentation and formatting.

These conventions improve readability, maintainability, and synthesis reliability.

---

# 13. Verification Requirements

Before integration, every module shall satisfy the following:

* Compiles without warnings.
* Passes lint checks (where applicable).
* Passes unit testbench.
* Produces expected waveforms.
* Handles reset correctly.
* Covers normal and corner-case behavior.

Only verified modules may be integrated into higher-level subsystems.

---

# 14. Summary

This section establishes the global interface conventions that govern the entire RTL codebase. All subsequent sections of this document will build upon these rules by defining the detailed interfaces for each processor stage, functional unit, memory module, bus component, and peripheral.

---

# 15. Processor Core Interfaces

This section defines the interface contracts for every module that forms the RV32I processor core.

Each interface described here represents a stable contract between modules. RTL implementations may change internally, but external interfaces should remain stable unless an architectural revision is made.

---

# 15.1 Program Counter (pc)

## Purpose

The Program Counter (PC) stores the address of the instruction currently being fetched.

The module is responsible for:

* Holding the current instruction address.
* Incrementing to the next sequential instruction.
* Loading branch and jump targets.
* Supporting pipeline stalls.
* Supporting pipeline flushes.

The Program Counter is the first stage of the processor pipeline and provides instruction addresses to the Instruction Fetch stage.

---

## RTL Location

```text
rtl/core/pc.v
```

---

## Dependencies

None.

This module operates independently.

---

## Interface Diagram

```text
                 +----------------------+
                 |     Program Counter  |
                 +----------------------+
 clk ----------->|                      |
 rst ----------->|                      |
 stall --------->|                      |
 pc_next ------->|                      |
 pc_write ------>|                      |
                 |                      |
 current_pc <----|                      |
 pc_plus4 <------|                      |
                 +----------------------+
```

---

## Parameters

| Parameter | Default | Description              |
| --------- | ------: | ------------------------ |
| PC_WIDTH  |      32 | Width of Program Counter |

---

## Inputs

| Signal   | Width | Description                   |
| -------- | ----: | ----------------------------- |
| clk      |     1 | System clock                  |
| rst      |     1 | Synchronous active-high reset |
| stall    |     1 | Freeze PC update              |
| pc_write |     1 | Enable PC update              |
| pc_next  |    32 | Next program counter value    |

---

## Outputs

| Signal     | Width | Description                 |
| ---------- | ----: | --------------------------- |
| current_pc |    32 | Current instruction address |
| pc_plus4   |    32 | Current PC + 4              |

---

## Functional Behavior

On every rising clock edge:

* If reset is asserted, the Program Counter is initialized to the reset vector.
* If stall is asserted, the current value is retained.
* If pc_write is asserted, the Program Counter loads `pc_next`.
* Otherwise, the Program Counter increments sequentially.

---

## Reset Behavior

On reset:

* Program Counter ← Reset Vector
* Output remains stable until the next valid update.

---

## Verification Requirements

The Program Counter shall be verified for:

* Reset operation
* Sequential increment
* Branch target loading
* Jump target loading
* Stall behavior
* Continuous execution

---

# 15.2 Instruction Fetch (instruction_fetch)

## Purpose

The Instruction Fetch (IF) module retrieves instructions from Instruction Memory.

Responsibilities include:

* Sending the Program Counter to Instruction Memory.
* Receiving the fetched instruction.
* Computing PC + 4.
* Passing results to the IF/ID pipeline register.

---

## RTL Location

```text
rtl/core/if/instruction_fetch.v
```

---

## Dependencies

* Program Counter
* Instruction Memory

---

## Interface Diagram

```text
               +-----------------------------+
               |    Instruction Fetch        |
               +-----------------------------+
 current_pc --->|                             |
 instruction <--|                             |
                |                             |
 imem_addr ---->|                             |
 fetched_inst <-|                             |
 pc_plus4 ----->|                             |
                +-----------------------------+
```

---

## Inputs

| Signal      | Width | Description                    |
| ----------- | ----: | ------------------------------ |
| clk         |     1 | System clock                   |
| rst         |     1 | Reset                          |
| current_pc  |    32 | Current Program Counter        |
| instruction |    32 | Instruction returned by memory |

---

## Outputs

| Signal              | Width | Description                |
| ------------------- | ----: | -------------------------- |
| imem_addr           |    32 | Instruction memory address |
| fetched_instruction |    32 | Current instruction        |
| pc_plus4            |    32 | Current PC + 4             |

---

## Verification Requirements

The module shall verify:

* Correct instruction fetch.
* Sequential instruction addresses.
* Reset behavior.
* Branch redirection.

---

# 15.3 IF/ID Pipeline Register

## Purpose

The IF/ID register stores information transferred between the Fetch and Decode stages.

This register isolates the two pipeline stages and ensures synchronous instruction flow.

---

## RTL Location

```text
rtl/core/pipeline/if_id.v
```

---

## Inputs

| Signal         | Width | Description             |
| -------------- | ----: | ----------------------- |
| clk            |     1 | Clock                   |
| rst            |     1 | Reset                   |
| stall          |     1 | Hold current contents   |
| flush          |     1 | Insert bubble           |
| instruction_in |    32 | Instruction from IF     |
| pc_in          |    32 | Current Program Counter |
| pc_plus4_in    |    32 | PC + 4                  |

---

## Outputs

| Signal          | Width | Description                 |
| --------------- | ----: | --------------------------- |
| instruction_out |    32 | Instruction to Decode stage |
| pc_out          |    32 | Program Counter             |
| pc_plus4_out    |    32 | PC + 4                      |

---

## Reset Behavior

When reset is asserted:

* All outputs are cleared to zero.

When flush is asserted:

* Instruction output becomes NOP.
* Remaining fields are cleared.

---

## Verification Requirements

Verify:

* Correct data transfer.
* Stall operation.
* Flush operation.
* Reset behavior.

---

# 15.4 Instruction Decode (instruction_decode)

## Purpose

The Instruction Decode module interprets the fetched instruction and prepares all information required for execution.

Responsibilities include:

* Extracting instruction fields.
* Identifying instruction format.
* Reading the Register File.
* Generating immediate values.
* Producing decoded control information.

---

## RTL Location

```text
rtl/core/id/instruction_decode.v
```

---

## Dependencies

* Register File
* Immediate Generator
* Control Unit

---

## Inputs

| Signal      | Width | Description         |
| ----------- | ----: | ------------------- |
| instruction |    32 | Current instruction |
| pc          |    32 | Program Counter     |
| clk         |     1 | Clock               |
| rst         |     1 | Reset               |

---

## Outputs

| Signal      | Width | Description             |
| ----------- | ----: | ----------------------- |
| rs1_addr    |     5 | Source Register 1       |
| rs2_addr    |     5 | Source Register 2       |
| rd_addr     |     5 | Destination Register    |
| immediate   |    32 | Generated immediate     |
| opcode      |     7 | Instruction opcode      |
| funct3      |     3 | Function field          |
| funct7      |     7 | Function field          |
| control_bus |   *N* | Decoded control signals |

---

## Verification Requirements

The decoder shall be verified using representative instructions from every supported RV32I instruction format:

* R-Type
* I-Type
* S-Type
* B-Type
* U-Type
* J-Type

Each instruction shall produce the expected register addresses, immediate value, opcode, and control information.

---

# 15.5 ID/EX Pipeline Register

The ID/EX register transfers decoded operands, immediate values, destination register information, and control signals from the Decode stage to the Execute stage.

This module shall support:

* Stall operation
* Pipeline flush
* Reset initialization
* Full control signal propagation

The detailed port definitions will follow the same format established for the IF/ID register and will include every datapath and control signal required by the Execute stage.

---

# 15.6 Design Notes

The interfaces defined in this section establish the complete front-end of the processor pipeline (IF and ID stages). These interfaces shall remain stable throughout RTL development, ensuring that subsequent implementation of the Execute, Memory, and Write-Back stages can proceed independently without requiring modifications to the front-end modules.

---

# 16. Processor Functional Unit Interfaces

This section defines the interface contracts for the primary computational modules within the RV32I processor. These functional units perform instruction execution, operand generation, hazard resolution, and pipeline control.

Each module shall adhere to the interface specifications described below.

---

# 16.1 Register File (register_file)

## Purpose

The Register File stores the thirty-two architectural registers defined by the RV32I ISA.

It provides:

* Two asynchronous read ports.
* One synchronous write port.
* Register x0 permanently tied to zero.

The Register File is accessed during the Instruction Decode stage and updated during the Write Back stage.

---

## RTL Location

```text
rtl/core/register_file.v
```

---

## Dependencies

* Write Back Stage
* Instruction Decode Stage

---

## Interface Diagram

```text
                  +---------------------------+
                  |       Register File       |
                  +---------------------------+
 rs1_addr ------->|                           |
 rs2_addr ------->|                           |
 rd_addr -------->|                           |
 rd_data -------->|                           |
 reg_write ------>|                           |
 clk ------------>|                           |
 rst ------------>|                           |
                  |                           |
 rs1_data <-------|                           |
 rs2_data <-------|                           |
                  +---------------------------+
```

---

## Parameters

| Parameter  | Default | Description            |
| ---------- | ------: | ---------------------- |
| DATA_WIDTH |      32 | Register width         |
| REG_COUNT  |      32 | Number of registers    |
| ADDR_WIDTH |       5 | Register address width |

---

## Inputs

| Signal    | Width | Description           |
| --------- | ----: | --------------------- |
| clk       |     1 | System clock          |
| rst       |     1 | Synchronous reset     |
| rs1_addr  |     5 | Source Register 1     |
| rs2_addr  |     5 | Source Register 2     |
| rd_addr   |     5 | Destination Register  |
| rd_data   |    32 | Write-back data       |
| reg_write |     1 | Register write enable |

---

## Outputs

| Signal   | Width | Description |
| -------- | ----: | ----------- |
| rs1_data |    32 | Operand A   |
| rs2_data |    32 | Operand B   |

---

## Functional Requirements

* Register x0 shall always return zero.
* Writes to x0 shall be ignored.
* Read operations shall be combinational.
* Write operations shall occur on the rising clock edge.

---

## Verification Requirements

* Read-after-write behavior
* Register x0 protection
* Simultaneous dual-read operation
* Reset behavior
* Boundary register addresses

---

# 16.2 Arithmetic Logic Unit (alu)

## Purpose

The ALU performs all arithmetic, logical, comparison, and shift operations required by the RV32I ISA.

The ALU is purely combinational.

---

## RTL Location

```text
rtl/core/ex/alu.v
```

---

## Interface Diagram

```text
                 +-------------------------+
                 |           ALU           |
                 +-------------------------+
 operand_a ----->|                         |
 operand_b ----->|                         |
 alu_control --->|                         |
                 |                         |
 result <--------|                         |
 zero <----------|                         |
 overflow <------|                         |
                 +-------------------------+
```

---

## Inputs

| Signal      | Width | Description          |
| ----------- | ----: | -------------------- |
| operand_a   |    32 | Operand A            |
| operand_b   |    32 | Operand B            |
| alu_control |     4 | ALU operation select |

---

## Outputs

| Signal   | Width | Description        |
| -------- | ----: | ------------------ |
| result   |    32 | ALU output         |
| zero     |     1 | Result equals zero |
| overflow |     1 | Signed overflow    |

---

## Supported Operations

| Operation | Code |
| --------- | ---- |
| ADD       | 0000 |
| SUB       | 0001 |
| AND       | 0010 |
| OR        | 0011 |
| XOR       | 0100 |
| SLL       | 0101 |
| SRL       | 0110 |
| SRA       | 0111 |
| SLT       | 1000 |
| SLTU      | 1001 |

---

## Verification Requirements

* Every RV32I ALU operation
* Overflow conditions
* Signed comparisons
* Unsigned comparisons
* Shift edge cases
* Zero flag generation

---

# 16.3 Immediate Generator (immediate_generator)

## Purpose

Generates sign-extended immediate values for all RV32I instruction formats.

---

## RTL Location

```text
rtl/core/id/immediate_generator.v
```

---

## Inputs

| Signal      | Width |
| ----------- | ----: |
| instruction |    32 |

---

## Outputs

| Signal    | Width |
| --------- | ----: |
| immediate |    32 |

---

## Supported Formats

* I-Type
* S-Type
* B-Type
* U-Type
* J-Type

---

## Verification Requirements

Every immediate format shall be validated using representative instruction encodings.

---

# 16.4 Control Unit (control_unit)

## Purpose

Generates all processor control signals based on the decoded instruction.

The Control Unit is responsible for translating the instruction opcode into control actions for the datapath.

---

## RTL Location

```text
rtl/core/control/control_unit.v
```

---

## Inputs

| Signal | Width |
| ------ | ----: |
| opcode |     7 |
| funct3 |     3 |
| funct7 |     7 |

---

## Outputs

| Signal      | Width |
| ----------- | ----: |
| reg_write   |     1 |
| mem_read    |     1 |
| mem_write   |     1 |
| mem_to_reg  |     1 |
| alu_src     |     1 |
| branch      |     1 |
| jump        |     1 |
| alu_control |     4 |

---

## Verification Requirements

Each supported instruction shall generate the expected control signal combination.

---

# 16.5 Branch Unit (branch_unit)

## Purpose

Evaluates branch conditions and determines whether program flow should change.

---

## RTL Location

```text
rtl/core/ex/branch_unit.v
```

---

## Inputs

| Signal    | Width |
| --------- | ----: |
| operand_a |    32 |
| operand_b |    32 |
| funct3    |     3 |

---

## Outputs

| Signal       | Width |
| ------------ | ----: |
| branch_taken |     1 |

---

## Supported Branches

* BEQ
* BNE
* BLT
* BGE
* BLTU
* BGEU

---

## Verification Requirements

Each branch type shall be tested using both taken and not-taken scenarios.

---

# 16.6 Forwarding Unit (forwarding_unit)

## Purpose

Resolves data hazards by forwarding results from later pipeline stages to the Execute stage.

This minimizes pipeline stalls and improves throughput.

---

## RTL Location

```text
rtl/core/control/forwarding_unit.v
```

---

## Inputs

| Signal        | Width |
| ------------- | ----: |
| ex_rs1        |     5 |
| ex_rs2        |     5 |
| mem_rd        |     5 |
| wb_rd         |     5 |
| mem_reg_write |     1 |
| wb_reg_write  |     1 |

---

## Outputs

| Signal    | Width |
| --------- | ----: |
| forward_a |     2 |
| forward_b |     2 |

---

## Verification Requirements

* EX→EX forwarding
* MEM→EX forwarding
* No false forwarding
* Priority resolution

---

# 16.7 Hazard Detection Unit (hazard_detection)

## Purpose

Detects hazards that cannot be resolved through forwarding.

The unit is responsible for inserting stalls and bubbles when required.

---

## RTL Location

```text
rtl/core/control/hazard_detection.v
```

---

## Inputs

| Signal      | Width |
| ----------- | ----: |
| id_rs1      |     5 |
| id_rs2      |     5 |
| ex_rd       |     5 |
| ex_mem_read |     1 |

---

## Outputs

| Signal         | Width |
| -------------- | ----: |
| stall          |     1 |
| pc_write       |     1 |
| if_id_write    |     1 |
| pipeline_flush |     1 |

---

## Verification Requirements

* Load-use hazards
* Consecutive hazards
* Stall duration
* Bubble insertion
* Recovery after hazard resolution

---

# 16.8 Design Principles

All functional units shall satisfy the following requirements:

* Clearly defined single responsibility.
* Stable and documented interfaces.
* Independent synthesizability.
* Independent unit-level verification.
* Minimal coupling with other modules.
* Parameterized where practical.
* Consistent naming conventions.

---

# 16.9 Summary

This section defines the interfaces and behavioral contracts for the computational units that implement the RV32I processor. Together, these modules perform operand generation, arithmetic execution, control generation, and hazard resolution. Their interfaces are intentionally frozen before RTL development to ensure independent implementation and straightforward integration.

---

# 17. Memory and Bus Interface Specification

This section defines the interfaces for the memory subsystem and the custom system bus. These interfaces form the communication boundary between the processor core and the external components of the System-on-Chip.

---

# 17.1 Instruction Memory (instruction_memory)

## Purpose

The Instruction Memory stores executable RV32I instructions and services instruction fetch requests from the Instruction Fetch stage.

Instruction Memory is read-only during processor execution.

---

## RTL Location

```text
rtl/memory/instruction_memory.v
```

---

## Module Classification

| Property       | Value               |
| -------------- | ------------------- |
| Module Type    | Memory              |
| Pipeline Stage | IF                  |
| Clocked        | Yes                 |
| Read Latency   | 1 Cycle             |
| Write Support  | Initialization Only |

---

## Interface Diagram

```text
                 +---------------------------+
                 |   Instruction Memory      |
                 +---------------------------+
 clk ----------->|                           |
 rst ----------->|                           |
 address ------->|                           |
                 |                           |
 instruction <---|                           |
 ready <---------|                           |
                 +---------------------------+
```

---

## Inputs

| Signal  | Width | Description         |
| ------- | ----: | ------------------- |
| clk     |     1 | System clock        |
| rst     |     1 | Synchronous reset   |
| address |    32 | Instruction address |

---

## Outputs

| Signal      | Width | Description              |
| ----------- | ----: | ------------------------ |
| instruction |    32 | Fetched instruction      |
| ready       |     1 | Memory response complete |

---

## Timing Contract

| Property          | Value                          |
| ----------------- | ------------------------------ |
| Address Sampled   | Rising Edge                    |
| Instruction Valid | Following Cycle                |
| Read Operation    | Synchronous                    |
| Write Operation   | Not Supported During Execution |

---

## Verification Requirements

* Sequential instruction fetch
* Boundary address access
* Reset behavior
* Program loading
* Illegal address handling

---

# 17.2 Data Memory (data_memory)

## Purpose

Provides read and write access to runtime data.

The Data Memory supports processor load/store instructions and serves as the primary storage for variables and the stack.

---

## RTL Location

```text
rtl/memory/data_memory.v
```

---

## Module Classification

| Property       | Value   |
| -------------- | ------- |
| Module Type    | Memory  |
| Pipeline Stage | MEM     |
| Clocked        | Yes     |
| Read Latency   | 1 Cycle |
| Write Latency  | 1 Cycle |

---

## Inputs

| Signal     | Width |
| ---------- | ----: |
| clk        |     1 |
| rst        |     1 |
| address    |    32 |
| write_data |    32 |
| mem_read   |     1 |
| mem_write  |     1 |

---

## Outputs

| Signal    | Width |
| --------- | ----: |
| read_data |    32 |
| ready     |     1 |

---

## Timing Contract

* Address sampled on rising edge.
* Read data valid one cycle later.
* Writes committed on rising edge.
* Simultaneous read/write to the same address is undefined in Version 1.

---

## Verification Requirements

* Sequential writes
* Sequential reads
* Consecutive accesses
* Reset behavior
* Boundary conditions

---

# 17.3 Address Decoder (address_decoder)

## Purpose

The Address Decoder determines which memory or peripheral should respond to a processor transaction.

Only one slave shall be selected for any valid address.

---

## RTL Location

```text
rtl/bus/address_decoder.v
```

---

## Module Classification

| Property       | Value         |
| -------------- | ------------- |
| Module Type    | Combinational |
| Pipeline Stage | MEM           |
| Clock Required | No            |

---

## Inputs

| Signal   | Width |
| -------- | ----: |
| bus_addr |    32 |

---

## Outputs

| Signal   | Width | Description                |
| -------- | ----: | -------------------------- |
| imem_sel |     1 | Instruction memory select  |
| dmem_sel |     1 | Data memory select         |
| sha_sel  |     1 | SHA-256 accelerator select |
| uart_sel |     1 | UART select                |
| gpio_sel |     1 | GPIO select                |

---

## Timing Contract

* Address decoding is purely combinational.
* Outputs must settle within the same clock cycle.
* Exactly one select signal may be asserted for a valid address.

---

## Verification Requirements

* Valid address decoding
* Invalid address detection
* One-hot output validation
* Boundary address testing

---

# 17.4 Bus Controller (bus_controller)

## Purpose

Coordinates all processor transactions on the custom memory-mapped bus.

The Bus Controller ensures proper sequencing of read and write operations and interfaces between the CPU and peripheral devices.

---

## RTL Location

```text
rtl/bus/bus_controller.v
```

---

## Module Classification

| Property       | Value      |
| -------------- | ---------- |
| Module Type    | Sequential |
| Pipeline Stage | MEM        |
| Clock Required | Yes        |

---

## Inputs

| Signal      | Width |
| ----------- | ----: |
| clk         |     1 |
| rst         |     1 |
| bus_addr    |    32 |
| bus_wdata   |    32 |
| bus_we      |     1 |
| bus_re      |     1 |
| slave_ready |     1 |
| slave_rdata |    32 |

---

## Outputs

| Signal       | Width |
| ------------ | ----: |
| master_ready |     1 |
| master_rdata |    32 |
| slave_addr   |    32 |
| slave_wdata  |    32 |
| slave_we     |     1 |
| slave_re     |     1 |

---

## Timing Contract

* Transactions begin on a rising edge.
* Controller waits for `slave_ready`.
* Read data becomes valid when `master_ready` is asserted.
* Only one transaction may be active at any time.

---

## Verification Requirements

* Single read transaction
* Single write transaction
* Consecutive transactions
* Ready signal handling
* Back-to-back accesses

---

# 17.5 Common Peripheral Interface

Every memory-mapped peripheral shall implement the following standard interface.

---

## Interface Definition

| Signal    | Width | Direction | Description          |
| --------- | ----: | --------- | -------------------- |
| clk       |     1 | Input     | System clock         |
| rst       |     1 | Input     | Synchronous reset    |
| bus_addr  |    32 | Input     | Peripheral address   |
| bus_wdata |    32 | Input     | Write data           |
| bus_rdata |    32 | Output    | Read data            |
| bus_we    |     1 | Input     | Write enable         |
| bus_re    |     1 | Input     | Read enable          |
| bus_ready |     1 | Output    | Transaction complete |

---

## Interface Contract

Every peripheral shall:

* Decode only addresses within its assigned address range.
* Ignore accesses outside its region.
* Respond with `bus_ready` when the transaction completes.
* Drive `bus_rdata` only during valid read operations.
* Never drive the bus simultaneously with another peripheral.

---

## Timing Contract

| Property               | Value              |
| ---------------------- | ------------------ |
| Address Stable         | Entire Transaction |
| Write Data Sampled     | Rising Edge        |
| Read Data Valid        | Before `bus_ready` |
| Transaction Completion | `bus_ready = 1`    |

---

# 17.6 Bus Arbitration

Version 1 implements a single-master architecture.

Therefore:

* No arbitration logic is required.
* The CPU is the only transaction initiator.
* Peripherals never initiate bus transfers.

Future versions may introduce DMA or additional bus masters.

---

# 17.7 Interface Design Rules

All memory and bus interfaces shall satisfy the following:

* Single clock domain.
* 32-bit address space.
* 32-bit data bus.
* Synchronous operation.
* Active-high control signals.
* No tri-state buses inside the FPGA.
* Stable outputs during active transactions.

---

# 17.8 Error Handling

Version 1 uses a simplified error model.

Rules:

* Undefined addresses return zero.
* Writes to undefined regions are ignored.
* Simultaneous read and write requests are not permitted.
* Peripheral timeouts are not implemented.

Future revisions may include bus error reporting and exception generation.

---

# 17.9 Summary

The interfaces defined in this section establish a consistent communication model between the processor, memories, and peripherals. By standardizing signal naming, timing behavior, and transaction sequencing, the design supports modular RTL development, straightforward verification, and scalable system integration.

These interface contracts shall remain stable throughout Version 1 of the project and provide the foundation for all memory-mapped peripherals and future bus enhancements.

---

# 18. Peripheral Interface Specification

This section defines the hardware interface, software-visible register map, and operational behavior of all memory-mapped peripherals integrated into the RV32I System-on-Chip.

Every peripheral conforms to the common bus interface defined in Section 17.

---

# 18.1 SHA-256 Hardware Accelerator

## Purpose

The SHA-256 accelerator performs cryptographic hash computation in dedicated hardware.

The accelerator accepts a single 512-bit message block, computes the corresponding 256-bit digest, and exposes all control and status through memory-mapped registers.

The processor interacts with the accelerator using ordinary load and store instructions.

---

## RTL Location

```text id="pqzcmg"
rtl/crypto/sha256_top.v
```

---

## Module Classification

| Property     | Value         |
| ------------ | ------------- |
| Type         | Peripheral    |
| Interface    | Memory-Mapped |
| Bus Width    | 32 bits       |
| Clock Domain | System Clock  |
| Operation    | Sequential    |

---

## Interface Diagram

```text id="trc8jc"
                 +----------------------------------+
                 |      SHA-256 Accelerator         |
                 +----------------------------------+
 clk ----------->|                                  |
 rst ----------->|                                  |
 bus_addr ------>|                                  |
 bus_wdata ----->|                                  |
 bus_we -------->|                                  |
 bus_re -------->|                                  |
                 |                                  |
 bus_rdata <-----|                                  |
 bus_ready <-----|                                  |
                 +----------------------------------+
```

---

## Register Map

| Offset      | Register      | Access | Description                |
| ----------- | ------------- | ------ | -------------------------- |
| 0x000       | CONTROL       | R/W    | Start and reset operations |
| 0x004       | STATUS        | R      | Busy, Done                 |
| 0x008–0x044 | MESSAGE[0:15] | W      | 512-bit message block      |
| 0x048–0x064 | HASH[0:7]     | R      | 256-bit digest             |
| 0x068       | VERSION       | R      | Accelerator version        |

---

## CONTROL Register

|  Bit | Name     | Description            |
| ---: | -------- | ---------------------- |
|    0 | START    | Begin hash computation |
|    1 | RESET    | Clear internal state   |
| 31:2 | Reserved | Read as zero           |

---

## STATUS Register

|  Bit | Name     | Description         |
| ---: | -------- | ------------------- |
|    0 | BUSY     | Accelerator running |
|    1 | DONE     | Digest available    |
| 31:2 | Reserved | Reserved            |

---

## Operation Sequence

1. CPU writes sixteen 32-bit words to the MESSAGE registers.
2. CPU sets the START bit.
3. Accelerator begins processing.
4. STATUS.BUSY is asserted.
5. Digest computation completes.
6. STATUS.DONE is asserted.
7. CPU reads HASH0–HASH7.

---

## Timing

| Operation       | Latency     |
| --------------- | ----------- |
| Register Write  | 1 Cycle     |
| Register Read   | 1 Cycle     |
| SHA Computation | Multi-cycle |

---

## Verification Requirements

* Register access
* Message loading
* Hash correctness
* Reset behavior
* Consecutive hash operations
* Busy/Done transitions

---

# 18.2 UART Peripheral

## Purpose

Provides asynchronous serial communication between the FPGA and a host computer.

The UART enables:

* Console output
* Debug messages
* Firmware interaction
* Future bootloader support

---

## RTL Location

```text id="wr80sh"
rtl/peripherals/uart_top.v
```

---

## Register Map

| Offset | Register | Access | Description        |
| ------ | -------- | ------ | ------------------ |
| 0x000  | TX_DATA  | W      | Transmit byte      |
| 0x004  | RX_DATA  | R      | Received byte      |
| 0x008  | STATUS   | R      | UART status        |
| 0x00C  | CONTROL  | R/W    | UART configuration |

---

## STATUS Register

|  Bit | Name     | Description             |
| ---: | -------- | ----------------------- |
|    0 | TX_READY | Ready to transmit       |
|    1 | RX_VALID | Received byte available |
| 31:2 | Reserved | Reserved                |

---

## CONTROL Register

|  Bit | Name        | Description        |
| ---: | ----------- | ------------------ |
|    0 | UART_ENABLE | Enable UART        |
|    1 | TX_ENABLE   | Enable transmitter |
|    2 | RX_ENABLE   | Enable receiver    |
| 31:3 | Reserved    | Reserved           |

---

## Timing

* Register accesses complete in one cycle.
* Serial transmission timing depends on the configured baud rate.
* Status bits update synchronously.

---

## Verification Requirements

* Byte transmission
* Byte reception
* Status register updates
* Reset behavior
* Continuous data transfer

---

# 18.3 GPIO Peripheral

## Purpose

Provides access to external user I/O available on the Basys-3 FPGA board.

Version 1 supports:

* LEDs
* Slide switches

Future versions may include buttons, seven-segment displays, and PMOD expansion.

---

## RTL Location

```text id="x6t9ae"
rtl/peripherals/gpio.v
```

---

## Register Map

| Offset | Register  | Access | Description           |
| ------ | --------- | ------ | --------------------- |
| 0x000  | LED_OUT   | R/W    | LED output register   |
| 0x004  | SWITCH_IN | R      | Switch input register |

---

## Functional Behavior

Writing to LED_OUT immediately updates the on-board LEDs.

Reading SWITCH_IN returns the current switch positions.

---

## Verification Requirements

* LED control
* Switch reading
* Reset behavior
* Consecutive accesses

---

# 18.4 Top-Level Module

## Purpose

The Top-Level Module integrates every subsystem into a complete FPGA implementation.

---

## RTL Location

```text id="bs3pf7"
rtl/top/top.v
```

---

## Responsibilities

* Instantiate CPU.
* Instantiate memories.
* Instantiate bus.
* Instantiate peripherals.
* Connect all interfaces.
* Connect FPGA pins.
* Distribute clock and reset.

---

## External FPGA Interface

| Signal  | Direction | Description          |
| ------- | --------- | -------------------- |
| clk     | Input     | 100 MHz system clock |
| rst     | Input     | System reset         |
| uart_tx | Output    | UART transmit        |
| uart_rx | Input     | UART receive         |
| led     | Output    | Basys-3 LEDs         |
| sw      | Input     | Basys-3 switches     |

---

## Verification Requirements

* Successful system integration
* Processor execution
* Memory accesses
* Peripheral accesses
* FPGA implementation
* End-to-end software execution

---

# 18.5 Peripheral Integration Rules

All peripherals shall satisfy the following:

* Implement the common bus interface.
* Decode only assigned addresses.
* Ignore accesses outside their address range.
* Respond within the specified timing.
* Drive the read data bus only during valid transactions.
* Maintain synchronous operation.

---

# 18.6 Software Programming Model

The processor accesses all peripherals using standard RV32I load and store instructions.

No custom processor instructions are required.

Example firmware flow:

1. Configure UART.
2. Load a message into the SHA-256 accelerator.
3. Start hashing.
4. Poll STATUS.
5. Read the digest.
6. Send the digest over UART.
7. Display status using GPIO.

This software model demonstrates hardware/software co-design while maintaining a simple programming interface.

---

# 18.7 Future Extensions

The peripheral architecture has been designed to support additional memory-mapped devices, including:

* Timer
* SPI Controller
* I²C Controller
* PWM Generator
* Interrupt Controller
* DMA Engine
* Performance Counters
* AES Accelerator

These peripherals can be integrated by allocating a new address range and implementing the common bus interface.

---

# 18.8 Summary

This section defines the complete interface contracts for all memory-mapped peripherals within the FPGA-based RV32I SoC. The standardized register maps, timing rules, and software interaction model ensure that peripherals can be implemented, verified, and integrated independently while presenting a consistent programming model to software executing on the processor.
