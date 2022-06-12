import wires::*;

module register
(
  input logic rst,
  input logic clk,
  input register_read_in_type register_rin,
  input register_write_in_type register_win,
  output register_out_type register_out
);
  timeunit 1ns;
  timeprecision 1ps;

  wire [0  : 0] wren;
  wire [31 : 0] wdata;
  wire [4  : 0] waddr;
  wire [31 : 0] rdata1;
  wire [31 : 0] rdata2;
  wire [4  : 0] raddr1;
  wire [4  : 0] raddr2;

  assign wren = register_win.wren & |(register_win.waddr);
  assign wdata = register_win.wdata;
  assign waddr = register_win.waddr;
  assign raddr1 = register_rin.raddr1;
  assign raddr2 = register_rin.raddr2;

  dram2#(
    .DATA (32),
    .ADDR (5)
  ) dram_comp(
    .clk     (clk),
    .wr      (wren),
    .wr_addr (waddr),
    .wr_data (wdata),
    .rd0_addr (raddr1),
    .rd0_data (rdata1),
    .rd1_addr (raddr2),
    .rd1_data (rdata2)
  );

  assign register_out.rdata1 = register_rin.rden1 == 1 ? rdata1 : 0; 
  assign register_out.rdata2 = register_rin.rden2 == 1 ? rdata2 : 0;

endmodule
