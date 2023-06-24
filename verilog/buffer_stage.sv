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

    hazard_in.pc = v.pc;
    hazard_in.rdata = v.rdata;
    hazard_in.ready = v.ready;

    v.pc0 = hazard_out.pc0;
    v.pc1 = hazard_out.pc1;
    v.instr0 = hazard_out.instr0;
    v.instr1 = hazard_out.instr1;
    v.stall = hazard_out.stall;

    if ((a.e.stall | a.m.stall | a.e.jump | a.e.fence | a.e.mret | a.e.exception | v.clear) == 1) begin
      v.instr0 = nop_instr;
      v.instr1 = nop_instr;
    end

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
