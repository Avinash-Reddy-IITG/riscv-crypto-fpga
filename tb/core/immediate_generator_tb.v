`timescale 1ns/1ps
`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : immediate_generator_tb
// Description :
//   Self-checking testbench for the RV32I Immediate Generator.
//
//==============================================================

module immediate_generator_tb;

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------

    parameter DATA_WIDTH = `XLEN;

    //----------------------------------------------------------
    // DUT Signals
    //----------------------------------------------------------

    reg  [DATA_WIDTH-1:0] instruction;

    wire [DATA_WIDTH-1:0] immediate;

    //----------------------------------------------------------
    // Verification Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // DUT
    //----------------------------------------------------------

    immediate_generator DUT (

        .instruction(instruction),
        .immediate(immediate)

    );

    //----------------------------------------------------------
    // Waveform Dump
    //----------------------------------------------------------

    initial begin

        $dumpfile("sim/immediate_generator/immediate_generator.vcd");
        $dumpvars(0, immediate_generator_tb);

    end

    //----------------------------------------------------------
    // TASK : Check Immediate
    //----------------------------------------------------------

    task check_immediate;

        input [31:0] instr;
        input [31:0] expected;
        input [127:0] test_name;

    begin

        instruction = instr;

        #1;

        tests = tests + 1;

        if(immediate !== expected) begin

            $display("[FAIL] %s", test_name);
            $display("       Expected = %h", expected);
            $display("       Got      = %h", immediate);

            errors = errors + 1;

        end

        else begin

            $display("[PASS] %s -> %h",
                     test_name,
                     immediate);

        end

    end

    endtask

    //----------------------------------------------------------
    // Test Sequence
    //----------------------------------------------------------

    initial begin

        instruction = 32'd0;

        tests  = 0;
        errors = 0;

        #5;

        $display("");
        $display("=================================================");
        $display(" Immediate Generator Verification");
        $display("=================================================");

        //------------------------------------------------------
        // I-Type
        //------------------------------------------------------

        check_immediate(
            32'h00500093,
            32'h00000005,
            "I-Type ADDI +5"
        );

        //------------------------------------------------------
        // I-Type Negative
        //------------------------------------------------------

        check_immediate(
            32'hFFF00093,
            32'hFFFFFFFF,
            "I-Type ADDI -1"
        );

        //------------------------------------------------------
        // S-Type
        //------------------------------------------------------
        // sw x5,8(x1)
        //------------------------------------------------------

        check_immediate(
            32'h0050A423,
            32'h00000008,
            "S-Type Store"
        );

        //------------------------------------------------------
        // B-Type
        //------------------------------------------------------
        // Branch offset = 16
        //------------------------------------------------------

        check_immediate(
            32'h00208863,
            32'h00000010,
            "B-Type Branch"
        );

        //------------------------------------------------------
        // U-Type
        //------------------------------------------------------

        check_immediate(
            32'h123450B7,
            32'h12345000,
            "U-Type LUI"
        );

        //------------------------------------------------------
        // J-Type
        //------------------------------------------------------
        // Jump offset = 32
        //------------------------------------------------------

        check_immediate(
            32'h020000EF,
            32'h00000020,
            "J-Type JAL"
        );

        //------------------------------------------------------
        // Invalid Opcode
        //------------------------------------------------------

        check_immediate(
            32'h00000000,
            32'h00000000,
            "Default Case"
        );

        //------------------------------------------------------
        // Summary
        //------------------------------------------------------

        $display("");
        $display("=================================================");
        $display("Verification Summary");
        $display("=================================================");

        $display("Tests  : %0d", tests);
        $display("Errors : %0d", errors);

        if(errors == 0) begin

            $display("");
            $display("***********************************************");
            $display("*                                             *");
            $display("*       ALL TESTS PASSED SUCCESSFULLY!        *");
            $display("*                                             *");
            $display("***********************************************");

        end

        else begin

            $display("");
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