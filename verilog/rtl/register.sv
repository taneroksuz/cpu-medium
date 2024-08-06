import wires::*;

module register (
    input logic reset,
    input logic clock,
    input register_read_in_type register0_rin,
    input register_read_in_type register1_rin,
    input register_write_in_type register0_win,
    input register_write_in_type register1_win,
    output register_out_type register0_out,
    output register_out_type register1_out
);
  timeunit 1ns; timeprecision 1ps;

  logic [31:0] reg_file[0:31] = '{default: '0};

  always_ff @(posedge clock) begin
    if (register0_win.wren == 1) begin
      reg_file[register0_win.waddr] <= register0_win.wdata;
    end
    if (register1_win.wren == 1) begin
      reg_file[register1_win.waddr] <= register1_win.wdata;
    end
  end

  assign register0_out.rdata1 = reg_file[register0_rin.raddr1];
  assign register0_out.rdata2 = reg_file[register0_rin.raddr2];
  assign register1_out.rdata1 = reg_file[register1_rin.raddr1];
  assign register1_out.rdata2 = reg_file[register1_rin.raddr2];

endmodule
