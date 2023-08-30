import configure::*;

module bram
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] bram_valid,
  input logic [0   : 0] bram_instr,
  input logic [31  : 0] bram_addr,
  input logic [31  : 0] bram_wdata,
  input logic [3   : 0] bram_wstrb,
  output logic [31 : 0] bram_rdata,
  output logic [0  : 0] bram_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(bram_depth-1);

  logic [31 : 0] bram_block[0:bram_depth-1];

  logic [31 : 0] count = 0;

  initial begin
    $readmemh("bram.dat", bram_block);
  end

  always_ff @(posedge clock) begin

    bram_rdata <= 0;
    bram_ready <= 0;

    if (bram_valid == 1) begin

      if (count == bram_cycle) begin

        if (bram_wstrb[0] == 1)
          bram_block[bram_addr[(depth+1):2]][7:0] <= bram_wdata[7:0];
        if (bram_wstrb[1] == 1)
          bram_block[bram_addr[(depth+1):2]][15:8] <= bram_wdata[15:8];
        if (bram_wstrb[2] == 1)
          bram_block[bram_addr[(depth+1):2]][23:16] <= bram_wdata[23:16];
        if (bram_wstrb[3] == 1)
          bram_block[bram_addr[(depth+1):2]][31:24] <= bram_wdata[31:24];

        bram_rdata <= bram_block[bram_addr[(depth+1):2]];
        bram_ready <= 1;

        count <= 0;

      end else begin

        count <= count + 1;

      end

    end

  end

endmodule
