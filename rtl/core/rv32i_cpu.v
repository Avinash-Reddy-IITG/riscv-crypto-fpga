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
//   branch, next-PC and write-back functionality.
//
//   Data memory is connected externally through the
//   datapath memory interface.
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
    input wire rst,

    // Debug output
    output wire [DATA_WIDTH-1:0] debug_pc
);

    //----------------------------------------------------------
    // Program Counter
    //----------------------------------------------------------

    wire [DATA_WIDTH-1:0] pc;
    wire [DATA_WIDTH-1:0] pc_next;

    //----------------------------------------------------------
// Debug Output
//----------------------------------------------------------

assign debug_pc = pc;

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
wire                  branch_taken;

    //----------------------------------------------------------
// External Data Memory Interface
//----------------------------------------------------------

wire [DATA_WIDTH-1:0] mem_address;
wire [DATA_WIDTH-1:0] mem_write_data;
wire                  mem_read;
wire                  mem_write;
wire [2:0]            mem_funct3;

wire [DATA_WIDTH-1:0] mem_read_data;


    //----------------------------------------------------------
// Data RAM Interface
//----------------------------------------------------------

wire                  ram_read;
wire                  ram_write;
wire [DATA_WIDTH-1:0] ram_address;
wire [DATA_WIDTH-1:0] ram_write_data;
wire [2:0]            ram_funct3;

wire [DATA_WIDTH-1:0] ram_read_data;

   //----------------------------------------------------------
// SHA-256 Interface
//
// The accelerator is not integrated yet.
// These signals are reserved for the next phase.
//----------------------------------------------------------

wire                  sha_read;
wire                  sha_write;
wire [DATA_WIDTH-1:0] sha_address;
wire [DATA_WIDTH-1:0] sha_write_data;
wire [2:0]            sha_funct3;

wire [DATA_WIDTH-1:0] sha_read_data;

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

            .next_pc        (pc_next),
    .rd_data        (rd_data),
    .alu_result     (alu_result),
    .branch_taken   (branch_taken),

    .mem_address    (mem_address),
    .mem_write_data (mem_write_data),
    .mem_read       (mem_read),
    .mem_write      (mem_write),
    .mem_funct3     (mem_funct3),

    .mem_read_data  (mem_read_data)
    );

    //----------------------------------------------------------
// Memory Interconnect
//
// Routes CPU memory transactions according to the
// memory-mapped address space.
//
// RAM:
//   0x0000_0000 - 0x0000_0FFF
//
// SHA-256:
//   0x1000_0000 - 0x1000_00FF
//----------------------------------------------------------

memory_interconnect #(
    .DATA_WIDTH(DATA_WIDTH)
) u_memory_interconnect (

    //------------------------------------------------------
    // CPU-Side Interface
    //------------------------------------------------------

    .cpu_address    (mem_address),
    .cpu_write_data (mem_write_data),
    .cpu_read       (mem_read),
    .cpu_write      (mem_write),
    .cpu_funct3     (mem_funct3),

    .cpu_read_data  (mem_read_data),

    //------------------------------------------------------
    // RAM Interface
    //------------------------------------------------------

    .ram_read       (ram_read),
    .ram_write      (ram_write),
    .ram_address    (ram_address),
    .ram_write_data (ram_write_data),
    .ram_funct3     (ram_funct3),

    .ram_read_data  (ram_read_data),

    //------------------------------------------------------
    // SHA-256 Interface
    //------------------------------------------------------

    .sha_read       (sha_read),
    .sha_write      (sha_write),
    .sha_address    (sha_address),
    .sha_write_data (sha_write_data),
    .sha_funct3     (sha_funct3),

    .sha_read_data  (sha_read_data)

);

//----------------------------------------------------------
// Data Memory
//
// Data Memory is accessed through the memory interconnect.
//----------------------------------------------------------

data_memory #(
    .DATA_WIDTH(DATA_WIDTH)
) u_data_memory (

    .clk       (clk),
    .rst       (rst),

    .mem_read  (ram_read),
    .mem_write (ram_write),

    .funct3    (ram_funct3),

    .address   (ram_address),

    .write_data(ram_write_data),

    .read_data (ram_read_data)

);

//----------------------------------------------------------
// Temporary SHA-256 Read Data
//
// The SHA-256 accelerator will be connected in a later
// integration phase. Until then, reads from the SHA region
// return zero.
//----------------------------------------------------------

assign sha_read_data = {DATA_WIDTH{1'b0}};



endmodule

`default_nettype wire