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

  assign register_out.rdata1 = register_rin.rden1 == 1 ? reg_file[register_rin.raddr1] : 0; 
  assign register_out.rdata2 = register_rin.rden2 == 1 ? reg_file[register_rin.raddr2] : 0;

  always_ff @(posedge clk) begin
    if (register_win.wren == 1) begin
      reg_file[register_win.waddr] <= register_win.wdata;
    end
  end

endmodule
