# Instruction Memory Verification Report

## 1. Objective

The objective of this verification is to ensure that the Instruction Memory correctly initializes program data from a hexadecimal file and returns the expected instruction for each Program Counter address.

---

# 2. Verification Environment

Simulation Tools

- Icarus Verilog
- GTKWave

Verification Method

- Directed testing
- Self-checking testbench
- Automatic PASS/FAIL reporting

---

# 3. Testbench Features

The verification environment includes

- Program Counter emulation
- Automatic instruction checking
- PASS/FAIL reporting
- Error counting
- VCD waveform generation

Since the Instruction Memory is purely combinational, no clock or reset signals are required.

---

# 4. Test Program

The following program was loaded using `program.hex`.

| Address | Machine Code | Assembly |
|----------|--------------|----------|
| 0x00000000 | 00500093 | addi x1,x0,5 |
| 0x00000004 | 00A00113 | addi x2,x0,10 |
| 0x00000008 | 002081B3 | add x3,x1,x2 |
| 0x0000000C | 00000013 | nop |

---

# 5. Test Cases

## Program Initialization

- Verify hexadecimal program loading.

---

## Sequential Instruction Fetch

Verify instruction fetch for

- PC = 0x00000000
- PC = 0x00000004
- PC = 0x00000008
- PC = 0x0000000C

---

## Address Translation

Verify conversion from byte address to word index.

---

# 6. Simulation Results

| Test | Status |
|------|--------|
| Program Initialization | PASS |
| Address 0x00000000 | PASS |
| Address 0x00000004 | PASS |
| Address 0x00000008 | PASS |
| Address 0x0000000C | PASS |

---

# 7. Waveform Verification

The waveform confirmed

- Correct program loading
- Correct word address calculation
- Correct instruction output
- Immediate response to Program Counter changes

Signals observed

- address
- word_address
- instruction

---

# 8. Observations

- Program data was successfully initialized using `$readmemh()`.
- Address translation correctly converted byte addresses into memory indices.
- Instruction fetch produced the expected machine code for every tested address.
- The module behaved as a combinational ROM.

---

# 9. Conclusion

The Instruction Memory successfully passed all verification tests with zero functional errors.

The module is ready for integration with the Program Counter and Instruction Decode stage of the RV32I processor.