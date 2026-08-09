`timescale 1ns/1ps
`default_nettype none




//==============================================================
// Module      : rv32i_datapath_tb
// Description :
//   Instruction-level verification of the integrated RV32I
//   datapath.
//
//   The testbench connects:
//     - Main Control Unit
//     - ALU Control Unit
//     - RV32I Datapath
//
//   Tested instructions:
//
//     ADDI
//     ADD
//     SUB
//     AND
//     OR
//     LW
//     SW
//     BEQ
//     BNE
//     JAL
//     JALR
//     LUI
//     AUIPC
//
//==============================================================

module rv32i_datapath_tb;

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------

    localparam DATA_WIDTH = 32;

    //----------------------------------------------------------
    // Clock and Reset
    //----------------------------------------------------------

    reg clk;
    reg rst;

    //----------------------------------------------------------
    // Instruction / PC
    //----------------------------------------------------------

    reg [31:0] pc;
    reg [31:0] instruction;

    //----------------------------------------------------------
    // Main Control Outputs
    //----------------------------------------------------------

    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;
    wire       MemToReg;
    wire       ALUSrc;
    wire       Branch;
    wire       Jump;
    wire [1:0] ALUOp;

    //----------------------------------------------------------
    // ALU Control Output
    //----------------------------------------------------------

    wire [3:0] alu_control_signal;

    //----------------------------------------------------------
    // Datapath Outputs
    //----------------------------------------------------------

    wire [31:0] next_pc;
    wire [31:0] rd_data;
    wire [31:0] alu_result;
    wire [31:0] memory_data;
    wire        branch_taken;

    //----------------------------------------------------------
    // Instruction Fields
    //----------------------------------------------------------

    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    //----------------------------------------------------------
    // Test Statistics
    //----------------------------------------------------------

    integer tests;
    integer errors;

    //----------------------------------------------------------
    // Main Control Unit
    //----------------------------------------------------------

    control_unit u_control_unit (
        .opcode   (opcode),

        .RegWrite(RegWrite),
        .MemRead (MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUSrc  (ALUSrc),
        .Branch  (Branch),
        .Jump    (Jump),
        .ALUOp   (ALUOp)
    );

    //----------------------------------------------------------
    // ALU Control Unit
    //----------------------------------------------------------

    alu_control u_alu_control (
        .ALUOp       (ALUOp),
        .funct3      (funct3),
        .funct7      (funct7),
        .alu_control (alu_control_signal)
    );

    //----------------------------------------------------------
    // RV32I Datapath
    //----------------------------------------------------------

    rv32i_datapath #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk         (clk),
        .rst         (rst),

        .pc          (pc),
        .instruction (instruction),

        .RegWrite    (RegWrite),
        .MemRead     (MemRead),
        .MemWrite    (MemWrite),
        .MemToReg    (MemToReg),
        .ALUSrc      (ALUSrc),
        .Branch      (Branch),
        .Jump        (Jump),
        .ALUOp       (ALUOp),

        .alu_control (alu_control_signal),

        .next_pc     (next_pc),
        .rd_data     (rd_data),
        .alu_result  (alu_result),
        .memory_data (memory_data),
        .branch_taken(branch_taken)
    );

    //----------------------------------------------------------
    // Clock
    //----------------------------------------------------------

    always #5 clk = ~clk;

    //----------------------------------------------------------
    // Waveform
    //----------------------------------------------------------

    initial begin

        $dumpfile("sim/rv32i_datapath/rv32i_datapath.vcd");
        $dumpvars(0, rv32i_datapath_tb);

    end

    //==========================================================
    // Instruction Encoding Functions
    //==========================================================

    //----------------------------------------------------------
    // R-Type
    //----------------------------------------------------------

    function [31:0] encode_r;

        input [6:0] funct7_in;
        input [4:0] rs2_in;
        input [4:0] rs1_in;
        input [2:0] funct3_in;
        input [4:0] rd_in;

        begin

            encode_r = {
                funct7_in,
                rs2_in,
                rs1_in,
                funct3_in,
                rd_in,
                7'b0110011
            };

        end

    endfunction

    //----------------------------------------------------------
    // I-Type
    //----------------------------------------------------------

    function [31:0] encode_i;

        input [11:0] imm_in;
        input [4:0] rs1_in;
        input [2:0] funct3_in;
        input [4:0] rd_in;
        input [6:0] opcode_in;

        begin

            encode_i = {
                imm_in,
                rs1_in,
                funct3_in,
                rd_in,
                opcode_in
            };

        end

    endfunction

    //----------------------------------------------------------
    // S-Type
    //----------------------------------------------------------

    function [31:0] encode_s;

        input [11:0] imm_in;
        input [4:0] rs2_in;
        input [4:0] rs1_in;
        input [2:0] funct3_in;
        input [6:0] opcode_in;

        begin

            encode_s = {
                imm_in[11:5],
                rs2_in,
                rs1_in,
                funct3_in,
                imm_in[4:0],
                opcode_in
            };

        end

    endfunction

    //----------------------------------------------------------
    // B-Type
    //----------------------------------------------------------

    function [31:0] encode_b;

        input [12:0] imm_in;
        input [4:0] rs2_in;
        input [4:0] rs1_in;
        input [2:0] funct3_in;

        begin

            encode_b = {
                imm_in[12],
                imm_in[10:5],
                rs2_in,
                rs1_in,
                funct3_in,
                imm_in[4:1],
                imm_in[11],
                7'b1100011
            };

        end

    endfunction

    //----------------------------------------------------------
    // U-Type
    //----------------------------------------------------------

    function [31:0] encode_u;

        input [19:0] imm_in;
        input [4:0] rd_in;
        input [6:0] opcode_in;

        begin

            encode_u = {
                imm_in,
                rd_in,
                opcode_in
            };

        end

    endfunction

    //----------------------------------------------------------
    // J-Type
    //----------------------------------------------------------

    function [31:0] encode_j;

        input [20:0] imm_in;
        input [4:0] rd_in;

        begin

            encode_j = {
                imm_in[20],
                imm_in[10:1],
                imm_in[11],
                imm_in[19:12],
                rd_in,
                7'b1101111
            };

        end

    endfunction

    //==========================================================
    // Checking Tasks
    //==========================================================

    //----------------------------------------------------------
    // Check Register
    //
    // Registers are accessed hierarchically because the
    // Register File is an internal component of the datapath.
    //----------------------------------------------------------

    task check_register;

        input [4:0]  reg_num;
        input [31:0] expected;
        input [127:0] test_name;

        reg [31:0] actual;

        begin

            #1;

            actual = DUT.u_register_file.registers[reg_num];

            tests = tests + 1;

            if (actual !== expected) begin

                $display("");
                $display("[FAIL] %s", test_name);
                $display("       Register = x%0d", reg_num);
                $display("       Expected = %h", expected);
                $display("       Got      = %h", actual);

                errors = errors + 1;

            end

            else begin

                $display("[PASS] %s", test_name);

            end

        end

    endtask

    //----------------------------------------------------------
    // Check Next PC
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
                $display("       Expected next_pc = %h", expected);
                $display("       Got next_pc      = %h",
                         next_pc);

                errors = errors + 1;

            end

            else begin

                $display("[PASS] %s", test_name);

            end

        end

    endtask

    //----------------------------------------------------------
    // Apply Instruction and Wait for Combinational Logic
    //----------------------------------------------------------

    task apply_instruction;

        input [31:0] instr;
        input [31:0] current_pc;

        begin

            instruction = instr;
            pc          = current_pc;

            #1;

        end

    endtask

    //----------------------------------------------------------
    // Execute Instruction
    //
    // One positive clock edge allows the Register File or
    // Data Memory to perform its synchronous operation.
    //----------------------------------------------------------

    task execute_instruction;

        input [31:0] instr;
        input [31:0] current_pc;

        begin

            instruction = instr;
            pc          = current_pc;

            #1;

            @(posedge clk);

            #1;

        end

    endtask

    //==========================================================
    // Main Test Sequence
    //==========================================================

    initial begin

        //------------------------------------------------------
        // Initial State
        //------------------------------------------------------

        clk = 1'b0;
        rst = 1'b1;

        pc          = 32'h00000000;
        instruction = 32'h00000013; // NOP / ADDI x0,x0,0

        tests  = 0;
        errors = 0;

        $display("");
        $display("=================================================");
        $display("       RV32I DATAPATH VERIFICATION");
        $display("=================================================");

        //------------------------------------------------------
        // Reset
        //------------------------------------------------------

        #2;
        @(posedge clk);
        #1;

        rst = 1'b0;

        $display("");
        $display("Reset completed.");
        $display("");

        //======================================================
        // TEST 1
        // ADDI x1, x0, 10
        //
        // x1 = 10
        //======================================================

        execute_instruction(
            encode_i(
                12'd10,
                5'd0,
                3'b000,
                5'd1,
                7'b0010011
            ),
            32'h00000000
        );

        check_register(
            5'd1,
            32'd10,
            "ADDI x1, x0, 10"
        );

        //======================================================
        // TEST 2
        // ADDI x2, x0, 20
        //
        // x2 = 20
        //======================================================

        execute_instruction(
            encode_i(
                12'd20,
                5'd0,
                3'b000,
                5'd2,
                7'b0010011
            ),
            32'h00000004
        );

        check_register(
            5'd2,
            32'd20,
            "ADDI x2, x0, 20"
        );

        //======================================================
        // TEST 3
        // ADD x3, x1, x2
        //
        // x3 = 10 + 20 = 30
        //======================================================

        execute_instruction(
            encode_r(
                7'b0000000,
                5'd2,
                5'd1,
                3'b000,
                5'd3
            ),
            32'h00000008
        );

        check_register(
            5'd3,
            32'd30,
            "ADD x3, x1, x2"
        );

        //======================================================
        // TEST 4
        // SUB x4, x2, x1
        //
        // x4 = 20 - 10 = 10
        //======================================================

        execute_instruction(
            encode_r(
                7'b0100000,
                5'd1,
                5'd2,
                3'b000,
                5'd4
            ),
            32'h0000000C
        );

        check_register(
            5'd4,
            32'd10,
            "SUB x4, x2, x1"
        );

        //======================================================
        // TEST 5
        // AND x5, x1, x2
        //======================================================

        execute_instruction(
            encode_r(
                7'b0000000,
                5'd2,
                5'd1,
                3'b111,
                5'd5
            ),
            32'h00000010
        );

        check_register(
            5'd5,
            32'd0,
            "AND x5, x1, x2"
        );

        //======================================================
        // TEST 6
        // OR x6, x1, x2
        //======================================================

               execute_instruction(
            encode_r(
                7'b0000000,
                5'd2,
                5'd1,
                3'b110,
                5'd6
            ),
            32'h00000014
        );

        check_register(
            5'd6,
            32'd30,
            "OR x6, x1, x2"
        );

        //======================================================
        // TEST 7
        // Store
        //
        // SW x3, 0(x0)
        //
        // memory[0] = 30
        //======================================================

        execute_instruction(
            encode_s(
                12'd0,
                5'd3,
                5'd0,
                3'b010,
                7'b0100011
            ),
            32'h00000018
        );

        $display("");
        $display("[INFO] SW x3, 0(x0) executed.");

        //======================================================
        // TEST 8
        // Load
        //
        // LW x7, 0(x0)
        //
        // x7 should become 30
        //======================================================

        execute_instruction(
            encode_i(
                12'd0,
                5'd0,
                3'b010,
                5'd7,
                7'b0000011
            ),
            32'h0000001C
        );

        check_register(
            5'd7,
            32'd30,
            "LW x7, 0(x0)"
        );

        //======================================================
        // TEST 9
        // BEQ
        //
        // x3 == x7
        // Therefore branch must be taken.
        //
        // Branch offset = +8
        // PC = 0x20
        // Target = 0x28
        //======================================================

        apply_instruction(
            encode_b(
                13'd8,
                5'd7,
                5'd3,
                3'b000
            ),
            32'h00000020
        );

        check_next_pc(
            32'h00000028,
            "BEQ taken"
        );

        //======================================================
        // TEST 10
        // BNE
        //
        // x3 == x7
        // Therefore branch must NOT be taken.
        //
        // Expected PC + 4
        //======================================================

        apply_instruction(
            encode_b(
                13'd8,
                5'd7,
                5'd3,
                3'b001
            ),
            32'h00000030
        );

        check_next_pc(
            32'h00000034,
            "BNE not taken"
        );

        //======================================================
        // TEST 11
        // JAL x8, +16
        //
        // PC = 0x40
        // Target = 0x50
        // x8 = PC + 4 = 0x44
        //======================================================

        apply_instruction(
            encode_j(
                21'd16,
                5'd8
            ),
            32'h00000040
        );

        check_next_pc(
            32'h00000050,
            "JAL target"
        );

        #1;

        tests = tests + 1;

        if (rd_data !== 32'h00000044) begin

            $display("[FAIL] JAL return address");
            $display("       Expected = 00000044");
            $display("       Got      = %h", rd_data);

            errors = errors + 1;

        end

        else begin

            $display("[PASS] JAL return address");

        end

        //======================================================
        // TEST 12
        // JALR x9, 4(x1)
        //
        // x1 = 10
        // target = 10 + 4 = 14
        // bit 0 cleared
        //
        // x9 = PC + 4
        //======================================================

        apply_instruction(
            encode_i(
                12'd4,
                5'd1,
                3'b000,
                5'd9,
                7'b1100111
            ),
            32'h00000060
        );

        check_next_pc(
            32'h0000000E,
            "JALR target"
        );

        #1;

        tests = tests + 1;

        if (rd_data !== 32'h00000064) begin

            $display("[FAIL] JALR return address");
            $display("       Expected = 00000064");
            $display("       Got      = %h", rd_data);

            errors = errors + 1;

        end

        else begin

            $display("[PASS] JALR return address");

        end
        
        //======================================================


        //======================================================
        // TEST 13
        // LUI x10, 0x12345
        //
        // x10 = 0x12345000
        //======================================================

        execute_instruction(
            encode_u(
                20'h12345,
                5'd10,
                7'b0110111
            ),
            32'h00000070
        );

        check_register(
            5'd10,
            32'h12345000,
            "LUI x10, 0x12345"
        );

        //======================================================
        // TEST 14
        // AUIPC x11, 0x1
        //
        // PC = 0x00000100
        //
        // x11 = PC + 0x1000
        //     = 0x00001100
        //======================================================

        execute_instruction(
            encode_u(
                20'h00001,
                5'd11,
                7'b0010111
            ),
            32'h00000100
        );

        check_register(
            5'd11,
            32'h00001100,
            "AUIPC x11, 0x1"
        );

        //======================================================
        // TEST 15
        // x0 must remain zero
        //
        // Attempt:
        // ADDI x0, x0, 123
        //======================================================

        execute_instruction(
            encode_i(
                12'd123,
                5'd0,
                3'b000,
                5'd0,
                7'b0010011
            ),
            32'h00000104
        );

        check_register(
            5'd0,
            32'h00000000,
            "x0 remains hardwired to zero"
        );

        //======================================================
        // Final Summary
        //======================================================

        $display("");
        $display("=================================================");
        $display("              VERIFICATION SUMMARY");
        $display("=================================================");
        $display("Tests  : %0d", tests);
        $display("Errors : %0d", errors);

        if (errors == 0) begin

            $display("");
            $display("***********************************************");
            $display("*                                             *");
            $display("*       ALL DATAPATH TESTS PASSED!           *");
            $display("*                                             *");
            $display("***********************************************");

        end

        else begin

            $display("");
            $display("***********************************************");
            $display("*                                             *");
            $display("*       DATAPATH VERIFICATION FAILED         *");
            $display("*                                             *");
            $display("***********************************************");

        end

        $finish;

    end

endmodule

`default_nettype wire