`timescale 1ns/1ps
`default_nettype none

//==============================================================
// Module      : next_pc_tb
// Description :
//   Testbench for the RV32I Next-PC Selection Unit.
//
//   Tests:
//     1. Normal sequential execution
//     2. Branch not taken
//     3. Branch taken
//     4. JAL
//     5. JALR
//
//==============================================================

module next_pc_tb;

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------

    localparam DATA_WIDTH = 32;

    //----------------------------------------------------------
    // Testbench Signals
    //----------------------------------------------------------

    reg [DATA_WIDTH-1:0] pc;

    reg [DATA_WIDTH-1:0] branch_target;
    reg [DATA_WIDTH-1:0] jal_target;
    reg [DATA_WIDTH-1:0] jalr_target;

    reg                  branch_taken;

    reg [1:0]            pc_src;

    wire [DATA_WIDTH-1:0] next_pc;

    //----------------------------------------------------------
    // Test Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Device Under Test
    //----------------------------------------------------------

    next_pc #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .pc           (pc),
        .branch_target(branch_target),
        .jal_target   (jal_target),
        .jalr_target  (jalr_target),
        .branch_taken (branch_taken),
        .pc_src       (pc_src),
        .next_pc      (next_pc)
    );

    //----------------------------------------------------------
    // Waveform Dump
    //----------------------------------------------------------

    initial begin

        $dumpfile("sim/next_pc/next_pc.vcd");
        $dumpvars(0, next_pc_tb);

    end

    //----------------------------------------------------------
    // Check Task
    //----------------------------------------------------------

    task check_next_pc;

        input [31:0] expected;
        input [127:0] test_name;

    begin

        #1;

        tests = tests + 1;

        if (next_pc !== expected) begin

            $display("");
            $display("[FAIL] %s", test_name);

            $display("       PC            = %h", pc);
            $display("       PC Source     = %b", pc_src);
            $display("       Branch Taken  = %b", branch_taken);

            $display("       Expected      = %h", expected);
            $display("       Got           = %h", next_pc);

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

        //------------------------------------------------------
        // Initial Values
        //------------------------------------------------------

        pc            = 32'b0;

        branch_target = 32'b0;
        jal_target    = 32'b0;
        jalr_target   = 32'b0;

        branch_taken  = 1'b0;

        pc_src        = 2'b00;

        tests  = 0;
        errors = 0;

        //------------------------------------------------------
        // Header
        //------------------------------------------------------

        $display("");
        $display("=================================================");
        $display("          Next-PC Unit Verification");
        $display("=================================================");

        //------------------------------------------------------
        // TEST 1
        // Normal Sequential Execution
        //
        // PC = 0x100
        // Expected = PC + 4 = 0x104
        //------------------------------------------------------

        pc     = 32'h00000100;
        pc_src = 2'b00;

        check_next_pc(
            32'h00000104,
            "Sequential PC + 4"
        );

        //------------------------------------------------------
        // TEST 2
        // Another Sequential Address
        //------------------------------------------------------

        pc     = 32'h00001000;
        pc_src = 2'b00;

        check_next_pc(
            32'h00001004,
            "Sequential PC + 4 at 0x1000"
        );

        //------------------------------------------------------
        // TEST 3
        // Branch NOT Taken
        //
        // Even though branch_target is available,
        // branch_taken = 0 means continue sequentially.
        //------------------------------------------------------

        pc            = 32'h00000200;
        branch_target = 32'h00000240;

        branch_taken = 1'b0;
        pc_src       = 2'b01;

        check_next_pc(
            32'h00000204,
            "Branch not taken -> PC + 4"
        );

        //------------------------------------------------------
        // TEST 4
        // Branch Taken
        //------------------------------------------------------

        pc            = 32'h00000200;
        branch_target = 32'h00000240;

        branch_taken = 1'b1;
        pc_src       = 2'b01;

        check_next_pc(
            32'h00000240,
            "Branch taken -> branch target"
        );

        //------------------------------------------------------
        // TEST 5
        // JAL
        //------------------------------------------------------

        pc          = 32'h00000300;
        jal_target  = 32'h00001000;

        pc_src = 2'b10;

        check_next_pc(
            32'h00001000,
            "JAL -> JAL target"
        );

        //------------------------------------------------------
        // TEST 6
        // JALR
        //------------------------------------------------------

        pc           = 32'h00000400;
        jalr_target  = 32'h00002000;

        pc_src = 2'b11;

        check_next_pc(
            32'h00002000,
            "JALR -> JALR target"
        );

        //------------------------------------------------------
        // TEST 7
        // Branch Taken with Negative/Backward Target
        //------------------------------------------------------

        pc            = 32'h00001000;
        branch_target = 32'h00000F00;

        branch_taken = 1'b1;
        pc_src       = 2'b01;

        check_next_pc(
            32'h00000F00,
            "Backward branch target"
        );

        //------------------------------------------------------
        // TEST 8
        // JAL to a Lower Address
        //------------------------------------------------------

        pc         = 32'h00002000;
        jal_target = 32'h00001800;

        pc_src = 2'b10;

        check_next_pc(
            32'h00001800,
            "JAL to lower address"
        );

        //------------------------------------------------------
        // TEST 9
        // JALR to a Different Address
        //------------------------------------------------------

        pc          = 32'h00003000;
        jalr_target = 32'h00004004;

        pc_src = 2'b11;

        check_next_pc(
            32'h00004004,
            "JALR target selection"
        );

        //------------------------------------------------------
        // TEST 10
        // Branch Target Should Be Ignored When Not Taken
        //------------------------------------------------------

        pc            = 32'h00005000;
        branch_target = 32'hDEADBEEF;

        branch_taken = 1'b0;
        pc_src       = 2'b01;

        check_next_pc(
            32'h00005004,
            "Not-taken branch ignores target"
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