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

    hazard_in.pc = d.f.pc;
    hazard_in.rdata = a.f.rdata;
    hazard_in.ready = a.f.ready;
    hazard_in.clear = a.e.instr0.op.jump | a.e.instr0.op.fence | a.e.instr0.op.mret | a.e.instr0.op.exception | d.w.clear;
    hazard_in.stall = a.d.stall | a.e.stall | a.m.stall;

    v.pc0 = hazard_out.pc0;
    v.pc1 = hazard_out.pc1;
    v.instr0 = hazard_out.instr0;
    v.instr1 = hazard_out.instr1;
    v.stall = hazard_out.stall;

    rin = v;

    y.pc0 = v.pc0;
    y.pc1 = v.pc1;
    y.instr1 = v.instr0;
    y.instr0 = v.instr1;
    y.stall = v.stall;

    q.pc0 = r.pc0;
    q.pc1 = r.pc1;
    q.instr0 = r.instr0;
    q.instr1 = r.instr1;
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
