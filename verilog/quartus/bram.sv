import configure::*;

module bram
(
  input logic rst,
  input logic clk,
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

  logic [3 : 0][7 : 0] bram_block[0:2**bram_depth-1];

  logic [bram_depth-1 : 0] bram_waddr;
  logic [bram_depth-1 : 0] bram_raddr;

  logic [0 : 0] bram_wen;

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  initial begin
    $readmemh("bram.dat", bram_block);
  end

  assign bram_waddr = bram_addr[bram_depth+1:2];
  assign bram_raddr = bram_addr[bram_depth+1:2];

  assign bram_wen = bram_valid & |(bram_wstrb);

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

  always_ff @(posedge clk) begin

    if (bram_valid == 1) begin
      ready <= 1;
    end else begin
      ready <= 0;
    end

  end

  assign bram_rdata = rdata;
  assign bram_ready = ready;


endmodule
