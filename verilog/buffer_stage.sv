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
  input btac_out_type btac_out,
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
  
    v.taken = d.f.taken;
    v.taddr = d.f.taddr;
    v.tpc = d.f.tpc;

    v.clear = csr_out.trap | csr_out.mret | btac_out.pred_branch | btac_out.pred_miss | btac_out.pred_rest | d.w.clear;

    hazard_in.pc = d.f.pc;
    hazard_in.rdata = a.f.rdata;
    hazard_in.ready = a.f.ready;
    hazard_in.clear =  a.e.instr0.op.fence | v.clear;
    hazard_in.stall = a.d.stall | a.e.stall | a.m.stall;

    v.pc0 = hazard_out.pc0;
    v.pc1 = hazard_out.pc1;
    v.npc0 = hazard_out.npc0;
    v.npc1 = hazard_out.npc1;
    v.instr0 = hazard_out.instr0;
    v.instr1 = hazard_out.instr1;
    v.stall = hazard_out.stall;

    if ((a.e.instr0.op.fence | csr_out.trap | csr_out.mret | btac_out.pred_miss | btac_out.pred_rest) == 1) begin
      v.taken = 0;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    rin = v;

    y.pc0 = v.pc0;
    y.pc1 = v.pc1;
    y.npc0 = v.npc0;
    y.npc1 = v.npc1;
    y.instr1 = v.instr0;
    y.instr0 = v.instr1;
    y.taken = v.taken;
    y.taddr = v.taddr;
    y.tpc = v.tpc;
    y.stall = v.stall;

    q.pc0 = r.pc0;
    q.pc1 = r.pc1;
    q.npc0 = r.npc0;
    q.npc1 = r.npc1;
    q.instr0 = r.instr0;
    q.instr1 = r.instr1;
    q.taken = r.taken;
    q.taddr = r.taddr;
    q.tpc = r.tpc;
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
