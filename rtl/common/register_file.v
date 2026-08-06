`default_nettype none

//==============================================================
// Module      : register_file
// Project     : FPGA RISC-V SoC with SHA-256 Accelerator
// Description :
//   32 × 32-bit Register File for the RV32I processor.
//
// Features:
//   - Two asynchronous read ports
//   - One synchronous write port
//   - Register x0 is hardwired to zero
//   - Parameterized implementation
//
//==============================================================

module register_file #(
    parameter DATA_WIDTH = 32,
    parameter REG_COUNT  = 32,
    parameter ADDR_WIDTH = 5
)(
    input  wire                     clk,
    input  wire                     rst,

    input  wire                     reg_write,

    input  wire [ADDR_WIDTH-1:0]    rs1_addr,
    input  wire [ADDR_WIDTH-1:0]    rs2_addr,

    output wire [DATA_WIDTH-1:0]    rs1_data,
    output wire [DATA_WIDTH-1:0]    rs2_data,

    input  wire [ADDR_WIDTH-1:0]    rd_addr,
    input  wire [DATA_WIDTH-1:0]    rd_data
);

    //----------------------------------------------------------
    // Local Parameters
    //----------------------------------------------------------

    localparam [ADDR_WIDTH-1:0] ZERO_REG = {ADDR_WIDTH{1'b0}};

    //----------------------------------------------------------
    // Register Storage Array
    //----------------------------------------------------------

    reg [DATA_WIDTH-1:0] registers [0:REG_COUNT-1];

    integer i;

    //----------------------------------------------------------
    // Sequential Write Logic
    //----------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < REG_COUNT; i = i + 1)
                registers[i] <= {DATA_WIDTH{1'b0}};

        end

        else if (reg_write && (rd_addr != ZERO_REG)) begin

            registers[rd_addr] <= rd_data;

        end

    end

    //----------------------------------------------------------
    // Asynchronous Read Port 1
    //----------------------------------------------------------

    assign rs1_data =
        (rs1_addr == ZERO_REG) ?
        {DATA_WIDTH{1'b0}} :
        registers[rs1_addr];

    //----------------------------------------------------------
    // Asynchronous Read Port 2
    //----------------------------------------------------------

    assign rs2_data =
        (rs2_addr == ZERO_REG) ?
        {DATA_WIDTH{1'b0}} :
        registers[rs2_addr];

endmodule

`default_nettype wire