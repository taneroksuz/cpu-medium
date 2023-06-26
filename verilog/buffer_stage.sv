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
    hazard_in.clear = csr_out.trap | csr_out.mret | bp_out.pred_branch | bp_out.pred_miss | bp_out.pred_return | d.e.instr0.op.jump | d.m.instr0.op.fence | d.w.clear;
    hazard_in.stall = a.d.stall | a.e.stall | a.m.stall;

    v.pc0 = hazard_out.pc0;
    v.pc1 = hazard_out.pc1;
    v.npc0 = hazard_out.npc0;
    v.npc1 = hazard_out.npc1;
    v.instr0 = hazard_out.instr0;
    v.instr1 = hazard_out.instr1;
    v.return_pop = hazard_out.return_pop;
    v.return_push = hazard_out.return_push;
    v.jump_uncond = hazard_out.jump_uncond;
    v.jump_rest = hazard_out.jump_rest;
    v.branch = hazard_out.branch;
    v.stall = hazard_out.stall;

    if ((a.d.stall | a.e.stall | a.m.stall | a.e.instr0.op.jump | a.e.instr0.op.fence | a.e.instr0.op.mret | a.e.instr0.op.exception) == 1) begin
      v.pc0 = 0;
      v.pc1 = 0;
      v.npc0 = 0;
      v.npc1 = 0;
      v.instr0 = nop_instr;
      v.instr1 = nop_instr;
      v.return_pop = 0;
      v.return_push = 0;
      v.jump_uncond = 0;
      v.jump_rest = 0;
      v.branch = 0;
    end

    rin = v;

    y.pc0 = v.pc0;
    y.pc1 = v.pc1;
    y.npc0 = v.npc0;
    y.npc1 = v.npc1;
    y.instr1 = v.instr0;
    y.instr0 = v.instr1;
    y.return_pop = v.return_pop;
    y.return_push = v.return_push;
    y.jump_uncond = v.jump_uncond;
    y.jump_rest = v.jump_rest;
    y.branch = v.branch;
    y.stall = v.stall;

    q.pc0 = r.pc0;
    q.pc1 = r.pc1;
    q.npc0 = r.npc0;
    q.npc1 = r.npc1;
    q.instr0 = r.instr0;
    q.instr1 = r.instr1;
    q.return_pop = r.return_pop;
    q.return_push = r.return_push;
    q.jump_uncond = r.jump_uncond;
    q.jump_rest = r.jump_rest;
    q.branch = r.branch;
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
