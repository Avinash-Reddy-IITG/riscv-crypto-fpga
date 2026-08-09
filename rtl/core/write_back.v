`default_nettype none

//==============================================================
// Module      : write_back
// Project     : FPGA RISC-V SoC with SHA-256 Accelerator
// Description :
//   Selects the value that will be written back into the
//   destination register (rd).
//
//   Write-back sources:
//
//     2'b00 -> ALU result
//     2'b01 -> Data Memory result
//     2'b10 -> PC + 4
//     2'b11 -> Reserved
//
//   This module is purely combinational.
//==============================================================

module write_back #(
    parameter DATA_WIDTH = 32
)(
    //----------------------------------------------------------
    // ALU Result
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] alu_result,

    //----------------------------------------------------------
    // Data Memory Result
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] memory_data,

    //----------------------------------------------------------
    // Return Address
    //
    // Used by JAL/JALR.
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] pc_plus_4,

    //----------------------------------------------------------
    // Write-Back Source
    //
    // 00 -> ALU result
    // 01 -> Memory data
    // 10 -> PC + 4
    // 11 -> Reserved
    //----------------------------------------------------------

    input wire [1:0] wb_src,

    //----------------------------------------------------------
    // Data Written to Register File
    //----------------------------------------------------------

    output reg [DATA_WIDTH-1:0] rd_data
);

    //----------------------------------------------------------
    // Write-Back Selection Logic
    //----------------------------------------------------------

    always @(*) begin

        case (wb_src)

            //--------------------------------------------------
            // ALU Result
            //--------------------------------------------------

            2'b00: begin

                rd_data = alu_result;

            end

            //--------------------------------------------------
            // Data Memory
            //--------------------------------------------------

            2'b01: begin

                rd_data = memory_data;

            end

            //--------------------------------------------------
            // PC + 4
            //--------------------------------------------------

            2'b10: begin

                rd_data = pc_plus_4;

            end

            //--------------------------------------------------
            // Reserved
            //
            // Safe default: write zero.
            //--------------------------------------------------

            2'b11: begin

                rd_data = {DATA_WIDTH{1'b0}};

            end

            //--------------------------------------------------
            // Default Safety Case
            //--------------------------------------------------

            default: begin

                rd_data = {DATA_WIDTH{1'b0}};

            end

        endcase

    end

endmodule

`default_nettype wire