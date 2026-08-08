`timescale 1ns/1ps
`default_nettype none

`include "rv32i_params.vh"

//==============================================================
// Module      : instruction_memory_tb
// Description :
//   Self-checking testbench for the Instruction Memory.
//
// Features:
//   - Verifies program loading
//   - Verifies address translation
//   - Verifies instruction output
//
//==============================================================

module instruction_memory_tb;

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------

    parameter DATA_WIDTH = `XLEN;

    //----------------------------------------------------------
    // DUT Signals
    //----------------------------------------------------------

    reg  [DATA_WIDTH-1:0] pc;

    wire [DATA_WIDTH-1:0] instruction;

    //----------------------------------------------------------
    // Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // DUT
    //----------------------------------------------------------

    instruction_memory DUT (

        .address(pc),
        .instruction(instruction)

    );

    //----------------------------------------------------------
    // Waveform Dump
    //----------------------------------------------------------

    initial begin

        $dumpfile("sim/instruction_memory/instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

    end

    //----------------------------------------------------------
    // TASK : Check Instruction
    //----------------------------------------------------------

    task check_instruction;

        input [31:0] address;
        input [31:0] expected;

    begin

        pc = address;

        #1;

        tests = tests + 1;

        if (instruction !== expected) begin

            $display("[FAIL] PC = %h  Expected = %h  Got = %h",
                     address,
                     expected,
                     instruction);

            errors = errors + 1;

        end
        else begin

            $display("[PASS] PC = %h  Instruction = %h",
                     address,
                     instruction);

        end

    end

    endtask

    //----------------------------------------------------------
    // Test Sequence
    //----------------------------------------------------------

    initial begin

        pc     = 32'h00000000;
        tests  = 0;
        errors = 0;

        // Allow time for $readmemh() initialization
        #5;

        $display("");
        $display("=================================================");
        $display("      Instruction Memory Verification");
        $display("=================================================");

        //------------------------------------------------------
        // Instruction Fetch Tests
        //------------------------------------------------------

        check_instruction(32'h00000000, 32'h00500093);
        check_instruction(32'h00000004, 32'h00A00113);
        check_instruction(32'h00000008, 32'h002081B3);
        check_instruction(32'h0000000C, 32'h00000013);

        //------------------------------------------------------
        // Verification Summary
        //------------------------------------------------------

        $display("");
        $display("=================================================");
        $display("Verification Summary");
        $display("=================================================");

        $display("Tests  : %0d", tests);
        $display("Errors : %0d", errors);

        $display("");

        if (errors == 0) begin

            $display("***********************************************");
            $display("*                                             *");
            $display("*       ALL TESTS PASSED SUCCESSFULLY!        *");
            $display("*                                             *");
            $display("***********************************************");

        end
        else begin

            $display("***********************************************");
            $display("*                                             *");
            $display("*      VERIFICATION FAILED                    *");
            $display("*                                             *");
            $display("*      Errors : %0d                           *", errors);
            $display("*                                             *");
            $display("***********************************************");

        end

        $finish;

    end

endmodule

`default_nettype wire