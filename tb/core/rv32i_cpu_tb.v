`timescale 1ns/1ps

`default_nettype none

//==============================================================
// Testbench      : rv32i_cpu_tb
// Description    : Comprehensive RV32I CPU verification
//
// Tests:
//   - Arithmetic
//   - Logical operations
//   - Register shifts
//   - Immediate shifts
//   - Signed/unsigned comparisons
//   - Immediate logical operations
//   - Byte/halfword/word memory operations
//   - Sign/zero extension
//   - All six conditional branches
//   - JAL
//   - JALR
//   - LUI
//   - AUIPC
//   - x0 protection
//==============================================================

module rv32i_cpu_tb;

    //----------------------------------------------------------
    // Clock and Reset
    //----------------------------------------------------------

    reg clk;
    reg rst;

    //----------------------------------------------------------
    // CPU
    //----------------------------------------------------------

    rv32i_cpu #(
        .INIT_FILE("programs/program.hex")
    ) dut (
        .clk(clk),
        .rst(rst)
    );

    //----------------------------------------------------------
    // Counters
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Clock
    //----------------------------------------------------------

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end

    //----------------------------------------------------------
    // Register Check
    //----------------------------------------------------------

    task check_register;

        input integer reg_num;
        input [31:0] expected;
        input [255:0] test_name;

        reg [31:0] actual;

        begin

            actual =
                dut.u_rv32i_datapath
                   .u_register_file
                   .registers[reg_num];

            tests = tests + 1;

            if (actual === expected) begin

                $display("[PASS] %s", test_name);

            end
            else begin

                errors = errors + 1;

                $display("[FAIL] %s", test_name);
                $display("Register = x%0d", reg_num);
                $display("Expected = %08h", expected);
                $display("Got      = %08h", actual);

            end

        end

    endtask

    //----------------------------------------------------------
    // Memory Byte Check
    //----------------------------------------------------------

    task check_memory_byte;

        input integer address;
        input [7:0] expected;
        input [255:0] test_name;

        reg [7:0] actual;

        begin

            actual =
                dut.u_rv32i_datapath
                   .u_data_memory
                   .memory[address];

            tests = tests + 1;

            if (actual === expected) begin

                $display("[PASS] %s", test_name);

            end
            else begin

                errors = errors + 1;

                $display("[FAIL] %s", test_name);
                $display("Address  = %0d", address);
                $display("Expected = %02h", expected);
                $display("Got      = %02h", actual);

            end

        end

    endtask

    //----------------------------------------------------------
    // Main Test
    //----------------------------------------------------------

    initial begin

        tests  = 0;
        errors = 0;

        //------------------------------------------------------
        // Reset
        //------------------------------------------------------

        rst = 1'b1;

        #20;

        rst = 1'b0;

        $display("");
        $display("=================================================");
        $display("             RV32I CPU VERIFICATION");
        $display("=================================================");
        $display("");

        //------------------------------------------------------
        // Allow complete test program to execute
        //------------------------------------------------------

        repeat (100) begin
            @(posedge clk);
        end

        #1;

        //======================================================
        // INTEGER ARITHMETIC
        //======================================================

        check_register(
            1,
            32'd10,
            "ADDI x1, x0, 10"
        );

        check_register(
            2,
            32'd20,
            "ADDI x2, x0, 20"
        );

        check_register(
            3,
            32'd30,
            "ADD x3, x1, x2"
        );

        check_register(
            4,
            32'd10,
            "SUB x4, x2, x1"
        );

        //======================================================
        // LOGICAL
        //======================================================

        check_register(
            5,
            32'd0,
            "AND x5, x1, x2"
        );

        check_register(
            6,
            32'd30,
            "OR x6, x1, x2"
        );

        check_register(
            7,
            32'd30,
            "XOR x7, x1, x2"
        );

        //======================================================
        // REGISTER SHIFTS
        //======================================================

        check_register(
            8,
            32'd40,
            "SLL x8, x1, x18"
        );

        check_register(
            9,
            32'd10,
            "SRL x9, x8, x18"
        );

        check_register(
            10,
            32'd10,
            "SRA x10, x8, x18"
        );

        //======================================================
        // COMPARISONS
        //======================================================

        check_register(
            11,
            32'd1,
            "SLT x11, x1, x2"
        );

        check_register(
            12,
            32'd1,
            "SLTU x12, x1, x2"
        );

        check_register(
            13,
            32'd1,
            "SLT signed negative comparison"
        );

        check_register(
            14,
            32'd0,
            "SLTU signed-bit-pattern comparison"
        );

        //======================================================
        // IMMEDIATE SHIFTS
        //======================================================

        check_register(
            15,
            32'd40,
            "SLLI x15"
        );

        check_register(
            16,
            32'd10,
            "SRLI x16"
        );

        check_register(
            17,
            32'hFFFFFFFF,
            "SRAI x17"
        );

        //======================================================
        // IMMEDIATE LOGICAL
        //======================================================

        check_register(
            20,
            32'd4,
            "ANDI x20"
        );

        check_register(
            21,
            32'd30,
            "ORI x21"
        );

        check_register(
            22,
            32'd27,
            "XORI x22"
        );

        //======================================================
        // WORD LOAD
        //======================================================

        check_register(
            23,
            32'd30,
            "LW x23, 0(x0)"
        );

        //======================================================
        // SIGNED / UNSIGNED LOADS
        //======================================================

        check_register(
            24,
            32'hFFFFFFFF,
            "LH sign extension"
        );

        check_register(
            18,
            32'h0000FFFF,
            "LHU zero extension"
        );

        check_register(
            25,
            32'hFFFFFFFF,
            "LB sign extension"
        );

        check_register(
            26,
            32'h000000FF,
            "LBU zero extension"
        );

        //======================================================
        // BRANCHES
        //
        // Taken branch  -> marker = 1
        // Not taken     -> marker = 0
        //======================================================

        check_memory_byte(
            32,
            8'h01,
            "BEQ taken"
        );

        check_memory_byte(
            36,
            8'h00,
            "BNE not taken"
        );

        check_memory_byte(
            40,
            8'h01,
            "BLT taken"
        );

        check_memory_byte(
            44,
            8'h00,
            "BGE not taken"
        );

        check_memory_byte(
            48,
            8'h01,
            "BLTU taken"
        );

        check_memory_byte(
            52,
            8'h00,
            "BGEU not taken"
        );

        //======================================================
        // JAL RETURN ADDRESS
        //
        // JAL at PC = 0xE4
        // Return address = 0xE8
        //
        // Stored at memory address 56.
        //======================================================

        check_memory_byte(
            56,
            8'hE8,
            "JAL return address byte 0"
        );

        check_memory_byte(
            57,
            8'h00,
            "JAL return address byte 1"
        );

        check_memory_byte(
            58,
            8'h00,
            "JAL return address byte 2"
        );

        check_memory_byte(
            59,
            8'h00,
            "JAL return address byte 3"
        );

        //======================================================
        // JALR RETURN ADDRESS
        //
        // JALR at PC = 0xF4
        // Return address = 0xF8
        //
        // Stored at memory address 60.
        //======================================================

        check_memory_byte(
            60,
            8'hF8,
            "JALR return address byte 0"
        );

        check_memory_byte(
            61,
            8'h00,
            "JALR return address byte 1"
        );

        check_memory_byte(
            62,
            8'h00,
            "JALR return address byte 2"
        );

        check_memory_byte(
            63,
            8'h00,
            "JALR return address byte 3"
        );

        //======================================================
        // LUI
        //======================================================

        check_register(
            30,
            32'h12345000,
            "LUI x30, 0x12345"
        );

        //======================================================
        // AUIPC
        //
        // AUIPC is at PC = 0x104.
        //
        // 0x00000104 + 0x00001000
        // = 0x00001104
        //======================================================

        check_register(
            31,
            32'h00001104,
            "AUIPC x31, 0x1"
        );

        //======================================================
        // SW
        //======================================================

        check_memory_byte(
            0,
            8'h1E,
            "SW byte 0"
        );

        check_memory_byte(
            1,
            8'h00,
            "SW byte 1"
        );

        check_memory_byte(
            2,
            8'h00,
            "SW byte 2"
        );

        check_memory_byte(
            3,
            8'h00,
            "SW byte 3"
        );

        //======================================================
        // SH
        //======================================================

        check_memory_byte(
            4,
            8'h1E,
            "SH byte 0"
        );

        check_memory_byte(
            5,
            8'h00,
            "SH byte 1"
        );

        //======================================================
        // SB
        //======================================================

        check_memory_byte(
            6,
            8'h1E,
            "SB byte"
        );

        //======================================================
        // NEGATIVE BYTE STORE
        //======================================================

        check_memory_byte(
            16,
            8'hFF,
            "Negative byte store"
        );

        //======================================================
        // NEGATIVE HALFWORD STORE
        //======================================================

        check_memory_byte(
            18,
            8'hFF,
            "Negative halfword byte 0"
        );

        check_memory_byte(
            19,
            8'hFF,
            "Negative halfword byte 1"
        );

        //======================================================
        // x0 PROTECTION
        //======================================================

        check_register(
            0,
            32'd0,
            "x0 remains hardwired to zero"
        );

        //======================================================
        // SUMMARY
        //======================================================

        $display("");
        $display("=================================================");
        $display("              VERIFICATION SUMMARY");
        $display("=================================================");
        $display("");

        $display("Tests  : %0d", tests);
        $display("Errors : %0d", errors);

        $display("");

        if (errors == 0) begin

            $display("***********************************************");
            $display("*                                             *");
            $display("*       ALL CPU TESTS PASSED!                *");
            $display("*                                             *");
            $display("***********************************************");

        end
        else begin

            $display("***********************************************");
            $display("*                                             *");
            $display("*       CPU VERIFICATION FAILED              *");
            $display("*                                             *");
            $display("***********************************************");

        end

        $display("");

        $finish;

    end

endmodule

`default_nettype wire