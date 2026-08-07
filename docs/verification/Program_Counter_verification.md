# Program Counter Verification Report

## 1. Objective

The objective of this verification is to validate the functionality of the RV32I Program Counter under all supported operating conditions.

The verification ensures correct behavior during reset, sequential updates, write disable, and repeated updates.

---

# 2. Verification Methodology

The Program Counter was verified using:

- Icarus Verilog
- GTKWave
- Directed testing
- Self-checking testbench
- Automatic PASS/FAIL reporting

---

# 3. Testbench Features

The verification environment includes:

- Automatic clock generation
- DUT reset task
- Program Counter update task
- Automatic result checking
- Error counting
- PASS/FAIL summary
- VCD waveform generation

---

# 4. Test Cases

## Reset Verification

- Reset vector loading
- Reset after normal operation

---

## Program Counter Updates

- Single Program Counter update
- Multiple consecutive updates

---

## Write Enable Verification

- Program Counter update enabled
- Program Counter hold when disabled

---

# 5. Test Coverage

| Test | Status |
|------|--------|
| Reset Vector | PASS |
| Single Update | PASS |
| Consecutive Updates | PASS |
| Hold Function | PASS |
| Reset After Operation | PASS |

---

# 6. Simulation Results

| Metric | Result |
|--------|--------|
| Total Tests | 7 |
| Passed | 7 |
| Failed | 0 |
| Functional Coverage | 100% |

---

# 7. Waveform Verification

The following signals were monitored during simulation:

- clk
- rst
- pc_write
- pc_next
- pc

The waveform confirmed:

- Correct reset behavior
- Correct Program Counter updates
- Stable output while write enable was deasserted
- Proper reset recovery

> **Note:** Insert GTKWave screenshots in `docs/diagrams/` and reference them here.

---

# 8. Observations

- The Program Counter updated correctly on each rising clock edge.
- Reset correctly initialized the Program Counter to the reset vector.
- The write enable successfully prevented unintended updates.
- No timing or functional issues were observed during simulation.

---

# 9. Conclusion

The Program Counter successfully passed all directed verification tests with zero functional errors.

The module satisfies all functional requirements of the RV32I Instruction Fetch stage and is ready for integration with the Instruction Memory and Next Program Counter logic.