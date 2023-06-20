import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic reset,
  input logic clock,
  input csr_out_type csr_out,
  input bp_out_type bp_out,
  output bp_in_type bp_in,
  output mem_in_type imem_in,
  input fetch_in_type a,
  input fetch_in_type d,
  output fetch_out_type y,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.valid = ~d.w.clear;
    v.stall = a.d.stall | a.e.stall | a.m.stall;

    v.fence = 0;
    v.spec = 0;

    bp_in.get_pc = d.d.pc;
    bp_in.get_npc = d.d.npc;
    bp_in.get_branch = d.d.branch;
    bp_in.get_return = d.d.return_pop;
    bp_in.get_uncond = d.d.jump_uncond;
    bp_in.upd_pc = d.e.pc;
    bp_in.upd_npc = d.e.npc;
    bp_in.upd_addr = d.e.address;
    bp_in.upd_branch = d.e.branch;
    bp_in.upd_return = d.e.return_push;
    bp_in.upd_uncond = d.e.jump_uncond;
    bp_in.upd_jump = d.e.jump;
    bp_in.stall = v.stall;
    bp_in.clear = d.w.clear;

    if (csr_out.trap == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = csr_out.mepc;
    end else if (bp_out.pred_branch == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = bp_out.pred_baddr;
    end else if (bp_out.pred_return == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = bp_out.pred_raddr;
    end else if (bp_out.pred_miss == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = bp_out.pred_maddr;
    end else if (d.e.jump == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = d.e.address;
    end else if (d.m.fence == 1) begin
      v.fence = 1;
      v.spec = 1;
      v.pc = d.m.npc;
    end else if (v.stall == 0) begin
      v.fence = 0;
      v.spec = 0;
      v.pc = a.b.npc;
    end

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = v.fence;
    imem_in.mem_spec = v.spec;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.pc;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    y.pc = v.pc;

    q.pc = r.pc;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
