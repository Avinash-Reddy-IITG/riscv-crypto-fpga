`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : branch_unit
// Description :
//   Determines whether an RV32I conditional branch condition
//   is satisfied.
//
//   The Branch Unit receives:
//     - funct3   : Identifies the branch condition
//     - rs1_data : First register operand
//     - rs2_data : Second register operand
//
//   It produces:
//     - branch_taken : 1 when the branch condition is satisfied
//
// Supported Branch Instructions:
//     BEQ  - Branch if Equal
//     BNE  - Branch if Not Equal
//     BLT  - Branch if Less Than (signed)
//     BGE  - Branch if Greater Than or Equal (signed)
//     BLTU - Branch if Less Than (unsigned)
//     BGEU - Branch if Greater Than or Equal (unsigned)
//
// Important:
//   This module does NOT calculate the branch target address.
//   It only determines whether the branch condition is true.
//==============================================================

module branch_unit #(
    parameter DATA_WIDTH = 32
)(
    //----------------------------------------------------------
    // Instruction Function Field
    //----------------------------------------------------------

    input wire [2:0] funct3,

    //----------------------------------------------------------
    // Register Operands
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] rs1_data,
    input wire [DATA_WIDTH-1:0] rs2_data,

    //----------------------------------------------------------
    // Branch Decision
    //----------------------------------------------------------

    output reg branch_taken
);

    //----------------------------------------------------------
    // Branch Condition Logic
    //----------------------------------------------------------

    always @(*) begin

        //------------------------------------------------------
        // Safe Default
        //------------------------------------------------------

        branch_taken = 1'b0;

        //------------------------------------------------------
        // Decode Branch Type
        //------------------------------------------------------

        case (funct3)

            //--------------------------------------------------
            // BEQ
            //
            // Branch if rs1 == rs2
            //--------------------------------------------------

            3'b000: begin

                if (rs1_data == rs2_data)
                    branch_taken = 1'b1;

            end

            //--------------------------------------------------
            // BNE
            //
            // Branch if rs1 != rs2
            //--------------------------------------------------

            3'b001: begin

                if (rs1_data != rs2_data)
                    branch_taken = 1'b1;

            end

            //--------------------------------------------------
            // BLT
            //
            // Signed comparison:
            // Branch if rs1 < rs2
            //--------------------------------------------------

            3'b100: begin

                if ($signed(rs1_data) < $signed(rs2_data))
                    branch_taken = 1'b1;

            end

            //--------------------------------------------------
            // BGE
            //
            // Signed comparison:
            // Branch if rs1 >= rs2
            //--------------------------------------------------

            3'b101: begin

                if ($signed(rs1_data) >= $signed(rs2_data))
                    branch_taken = 1'b1;

            end

            //--------------------------------------------------
            // BLTU
            //
            // Unsigned comparison:
            // Branch if rs1 < rs2
            //--------------------------------------------------

            3'b110: begin

                if (rs1_data < rs2_data)
                    branch_taken = 1'b1;

            end

            //--------------------------------------------------
            // BGEU
            //
            // Unsigned comparison:
            // Branch if rs1 >= rs2
            //--------------------------------------------------

            3'b111: begin

                if (rs1_data >= rs2_data)
                    branch_taken = 1'b1;

            end

            //--------------------------------------------------
            // Unsupported funct3
            //--------------------------------------------------

            default: begin

                branch_taken = 1'b0;

            end

        endcase

    end

endmodule

`default_nettype wire