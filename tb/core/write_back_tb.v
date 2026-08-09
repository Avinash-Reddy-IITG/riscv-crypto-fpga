`timescale 1ns/1ps
`default_nettype none

module write_back_tb;

    localparam DATA_WIDTH = 32;

    reg [DATA_WIDTH-1:0] alu_result;
    reg [DATA_WIDTH-1:0] memory_data;
    reg [DATA_WIDTH-1:0] pc_plus_4;

    reg [1:0] wb_src;

    wire [DATA_WIDTH-1:0] rd_data;

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Device Under Test
    //----------------------------------------------------------

    write_back #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .alu_result (alu_result),
        .memory_data(memory_data),
        .pc_plus_4  (pc_plus_4),
        .wb_src     (wb_src),
        .rd_data    (rd_data)
    );

    //----------------------------------------------------------
    // Waveform
    //----------------------------------------------------------

    initial begin
        $dumpfile("sim/write_back/write_back.vcd");
        $dumpvars(0, write_back_tb);
    end

    //----------------------------------------------------------
    // Check Task
    //----------------------------------------------------------

    task check_result;

        input [31:0] expected;
        input [127:0] test_name;

    begin

        #1;

        tests = tests + 1;

        if (rd_data !== expected) begin

            $display("[FAIL] %s", test_name);
            $display("       Expected = %h", expected);
            $display("       Got      = %h", rd_data);

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

        tests  = 0;
        errors = 0;

        alu_result  = 32'h12345678;
        memory_data = 32'hAABBCCDD;
        pc_plus_4   = 32'h00000104;

        $display("");
        $display("=================================================");
        $display("          Write-Back Unit Verification");
        $display("=================================================");

        //------------------------------------------------------
        // Test 1: ALU result
        //------------------------------------------------------

        wb_src = 2'b00;

        check_result(
            32'h12345678,
            "ALU result selected"
        );

        //------------------------------------------------------
        // Test 2: Memory data
        //------------------------------------------------------

        wb_src = 2'b01;

        check_result(
            32'hAABBCCDD,
            "Memory data selected"
        );

        //------------------------------------------------------
        // Test 3: PC + 4
        //------------------------------------------------------

        wb_src = 2'b10;

        check_result(
            32'h00000104,
            "PC + 4 selected"
        );

        //------------------------------------------------------
        // Test 4: Reserved source
        //------------------------------------------------------

        wb_src = 2'b11;

        check_result(
            32'h00000000,
            "Reserved source produces zero"
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

        if (errors == 0) begin

            $display("");
            $display("ALL TESTS PASSED");

        end

        else begin

            $display("");
            $display("VERIFICATION FAILED");

        end

        $finish;

    end

endmodule

`default_nettype wire