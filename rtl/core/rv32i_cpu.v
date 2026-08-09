`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : rv32i_cpu
// Project     : FPGA RISC-V SoC with SHA-256 Accelerator
// Description :
//   Top-level RV32I processor.
//
//   Integrates:
//     - Program Counter
//     - Instruction Memory
//     - Main Control Unit
//     - ALU Control Unit
//     - RV32I Datapath
//
//   The datapath contains the internal register, ALU,
//   branch, memory, next-PC and write-back functionality.
//
// Target FPGA : Xilinx Artix-7 (Basys-3)
//==============================================================

module rv32i_cpu #(
    parameter DATA_WIDTH = 32,
    parameter INIT_FILE  = "programs/program.hex"
)(
    //----------------------------------------------------------
    // Clock and Reset
    //----------------------------------------------------------

    input wire clk,
    input wire rst
);

    //----------------------------------------------------------
    // Program Counter
    //----------------------------------------------------------

    wire [DATA_WIDTH-1:0] pc;
    wire [DATA_WIDTH-1:0] pc_next;

    //----------------------------------------------------------
    // Instruction Memory
    //----------------------------------------------------------

    wire [DATA_WIDTH-1:0] instruction;

    //----------------------------------------------------------
    // Instruction Fields
    //----------------------------------------------------------

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    //----------------------------------------------------------
    // Main Control Signals
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
    // ALU Control
    //----------------------------------------------------------

    wire [3:0] alu_control;

    //----------------------------------------------------------
    // Datapath Outputs
    //----------------------------------------------------------

    wire [DATA_WIDTH-1:0] rd_data;
    wire [DATA_WIDTH-1:0] alu_result;
    wire [DATA_WIDTH-1:0] memory_data;
    wire                  branch_taken;

    //----------------------------------------------------------
    // Program Counter
    //
    // pc_write is currently permanently enabled.
    // Every clock cycle therefore loads pc_next.
    //----------------------------------------------------------

    program_counter #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_program_counter (
        .clk     (clk),
        .rst     (rst),
        .pc_write(1'b1),
        .pc_next (pc_next),
        .pc      (pc)
    );

    //----------------------------------------------------------
    // Instruction Memory
    //----------------------------------------------------------

   instruction_memory #(
    .DATA_WIDTH(DATA_WIDTH),
    .INIT_FILE (INIT_FILE)
) u_instruction_memory (
        .address    (pc),
        .instruction(instruction)
    );

    //----------------------------------------------------------
    // Main Control Unit
    //----------------------------------------------------------

    control_unit u_control_unit (
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
    // ALU Control Unit
    //----------------------------------------------------------

    alu_control u_alu_control (
        .ALUOp       (ALUOp),
        .funct3      (funct3),
        .funct7      (funct7),
        .alu_control (alu_control)
    );

    //----------------------------------------------------------
    // RV32I Datapath
    //----------------------------------------------------------

    rv32i_datapath #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_rv32i_datapath (
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

        .alu_control (alu_control),

        .next_pc     (pc_next),
        .rd_data     (rd_data),
        .alu_result  (alu_result),
        .memory_data (memory_data),
        .branch_taken(branch_taken)
    );

endmodule

`default_nettype wire