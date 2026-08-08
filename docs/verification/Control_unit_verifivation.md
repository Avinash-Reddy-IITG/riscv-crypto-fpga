# Main Control Unit Verification Report

## 1. Objective

The objective of this verification is to confirm that the Main Control Unit generates the correct control signals for each supported RV32I instruction class.

## 2. Verification Environment

### Simulation Tools

- Icarus Verilog
- GTKWave

### Verification Method

- Directed testing
- Self-checking testbench
- Automatic PASS/FAIL reporting
- Error counting
- VCD waveform generation

## 3. Testbench

Testbench location:

```text
tb/core/control_unit_tb.v
```

The testbench applies each instruction-class opcode to the Control Unit and compares all generated control signals against their expected values.

The following signals are checked for every test:

- `RegWrite`
- `MemRead`
- `MemWrite`
- `MemToReg`
- `ALUSrc`
- `Branch`
- `Jump`
- `ALUOp`

## 4. Test Cases

The following ten cases were verified:

| Test Case | Opcode | Expected Result |
|---|---|---|
| R-Type | `0110011` | PASS |
| I-Type ALU | `0010011` | PASS |
| Load | `0000011` | PASS |
| Store | `0100011` | PASS |
| Branch | `1100011` | PASS |
| LUI | `0110111` | PASS |
| AUIPC | `0010111` | PASS |
| JAL | `1101111` | PASS |
| JALR | `1100111` | PASS |
| Invalid Opcode | `1111111` | PASS |

## 5. Verification Results

Total tests:

```text
10
```

Total errors:

```text
0
```

Final result:

```text
ALL TESTS PASSED
```

## 6. Individual Signal Verification

For each opcode class, the testbench compares all eight control outputs with the expected control vector.

This verifies:

- Correct register write enable generation
- Correct memory read control
- Correct memory write control
- Correct write-back source selection
- Correct ALU operand selection
- Correct branch indication
- Correct jump indication
- Correct ALU operation class

## 7. Invalid Opcode Test

The unsupported opcode

```text
1111111
```

was applied to the Control Unit.

The expected safe output was:

```text
RegWrite = 0
MemRead  = 0
MemWrite = 0
MemToReg = 0
ALUSrc   = 0
Branch   = 0
Jump     = 0
ALUOp    = 00
```

Result:

**PASS**

This confirms that an unsupported opcode does not accidentally enable a register or memory operation.

## 8. Waveform Verification

The generated waveform can be inspected using GTKWave.

Waveform file:

```text
sim/control_unit/control_unit.vcd
```

The waveform confirms that the control outputs respond combinationally to changes in the opcode.

The following signals can be observed:

```text
opcode
RegWrite
MemRead
MemWrite
MemToReg
ALUSrc
Branch
Jump
ALUOp
```

## 9. Verification Summary

```text
=================================================
Main Control Unit Verification
=================================================

Tests  : 10
Errors : 0

Result : ALL TESTS PASSED
```

## 10. Conclusion

The Main Control Unit successfully passed all directed verification tests with zero errors.

All supported instruction classes generated the expected control signals, and the invalid opcode test confirmed safe default behavior.

The module is verified and ready for integration with the remaining RV32I datapath components.