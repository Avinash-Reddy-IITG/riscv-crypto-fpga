`default_nettype none

//==============================================================
// Module      : fpga_top
// Project     : FPGA RISC-V SoC with SHA-256 Accelerator
// Description :
//   FPGA top-level wrapper for the RV32I processor.
//
//   Initial hardware bring-up configuration:
//
//     Clock : Basys-3 100 MHz oscillator
//     Reset : External reset input
//     LEDs  : Display the lower 8 bits of the CPU PC
//
//   The purpose of this module is to connect the verified
//   processor core to physical FPGA resources.
//
// Target FPGA : Xilinx Artix-7
// Board       : Digilent Basys-3
//==============================================================

module fpga_top #(
    parameter DATA_WIDTH = 32,
    parameter INIT_FILE  = "programs/program.hex"
)(
    //----------------------------------------------------------
    // FPGA Clock
    //----------------------------------------------------------

    input wire clk,

    //----------------------------------------------------------
    // FPGA Reset
    //----------------------------------------------------------

    input wire rst,

    //----------------------------------------------------------
    // Debug LEDs
    //----------------------------------------------------------

    output wire [7:0] led
);

    //----------------------------------------------------------
    // CPU Debug Signal
    //----------------------------------------------------------

    wire [DATA_WIDTH-1:0] debug_pc;

    //----------------------------------------------------------
    // RV32I CPU
    //----------------------------------------------------------

    rv32i_cpu #(
        .DATA_WIDTH(DATA_WIDTH),
        .INIT_FILE (INIT_FILE)
    ) u_rv32i_cpu (

        .clk      (clk),
        .rst      (rst),

        .debug_pc (debug_pc)

    );

    //----------------------------------------------------------
    // PC Debug Output
    //
    // Display the lower 8 bits of the current program counter
    // on the Basys-3 LEDs.
    //----------------------------------------------------------

    assign led = debug_pc[7:0];

endmodule

`default_nettype wire