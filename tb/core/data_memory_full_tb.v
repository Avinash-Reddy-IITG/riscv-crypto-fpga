`timescale 1ns/1ps
`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : data_memory_full_tb
// Description :
//   Comprehensive testbench for the RV32I Data Memory.
//
//   Supported operations:
//     Loads:
//       LB
//       LBU
//       LH
//       LHU
//       LW
//
//     Stores:
//       SB
//       SH
//       SW
//
//   Verification includes:
//     - Little-endian storage
//     - Signed byte load
//     - Unsigned byte load
//     - Signed halfword load
//     - Unsigned halfword load
//     - Word load
//     - Byte store
//     - Halfword store
//     - Word store
//     - Memory isolation
//     - Read/write enables
//
//==============================================================

module data_memory_full_tb;

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------

    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 10;

    //----------------------------------------------------------
    // Clock and Reset
    //----------------------------------------------------------

    reg clk;
    reg rst;

    //----------------------------------------------------------
    // Memory Control
    //----------------------------------------------------------

    reg mem_read;
    reg mem_write;

    //----------------------------------------------------------
    // Instruction Function Field
    //----------------------------------------------------------

    reg [2:0] funct3;

    //----------------------------------------------------------
    // Memory Interface
    //----------------------------------------------------------

    reg [DATA_WIDTH-1:0] address;
    reg [DATA_WIDTH-1:0] write_data;

    wire [DATA_WIDTH-1:0] read_data;

    //----------------------------------------------------------
    // Test Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Device Under Test
    //----------------------------------------------------------

    data_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        .clk        (clk),
        .rst        (rst),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .funct3     (funct3),
        .address    (address),
        .write_data (write_data),
        .read_data  (read_data)
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

        $dumpfile("sim/data_memory/data_memory_full.vcd");
        $dumpvars(0, data_memory_full_tb);

    end

    //----------------------------------------------------------
    // Store Task
    //----------------------------------------------------------

    task store_word;

        input [2:0]  test_funct3;
        input [31:0] test_address;
        input [31:0] test_data;
        input [127:0] test_name;

    begin

        funct3    = test_funct3;
        address   = test_address;
        write_data = test_data;

        mem_read  = 1'b0;
        mem_write = 1'b1;

        @(posedge clk);

        #1;

        mem_write = 1'b0;

        $display("[INFO] %s", test_name);

    end

    endtask

    //----------------------------------------------------------
    // Read/Check Task
    //----------------------------------------------------------

    task check_load;

        input [2:0]  test_funct3;
        input [31:0] test_address;
        input [31:0] expected_data;
        input [127:0] test_name;

    begin

        funct3  = test_funct3;
        address = test_address;

        mem_read  = 1'b1;
        mem_write = 1'b0;

        #1;

        tests = tests + 1;

        if (read_data !== expected_data) begin

            $display("");
            $display("[FAIL] %s", test_name);

            $display("       funct3   = %b", test_funct3);
            $display("       address  = %h", test_address);
            $display("       Expected = %h", expected_data);
            $display("       Got      = %h", read_data);

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
        // Initial Conditions
        //------------------------------------------------------

        rst        = 1'b1;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        funct3     = 3'b000;
        address    = 32'b0;
        write_data = 32'b0;

        tests  = 0;
        errors = 0;

        //------------------------------------------------------
        // Reset
        //------------------------------------------------------

        #10;

        rst = 1'b0;

        #2;

        $display("");
        $display("=================================================");
        $display("       Full Data Memory Verification");
        $display("=================================================");

        //------------------------------------------------------
        // TEST 1
        // SW
        //
        // Store:
        //     0x12345678
        //
        // Expected memory:
        //     0x10 -> 78
        //     0x11 -> 56
        //     0x12 -> 34
        //     0x13 -> 12
        //------------------------------------------------------

        store_word(
            3'b010,
            32'h00000010,
            32'h12345678,
            "SW 0x12345678 -> address 0x10"
        );

        //------------------------------------------------------
        // TEST 2
        // LW
        //------------------------------------------------------

        check_load(
            3'b010,
            32'h00000010,
            32'h12345678,
            "LW from 0x10"
        );

        //------------------------------------------------------
        // TEST 3
        // Little-endian verification
        //------------------------------------------------------

        tests = tests + 1;

        if (
            (DUT.memory[10'h010] !== 8'h78) ||
            (DUT.memory[10'h011] !== 8'h56) ||
            (DUT.memory[10'h012] !== 8'h34) ||
            (DUT.memory[10'h013] !== 8'h12)
        ) begin

            $display("");
            $display("[FAIL] SW little-endian byte ordering");

            errors = errors + 1;

        end

        else begin

            $display("[PASS] SW little-endian byte ordering");

        end

        //------------------------------------------------------
        // TEST 4
        // SB
        //
        // Store FF at address 0x20.
        //------------------------------------------------------

        store_word(
            3'b000,
            32'h00000020,
            32'h000000FF,
            "SB 0xFF -> address 0x20"
        );

        //------------------------------------------------------
        // TEST 5
        // LB
        //
        // 0xFF sign extends to 0xFFFFFFFF.
        //------------------------------------------------------

        check_load(
            3'b000,
            32'h00000020,
            32'hFFFFFFFF,
            "LB 0xFF -> sign extension"
        );

        //------------------------------------------------------
        // TEST 6
        // LBU
        //
        // 0xFF zero extends to 0x000000FF.
        //------------------------------------------------------

        check_load(
            3'b100,
            32'h00000020,
            32'h000000FF,
            "LBU 0xFF -> zero extension"
        );

        //------------------------------------------------------
        // TEST 7
        // SH
        //
        // Store 0x80FF.
        //
        // Expected:
        //     0x30 -> FF
        //     0x31 -> 80
        //------------------------------------------------------

        store_word(
            3'b001,
            32'h00000030,
            32'h000080FF,
            "SH 0x80FF -> address 0x30"
        );

        //------------------------------------------------------
        // TEST 8
        // LH
        //
        // 0x80FF sign extends.
        //------------------------------------------------------

        check_load(
            3'b001,
            32'h00000030,
            32'hFFFF80FF,
            "LH 0x80FF -> sign extension"
        );

        //------------------------------------------------------
        // TEST 9
        // LHU
        //
        // 0x80FF zero extends.
        //------------------------------------------------------

        check_load(
            3'b101,
            32'h00000030,
            32'h000080FF,
            "LHU 0x80FF -> zero extension"
        );

        //------------------------------------------------------
        // TEST 10
        // Store another word at another address.
        //------------------------------------------------------

        store_word(
            3'b010,
            32'h00000040,
            32'hAABBCCDD,
            "SW 0xAABBCCDD -> address 0x40"
        );

        //------------------------------------------------------
        // TEST 11
        // Verify second word.
        //------------------------------------------------------

        check_load(
            3'b010,
            32'h00000040,
            32'hAABBCCDD,
            "LW from 0x40"
        );

        //------------------------------------------------------
        // TEST 12
        // Verify first word remains unchanged.
        //------------------------------------------------------

        check_load(
            3'b010,
            32'h00000010,
            32'h12345678,
            "First memory location preserved"
        );

        //------------------------------------------------------
        // TEST 13
        // Read disabled.
        //------------------------------------------------------

        funct3    = 3'b010;
        address   = 32'h00000010;
        mem_read  = 1'b0;
        mem_write = 1'b0;

        #1;

        tests = tests + 1;

        if (read_data !== 32'b0) begin

            $display("");
            $display("[FAIL] Read disabled");

            $display("       Expected = 00000000");
            $display("       Got      = %h", read_data);

            errors = errors + 1;

        end

        else begin

            $display("[PASS] Read disabled");

        end

        //------------------------------------------------------
        // TEST 14
        // Write disabled.
        //
        // Attempt to overwrite 0x10 without mem_write.
        //------------------------------------------------------

        funct3     = 3'b010;
        address    = 32'h00000010;
        write_data = 32'hDEADBEEF;

        mem_read  = 1'b0;
        mem_write = 1'b0;

        @(posedge clk);

        #1;

        //------------------------------------------------------
        // Read original value.
        //------------------------------------------------------

        check_load(
            3'b010,
            32'h00000010,
            32'h12345678,
            "Write disabled - original word preserved"
        );

        //------------------------------------------------------
        // Final Summary
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