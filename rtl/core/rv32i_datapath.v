`default_nettype none

`include "../common/rv32i_params.vh"
`include "../common/rv32i_defs.vh"

//==============================================================
// Module      : rv32i_datapath
// Project     : FPGA RISC-V SoC with SHA-256 Accelerator
//
// Description :
//   Integrated single-cycle RV32I datapath.
//
//   This module connects the previously verified processor
//   blocks:
//
//     - Register File
//     - Immediate Generator
//     - ALU
//     - Branch Unit
//     - Data Memory
//     - Next-PC Unit
//     - Write-Back Unit
//
//   The Main Control Unit and ALU Control Unit are external
//   to this module. Their control signals are supplied as
//   inputs.
//
//==============================================================

module rv32i_datapath #(
    parameter DATA_WIDTH = 32
)(
    //----------------------------------------------------------
    // Clock and Reset
    //----------------------------------------------------------

    input wire                  clk,
    input wire                  rst,

    //----------------------------------------------------------
    // Current PC and Instruction
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] pc,
    input wire [DATA_WIDTH-1:0] instruction,

    //----------------------------------------------------------
    // Main Control Signals
    //----------------------------------------------------------

    input wire                  RegWrite,
    input wire                  MemRead,
    input wire                  MemWrite,
    input wire                  MemToReg,
    input wire                  ALUSrc,
    input wire                  Branch,
    input wire                  Jump,
    input wire [1:0]            ALUOp,

    //----------------------------------------------------------
    // ALU Control
    //----------------------------------------------------------

    input wire [3:0]            alu_control,

    //----------------------------------------------------------
    // Datapath Outputs
    //----------------------------------------------------------

    //----------------------------------------------------------
// Datapath Outputs
//----------------------------------------------------------

output wire [DATA_WIDTH-1:0] next_pc,
output wire [DATA_WIDTH-1:0] rd_data,
output wire [DATA_WIDTH-1:0] alu_result,
output wire                  branch_taken,

//----------------------------------------------------------
// External Memory Interface
//----------------------------------------------------------

output wire [DATA_WIDTH-1:0] mem_address,
output wire [DATA_WIDTH-1:0] mem_write_data,
output wire                  mem_read,
output wire                  mem_write,
output wire [2:0]            mem_funct3,

input wire  [DATA_WIDTH-1:0] mem_read_data
);

    //==========================================================
    // 1. Instruction Field Extraction
    //==========================================================

    wire [6:0] opcode;
    wire [4:0] rd_addr;
    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode   = instruction[6:0];
    assign rd_addr  = instruction[11:7];
    assign funct3   = instruction[14:12];
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign funct7   = instruction[31:25];


    //==========================================================
    // 2. Register File
    //==========================================================

    wire [DATA_WIDTH-1:0] rs1_data;
    wire [DATA_WIDTH-1:0] rs2_data;

    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_COUNT (32),
        .ADDR_WIDTH(5)
    ) u_register_file (

        .clk       (clk),
        .rst       (rst),

        .reg_write (RegWrite),

        .rs1_addr  (rs1_addr),
        .rs2_addr  (rs2_addr),

        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data),

        .rd_addr   (rd_addr),
        .rd_data   (rd_data)

    );


    //==========================================================
    // 3. Immediate Generator
    //==========================================================

    wire [DATA_WIDTH-1:0] immediate;

    immediate_generator #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_immediate_generator (

        .instruction(instruction),
        .immediate  (immediate)

    );


    //==========================================================
    // 4. ALU Operand-A Selection
    //
    // Normal instruction:
    //     ALU A = rs1_data
    //
    // AUIPC:
    //     ALU A = PC
    //
    // LUI:
    //     ALU A = 0
    //
    // Encoding:
    //
    //     00 -> rs1_data
    //     01 -> PC
    //     10 -> zero
    //==========================================================

    reg [1:0] alu_a_src;

    reg [DATA_WIDTH-1:0] alu_operand_a;

    always @(*) begin

        //------------------------------------------------------
        // Select ALU-A source
        //------------------------------------------------------

        if (opcode == `OPCODE_AUIPC) begin

            alu_a_src = 2'b01;

        end

        else if (opcode == `OPCODE_LUI) begin

            alu_a_src = 2'b10;

        end

        else begin

            alu_a_src = 2'b00;

        end


        //------------------------------------------------------
        // ALU-A MUX
        //------------------------------------------------------

        case (alu_a_src)

            2'b00: begin

                alu_operand_a = rs1_data;

            end

            2'b01: begin

                alu_operand_a = pc;

            end

            2'b10: begin

                alu_operand_a = {DATA_WIDTH{1'b0}};

            end

            default: begin

                alu_operand_a = {DATA_WIDTH{1'b0}};

            end

        endcase

    end


    //==========================================================
    // 5. ALU Operand-B Selection
    //
    // ALUSrc = 0 -> rs2_data
    // ALUSrc = 1 -> immediate
    //==========================================================

    wire [DATA_WIDTH-1:0] alu_operand_b;

    assign alu_operand_b =
        ALUSrc ? immediate : rs2_data;


    //==========================================================
    // 6. ALU
    //==========================================================

    wire alu_zero;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_alu (

        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),

        .alu_op   (alu_control),

        .result   (alu_result),
        .zero     (alu_zero)

    );

    //----------------------------------------------------------
// External Memory Interface
//----------------------------------------------------------

// ALU result is the effective address for load/store
assign mem_address = alu_result;

// Store data comes from rs2
assign mem_write_data = rs2_data;

// Memory control signals come from the main control unit
assign mem_read  = MemRead;
assign mem_write = MemWrite;

// funct3 determines byte/halfword/word operation
assign mem_funct3 = instruction[14:12];





    //==========================================================
    // 8. Branch Unit
    //
    // The Branch Unit only evaluates the branch condition.
    //
    // It does NOT determine whether the current instruction
    // is a branch. The PC-selection logic handles that using
    // the opcode.
    //==========================================================

    wire branch_condition;

    branch_unit #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_branch_unit (

        .funct3      (funct3),

        .rs1_data    (rs1_data),
        .rs2_data    (rs2_data),

        .branch_taken(branch_condition)

    );

    assign branch_taken = branch_condition;


    //==========================================================
    // 9. PC + 4
    //
    // Used by:
    //
    //   - Normal sequential execution
    //   - JAL return address
    //   - JALR return address
    //==========================================================

    wire [DATA_WIDTH-1:0] pc_plus_4;

    assign pc_plus_4 =
        pc + {{(DATA_WIDTH-3){1'b0}}, 3'b100};


    //==========================================================
    // 10. Branch Target
    //
    // Branch target:
    //
    //     PC + B-type immediate
    //
    // The Immediate Generator automatically provides the
    // correct B-type immediate for branch instructions.
    //==========================================================

    wire [DATA_WIDTH-1:0] branch_target;

    assign branch_target =
        pc + immediate;


    //==========================================================
    // 11. JAL Target
    //
    // JAL target:
    //
    //     PC + J-type immediate
    //==========================================================

    wire [DATA_WIDTH-1:0] jal_target;

    assign jal_target =
        pc + immediate;


    //==========================================================
    // 12. JALR Target
    //
    // JALR target:
    //
    //     rs1 + I-type immediate
    //
    // RISC-V requires bit 0 of the resulting address to be
    // cleared.
    //==========================================================

    wire [DATA_WIDTH-1:0] jalr_target_raw;

    wire [DATA_WIDTH-1:0] jalr_target;

    assign jalr_target_raw =
        rs1_data + immediate;

    assign jalr_target =
        jalr_target_raw &
        {{(DATA_WIDTH-1){1'b1}}, 1'b0};


    //==========================================================
    // 13. PC Source Selection
    //
    //     00 -> PC + 4
    //     01 -> Conditional Branch
    //     10 -> JAL
    //     11 -> JALR
    //
    // The Main Control Unit provides Branch and Jump, but
    // does not distinguish JAL from JALR. The opcode provides
    // that distinction here.
    //==========================================================

    reg [1:0] pc_src;

    always @(*) begin

        if (opcode == `OPCODE_BRANCH) begin

            pc_src = 2'b01;

        end

        else if (opcode == `OPCODE_JAL) begin

            pc_src = 2'b10;

        end

        else if (opcode == `OPCODE_JALR) begin

            pc_src = 2'b11;

        end

        else begin

            pc_src = 2'b00;

        end

    end


    //==========================================================
    // 14. Next-PC Unit
    //==========================================================

    next_pc #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_next_pc (

        .pc           (pc),

        .branch_target(branch_target),
        .jal_target   (jal_target),
        .jalr_target  (jalr_target),

        .branch_taken (branch_taken),

        .pc_src       (pc_src),

        .next_pc      (next_pc)

    );


    //==========================================================
    // 15. Write-Back Source Selection
    //
    //     00 -> ALU result
    //     01 -> Data Memory
    //     10 -> PC + 4
    //
    // Priority:
    //
    //     MemToReg
    //         >
    //       Jump
    //         >
    //        ALU
    //
    // Loads use memory data.
    // JAL/JALR use PC + 4.
    // All other register-writing instructions use ALU result.
    //==========================================================

    reg [1:0] wb_src;

    always @(*) begin

        if (MemToReg) begin

            wb_src = 2'b01;

        end

        else if (Jump) begin

            wb_src = 2'b10;

        end

        else begin

            wb_src = 2'b00;

        end

    end


    //==========================================================
    // 16. Write-Back Unit
    //==========================================================

    write_back #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_write_back (

        .alu_result (alu_result),
        .memory_data(mem_read_data),
        .pc_plus_4  (pc_plus_4),

        .wb_src     (wb_src),

        .rd_data    (rd_data)

    );

endmodule

`default_nettype wire