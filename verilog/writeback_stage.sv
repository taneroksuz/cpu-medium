import constants::*;
import wires::*;

module writeback_stage
(
  input logic rst,
  input logic clk,
  output register_write_in_type register_win,
  output fp_register_write_in_type fp_register_win,
  output forwarding_writeback_in_type forwarding_win,
  output fp_forwarding_writeback_in_type fp_forwarding_win,
  input writeback_in_type a,
  input writeback_in_type d,
  output writeback_out_type y,
  output writeback_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  writeback_reg_type r,rin = init_writeback_reg;
  writeback_reg_type v = init_writeback_reg;

  always_comb begin

    v = r;
    v.wren = d.m.wren;
    v.fwren = d.m.fwren;
    v.waddr = d.m.waddr;
    v.wdata = d.m.wdata;
    v.fdata = d.m.fdata;

    if (d.w.clear == 1) begin
      v.clear = 0;
    end

    register_win.wren = v.wren & |(v.waddr);
    register_win.waddr = v.waddr;
    register_win.wdata = v.wdata;

    fp_register_win.wren = v.fwren;
    fp_register_win.waddr = v.waddr;
    fp_register_win.wdata = v.fdata;

    forwarding_win.wren = v.wren;
    forwarding_win.waddr = v.waddr;
    forwarding_win.wdata = v.wdata;

    fp_forwarding_win.wren = v.fwren;
    fp_forwarding_win.waddr = v.waddr;
    fp_forwarding_win.wdata = v.fdata;

    rin = v;

    y.stall = v.stall;
    y.clear = v.clear;
  
    q.stall = r.stall;
    q.clear = r.clear;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_writeback_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
