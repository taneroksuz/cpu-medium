import configure::*;

module sram_memory (
    input          CLOCK,
    input          SRAM_CE_n,
    input          SRAM_WE_n,
    input          SRAM_OE_n,
    input          SRAM_UB_n,
    input          SRAM_LB_n,
    inout [15 : 0] SRAM_D,
    input [17 : 0] SRAM_A
);
  timeunit 1ns; timeprecision 1ps;

  localparam sram_depth = 32'h40000;

  logic [15 : 0] sram_block[0:sram_depth-1];

  logic [15 : 0] sram_rdata;

  always_ff @(posedge CLOCK) begin

    if (SRAM_CE_n == 0) begin

      if (SRAM_WE_n == 0) begin

        if (SRAM_LB_n == 0)
          sram_block[SRAM_A][7:0] <= SRAM_D[7:0];
        if (SRAM_UB_n == 0)
          sram_block[SRAM_A][15:8] <= SRAM_D[15:8];

      end else if (SRAM_OE_n == 0) begin

        sram_rdata <= sram_block[SRAM_A];

      end

    end

  end

  assign SRAM_D = (SRAM_CE_n == 0 && SRAM_OE_n == 0) ? sram_rdata : 16'bz;

endmodule