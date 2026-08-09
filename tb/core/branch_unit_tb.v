`timescale 1ns/1ps
`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : branch_unit_tb
// Description :
//   Basic functional testbench for the RV32I Branch Unit.
//
//   Tests:
//     BEQ
//     BNE
//     BLT
//     BGE
//     BLTU
//     BGEU
//
//==============================================================

module branch_unit_tb;

    //----------------------------------------------------------
    // DUT Inputs
    //----------------------------------------------------------

    reg [2:0]  funct3;

    reg [31:0] rs1_data;
    reg [31:0] rs2_data;

    //----------------------------------------------------------
    // DUT Output
    //----------------------------------------------------------

    wire branch_taken;

    //----------------------------------------------------------
    // Test Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Device Under Test
    //----------------------------------------------------------

    branch_unit DUT (
        .funct3       (funct3),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .branch_taken (branch_taken)
    );

    //----------------------------------------------------------
    // Waveform Dump
    //----------------------------------------------------------

    initial begin

        $dumpfile("sim/branch_unit/branch_unit.vcd");
        $dumpvars(0, branch_unit_tb);

    end

    //----------------------------------------------------------
    // Test Task
    //----------------------------------------------------------

    task check_branch;

        input [2:0]  test_funct3;
        input [31:0] test_rs1;
        input [31:0] test_rs2;
        input        expected;
        input [127:0] test_name;

    begin

        //------------------------------------------------------
        // Apply Inputs
        //------------------------------------------------------

        funct3   = test_funct3;
        rs1_data = test_rs1;
        rs2_data = test_rs2;

        #1;

        tests = tests + 1;

        //------------------------------------------------------
        // Check Result
        //------------------------------------------------------

        if (branch_taken !== expected) begin

            $display("");
            $display("[FAIL] %s", test_name);

            $display("       funct3       = %b", test_funct3);
            $display("       rs1_data     = %h", test_rs1);
            $display("       rs2_data     = %h", test_rs2);
            $display("       Expected    = %b", expected);
            $display("       Actual      = %b", branch_taken);

            errors = errors + 1;

        end

        else begin

            $display("[PASS] %s", test_name);

        end

    end

    endtask

    //----------------------------------------------------------
    // Test Sequence
    //----------------------------------------------------------

    initial begin

        funct3   = 3'b000;
        rs1_data = 32'd0;
        rs2_data = 32'd0;

        tests  = 0;
        errors = 0;

        #5;

        $display("");
        $display("=================================================");
        $display("          Branch Unit Verification");
        $display("=================================================");

        //------------------------------------------------------
        // BEQ
        //------------------------------------------------------

        check_branch(
            3'b000,
            32'd10,
            32'd10,
            1'b1,
            "BEQ - Equal"
        );

        check_branch(
            3'b000,
            32'd10,
            32'd20,
            1'b0,
            "BEQ - Not Equal"
        );

        //------------------------------------------------------
        // BNE
        //------------------------------------------------------

        check_branch(
            3'b001,
            32'd10,
            32'd20,
            1'b1,
            "BNE - Not Equal"
        );

        check_branch(
            3'b001,
            32'd10,
            32'd10,
            1'b0,
            "BNE - Equal"
        );

        //------------------------------------------------------
        // BLT - Signed
        //------------------------------------------------------

        check_branch(
            3'b100,
            32'd10,
            32'd20,
            1'b1,
            "BLT - Less Than"
        );

        check_branch(
            3'b100,
            32'd20,
            32'd10,
            1'b0,
            "BLT - Greater Than"
        );

        //------------------------------------------------------
        // BGE - Signed
        //------------------------------------------------------

        check_branch(
            3'b101,
            32'd20,
            32'd10,
            1'b1,
            "BGE - Greater Than"
        );

        check_branch(
            3'b101,
            32'd10,
            32'd20,
            1'b0,
            "BGE - Less Than"
        );

        //------------------------------------------------------
        // BLTU - Unsigned
        //------------------------------------------------------

        check_branch(
            3'b110,
            32'd10,
            32'd20,
            1'b1,
            "BLTU - Less Than"
        );

        check_branch(
            3'b110,
            32'd20,
            32'd10,
            1'b0,
            "BLTU - Greater Than"
        );

        //------------------------------------------------------
        // BGEU - Unsigned
        //------------------------------------------------------

        check_branch(
            3'b111,
            32'd20,
            32'd10,
            1'b1,
            "BGEU - Greater Than"
        );

        check_branch(
            3'b111,
            32'd10,
            32'd20,
            1'b0,
            "BGEU - Less Than"
        );

        //------------------------------------------------------
        // Invalid funct3
        //------------------------------------------------------

        check_branch(
            3'b010,
            32'd10,
            32'd10,
            1'b0,
            "Invalid funct3"
        );

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
            $display("*       ALL TESTS PASSED SUCCESSFULLY!       *");
            $display("*                                             *");
            $display("***********************************************");

        end

        else begin

            $display("***********************************************");
            $display("*                                             *");
            $display("*       VERIFICATION FAILED                   *");
            $display("*                                             *");
            $display("*       Errors : %0d                           *", errors);
            $display("*                                             *");
            $display("***********************************************");

        end

        $finish;

    end

endmodule

`default_nettype wire
