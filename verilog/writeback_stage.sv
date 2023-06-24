import constants::*;
import wires::*;

module writeback_stage
(
  input logic reset,
  input logic clock,
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

  writeback_reg_type r,rin;
  writeback_reg_type v;

  always_comb begin

    v = r;

    v.instr0 = d.m.instr0;
    v.instr1 = d.m.instr1;

    if (d.w.clear == 1) begin
      v.clear = 0;
    end

    register_win.wren = v.instr0.wren & |(v.instr0.waddr);
    register_win.waddr = v.instr0.waddr;
    register_win.wdata = v.instr0.wdata;

    fp_register_win.wren = v.instr0.fwren;
    fp_register_win.waddr = v.instr0.waddr;
    fp_register_win.wdata = v.instr0.fdata;

    forwarding_win.wren = v.instr0.wren;
    forwarding_win.waddr = v.instr0.waddr;
    forwarding_win.wdata = v.instr0.wdata;

    fp_forwarding_win.wren = v.instr0.fwren;
    fp_forwarding_win.waddr = v.instr0.waddr;
    fp_forwarding_win.wdata = v.instr0.fdata;

    rin = v;

    y.stall = v.stall;
    y.clear = v.clear;
  
    q.stall = r.stall;
    q.clear = r.clear;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_writeback_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
