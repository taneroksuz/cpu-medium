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

  logic [31:0] reg_file[0:31] = '{default:'0};
  
  logic [4:0] raddr1 = 0;
  logic [4:0] raddr2 = 0;

  always_ff @(posedge clk) begin
    raddr1 <= register_rin.raddr1;
    raddr2 <= register_rin.raddr2;
    if (register_win.wren == 1) begin
      reg_file[register_win.waddr] <= register_win.wdata;
    end
  end

  assign register_out.rdata1 = reg_file[raddr1];
  assign register_out.rdata2 = reg_file[raddr2];

endmodule
