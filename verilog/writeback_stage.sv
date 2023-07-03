import constants::*;
import wires::*;

module writeback_stage
(
  input logic reset,
  input logic clock,
  output register_write_in_type register0_win,
  output register_write_in_type register1_win,
  output fp_register_write_in_type fp_register_win,
  output forwarding_writeback_in_type forwarding0_win,
  output forwarding_writeback_in_type forwarding1_win,
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

    v.calc0 = d.m.calc0;
    v.calc1 = d.m.calc1;

    if (d.w.clear == 1) begin
      v.clear = 0;
    end

    register0_win.wren = v.calc0.op.wren & |(v.calc0.waddr);
    register0_win.waddr = v.calc0.waddr;
    register0_win.wdata = v.calc0.wdata;

    register1_win.wren = v.calc1.op.wren & |(v.calc1.waddr);
    register1_win.waddr = v.calc1.waddr;
    register1_win.wdata = v.calc1.wdata;

    fp_register_win.wren = v.calc0.op.fwren;
    fp_register_win.waddr = v.calc0.waddr;
    fp_register_win.wdata = v.calc0.fdata;

    forwarding0_win.wren = v.calc0.op.wren;
    forwarding0_win.waddr = v.calc0.waddr;
    forwarding0_win.wdata = v.calc0.wdata;

    forwarding1_win.wren = v.calc1.op.wren;
    forwarding1_win.waddr = v.calc1.waddr;
    forwarding1_win.wdata = v.calc1.wdata;

    fp_forwarding_win.wren = v.calc0.op.fwren;
    fp_forwarding_win.waddr = v.calc0.waddr;
    fp_forwarding_win.wdata = v.calc0.fdata;

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
