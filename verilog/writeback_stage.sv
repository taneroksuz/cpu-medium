import constants::*;
import wires::*;

module writeback_stage
(
  input logic rst,
  input logic clk,
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

    if (d.w.clear == 1) begin
      v.clear = 0;
    end

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
