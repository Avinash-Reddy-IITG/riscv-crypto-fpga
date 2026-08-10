`timescale 1ns/1ps
`default_nettype none

//==============================================================
// Testbench   : memory_interconnect_tb
// Description :
//   Verification testbench for the memory_interconnect module.
//
//   Tests:
//     - RAM address decoding
//     - RAM read/write routing
//     - SHA-256 address decoding
//     - SHA-256 read/write routing
//     - Read-data multiplexing
//     - Address propagation
//     - Write-data propagation
//     - funct3 propagation
//     - Unsupported address handling
//     - Device isolation
//
//==============================================================

module memory_interconnect_tb;

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------

    localparam DATA_WIDTH = 32;

    //----------------------------------------------------------
    // CPU-Side Signals
    //----------------------------------------------------------

    reg [DATA_WIDTH-1:0] cpu_address;
    reg [DATA_WIDTH-1:0] cpu_write_data;
    reg                  cpu_read;
    reg                  cpu_write;
    reg [2:0]            cpu_funct3;

    wire [DATA_WIDTH-1:0] cpu_read_data;

    //----------------------------------------------------------
    // RAM-Side Signals
    //----------------------------------------------------------

    wire                  ram_read;
    wire                  ram_write;
    wire [DATA_WIDTH-1:0] ram_address;
    wire [DATA_WIDTH-1:0] ram_write_data;
    wire [2:0]            ram_funct3;

    reg [DATA_WIDTH-1:0]  ram_read_data;

    //----------------------------------------------------------
    // SHA-256-Side Signals
    //----------------------------------------------------------

    wire                  sha_read;
    wire                  sha_write;
    wire [DATA_WIDTH-1:0] sha_address;
    wire [DATA_WIDTH-1:0] sha_write_data;
    wire [2:0]            sha_funct3;

    reg [DATA_WIDTH-1:0]  sha_read_data;

    //----------------------------------------------------------
    // Test Counters
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Device Under Test
    //----------------------------------------------------------

    memory_interconnect #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (

        .cpu_address    (cpu_address),
        .cpu_write_data (cpu_write_data),
        .cpu_read       (cpu_read),
        .cpu_write      (cpu_write),
        .cpu_funct3     (cpu_funct3),
        .cpu_read_data  (cpu_read_data),

        .ram_read       (ram_read),
        .ram_write      (ram_write),
        .ram_address    (ram_address),
        .ram_write_data (ram_write_data),
        .ram_funct3     (ram_funct3),
        .ram_read_data  (ram_read_data),

        .sha_read       (sha_read),
        .sha_write      (sha_write),
        .sha_address    (sha_address),
        .sha_write_data (sha_write_data),
        .sha_funct3     (sha_funct3),
        .sha_read_data  (sha_read_data)
    );

    //----------------------------------------------------------
    // Task: Check Signal
    //----------------------------------------------------------

    task check_signal;

        input [DATA_WIDTH-1:0] actual;
        input [DATA_WIDTH-1:0] expected;
        input [8*50-1:0]       test_name;

        begin

            tests = tests + 1;

            if (actual !== expected) begin

                errors = errors + 1;

                $display(
                    "[FAIL] %s",
                    test_name
                );

                $display(
                    "       Expected = %h",
                    expected
                );

                $display(
                    "       Got      = %h",
                    actual
                );

            end

            else begin

                $display(
                    "[PASS] %s",
                    test_name
                );

            end

        end

    endtask

    //----------------------------------------------------------
    // Task: Check Bit
    //----------------------------------------------------------

    task check_bit;

        input actual;
        input expected;
        input [8*50-1:0] test_name;

        begin

            tests = tests + 1;

            if (actual !== expected) begin

                errors = errors + 1;

                $display(
                    "[FAIL] %s",
                    test_name
                );

                $display(
                    "       Expected = %b",
                    expected
                );

                $display(
                    "       Got      = %b",
                    actual
                );

            end

            else begin

                $display(
                    "[PASS] %s",
                    test_name
                );

            end

        end

    endtask

    //----------------------------------------------------------
    // Initial Test Procedure
    //----------------------------------------------------------

    initial begin

        //------------------------------------------------------
        // Initialize
        //------------------------------------------------------

        tests = 0;
        errors = 0;

        cpu_address    = 32'b0;
        cpu_write_data = 32'b0;
        cpu_read       = 1'b0;
        cpu_write      = 1'b0;
        cpu_funct3     = 3'b0;

        ram_read_data  = 32'b0;
        sha_read_data  = 32'b0;

        #10;

        $display("");
        $display("==============================================");
        $display("       MEMORY INTERCONNECT VERIFICATION");
        $display("==============================================");
        $display("");

        //------------------------------------------------------
        // TEST 1
        // RAM Write Selection
        //------------------------------------------------------

        cpu_address    = 32'h0000_0020;
        cpu_write_data = 32'hDEAD_BEEF;
        cpu_read       = 1'b0;
        cpu_write      = 1'b1;
        cpu_funct3     = 3'b010;

        #1;

        check_bit(
            ram_write,
            1'b1,
            "RAM write selected"
        );

        check_bit(
            ram_read,
            1'b0,
            "RAM read disabled during write"
        );

        check_bit(
            sha_write,
            1'b0,
            "SHA write not selected for RAM address"
        );

        //------------------------------------------------------
        // TEST 2
        // RAM Address Propagation
        //------------------------------------------------------

        check_signal(
            ram_address,
            32'h0000_0020,
            "RAM address propagation"
        );

        //------------------------------------------------------
        // TEST 3
        // RAM Write Data Propagation
        //------------------------------------------------------

        check_signal(
            ram_write_data,
            32'hDEAD_BEEF,
            "RAM write-data propagation"
        );

        //------------------------------------------------------
        // TEST 4
        // RAM funct3 Propagation
        //------------------------------------------------------

        check_signal(
            {29'b0, ram_funct3},
            {29'b0, 3'b010},
            "RAM funct3 propagation"
        );

        //------------------------------------------------------
        // TEST 5
        // RAM Read Selection
        //------------------------------------------------------

        cpu_address    = 32'h0000_0040;
        cpu_write_data = 32'b0;
        cpu_read       = 1'b1;
        cpu_write      = 1'b0;
        cpu_funct3     = 3'b010;

        ram_read_data = 32'h1234_5678;

        #1;

        check_bit(
            ram_read,
            1'b1,
            "RAM read selected"
        );

        check_bit(
            ram_write,
            1'b0,
            "RAM write disabled during read"
        );

        //------------------------------------------------------
        // TEST 6
        // RAM Read Data Return
        //------------------------------------------------------

        check_signal(
            cpu_read_data,
            32'h1234_5678,
            "RAM read-data returned to CPU"
        );

        //------------------------------------------------------
        // TEST 7
        // SHA Write Selection
        //------------------------------------------------------

        cpu_address    = 32'h1000_0020;
        cpu_write_data = 32'hCAFE_BABE;
        cpu_read       = 1'b0;
        cpu_write      = 1'b1;
        cpu_funct3     = 3'b010;

        #1;

        check_bit(
            sha_write,
            1'b1,
            "SHA write selected"
        );

        check_bit(
            sha_read,
            1'b0,
            "SHA read disabled during write"
        );

        check_bit(
            ram_write,
            1'b0,
            "RAM write not selected for SHA address"
        );

        //------------------------------------------------------
        // TEST 8
        // SHA Address Propagation
        //------------------------------------------------------

        check_signal(
            sha_address,
            32'h1000_0020,
            "SHA address propagation"
        );

        //------------------------------------------------------
        // TEST 9
        // SHA Write Data Propagation
        //------------------------------------------------------

        check_signal(
            sha_write_data,
            32'hCAFE_BABE,
            "SHA write-data propagation"
        );

        //------------------------------------------------------
        // TEST 10
        // SHA funct3 Propagation
        //------------------------------------------------------

        check_signal(
            {29'b0, sha_funct3},
            {29'b0, 3'b010},
            "SHA funct3 propagation"
        );

        //------------------------------------------------------
        // TEST 11
        // SHA Read Selection
        //------------------------------------------------------

        cpu_address    = 32'h1000_0040;
        cpu_write_data = 32'b0;
        cpu_read       = 1'b1;
        cpu_write      = 1'b0;
        cpu_funct3     = 3'b010;

        sha_read_data = 32'hFACE_1234;

        #1;

        check_bit(
            sha_read,
            1'b1,
            "SHA read selected"
        );

        check_bit(
            sha_write,
            1'b0,
            "SHA write disabled during read"
        );

        //------------------------------------------------------
        // TEST 12
        // SHA Read Data Return
        //------------------------------------------------------

        check_signal(
            cpu_read_data,
            32'hFACE_1234,
            "SHA read-data returned to CPU"
        );

        //------------------------------------------------------
        // TEST 13
        // RAM and SHA Isolation
        //------------------------------------------------------

        check_bit(
            ram_read,
            1'b0,
            "RAM isolated from SHA read"
        );

        //------------------------------------------------------
        // TEST 14
        // Unsupported Address
        //------------------------------------------------------

        cpu_address    = 32'h3000_0000;
        cpu_write_data = 32'hAAAA_AAAA;
        cpu_read       = 1'b1;
        cpu_write      = 1'b0;
        cpu_funct3     = 3'b010;

        #1;

        check_bit(
            ram_read,
            1'b0,
            "RAM disabled for unsupported address"
        );

        check_bit(
            sha_read,
            1'b0,
            "SHA disabled for unsupported address"
        );

        check_signal(
            cpu_read_data,
            32'h0000_0000,
            "Unsupported read returns zero"
        );

        //------------------------------------------------------
        // TEST 15
        // Unsupported Write
        //------------------------------------------------------

        cpu_address = 32'h3000_0000;
        cpu_read    = 1'b0;
        cpu_write   = 1'b1;

        #1;

        check_bit(
            ram_write,
            1'b0,
            "RAM disabled for unsupported write"
        );

        check_bit(
            sha_write,
            1'b0,
            "SHA disabled for unsupported write"
        );

        //------------------------------------------------------
        // TEST 16
        // RAM Upper Boundary
        //------------------------------------------------------

        cpu_address = 32'h0000_0FFF;
        cpu_read    = 1'b1;
        cpu_write   = 1'b0;

        #1;

        check_bit(
            ram_read,
            1'b1,
            "RAM upper boundary selected"
        );

        //------------------------------------------------------
        // TEST 17
        // SHA Upper Boundary
        //------------------------------------------------------

        cpu_address = 32'h1000_00FF;
        cpu_read    = 1'b1;
        cpu_write   = 1'b0;

        #1;

        check_bit(
            sha_read,
            1'b1,
            "SHA upper boundary selected"
        );

        //------------------------------------------------------
        // Final Results
        //------------------------------------------------------

        $display("");
        $display("==============================================");
        $display("Tests  : %0d", tests);
        $display("Errors : %0d", errors);
        $display("==============================================");
        $display("");

        if (errors == 0) begin

            $display("----------------------------------------------");
            $display("      MEMORY INTERCONNECT VERIFICATION PASS");
            $display("----------------------------------------------");

        end

        else begin

            $display("----------------------------------------------");
            $display("      MEMORY INTERCONNECT VERIFICATION FAIL");
            $display("----------------------------------------------");

        end

        $display("");

        $finish;

    end

endmodule

`default_nettype wire