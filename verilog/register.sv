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
  
  logic [31:0] rdata1 = 0;
  logic [31:0] rdata2 = 0;

  assign register_out.rdata1 = rdata1; 
  assign register_out.rdata2 = rdata2;

  always_ff @(posedge clk) begin
    if (register_win.wren == 1) begin
      reg_file[register_win.waddr] <= register_win.wdata;
    end
    rdata1 <= reg_file[register_rin.raddr1];
    rdata2 <= reg_file[register_rin.raddr2];
  end

endmodule
