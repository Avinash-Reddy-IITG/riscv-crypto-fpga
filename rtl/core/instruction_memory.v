`default_nettype none

`include "rv32i_params.vh"

//==============================================================
// Module      : instruction_memory
// Description :
//   Read-only Instruction Memory (ROM) for the RV32I processor.
//
// Features:
//   - Parameterized data width
//   - Parameterized memory depth
//   - Asynchronous read interface
//   - Program initialization using $readmemh()
//   - Word-aligned addressing
//
// Target FPGA : Xilinx Artix-7 (Basys-3)
//==============================================================

module instruction_memory #(
    parameter DATA_WIDTH = `XLEN,
    parameter MEM_DEPTH  = `IMEM_DEPTH,
    parameter INIT_FILE  = "programs/program.hex"
)(
    //----------------------------------------------------------
    // Address Input
    //----------------------------------------------------------
    input  wire [DATA_WIDTH-1:0] address,

    //----------------------------------------------------------
    // Instruction Output
    //----------------------------------------------------------
    output wire [DATA_WIDTH-1:0] instruction
);

    //----------------------------------------------------------
    // Instruction Memory Array
    //----------------------------------------------------------
    reg [DATA_WIDTH-1:0] instruction_mem [0:MEM_DEPTH-1];

    //----------------------------------------------------------
    // Word Address
    //----------------------------------------------------------
    wire [DATA_WIDTH-3:0] word_address;

    assign word_address = address[DATA_WIDTH-1:2];

    //----------------------------------------------------------
    // Program Initialization
    //----------------------------------------------------------
    initial begin
        $readmemh(INIT_FILE, instruction_mem);
    end

    //----------------------------------------------------------
    // Asynchronous Read
    //----------------------------------------------------------
    assign instruction = instruction_mem[word_address];

endmodule

`default_nettype wire