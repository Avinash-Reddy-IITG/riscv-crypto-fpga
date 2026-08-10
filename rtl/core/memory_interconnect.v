`default_nettype none

//==============================================================
// Module      : memory_interconnect
// Project     : FPGA RISC-V SoC with SHA-256 Accelerator
// Description :
//   Memory-mapped interconnect for the RV32I SoC.
//
//   The interconnect decodes CPU addresses and routes memory
//   transactions to the appropriate memory-mapped device.
//
// Address Map:
//   0x0000_0000 - 0x0000_0FFF : Data RAM
//   0x1000_0000 - 0x1000_00FF : SHA-256 Accelerator
//   0x2000_0000 - 0x2000_00FF : Future Peripherals
//
//   Unsupported addresses return zero on reads and generate
//   no device request.
//
//==============================================================

module memory_interconnect #(
    parameter DATA_WIDTH = 32
)(
    //----------------------------------------------------------
    // CPU-Side Interface
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] cpu_address,
    input wire [DATA_WIDTH-1:0] cpu_write_data,
    input wire                  cpu_read,
    input wire                  cpu_write,
    input wire [2:0]            cpu_funct3,

    output wire [DATA_WIDTH-1:0] cpu_read_data,

    //----------------------------------------------------------
    // Data RAM Interface
    //----------------------------------------------------------

    output wire                  ram_read,
    output wire                  ram_write,
    output wire [DATA_WIDTH-1:0] ram_address,
    output wire [DATA_WIDTH-1:0] ram_write_data,
    output wire [2:0]            ram_funct3,

    input wire [DATA_WIDTH-1:0]  ram_read_data,

    //----------------------------------------------------------
    // SHA-256 Accelerator Interface
    //----------------------------------------------------------

    output wire                  sha_read,
    output wire                  sha_write,
    output wire [DATA_WIDTH-1:0] sha_address,
    output wire [DATA_WIDTH-1:0] sha_write_data,
    output wire [2:0]            sha_funct3,

    input wire [DATA_WIDTH-1:0]  sha_read_data
);

    //----------------------------------------------------------
    // Address Map
    //----------------------------------------------------------

    localparam [DATA_WIDTH-1:0] RAM_BASE =
        32'h0000_0000;

    localparam [DATA_WIDTH-1:0] RAM_END =
        32'h0000_0FFF;

    localparam [DATA_WIDTH-1:0] SHA_BASE =
        32'h1000_0000;

    localparam [DATA_WIDTH-1:0] SHA_END =
        32'h1000_00FF;

    //----------------------------------------------------------
    // Device Select Signals
    //----------------------------------------------------------

    wire ram_select;
    wire sha_select;

    assign ram_select =
        (cpu_address >= RAM_BASE) &&
        (cpu_address <= RAM_END);

    assign sha_select =
        (cpu_address >= SHA_BASE) &&
        (cpu_address <= SHA_END);

    //----------------------------------------------------------
    // RAM Request
    //----------------------------------------------------------

    assign ram_read =
        cpu_read && ram_select;

    assign ram_write =
        cpu_write && ram_select;

    assign ram_address =
        cpu_address;

    assign ram_write_data =
        cpu_write_data;

    assign ram_funct3 =
        cpu_funct3;

    //----------------------------------------------------------
    // SHA-256 Request
    //----------------------------------------------------------

    assign sha_read =
        cpu_read && sha_select;

    assign sha_write =
        cpu_write && sha_select;

    assign sha_address =
        cpu_address;

    assign sha_write_data =
        cpu_write_data;

    assign sha_funct3 =
        cpu_funct3;

    //----------------------------------------------------------
    // Read-Data Multiplexer
    //----------------------------------------------------------

    assign cpu_read_data =
        ram_select ? ram_read_data :
        sha_select ? sha_read_data :
        {DATA_WIDTH{1'b0}};

endmodule

`default_nettype wire