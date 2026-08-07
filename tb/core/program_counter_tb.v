`timescale 1ns/1ps
`default_nettype none

`include "rv32i_params.vh"

//==============================================================
// Module      : program_counter_tb
// Description :
//   Self-checking verification environment for the
//   RV32I Program Counter.
//
// Features:
//   - Clock generation
//   - Reset verification
//   - Write enable verification
//   - Consecutive PC updates
//   - Hold functionality
//   - Automatic PASS/FAIL reporting
//
//==============================================================

module program_counter_tb;

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------

    parameter DATA_WIDTH = 32;

    //----------------------------------------------------------
    // DUT Signals
    //----------------------------------------------------------

    reg                     clk;
    reg                     rst;
    reg                     pc_write;

    reg  [DATA_WIDTH-1:0]   pc_next;

    wire [DATA_WIDTH-1:0]   pc;

    //----------------------------------------------------------
    // Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Device Under Test
    //----------------------------------------------------------

    program_counter DUT (

        .clk      (clk),
        .rst      (rst),

        .pc_write (pc_write),
        .pc_next  (pc_next),

        .pc       (pc)

    );

    //----------------------------------------------------------
    // Clock Generation
    //----------------------------------------------------------

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end

    //----------------------------------------------------------
    // Waveform Dump
    //----------------------------------------------------------

    initial begin

        $dumpfile("sim/program_counter/program_counter.vcd");
        $dumpvars(0, program_counter_tb);

    end

    //----------------------------------------------------------
    // Initialize Statistics
    //----------------------------------------------------------

    initial begin

        tests  = 0;
        errors = 0;

    end

    //----------------------------------------------------------
    // TASK : Reset DUT
    //----------------------------------------------------------

    task reset_dut;

    begin

        $display("");
        $display("-----------------------------------------------");
        $display("Resetting DUT");
        $display("-----------------------------------------------");

        rst      = 1'b1;
        pc_write = 1'b0;
        pc_next  = {DATA_WIDTH{1'b0}};

        @(posedge clk);
        @(posedge clk);

        rst = 1'b0;

    end

    endtask

    //----------------------------------------------------------
    // TASK : Update Program Counter
    //----------------------------------------------------------

    task update_pc;

        input [DATA_WIDTH-1:0] next_address;

    begin

        pc_next  = next_address;
        pc_write = 1'b1;

        @(posedge clk);
        @(posedge clk);

        pc_write = 1'b0;

    end

    endtask

    //----------------------------------------------------------
    // TASK : Check Program Counter
    //----------------------------------------------------------

    task check_pc;

        input [DATA_WIDTH-1:0] expected;

    begin

        #1;

        tests = tests + 1;

        if (pc !== expected) begin

            $display("[FAIL] Expected = %h  Got = %h",
                     expected,
                     pc);

            errors = errors + 1;

        end

        else begin

            $display("[PASS] PC = %h",
                     pc);

        end

    end

    endtask

    //----------------------------------------------------------
    // Test Sequence
    //----------------------------------------------------------

    initial begin

        //------------------------------------------------------
        // Initialize Inputs
        //------------------------------------------------------

        rst      = 1'b0;
        pc_write = 1'b0;
        pc_next  = {DATA_WIDTH{1'b0}};

        $display("");
        $display("=================================================");
        $display("      Program Counter Verification");
        $display("=================================================");

        //------------------------------------------------------
        // Reset Test
        //------------------------------------------------------

        reset_dut();

        check_pc(`RESET_VECTOR);

        //------------------------------------------------------
        // Single Update
        //------------------------------------------------------

        $display("");
        $display("Single Update");

        update_pc(32'h00000004);

        check_pc(32'h00000004);

        //------------------------------------------------------
        // Consecutive Updates
        //------------------------------------------------------

        $display("");
        $display("Consecutive Updates");

        update_pc(32'h00000008);
        check_pc(32'h00000008);

        update_pc(32'h0000000C);
        check_pc(32'h0000000C);

        update_pc(32'h00000010);
        check_pc(32'h00000010);

        //------------------------------------------------------
        // Hold Test
        //------------------------------------------------------

        $display("");
        $display("Write Disable");

        pc_next  = 32'hFFFFFFFF;
        pc_write = 1'b0;

        @(posedge clk);

        check_pc(32'h00000010);

        //------------------------------------------------------
        // Reset Again
        //------------------------------------------------------

        $display("");
        $display("Reset After Operation");

        reset_dut();

        check_pc(`RESET_VECTOR);

        //------------------------------------------------------
        // Verification Summary
        //------------------------------------------------------

        $display("");
        $display("=================================================");
        $display("      Program Counter Verification Summary");
        $display("=================================================");
        $display("");

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

        $display("");

        $finish;

    end

endmodule

`default_nettype wire