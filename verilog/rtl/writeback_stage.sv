import constants::*;
import wires::*;

module writeback_stage (
    input logic reset,
    input logic clock,
    input writeback_in_type a,
    input writeback_in_type d,
    output writeback_out_type y,
    output writeback_out_type q,
    output logic [1:0] clear
);
  timeunit 1ns; timeprecision 1ps;

  writeback_reg_type r, rin;
  writeback_reg_type v;

  always_comb begin

    v = r;

    v.calc0 = d.m.calc0;
    v.calc1 = d.m.calc1;

    rin = v;

    y.stall = v.stall;

    q.stall = r.stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_writeback_reg;
    end else begin
      r <= rin;
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      clear <= 2'b11;
    end else begin
      clear <= {1'b0, clear[1]};
    end
  end

endmodule
