`timescale 1ns/1ps
`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : alu_control_tb
// Description :
//   Self-checking testbench for the RV32I ALU Control Unit.
//
//   Tests:
//   - Address calculation
//   - Branch comparison
//   - R-Type ALU operations
//   - I-Type ALU operations
//   - ADD/SUB distinction
//   - SRL/SRA distinction
//   - Invalid ALUOp
//
//==============================================================

module alu_control_tb;

    //----------------------------------------------------------
    // DUT Inputs
    //----------------------------------------------------------

    reg [1:0] ALUOp;
    reg [2:0] funct3;
    reg [6:0] funct7;

    //----------------------------------------------------------
    // DUT Output
    //----------------------------------------------------------

    wire [3:0] alu_control;

    //----------------------------------------------------------
    // Verification Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Device Under Test
    //----------------------------------------------------------

    alu_control DUT (
        .ALUOp       (ALUOp),
        .funct3      (funct3),
        .funct7      (funct7),
        .alu_control (alu_control)
    );

    //----------------------------------------------------------
    // Waveform Dump
    //----------------------------------------------------------

    initial begin

        $dumpfile("sim/alu_control/alu_control.vcd");
        $dumpvars(0, alu_control_tb);

    end

    //----------------------------------------------------------
    // TASK : Check ALU Control
    //----------------------------------------------------------

    task check_alu_control;

        input [1:0]   test_ALUOp;
        input [2:0]   test_funct3;
        input [6:0]   test_funct7;
        input [3:0]   expected;
        input [127:0] test_name;

    begin

        //------------------------------------------------------
        // Apply Inputs
        //------------------------------------------------------

        ALUOp  = test_ALUOp;
        funct3 = test_funct3;
        funct7 = test_funct7;

        #1;

        tests = tests + 1;

        //------------------------------------------------------
        // Compare Output
        //------------------------------------------------------

        if (alu_control !== expected) begin

            $display("");
            $display("[FAIL] %s", test_name);

            $display("       Inputs:");
            $display("       ALUOp  = %b", test_ALUOp);
            $display("       funct3 = %b", test_funct3);
            $display("       funct7 = %b", test_funct7);

            $display("       Expected = %b", expected);
            $display("       Got      = %b", alu_control);

            errors = errors + 1;

        end

        else begin

            $display("[PASS] %s -> %b",
                     test_name,
                     alu_control);

        end

    end

    endtask

    //----------------------------------------------------------
    // Test Sequence
    //----------------------------------------------------------

    initial begin

        ALUOp  = 2'b00;
        funct3 = 3'b000;
        funct7 = 7'b0000000;

        tests  = 0;
        errors = 0;

        #5;

        $display("");
        $display("=================================================");
        $display("          ALU Control Unit Verification");
        $display("=================================================");

        //------------------------------------------------------
        // ALUOp = 00
        // Address Calculation
        //------------------------------------------------------

        check_alu_control(
            2'b00,
            3'b000,
            7'b0000000,
            `ALU_ADD,
            "Address Calculation -> ADD"
        );

        //------------------------------------------------------
        // ALUOp = 01
        // Branch Comparison
        //------------------------------------------------------

        check_alu_control(
            2'b01,
            3'b000,
            7'b0000000,
            `ALU_SUB,
            "Branch Comparison -> SUB"
        );

        //------------------------------------------------------
        // R-Type ADD
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b000,
            7'b0000000,
            `ALU_ADD,
            "R-Type ADD"
        );

        //------------------------------------------------------
        // R-Type SUB
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b000,
            7'b0100000,
            `ALU_SUB,
            "R-Type SUB"
        );

        //------------------------------------------------------
        // R-Type SLL
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b001,
            7'b0000000,
            `ALU_SLL,
            "R-Type SLL"
        );

        //------------------------------------------------------
        // R-Type SLT
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b010,
            7'b0000000,
            `ALU_SLT,
            "R-Type SLT"
        );

        //------------------------------------------------------
        // R-Type SLTU
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b011,
            7'b0000000,
            `ALU_SLTU,
            "R-Type SLTU"
        );

        //------------------------------------------------------
        // R-Type XOR
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b100,
            7'b0000000,
            `ALU_XOR,
            "R-Type XOR"
        );

        //------------------------------------------------------
        // R-Type SRL
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b101,
            7'b0000000,
            `ALU_SRL,
            "R-Type SRL"
        );

        //------------------------------------------------------
        // R-Type SRA
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b101,
            7'b0100000,
            `ALU_SRA,
            "R-Type SRA"
        );

        //------------------------------------------------------
        // R-Type OR
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b110,
            7'b0000000,
            `ALU_OR,
            "R-Type OR"
        );

        //------------------------------------------------------
        // R-Type AND
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b111,
            7'b0000000,
            `ALU_AND,
            "R-Type AND"
        );

        //------------------------------------------------------
        // I-Type ADDI
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b000,
            7'b0000000,
            `ALU_ADD,
            "I-Type ADDI -> ADD"
        );

        //------------------------------------------------------
        // I-Type SLTI
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b010,
            7'b0000000,
            `ALU_SLT,
            "I-Type SLTI -> SLT"
        );

        //------------------------------------------------------
        // I-Type SLTIU
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b011,
            7'b0000000,
            `ALU_SLTU,
            "I-Type SLTIU -> SLTU"
        );

        //------------------------------------------------------
        // I-Type XORI
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b100,
            7'b0000000,
            `ALU_XOR,
            "I-Type XORI -> XOR"
        );

        //------------------------------------------------------
        // I-Type ORI
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b110,
            7'b0000000,
            `ALU_OR,
            "I-Type ORI -> OR"
        );

        //------------------------------------------------------
        // I-Type ANDI
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b111,
            7'b0000000,
            `ALU_AND,
            "I-Type ANDI -> AND"
        );

        //------------------------------------------------------
        // I-Type SLLI
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b001,
            7'b0000000,
            `ALU_SLL,
            "I-Type SLLI -> SLL"
        );

        //------------------------------------------------------
        // I-Type SRLI
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b101,
            7'b0000000,
            `ALU_SRL,
            "I-Type SRLI -> SRL"
        );

        //------------------------------------------------------
        // I-Type SRAI
        //------------------------------------------------------

        check_alu_control(
            2'b10,
            3'b101,
            7'b0100000,
            `ALU_SRA,
            "I-Type SRAI -> SRA"
        );

        //------------------------------------------------------
        // Invalid ALUOp
        //------------------------------------------------------

        check_alu_control(
            2'b11,
            3'b111,
            7'b1111111,
            `ALU_ADD,
            "Invalid ALUOp"
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