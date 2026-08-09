`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : control_unit
// Description :
//   Main control unit for the RV32I processor.
//
//   Decodes the instruction opcode and generates the control
//   signals required to control the processor datapath.
//
// Control Signals:
//   - RegWrite : Enable register-file write
//   - MemRead  : Enable data-memory read
//   - MemWrite : Enable data-memory write
//   - MemToReg : Select memory data for register write-back
//   - ALUSrc   : Select ALU second operand
//   - Branch   : Indicates conditional branch
//   - Jump     : Indicates jump instruction
//   - ALUOp    : Selects ALU-control operation class
//
// Target FPGA : Xilinx Artix-7 (Basys-3)
//==============================================================

module control_unit (
    //----------------------------------------------------------
    // Instruction Opcode
    //----------------------------------------------------------

    input wire [6:0] opcode,

    //----------------------------------------------------------
    // Control Outputs
    //----------------------------------------------------------

    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       MemToReg,
    output reg       ALUSrc,
    output reg       Branch,
    output reg       Jump,
    output reg [1:0] ALUOp
);

    //----------------------------------------------------------
    // Main Control Logic
    //----------------------------------------------------------

    always @(*) begin

        //------------------------------------------------------
        // Safe Default Values
        //------------------------------------------------------

        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        ALUSrc   = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        ALUOp    = 2'b00;

        //------------------------------------------------------
        // Opcode Decode
        //------------------------------------------------------

        case (opcode)

            //--------------------------------------------------
            // R-Type
            //
            // ADD, SUB, AND, OR, XOR, SLL, SRL, SRA,
            // SLT, SLTU
            //--------------------------------------------------

            `OPCODE_OP: begin

                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10;

            end

            //--------------------------------------------------
            // I-Type ALU
            //
            // ADDI, SLTI, SLTIU, XORI, ORI, ANDI,
            // SLLI, SRLI, SRAI
            //--------------------------------------------------

            `OPCODE_OP_IMM: begin

                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b10;

            end

            //--------------------------------------------------
            // Load
            //
            // LB, LH, LW, LBU, LHU
            //--------------------------------------------------

            `OPCODE_LOAD: begin

                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemToReg = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;

            end

            //--------------------------------------------------
            // Store
            //
            // SB, SH, SW
            //--------------------------------------------------

            `OPCODE_STORE: begin

                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;

            end

            //--------------------------------------------------
            // Branch
            //
            // BEQ, BNE, BLT, BGE, BLTU, BGEU
            //--------------------------------------------------

            `OPCODE_BRANCH: begin

                Branch = 1'b1;
                ALUSrc = 1'b0;
                ALUOp  = 2'b01;

            end

            //--------------------------------------------------
  // LUI
//
// rd = immediate
//
// ALU:
//     0 + immediate
//
// ALUOp = 00 forces ADD.
//--------------------------------------------------

`OPCODE_LUI: begin

    RegWrite = 1'b1;
    ALUSrc   = 1'b1;
    ALUOp    = 2'b00;

end


//--------------------------------------------------
// AUIPC
//
// rd = PC + immediate
//
// ALU:
//     PC + immediate
//
// ALUOp = 00 forces ADD.
//--------------------------------------------------

`OPCODE_AUIPC: begin

    RegWrite = 1'b1;
    ALUSrc   = 1'b1;
    ALUOp    = 2'b00;

end


            //--------------------------------------------------
            // JAL
            //--------------------------------------------------

            `OPCODE_JAL: begin

                RegWrite = 1'b1;
                Jump     = 1'b1;

            end

            //--------------------------------------------------
            // JALR
            //--------------------------------------------------

            `OPCODE_JALR: begin

                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                Jump     = 1'b1;
                ALUOp    = 2'b00;

            end

            //--------------------------------------------------
            // Unsupported Opcode
            //--------------------------------------------------

            default: begin

                // Safe defaults already assigned above.

            end

        endcase

    end

endmodule

`default_nettype wire