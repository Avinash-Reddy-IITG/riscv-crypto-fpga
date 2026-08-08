`timescale 1ns/1ps
`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : control_unit_tb
// Description :
//   Self-checking testbench for the RV32I Main Control Unit.
//
//   Tests:
//   - R-Type
//   - I-Type ALU
//   - Load
//   - Store
//   - Branch
//   - LUI
//   - AUIPC
//   - JAL
//   - JALR
//   - Invalid opcode
//
//==============================================================

module control_unit_tb;

    //----------------------------------------------------------
    // DUT Signals
    //----------------------------------------------------------

    reg [6:0] opcode;

    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;
    wire       MemToReg;
    wire       ALUSrc;
    wire       Branch;
    wire       Jump;
    wire [1:0] ALUOp;

    //----------------------------------------------------------
    // Verification Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Device Under Test
    //----------------------------------------------------------

    control_unit DUT (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemToReg (MemToReg),
        .ALUSrc   (ALUSrc),
        .Branch   (Branch),
        .Jump     (Jump),
        .ALUOp    (ALUOp)
    );

    //----------------------------------------------------------
    // Waveform Dump
    //----------------------------------------------------------

    initial begin

        $dumpfile("sim/control_unit/control_unit.vcd");
        $dumpvars(0, control_unit_tb);

    end

    //----------------------------------------------------------
    // TASK : Check Control Signals
    //----------------------------------------------------------

    task check_control;

        input [6:0]  test_opcode;

        input        exp_RegWrite;
        input        exp_MemRead;
        input        exp_MemWrite;
        input        exp_MemToReg;
        input        exp_ALUSrc;
        input        exp_Branch;
        input        exp_Jump;
        input [1:0]  exp_ALUOp;

        input [127:0] test_name;

    begin

        //------------------------------------------------------
        // Apply Opcode
        //------------------------------------------------------

        opcode = test_opcode;

        #1;

        tests = tests + 1;

        //------------------------------------------------------
        // Compare Outputs
        //------------------------------------------------------

        if ((RegWrite !== exp_RegWrite) ||
            (MemRead  !== exp_MemRead ) ||
            (MemWrite !== exp_MemWrite) ||
            (MemToReg !== exp_MemToReg) ||
            (ALUSrc   !== exp_ALUSrc  ) ||
            (Branch   !== exp_Branch  ) ||
            (Jump     !== exp_Jump    ) ||
            (ALUOp    !== exp_ALUOp   )) begin

            $display("");
            $display("[FAIL] %s", test_name);

            $display("       Opcode   = %b", test_opcode);

            $display("       Expected:");
            $display("       RegWrite = %b", exp_RegWrite);
            $display("       MemRead  = %b", exp_MemRead);
            $display("       MemWrite = %b", exp_MemWrite);
            $display("       MemToReg = %b", exp_MemToReg);
            $display("       ALUSrc   = %b", exp_ALUSrc);
            $display("       Branch   = %b", exp_Branch);
            $display("       Jump     = %b", exp_Jump);
            $display("       ALUOp    = %b", exp_ALUOp);

            $display("       Actual:");
            $display("       RegWrite = %b", RegWrite);
            $display("       MemRead  = %b", MemRead);
            $display("       MemWrite = %b", MemWrite);
            $display("       MemToReg = %b", MemToReg);
            $display("       ALUSrc   = %b", ALUSrc);
            $display("       Branch   = %b", Branch);
            $display("       Jump     = %b", Jump);
            $display("       ALUOp    = %b", ALUOp);

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

        opcode = 7'b0000000;

        tests  = 0;
        errors = 0;

        #5;

        $display("");
        $display("=================================================");
        $display("        Main Control Unit Verification");
        $display("=================================================");

        //------------------------------------------------------
        // R-Type
        //------------------------------------------------------

        check_control(
            `OPCODE_OP,

            1'b1,       // RegWrite
            1'b0,       // MemRead
            1'b0,       // MemWrite
            1'b0,       // MemToReg
            1'b0,       // ALUSrc
            1'b0,       // Branch
            1'b0,       // Jump
            2'b10,      // ALUOp

            "R-Type"
        );

        //------------------------------------------------------
        // I-Type ALU
        //------------------------------------------------------

        check_control(
            `OPCODE_OP_IMM,

            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            2'b10,

            "I-Type ALU"
        );

        //------------------------------------------------------
        // Load
        //------------------------------------------------------

        check_control(
            `OPCODE_LOAD,

            1'b1,
            1'b1,
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            1'b0,
            2'b00,

            "Load"
        );

        //------------------------------------------------------
        // Store
        //------------------------------------------------------

        check_control(
            `OPCODE_STORE,

            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            2'b00,

            "Store"
        );

        //------------------------------------------------------
        // Branch
        //------------------------------------------------------

        check_control(
            `OPCODE_BRANCH,

            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            2'b01,

            "Branch"
        );

        //------------------------------------------------------
        // LUI
        //------------------------------------------------------

        check_control(
            `OPCODE_LUI,

            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            2'b10,

            "LUI"
        );

        //------------------------------------------------------
        // AUIPC
        //------------------------------------------------------

        check_control(
            `OPCODE_AUIPC,

            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            2'b10,

            "AUIPC"
        );

        //------------------------------------------------------
        // JAL
        //------------------------------------------------------

        check_control(
            `OPCODE_JAL,

            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            2'b00,

            "JAL"
        );

        //------------------------------------------------------
        // JALR
        //------------------------------------------------------

        check_control(
            `OPCODE_JALR,

            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            2'b00,

            "JALR"
        );

        //------------------------------------------------------
        // Invalid Opcode
        //------------------------------------------------------

        check_control(
            7'b1111111,

            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            2'b00,

            "Invalid Opcode"
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