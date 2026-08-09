# RV32I CPU Verification Report

## 1. Verification Objective

The objective of this verification stage was to validate the integration of the previously developed RV32I processor blocks into a complete functional CPU.

The verification was designed to check both normal instruction execution and integration between the individual processor modules.

The final regression test contains 52 individual checks.

---

## 2. Verification Environment

The CPU was simulated using Icarus Verilog and VVP.

The complete CPU was instantiated in the testbench and executed a verification program stored in `programs/program.hex`.

The testbench checks the internal Register File and Data Memory to verify the results produced by the processor.

The verification environment checks:

- Register values
- Memory values
- Arithmetic operations
- Logical operations
- Shift operations
- Comparisons
- Load and store operations
- Conditional branches
- JAL and JALR
- LUI and AUIPC
- Register x0 protection

---

## 3. Verification Categories

The final regression test covers the following instruction classes.

| Category | Instructions |
|---|---|
| Arithmetic | ADD, SUB, ADDI |
| Logical | AND, OR, XOR |
| Register shifts | SLL, SRL, SRA |
| Immediate shifts | SLLI, SRLI, SRAI |
| Comparisons | SLT, SLTU |
| Immediate logical | ANDI, ORI, XORI |
| Word memory | LW, SW |
| Halfword memory | LH, LHU, SH |
| Byte memory | LB, LBU, SB |
| Branches | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jumps | JAL, JALR |
| Upper immediate | LUI, AUIPC |
| Register protection | x0 |

---

## 4. Initial CPU Integration Test

The first CPU-level test used a small program containing basic arithmetic instructions.

The program executed:

- `ADDI x1, x0, 10`
- `ADDI x2, x0, 20`
- `ADD x3, x1, x2`

The expected results were:

- `x1 = 10`
- `x2 = 20`
- `x3 = 30`

The test confirmed that the basic instruction-fetch, decode, execute, write-back, and PC-update path was functioning.

---

## 5. Problem 1: Incorrect Instruction Memory File Path

### 5.1 Problem

During the first comprehensive CPU test, the simulator reported that the instruction-memory initialization file could not be opened.

The reported path was:

`programs/programs.hex`

The actual file was:

`programs/program.hex`

As a result, the Instruction Memory was not initialized with the intended test program.

### 5.2 Effect

Because the processor was not receiving the intended instructions, a large number of apparently unrelated CPU tests failed.

This initially made the problem appear to be a processor integration failure.

### 5.3 Resolution

The `INIT_FILE` parameter used by the CPU testbench was corrected to:

`programs/program.hex`

After this change, the processor began executing the intended verification program.

### 5.4 Lesson

The simulation environment and test stimulus must be verified before debugging the processor RTL.

An incorrectly loaded instruction memory can produce many misleading failures throughout the CPU.

---

## 6. Problem 2: Incorrect SRAI Instruction Encoding

### 6.1 Problem

After correcting the instruction-memory file path, only one instruction test was failing.

The failure was:

`SRAI x17`

The expected result was:

`FFFFFFFF`

The actual result was:

`7FFFFFFF`

### 6.2 Investigation

The instruction in the verification program was:

`0019D893`

The instruction used `funct3 = 101`, which identifies the shift-right-immediate instruction class.

However, its `funct7` field was `0000000`.

This encoding corresponds to `SRLI`, not `SRAI`.

For `SRAI`, the required `funct7` field is `0100000`.

### 6.3 Resolution

The instruction was changed from:

`0019D893`

to:

`4019D893`

This changed the `funct7` field from `0000000` to `0100000`.

The ALU Control Unit then correctly selected the arithmetic-right-shift operation.

### 6.4 Result

After correcting the instruction encoding, the SRAI test passed.

The result became:

`FFFFFFFF`

as expected.

### 6.5 Lesson

A failing instruction test does not necessarily indicate an RTL error.

The complete instruction encoding must be checked before modifying the processor implementation.

In this case, the ALU and ALU Control Unit were already functioning correctly.

---

## 7. Problem 3: Overlapping Verification Memory Regions

### 7.1 Problem

After correcting the SRAI instruction, three tests were still failing:

- BLT
- SH
- SB

One of the failures was:

`SH byte 0`

The expected value was `1E`, while the observed value was `01`.

### 7.2 Investigation

The value `01` was identified as a branch-success marker used by the verification program.

The test program was using overlapping memory locations for different purposes.

The store tests were using low memory addresses while the branch tests were also writing their pass/fail markers into nearby memory locations.

Therefore, a later branch test could overwrite the memory location used to verify an earlier store instruction.

### 7.3 Resolution

The verification memory map was reorganized so that different categories of tests use separate memory regions.

The final memory layout was organized as follows.

| Address | Purpose |
|---:|---|
| 0 to 15 | Load and store tests |
| 16 | Negative byte store |
| 18 to 19 | Negative halfword store |
| 32 | BEQ marker |
| 36 | BNE marker |
| 40 | BLT marker |
| 44 | BGE marker |
| 48 | BLTU marker |
| 52 | BGEU marker |
| 56 to 59 | JAL return address |
| 60 to 63 | JALR return address |

This prevents one verification test from modifying the data used by another test.

### 7.4 Result

After reorganizing the verification memory map, the BLT, SH, and SB tests all passed.

No modification to the corresponding CPU RTL was required.

### 7.5 Lesson

A verification testbench must isolate the state used by individual tests.

Overlapping test resources can create failures that appear to originate from the processor even though the processor is functioning correctly.

---

## 8. Final Verification

After resolving the instruction-memory path, instruction encoding, and verification-memory layout issues, the complete CPU regression test was executed again.

The final result was:

**Tests: 52**

**Errors: 0**

All 52 verification checks passed.

---

## 9. Verification Results

| Verification Area | Result |
|---|---|
| Instruction Fetch | PASS |
| Main Control | PASS |
| ALU Control | PASS |
| Register File Integration | PASS |
| Immediate Generation | PASS |
| ALU Integration | PASS |
| Data Memory Integration | PASS |
| Branch Unit Integration | PASS |
| Next-PC Logic | PASS |
| Write-Back | PASS |
| JAL | PASS |
| JALR | PASS |
| LUI | PASS |
| AUIPC | PASS |
| x0 Protection | PASS |
| Complete CPU Regression | PASS |

---

## 10. Final Test Coverage

The final 52-test regression verifies:

- ADD
- SUB
- ADDI
- AND
- OR
- XOR
- SLL
- SRL
- SRA
- SLT
- SLTU
- SLLI
- SRLI
- SRAI
- ANDI
- ORI
- XORI
- LW
- LB
- LBU
- LH
- LHU
- BEQ
- BNE
- BLT
- BGE
- BLTU
- BGEU
- JAL
- JALR
- LUI
- AUIPC
- SW
- SH
- SB
- Negative byte and halfword operations
- x0 protection

---

## 11. Verification Conclusion

The RV32I CPU was successfully integrated and verified at the RTL simulation level.

The final regression achieved 52 successful tests with zero errors.

The troubleshooting process also demonstrated that several apparent CPU failures were caused by the verification environment rather than the processor RTL.

The major issues encountered were:

1. Incorrect Instruction Memory file path.
2. Incorrect SRAI instruction encoding.
3. Overlapping memory regions in the verification program.

Each issue was isolated and corrected without unnecessary modification of already verified processor blocks.

The final CPU implementation is therefore considered functionally verified at the RTL simulation level and is ready for the next stage of the project.