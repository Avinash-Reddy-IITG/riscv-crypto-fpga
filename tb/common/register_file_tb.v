`timescale 1ns/1ps
`default_nettype none

//==============================================================
// Module      : register_file_tb
// Project     : FPGA RISC-V SoC with SHA-256 Accelerator
// Description :
//   Self-checking testbench for the RV32I Register File.
//
// Features Tested:
//   - Reset
//   - x0 protection
//   - Single register writes
//   - Single register reads
//   - Dual read ports
//   - Highest register (x31)
//   - Write disable
//   - Consecutive writes
//
//==============================================================

module register_file_tb;

//--------------------------------------------------------------
// Parameters
//--------------------------------------------------------------

parameter DATA_WIDTH = 32;
parameter REG_COUNT  = 32;
parameter ADDR_WIDTH = 5;

//--------------------------------------------------------------
// DUT Signals
//--------------------------------------------------------------

reg clk;
reg rst;

reg reg_write;

reg [ADDR_WIDTH-1:0] rs1_addr;
reg [ADDR_WIDTH-1:0] rs2_addr;
reg [ADDR_WIDTH-1:0] rd_addr;

reg [DATA_WIDTH-1:0] rd_data;

wire [DATA_WIDTH-1:0] rs1_data;
wire [DATA_WIDTH-1:0] rs2_data;

//--------------------------------------------------------------
// Test Variables
//--------------------------------------------------------------

integer errors;

//--------------------------------------------------------------
// Device Under Test
//--------------------------------------------------------------

register_file DUT (

    .clk(clk),
    .rst(rst),

    .reg_write(reg_write),

    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),

    .rs1_data(rs1_data),
    .rs2_data(rs2_data),

    .rd_addr(rd_addr),
    .rd_data(rd_data)

);

//--------------------------------------------------------------
// Clock Generation (100 MHz)
//--------------------------------------------------------------

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

//--------------------------------------------------------------
// Waveform Dump
//--------------------------------------------------------------

initial begin
    $dumpfile("register_file.vcd");
    $dumpvars(0, register_file_tb);
end

//--------------------------------------------------------------
// TASK : Reset DUT
//--------------------------------------------------------------

task reset_dut;
begin

    $display("\n=================================================");
    $display("[%0t] Resetting DUT...", $time);
    $display("=================================================\n");

    rst       = 1'b1;
    reg_write = 1'b0;

    rs1_addr  = 5'd0;
    rs2_addr  = 5'd0;

    rd_addr   = 5'd0;
    rd_data   = 32'd0;

    @(posedge clk);
    @(posedge clk);

    rst = 1'b0;

    @(posedge clk);

    $display("[%0t] Reset Complete\n",$time);

end
endtask

//--------------------------------------------------------------
// TASK : Write Register
//--------------------------------------------------------------

task write_reg;

    input [ADDR_WIDTH-1:0] addr;
    input [DATA_WIDTH-1:0] data;

begin

    $display("[%0t] WRITE : x%0d <= 0x%08h",
             $time, addr, data);

    rd_addr   = addr;
    rd_data   = data;
    reg_write = 1'b1;

    @(posedge clk);
    @(posedge clk);
    reg_write = 1'b0;

end

endtask

//--------------------------------------------------------------
// TASK : Check Register (Read Port 1)
//--------------------------------------------------------------

task check_reg;

    input [ADDR_WIDTH-1:0] addr;
    input [DATA_WIDTH-1:0] expected;

begin

    rs1_addr = addr;

    #1;

    if(rs1_data !== expected) begin

        $display("[FAIL] x%0d Expected = %h Got = %h",
                  addr,
                  expected,
                  rs1_data);

        errors = errors + 1;

    end

    else begin

        $display("[PASS] x%0d = %h",
                  addr,
                  rs1_data);

    end

end

endtask

//--------------------------------------------------------------
// TASK : Check Register (Read Port 2)
//--------------------------------------------------------------

task check_reg_rs2;

    input [ADDR_WIDTH-1:0] addr;
    input [DATA_WIDTH-1:0] expected;

begin

    rs2_addr = addr;

    #1;

    if(rs2_data !== expected) begin

        $display("[FAIL] x%0d Expected = %h Got = %h",
                  addr,
                  expected,
                  rs2_data);

        errors = errors + 1;

    end

    else begin

        $display("[PASS] x%0d = %h",
                  addr,
                  rs2_data);

    end

end

endtask

//--------------------------------------------------------------
// TASK : Dual Read Verification
//--------------------------------------------------------------

task check_dual_read;

    input [4:0] addr1;
    input [31:0] expected1;

    input [4:0] addr2;
    input [31:0] expected2;

begin

    rs1_addr = addr1;
    rs2_addr = addr2;

    #1;

    if(rs1_data !== expected1) begin

        $display("[FAIL] RS1");

        errors = errors + 1;

    end

    if(rs2_data !== expected2) begin

        $display("[FAIL] RS2");

        errors = errors + 1;

    end

    if((rs1_data === expected1) &&
       (rs2_data === expected2))

        $display("[PASS] Dual Read Successful");

end

endtask

//--------------------------------------------------------------
// Main Test Sequence
//--------------------------------------------------------------

initial begin

    errors = 0;

    //----------------------------------------------------------
    // Reset
    //----------------------------------------------------------

    reset_dut();

    //----------------------------------------------------------
    // Test x0
    //----------------------------------------------------------

    $display("\n---- Test : x0 Always Zero ----");

    check_reg(0,32'h00000000);

    //----------------------------------------------------------
    // Write x5
    //----------------------------------------------------------

    $display("\n---- Test : Write x5 ----");

    write_reg(5,32'hDEADBEEF);

    check_reg(5,32'hDEADBEEF);

    //----------------------------------------------------------
    // Attempt Write to x0
    //----------------------------------------------------------

    $display("\n---- Test : x0 Protection ----");

    write_reg(0,32'hFFFFFFFF);

    check_reg(0,32'h00000000);

    //----------------------------------------------------------
    // Highest Register
    //----------------------------------------------------------

    $display("\n---- Test : x31 ----");

    write_reg(31,32'h12345678);

    check_reg(31,32'h12345678);

    //----------------------------------------------------------
    // Consecutive Writes
    //----------------------------------------------------------

    $display("\n---- Test : Consecutive Writes ----");

    write_reg(10,32'hAAAAAAAA);

    write_reg(20,32'h55555555);

    check_reg(10,32'hAAAAAAAA);

    check_reg(20,32'h55555555);

    //----------------------------------------------------------
    // Read Port 2
    //----------------------------------------------------------

    $display("\n---- Test : Read Port 2 ----");

    check_reg_rs2(10,32'hAAAAAAAA);

    //----------------------------------------------------------
    // Dual Read
    //----------------------------------------------------------

    $display("\n---- Test : Dual Read ----");

    check_dual_read(

        10,
        32'hAAAAAAAA,

        20,
        32'h55555555

    );

    //----------------------------------------------------------
    // Write Disable
    //----------------------------------------------------------

    $display("\n---- Test : Write Disable ----");

    rd_addr = 8;
    rd_data = 32'hFFFFFFFF;

    reg_write = 1'b0;

    @(posedge clk);

    check_reg(8,32'h00000000);

    //----------------------------------------------------------
    // Simulation Summary
    //----------------------------------------------------------

    $display("\n==============================================");

    if(errors == 0)

        $display(" ALL TESTS PASSED ");

    else

        $display(" %0d TEST(S) FAILED ",errors);

    $display("==============================================");

    $finish;

end

endmodule

`default_nettype wire