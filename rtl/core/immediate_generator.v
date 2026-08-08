`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : immediate_generator
// Description :
//   Generates the 32-bit immediate value from an RV32I
//   instruction.
//
// Supported Formats:
//   - I-Type
//   - S-Type
//   - B-Type
//   - U-Type
//   - J-Type
//
// Features:
//   - Pure combinational implementation
//   - Automatic sign extension
//   - Parameterized data width
//
// Target FPGA : Xilinx Artix-7 (Basys-3)
//==============================================================

module immediate_generator #(
    parameter DATA_WIDTH = `XLEN
)(
    //----------------------------------------------------------
    // Instruction Input
    //----------------------------------------------------------
    input  wire [DATA_WIDTH-1:0] instruction,

    //----------------------------------------------------------
    // Immediate Output
    //----------------------------------------------------------
    output reg  [DATA_WIDTH-1:0] immediate
);

    //----------------------------------------------------------
    // Internal Signals
    //----------------------------------------------------------

    wire [6:0] opcode;

    assign opcode = instruction[6:0];

    //----------------------------------------------------------
    // Immediate Generation
    //----------------------------------------------------------

    always @(*) begin

        case (opcode)

            //--------------------------------------------------
            // I-Type
            // ADDI, SLTI, XORI, ORI, ANDI
            // Loads
            // JALR
            //--------------------------------------------------

            `OPCODE_OP_IMM,
            `OPCODE_LOAD,
            `OPCODE_JALR :

                immediate = {
                    {20{instruction[31]}},
                    instruction[31:20]
                };

            //--------------------------------------------------
            // S-Type
            // Store Instructions
            //--------------------------------------------------

            `OPCODE_STORE :

                immediate = {
                    {20{instruction[31]}},
                    instruction[31:25],
                    instruction[11:7]
                };

            //--------------------------------------------------
            // B-Type
            // Branch Instructions
            //--------------------------------------------------

            `OPCODE_BRANCH :

                immediate = {
                    {19{instruction[31]}},
                    instruction[31],
                    instruction[7],
                    instruction[30:25],
                    instruction[11:8],
                    1'b0
                };

            //--------------------------------------------------
            // U-Type
            // LUI / AUIPC
            //--------------------------------------------------

            `OPCODE_LUI,
            `OPCODE_AUIPC :

                immediate = {
                    instruction[31:12],
                    12'b0
                };

            //--------------------------------------------------
            // J-Type
            // JAL
            //--------------------------------------------------

            `OPCODE_JAL :

                immediate = {
                    {11{instruction[31]}},
                    instruction[31],
                    instruction[19:12],
                    instruction[20],
                    instruction[30:21],
                    1'b0
                };

            //--------------------------------------------------
            // Default
            //--------------------------------------------------

            default :

                immediate = {DATA_WIDTH{1'b0}};

        endcase

    end

endmodule

`default_nettype wire