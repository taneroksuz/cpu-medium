import configure::*;

module bram
(
  input logic clk,
  input logic [0   : 0] bram_wen,
  input logic [bram_depth-1 : 0] bram_waddr,
  input logic [bram_depth-1 : 0] bram_raddr,
  input logic [31  : 0] bram_wdata,
  input logic [3   : 0] bram_wstrb,
  output logic [31 : 0] bram_rdata
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [3 : 0][7 : 0] bram_block[0:2**bram_depth-1];

  logic [31 : 0] rdata;

  initial begin
    $readmemh("bram.dat", bram_block);
  end

  always_ff @(posedge clk) begin

    if (bram_wen == 1) begin

      if (bram_wstrb[0] == 1)
        bram_block[bram_waddr][0] <= bram_wdata[7:0];
      if (bram_wstrb[1] == 1)
        bram_block[bram_waddr][1] <= bram_wdata[15:8];
      if (bram_wstrb[2] == 1)
        bram_block[bram_waddr][2] <= bram_wdata[23:16];
      if (bram_wstrb[3] == 1)
        bram_block[bram_waddr][3] <= bram_wdata[31:24];

    end

    rdata <= bram_block[bram_raddr];

  end

  assign bram_rdata = rdata;


endmodule
