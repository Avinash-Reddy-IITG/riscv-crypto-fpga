`default_nettype none

//==============================================================
// Module      : next_pc
// Project     : FPGA RISC-V SoC with SHA-256 Accelerator
// Description :
//   Selects the next Program Counter value for the RV32I core.
//
//   PC source selection:
//
//     2'b00 -> Sequential execution : PC + 4
//     2'b01 -> Conditional branch
//     2'b10 -> JAL target
//     2'b11 -> JALR target
//
//   The target addresses are calculated outside this module.
//   This module only selects the appropriate target.
//
//==============================================================

module next_pc #(
    parameter DATA_WIDTH = 32
)(
    //----------------------------------------------------------
    // Current Program Counter
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] pc,

    //----------------------------------------------------------
    // Pre-calculated PC Targets
    //----------------------------------------------------------

    input wire [DATA_WIDTH-1:0] branch_target,
    input wire [DATA_WIDTH-1:0] jal_target,
    input wire [DATA_WIDTH-1:0] jalr_target,

    //----------------------------------------------------------
    // Branch Condition
    //----------------------------------------------------------

    input wire                  branch_taken,

    //----------------------------------------------------------
    // PC Source Selection
    //
    // 00 -> PC + 4
    // 01 -> Branch
    // 10 -> JAL
    // 11 -> JALR
    //----------------------------------------------------------

    input wire [1:0]            pc_src,

    //----------------------------------------------------------
    // Next Program Counter
    //----------------------------------------------------------

    output reg [DATA_WIDTH-1:0] next_pc
);

    //----------------------------------------------------------
    // Next-PC Selection Logic
    //----------------------------------------------------------

    always @(*) begin

        case (pc_src)

            //--------------------------------------------------
            // Normal Sequential Execution
            //--------------------------------------------------

            2'b00: begin

                next_pc = pc + {{(DATA_WIDTH-3){1'b0}}, 3'b100};

            end

            //--------------------------------------------------
            // Conditional Branch
            //--------------------------------------------------

            2'b01: begin

                if (branch_taken)
                    next_pc = branch_target;
                else
                    next_pc = pc + {{(DATA_WIDTH-3){1'b0}}, 3'b100};

            end

            //--------------------------------------------------
            // JAL
            //--------------------------------------------------

            2'b10: begin

                next_pc = jal_target;

            end

            //--------------------------------------------------
            // JALR
            //--------------------------------------------------

            2'b11: begin

                next_pc = jalr_target;

            end

            //--------------------------------------------------
            // Default
            //
            // This should never be reached because pc_src
            // contains only four possible 2-bit values.
            //--------------------------------------------------

            default: begin

                next_pc = pc + {{(DATA_WIDTH-3){1'b0}}, 3'b100};

            end

        endcase

    end

endmodule

`default_nettype wire