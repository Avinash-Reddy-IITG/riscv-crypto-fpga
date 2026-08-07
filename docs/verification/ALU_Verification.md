# ALU Verification Report

## 1. Objective

The objective of this verification is to ensure the functional correctness of the RV32I Arithmetic Logic Unit (ALU). Every supported operation is exercised through directed test cases using a self-checking Verilog testbench.

---

# 2. Verification Methodology

The ALU was verified using simulation with Icarus Verilog and GTKWave.

Verification strategy:

- Directed testing
- Self-checking testbench
- Automatic PASS/FAIL reporting
- Zero flag verification
- Waveform generation (VCD)
- Final verification summary

---

# 3. Testbench Structure

The verification environment consists of:

- Parameterized DUT instantiation
- Reusable verification task
- Directed test sequences
- Automatic result checking
- Error counter
- Test counter
- PASS/FAIL summary

---

# 4. Test Coverage

## Arithmetic Operations

- ADD
- ADD (Zero Result)
- ADD (Overflow Wraparound)
- SUB
- SUB (Zero Result)
- SUB (Negative Result)

---

## Logical Operations

- AND
- AND (All Ones)
- AND (Zero Result)
- OR
- OR (Zero Result)
- XOR
- XOR (Identical Inputs)
- XOR (Pattern Verification)

---

## Shift Operations

- SLL
- SLL (Shift by 0)
- SLL (Shift by 31)
- SRL
- SRL (Shift by 0)
- SRL (Shift by 31)
- SRA (Positive Operand)
- SRA (Negative Operand)
- SRA (Shift by 0)

---

## Comparison Operations

- SLT
- SLT (False Condition)
- SLT (Signed Comparison)
- SLTU
- SLTU (False Condition)
- SLTU (Unsigned Comparison)

---

## Miscellaneous Operations

- PASS_B
- PASS_B (Zero Output)

---

## Zero Flag Verification

The zero flag was verified for all operations that produce a zero result, including:

- ADD
- SUB
- AND
- OR
- XOR
- PASS_B

---

# 5. Simulation Results

| Metric | Result |
|--------|--------|
| Total Test Cases | 31 |
| Passed | 31 |
| Failed | 0 |
| Functional Coverage | 100% |

---

# 6. Waveform Verification

Simulation waveforms were inspected using GTKWave.

The following signals were monitored:

- operand_a
- operand_b
- alu_op
- result
- zero

The observed waveforms matched the expected functional behavior for all directed test cases.

> **Note:** Insert representative GTKWave screenshots in the `docs/diagrams/` directory and reference them here.

---

# 7. Observations

- All arithmetic operations produced the expected results.
- Logical operations matched bitwise expectations.
- Shift operations correctly used the lower five bits of the shift amount.
- Arithmetic right shifts preserved the sign bit.
- Signed and unsigned comparisons behaved according to the RV32I specification.
- The zero flag was asserted only when the ALU output was zero.

---

# 8. Conclusion

The ALU successfully passed all directed verification tests with zero functional errors. The verification demonstrates compliance with the required RV32I ALU operations and confirms that the module is ready for integration into the processor datapath.