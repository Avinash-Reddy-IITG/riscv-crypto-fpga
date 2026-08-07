`default_nettype none

`include "../common/rv32i_defs.vh"

//==============================================================
// Module      : alu
// Description :
//   Arithmetic Logic Unit (ALU) for the RV32I processor.
//
// Features:
//   - Parameterized data width
//   - Pure combinational implementation
//   - Arithmetic operations
//   - Logical operations
//   - Shift operations
//   - Comparison operations
//   - Zero flag generation
//
// Supported Operations:
//   - ADD
//   - SUB
//   - AND
//   - OR
//   - XOR
//   - SLL
//   - SRL
//   - SRA
//   - SLT
//   - SLTU
//   - PASS_B
//
// Target FPGA : Xilinx Artix-7 (Basys-3)
//==============================================================

module alu #(
    parameter DATA_WIDTH = 32
)(
    input  wire [DATA_WIDTH-1:0] operand_a,
    input  wire [DATA_WIDTH-1:0] operand_b,

    input  wire [3:0] alu_op,

    output reg  [DATA_WIDTH-1:0] result,
    output wire                  zero
);

    //----------------------------------------------------------
    // ALU Combinational Logic
    //----------------------------------------------------------

    always @(*) begin

        // Default assignment
        result = {DATA_WIDTH{1'b0}};

        case (alu_op)

            //--------------------------------------------------
            // Arithmetic Operations
            //--------------------------------------------------

            `ALU_ADD:
                result = operand_a + operand_b;

            `ALU_SUB:
                result = operand_a - operand_b;

            //--------------------------------------------------
            // Logical Operations
            //--------------------------------------------------

            `ALU_AND:
                result = operand_a & operand_b;

            `ALU_OR:
                result = operand_a | operand_b;

            `ALU_XOR:
                result = operand_a ^ operand_b;

            //--------------------------------------------------
            // Shift Operations
            //--------------------------------------------------

            `ALU_SLL:
                result = operand_a << operand_b[4:0];

            `ALU_SRL:
                result = operand_a >> operand_b[4:0];

            `ALU_SRA:
                result = $signed(operand_a) >>> operand_b[4:0];

            //--------------------------------------------------
            // Comparison Operations
            //--------------------------------------------------

            `ALU_SLT:
                result = ($signed(operand_a) < $signed(operand_b))
                         ? 32'd1
                         : 32'd0;

            `ALU_SLTU:
                result = (operand_a < operand_b)
                         ? 32'd1
                         : 32'd0;

            //--------------------------------------------------
            // Pass Through
            //--------------------------------------------------

            `ALU_PASS_B:
                result = operand_b;

            //--------------------------------------------------
            // Default
            //--------------------------------------------------

            default:
                result = {DATA_WIDTH{1'b0}};

        endcase

    end

    //----------------------------------------------------------
    // Zero Flag
    //----------------------------------------------------------

    assign zero = (result == {DATA_WIDTH{1'b0}});

endmodule

`default_nettype wire