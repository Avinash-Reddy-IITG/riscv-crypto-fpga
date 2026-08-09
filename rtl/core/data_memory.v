`default_nettype none

`include "rv32i_params.vh"
`include "rv32i_defs.vh"

//==============================================================
// Module      : data_memory
// Description :
//   Byte-addressable data memory for the RV32I processor.
//
//   Supported Loads:
//     LB
//     LBU
//     LH
//     LHU
//     LW
//
//   Supported Stores:
//     SB
//     SH
//     SW
//
//   Memory format:
//     - Byte addressable
//     - Little endian
//     - 32-bit data path
//
//==============================================================

module data_memory #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10
)(
    //----------------------------------------------------------
    // Clock and Reset
    //----------------------------------------------------------

    input wire                  clk,
    input wire                  rst,

    //----------------------------------------------------------
    // Memory Control
    //----------------------------------------------------------

    input wire                  mem_read,
    input wire                  mem_write,

    //----------------------------------------------------------
    // Instruction Function Field
    //----------------------------------------------------------

    input wire [2:0]            funct3,

    //----------------------------------------------------------
    // Address
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] address,

    //----------------------------------------------------------
    // Write Data
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] write_data,

    //----------------------------------------------------------
    // Read Data
    //----------------------------------------------------------

    output reg [DATA_WIDTH-1:0] read_data
);

    //----------------------------------------------------------
    // Memory Size
    //
    // One memory location stores one byte.
    //----------------------------------------------------------

    localparam MEMORY_SIZE = (1 << ADDR_WIDTH);

    //----------------------------------------------------------
    // Byte-Addressable Memory
    //----------------------------------------------------------

    reg [7:0] memory [0:MEMORY_SIZE-1];

    integer i;

    //----------------------------------------------------------
    // Sequential Write Logic
    //----------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            //--------------------------------------------------
            // Clear Memory
            //--------------------------------------------------

            for (i = 0; i < MEMORY_SIZE; i = i + 1) begin

                memory[i] <= 8'b0;

            end

        end

        else if (mem_write) begin

            //--------------------------------------------------
            // Store Instruction Decode
            //--------------------------------------------------

            case (funct3)

                //--------------------------------------------------
                // SB - Store Byte
                //
                // Store lowest 8 bits of write_data.
                //--------------------------------------------------

                3'b000: begin

                    memory[address[ADDR_WIDTH-1:0]]
                        <= write_data[7:0];

                end

                //--------------------------------------------------
                // SH - Store Halfword
                //
                // Little endian:
                //
                // address     -> bits [7:0]
                // address + 1 -> bits [15:8]
                //--------------------------------------------------

                3'b001: begin

                    memory[address[ADDR_WIDTH-1:0]]
                        <= write_data[7:0];

                    memory[address[ADDR_WIDTH-1:0] + 1]
                        <= write_data[15:8];

                end

                //--------------------------------------------------
                // SW - Store Word
                //
                // Little endian:
                //
                // address     -> bits [7:0]
                // address + 1 -> bits [15:8]
                // address + 2 -> bits [23:16]
                // address + 3 -> bits [31:24]
                //--------------------------------------------------

                3'b010: begin

                    memory[address[ADDR_WIDTH-1:0]]
                        <= write_data[7:0];

                    memory[address[ADDR_WIDTH-1:0] + 1]
                        <= write_data[15:8];

                    memory[address[ADDR_WIDTH-1:0] + 2]
                        <= write_data[23:16];

                    memory[address[ADDR_WIDTH-1:0] + 3]
                        <= write_data[31:24];

                end

                //--------------------------------------------------
                // Unsupported Store
                //--------------------------------------------------

                default: begin

                    // No write
                    // LBU/LHU are load-only instructions.

                end

            endcase

        end

    end

    //----------------------------------------------------------
    // Combinational Read Logic
    //----------------------------------------------------------

    always @(*) begin

        //------------------------------------------------------
        // Default
        //------------------------------------------------------

        read_data = {DATA_WIDTH{1'b0}};

        //------------------------------------------------------
        // Perform Read Only When Enabled
        //------------------------------------------------------

        if (mem_read) begin

            case (funct3)

                //--------------------------------------------------
                // LB - Load Byte, Signed
                //
                // Sign extend 8-bit value to 32 bits.
                //--------------------------------------------------

                3'b000: begin

                    read_data = {
                        {24{memory[address[ADDR_WIDTH-1:0]][7]}},
                        memory[address[ADDR_WIDTH-1:0]]
                    };

                end

                //--------------------------------------------------
                // LH - Load Halfword, Signed
                //
                // Sign extend 16-bit value to 32 bits.
                //--------------------------------------------------

                3'b001: begin

                    read_data = {
                        {16{memory[address[ADDR_WIDTH-1:0] + 1][7]}},
                        memory[address[ADDR_WIDTH-1:0] + 1],
                        memory[address[ADDR_WIDTH-1:0]]
                    };

                end

                //--------------------------------------------------
                // LW - Load Word
                //
                // Reconstruct 32-bit little-endian word.
                //--------------------------------------------------

                3'b010: begin

                    read_data = {
                        memory[address[ADDR_WIDTH-1:0] + 3],
                        memory[address[ADDR_WIDTH-1:0] + 2],
                        memory[address[ADDR_WIDTH-1:0] + 1],
                        memory[address[ADDR_WIDTH-1:0]]
                    };

                end

                //--------------------------------------------------
                // LBU - Load Byte, Unsigned
                //
                // Zero extend 8-bit value to 32 bits.
                //--------------------------------------------------

                3'b100: begin

                    read_data = {
                        24'b0,
                        memory[address[ADDR_WIDTH-1:0]]
                    };

                end

                //--------------------------------------------------
                // LHU - Load Halfword, Unsigned
                //
                // Zero extend 16-bit value to 32 bits.
                //--------------------------------------------------

                3'b101: begin

                    read_data = {
                        16'b0,
                        memory[address[ADDR_WIDTH-1:0] + 1],
                        memory[address[ADDR_WIDTH-1:0]]
                    };

                end

                //--------------------------------------------------
                // Unsupported Load
                //--------------------------------------------------

                default: begin

                    read_data = {DATA_WIDTH{1'b0}};

                end

            endcase

        end

    end

endmodule

`default_nettype wire