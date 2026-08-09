# RV32I Datapath Verification

## 1. Overview

This document describes the verification process used to validate the integrated RV32I datapath.

The verification was performed using a Verilog simulation environment based on Icarus Verilog and GTKWave.

The objective of the verification was to confirm that the integrated datapath correctly handles the major RV32I instruction classes and that the individual processor modules interact correctly.

The following areas were verified:

- Register File operation
- Immediate generation
- ALU operation
- ALU Control
- Load and Store operations
- Conditional branches
- JAL
- JALR
- LUI
- AUIPC
- Register x0 protection
- Integration between control and datapath


## 2. Verification Environment

The datapath was verified using the following tools:

| Tool | Purpose |
|---|---|
| Icarus Verilog | Verilog compilation and simulation |
| VVP | Simulation execution |
| GTKWave | Waveform analysis |
| VS Code | RTL and testbench development |
| Git | Version control |

The project uses the following simulation flow:

```text
Verilog Testbench
       |
       v
   Icarus Verilog
       |
       v
     VVP
       |
       +------> Console Test Results
       |
       +------> VCD Waveform
                    |
                    v
                GTKWave
```


## 3. Testbench Organization

The integrated datapath testbench is located at:

```text
tb/core/rv32i_datapath_tb.v
```

The testbench instantiates the Main Control Unit, ALU Control Unit, and RV32I datapath.

The general verification structure is:

```text
                    Instruction
                         |
             +-----------+-----------+
             |                       |
             v                       v
       Main Control            ALU Control
             |                       |
             +-----------+-----------+
                         |
                         v
                  RV32I Datapath
                         |
                         v
                   Test Results
```

The testbench generates actual RV32I instruction encodings instead of directly forcing internal datapath control signals.


## 4. Instruction Encoding Functions

To simplify instruction generation, the testbench provides encoding functions for different RISC-V instruction formats.

The following formats are supported:

- R-Type
- I-Type
- S-Type
- B-Type
- U-Type
- J-Type

This allows the testbench to generate 32-bit machine instructions directly.

For example, an R-type instruction is constructed using:

```text
funct7
rs2
rs1
funct3
rd
opcode
```

Similarly, the testbench constructs the appropriate immediate fields for I-type, S-type, B-type, U-type, and J-type instructions.


## 5. Reset Verification

The first stage of the testbench is processor reset.

During reset:

- The Register File is cleared.
- Register x0 remains zero.
- Memory is initialized.
- The datapath is placed in a known state.

The testbench waits for reset to complete before executing instructions.

The simulation reports:

```text
Reset completed.
```

Only after this point are instruction-level tests started.


# 6. Test Cases

The integrated datapath was tested using 16 primary verification tests.

## 6.1 ADDI x1, x0, 10

This test verifies:

- I-type instruction decoding
- Immediate generation
- ALUSrc selection
- ADD operation
- Register write-back

Expected result:

```text
x1 = 10
```

Result:

```text
PASS
```


## 6.2 ADDI x2, x0, 20

This test verifies another I-type arithmetic operation.

Expected result:

```text
x2 = 20
```

Result:

```text
PASS
```


## 6.3 ADD x3, x1, x2

This test verifies the R-type datapath.

Expected calculation:

```text
x3 = x1 + x2
   = 10 + 20
   = 30
```

Result:

```text
PASS
```


## 6.4 SUB x4, x2, x1

Expected calculation:

```text
x4 = x2 - x1
   = 20 - 10
   = 10
```

Result:

```text
PASS
```


## 6.5 AND x5, x1, x2

This test verifies the logical AND operation.

Expected result:

```text
x5 = x1 & x2
```

Result:

```text
PASS
```


## 6.6 OR x6, x1, x2

This test verifies the logical OR operation.

Expected result:

```text
x6 = x1 | x2
```

Result:

```text
PASS
```


## 6.7 SW x3, 0(x0)

This test verifies the store datapath.

The value contained in x3 is stored at memory address zero.

Expected operation:

```text
memory[0] = x3
```

Since:

```text
x3 = 30
```

the expected memory contents are:

```text
memory[0] = 0x1E
```

Result:

```text
PASS
```


## 6.8 LW x7, 0(x0)

This test verifies the load datapath.

The previously stored value is loaded back from memory.

Expected result:

```text
x7 = memory[0]
   = 30
   = 0x0000001E
```

Result:

```text
PASS
```


## 6.9 BEQ Taken

The branch test uses two equal register values.

The expected condition is:

```text
rs1 == rs2
```

Therefore the branch should be taken.

Expected PC:

```text
PC + branch_offset
```

Result:

```text
PASS
```


## 6.10 BNE Not Taken

The BNE test uses equal register values.

The condition:

```text
rs1 != rs2
```

is therefore false.

The branch must not be taken.

Expected PC:

```text
PC + 4
```

Result:

```text
PASS
```


## 6.11 JAL Target

This test verifies the J-type immediate and jump target calculation.

Expected operation:

```text
next_pc = PC + J-type immediate
```

Result:

```text
PASS
```


## 6.12 JAL Return Address

JAL must also write the return address into the destination register.

Expected operation:

```text
rd = PC + 4
```

Result:

```text
PASS
```


## 6.13 JALR Target

This test verifies the JALR target calculation.

Expected operation:

```text
target = rs1 + immediate
```

The least significant bit of the resulting target is cleared.

Result:

```text
PASS
```


## 6.14 JALR Return Address

JALR must write:

```text
rd = PC + 4
```

The test verifies that the correct return address is written.

Result:

```text
PASS
```


## 6.15 LUI x10, 0x12345

This test verifies U-type immediate generation and LUI operation.

Expected result:

```text
x10 = 0x12345000
```

Result:

```text
PASS
```


## 6.16 AUIPC x11, 0x1

This test verifies U-type immediate generation and PC-relative addition.

For the test:

```text
PC = 0x00000100
```

and:

```text
immediate = 0x00001000
```

Therefore:

```text
x11 = PC + immediate
    = 0x00000100 + 0x00001000
    = 0x00001100
```

Result:

```text
PASS
```


## 7. x0 Verification

In addition to the 16 primary tests, the testbench verifies that register x0 remains hardwired to zero.

The RISC-V specification requires:

```text
x0 = 0
```

regardless of attempted writes.

The testbench attempts to write to x0 and verifies that the value remains zero.

Result:

```text
PASS
```


# 8. Initial Verification Problems

The first complete datapath simulation did not pass all tests.

The initial result was:

```text
Tests  : 16
Errors : 5
```

The failures were:

```text
LW
BEQ
BNE
LUI
AUIPC
```

The other tests passed.

This was useful because the failures were not random. They formed identifiable groups that could be traced to specific datapath interfaces.


# 9. Debugging the Load Failure

## 9.1 Observed Failure

The initial LW result was:

```text
Expected = 0000001E
Got      = 00000000
```

The preceding store operation had passed.

Therefore, the problem was not initially suspected to be the basic memory write operation.

## 9.2 Investigation

The Data Memory module uses `funct3` to determine the memory operation.

For LW:

```text
funct3 = 010
```

However, the datapath Data Memory instantiation did not initially connect the instruction's `funct3` signal.

As a result, the Data Memory could not correctly identify the requested load operation.

## 9.3 Solution

The datapath was corrected to connect:

```verilog
.funct3(funct3)
```

to the Data Memory.

After recompilation and simulation:

```text
LW -> PASS
```

This also affected the branch tests because the branch operands depended on the loaded value.


# 10. Debugging the Branch Failures

## 10.1 Initial Observation

The initial branch results were:

```text
BEQ:
Expected next_pc = 00000028
Got next_pc      = 00000024
```

and:

```text
BNE:
Expected next_pc = 00000034
Got next_pc      = 00000038
```

At first, this suggested a possible problem in the Branch Unit or Next-PC Unit.

## 10.2 Root Cause

The branch tests were executed after the failed LW.

The expected state was:

```text
x3 = 30
x7 = 30
```

but the actual state was:

```text
x3 = 30
x7 = 0
```

Therefore:

```text
BEQ:
30 == 0 -> false
```

and:

```text
BNE:
30 != 0 -> true
```

The observed branch behavior was therefore consistent with the incorrect register contents.

## 10.3 Solution

After correcting the Data Memory interface, LW correctly produced:

```text
x7 = 30
```

The branch instructions then produced the correct results.

No changes were required to the Branch Unit or Next-PC Unit.

This was an important debugging lesson: a control-path failure can be caused by incorrect data produced earlier in the datapath.


# 11. Debugging LUI and AUIPC

## 11.1 Initial Observation

After fixing Data Memory and the branch behavior, only LUI and AUIPC remained as failures.

The results were:

```text
LUI:
Expected = 12345000
Got      = 00000000
```

```text
AUIPC:
Expected = 00001100
Got      = 00000100
```

## 11.2 Debug Instrumentation

A temporary debug section was added to the testbench.

For LUI, the following values were observed:

```text
Instruction = 12345537
Opcode      = 0110111
RegWrite    = 1
ALUSrc      = 1
ALUOp       = 10
ALU Control = 0110
Immediate   = 12345000
ALU A       = 00000000
ALU B       = 12345000
ALU Result  = 00000000
RD Data     = 00000000
```

The important observation was:

```text
ALU Control = 0110
```

The ALU control value `0110` corresponds to SRL.

Therefore the ALU was performing a shift instead of an addition.

## 11.3 Root Cause

The ALU Control Unit interprets `funct3` when:

```text
ALUOp = 10
```

However, LUI and AUIPC are U-type instructions.

Their `funct3` and `funct7` positions are not meaningful operation selectors.

Using:

```text
ALUOp = 10
```

caused the unused bits to be interpreted as an ALU operation.

## 11.4 Solution

The Main Control Unit was modified so that:

```text
LUI   -> ALUOp = 00
AUIPC -> ALUOp = 00
```

ALUOp `00` selects ADD.

Therefore:

```text
LUI:
0 + immediate
```

and:

```text
AUIPC:
PC + immediate
```

Both instructions could then reuse the existing ALU ADD operation.

After the correction:

```text
LUI   -> PASS
AUIPC -> PASS
```


# 12. Compilation

The final integrated datapath was compiled using:

```powershell
iverilog -I rtl/common -o sim/rv32i_datapath/rv32i_datapath_tb.out tb/core/rv32i_datapath_tb.v rtl/core/rv32i_datapath.v rtl/common/register_file.v rtl/core/immediate_generator.v rtl/core/alu.v rtl/core/branch_unit.v rtl/core/data_memory.v rtl/core/next_pc.v rtl/core/write_back.v rtl/core/control_unit.v rtl/core/alu_control.v
```

The compilation completed without errors.

The simulation was then executed using:

```powershell
vvp sim/rv32i_datapath/rv32i_datapath_tb.out
```


# 13. Final Simulation Output

The final simulation produced:

```text
Reset completed.

[PASS]  ADDI x1, x0, 10
[PASS]  ADDI x2, x0, 20
[PASS]   ADD x3, x1, x2
[PASS]   SUB x4, x2, x1
[PASS]   AND x5, x1, x2
[PASS]    OR x6, x1, x2

[INFO] SW x3, 0(x0) executed.
[PASS]     LW x7, 0(x0)
[PASS]        BEQ taken
[PASS]    BNE not taken
[PASS]       JAL target
[PASS] JAL return address
[PASS]      JALR target
[PASS] JALR return address
[PASS] LUI x10, 0x12345
[PASS] AUIPC x11, 0x1
[PASS] x0 remains hardwired to zero
```

Final summary:

```text
=================================================
              VERIFICATION SUMMARY
=================================================

Tests  : 16
Errors : 0
```

Therefore:

```text
Tests Passed : 16
Tests Failed : 0
Pass Rate    : 100%
```


# 14. Waveform Verification

In addition to console-based checking, the testbench generates a VCD waveform file.

The waveform can be opened using GTKWave:

```powershell
gtkwave sim/rv32i_datapath/rv32i_datapath.vcd
```

Important signals to inspect include:

- `pc`
- `instruction`
- `opcode`
- `rs1_data`
- `rs2_data`
- `immediate`
- `alu_operand_a`
- `alu_operand_b`
- `alu_result`
- `memory_data`
- `branch_taken`
- `next_pc`
- `rd_data`
- `RegWrite`
- `MemRead`
- `MemWrite`
- `ALUSrc`
- `MemToReg`
- `Jump`

Waveform inspection is useful for debugging timing and signal-routing problems that may not be obvious from the final register values.


# 15. Verification Results Summary

| Category | Result |
|---|---|
| I-Type arithmetic | PASS |
| R-Type arithmetic | PASS |
| Logical operations | PASS |
| Store operation | PASS |
| Load operation | PASS |
| Conditional branch | PASS |
| JAL | PASS |
| JALR | PASS |
| LUI | PASS |
| AUIPC | PASS |
| x0 protection | PASS |
| Compilation | PASS |
| Simulation | PASS |
| Total tests | 16 |
| Failed tests | 0 |
| Pass rate | 100% |


# 16. Lessons Learned

## 16.1 Integration testing is essential

Individual modules can pass their own testbenches while the integrated processor still contains interface errors.

The datapath verification exposed an incorrect Data Memory connection that was not visible during isolated module testing.

## 16.2 Follow the data path when debugging

The branch failures initially appeared to be control failures.

However, tracing the register values showed that the branch operands were incorrect because of the preceding LW failure.

The actual problem was therefore upstream.

## 16.3 Do not assume every instruction has meaningful function fields

R-type instructions rely heavily on `funct3` and `funct7`.

U-type instructions such as LUI and AUIPC do not.

The control logic must account for instruction format before using these fields for ALU decoding.

## 16.4 Reuse verified hardware

LUI and AUIPC were implemented using the existing ADD operation instead of creating additional ALU operations.

This reduced the amount of new hardware and simplified the control logic.


# 17. Files Used for Verification

Testbench:

```text
tb/core/rv32i_datapath_tb.v
```

Datapath:

```text
rtl/core/rv32i_datapath.v
```

Main Control:

```text
rtl/core/control_unit.v
```

ALU Control:

```text
rtl/core/alu_control.v
```

Supporting modules:

```text
rtl/common/register_file.v
rtl/core/immediate_generator.v
rtl/core/alu.v
rtl/core/branch_unit.v
rtl/core/data_memory.v
rtl/core/next_pc.v
rtl/core/write_back.v
```


# 18. Final Status

The integrated RV32I datapath has successfully completed functional verification.

Final result:

```text
Tests  : 16
Passed : 16
Failed : 0
Pass   : 100%
```

The datapath is therefore ready to be committed as a verified project milestone.

The next development stage can proceed to the next processor-level block.