# Register File Verification Report

**Project:** FPGA RISC-V SoC with SHA-256 Accelerator

**Module:** Register File (RV32I)

**Version:** v1.0

**Status:** ✅ Verified

---

# 1. Objective

The objective of this verification process was to validate the functionality of the RV32I Register File before integrating it into the processor datapath.

The verification focused on:

- Correct synchronous write operation
- Correct asynchronous read operation
- Reset functionality
- x0 register protection
- Read Port 1
- Read Port 2
- Dual read capability
- Consecutive writes
- Write disable functionality

---

# 2. Register File Architecture

The implemented register file contains:

| Feature | Specification |
|----------|---------------|
| Number of Registers | 32 |
| Register Width | 32 bits |
| Read Ports | 2 (Asynchronous) |
| Write Ports | 1 (Synchronous) |
| Reset | Synchronous |
| x0 Register | Hardwired to Zero |

---

# 3. Verification Environment

Simulation Tool

- Icarus Verilog

Waveform Viewer

- GTKWave

Verification Style

- Self-checking testbench

Testbench Features

- Parameterized
- Reusable Tasks
- PASS / FAIL reporting
- Waveform dumping
- Directed testing

---

# 4. Testbench Architecture

The testbench consists of:

```
Signal Declaration
        │
        ▼
DUT Instantiation
        │
        ▼
Clock Generator
        │
        ▼
Waveform Dump
        │
        ▼
Verification Tasks
        │
        ▼
Directed Test Cases
        │
        ▼
PASS / FAIL Summary
```

---

# 5. Verification Tasks

The following reusable tasks were created.

## reset_dut()

Purpose

- Reset the DUT
- Initialize all inputs
- Synchronize reset with the clock
- Start every test from a known state

---

## write_reg(addr,data)

Purpose

- Drive write address
- Drive write data
- Enable write
- Wait for one positive clock edge
- Disable write

---

## check_reg(addr,expected)

Purpose

- Read using Read Port 1
- Compare expected and actual values
- Report PASS/FAIL

---

## check_reg_rs2(addr,expected)

Purpose

- Verify Read Port 2 independently.

---

## check_dual_read()

Purpose

Verify simultaneous operation of both asynchronous read ports.

---

# 6. Directed Test Cases

| Test | Description | Result |
|-------|-------------|--------|
| Reset | Clear all registers | PASS |
| x0 Read | Always zero | PASS |
| Write x5 | Store data | PASS |
| Read x5 | Correct read | PASS |
| Write x31 | Highest register | PASS |
| Consecutive Writes | Multiple sequential writes | PASS |
| Read Port 2 | Independent read | PASS |
| Dual Read | Simultaneous read | PASS |
| Write Disable | No unintended write | PASS |
| Write x0 | Ignored | PASS |

---

# 7. Major Debugging Sessions

During verification several issues were encountered and resolved.

---

## Issue 1 — Registers Reading XXXXXXXX

### Observation

Simulation produced:

```
Expected : DEADBEEF

Actual   : XXXXXXXX
```

### Initial Hypothesis

Possible RTL bug inside the Register File.

### Investigation

A minimal standalone testbench was created to isolate the problem.

### Result

The minimal testbench passed successfully.

### Root Cause

The Register File RTL was correct.

The issue originated from the verification environment rather than the DUT.

---

## Issue 2 — Reset Timing

### Observation

Registers remained uninitialized after reset.

### Root Cause

The testbench did not allow sufficient time for the synchronous reset to be sampled on a positive clock edge.

Since the Register File uses

```verilog
always @(posedge clk)
```

the reset is only applied on a clock edge.

### Solution

The reset task was modified to:

1. Assert reset.
2. Wait for a positive clock edge.
3. Deassert reset.
4. Wait one additional clock cycle before beginning tests.

This guarantees that the DUT starts from a known state.

---

## Issue 3 — Synchronous Write Timing

### Observation

Read operations occurred immediately after enabling write.

The expected value had not yet been stored.

### Root Cause

The Register File performs synchronous writes.

Register updates occur only on a positive clock edge.

### Incorrect Sequence

```
reg_write = 1

Read Register
```

### Correct Sequence

```
Drive Address

↓

Drive Data

↓

Assert reg_write

↓

Wait for posedge clk

↓

Write occurs

↓

Disable reg_write

↓

Read Register
```

---

## Issue 4 — Verification Methodology

Originally the entire testbench was debugged simultaneously.

This made locating the bug difficult.

A professional debugging methodology was adopted.

```
Large Testbench

↓

Create Minimal Testbench

↓

Verify DUT

↓

Identify Verification Bug

↓

Fix Timing

↓

Return to Full Testbench
```

This significantly reduced debugging time.

---

# 8. Important Design Lessons

## Asynchronous Read

Changing the read address immediately changes the output.

No clock edge is required.

---

## Synchronous Write

Changing write inputs alone does not update the register.

The update occurs only at the next positive clock edge.

---

## Importance of Reset

Every verification sequence should begin from a known hardware state.

Proper reset synchronization is essential.

---

## Value of Minimal Testbenches

Reducing the problem to the smallest reproducible example greatly simplifies debugging.

This methodology is widely used in FPGA and ASIC verification.

---

# 9. Final Verification Status

| Feature | Status |
|----------|--------|
| RTL Review | PASS |
| Functional Simulation | PASS |
| Reset Verification | PASS |
| x0 Protection | PASS |
| Read Port 1 | PASS |
| Read Port 2 | PASS |
| Dual Read | PASS |
| Consecutive Writes | PASS |
| Write Disable | PASS |
| Waveform Inspection | PASS |

---

# 10. Conclusions

The Register File has been successfully verified using a self-checking testbench.

All planned functional requirements have been satisfied.

The debugging process reinforced several important digital design concepts, including:

- Synchronous versus asynchronous logic
- Clocked storage elements
- Verification task abstraction
- Timing synchronization
- Incremental debugging using minimal reproducible examples

The Register File is now considered verified and ready for integration into the processor datapath.

---

# 11. Future Improvements

Future versions of the verification environment may include:

- Randomized testing
- Functional coverage
- Constrained-random verification
- Assertion-based verification (SystemVerilog Assertions)
- Continuous Integration (CI) simulation workflow
- Regression testing