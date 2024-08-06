import constants::*;
import wires::*;

module writeback_stage (
    input logic reset,
    input logic clock,
    input writeback_in_type a,
    input writeback_in_type d,
    output writeback_out_type y,
    output writeback_out_type q
);
  timeunit 1ns; timeprecision 1ps;

  writeback_reg_type r, rin;
  writeback_reg_type v;

  always_comb begin

    v = r;

    v.calc0 = d.m.calc0;
    v.calc1 = d.m.calc1;

    if (d.w.clear == 1) begin
      v.clear = 0;
    end

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
