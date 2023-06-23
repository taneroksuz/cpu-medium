import constants::*;
import wires::*;
import functions::*;
import fp_wire::*;

module buffer_stage
(
  input logic reset,
  input logic clock,
  input hazard_out_type hazard_out,
  output hazard_in_type hazard_in,
  input csr_out_type csr_out,
  input bp_out_type bp_out,
  input buffer_in_type a,
  input buffer_in_type d,
  output buffer_out_type y,
  output buffer_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  buffer_reg_type r,rin;
  buffer_reg_type v;

  always_comb begin

    v = r;

    v.pc = d.f.pc;
    v.rdata = a.f.rdata;
    v.ready = a.f.ready;

    v.instr = nop_instr;

    if ((v.stall | a.e.stall | a.m.stall | a.e.jump | a.e.fence | a.e.mret | a.e.exception | v.clear) == 1) begin
      v.instr = nop_instr;
    end

    rin = v;

    y.pc = v.pc;
    y.instr = v.instr;
    y.stall = v.stall;

    q.pc = r.pc;
    q.instr = r.instr;
    q.stall = r.stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_buffer_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
