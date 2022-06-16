import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic rst,
  input logic clk,
  input csr_out_type csr_out,
  input bp_out_type bp_out,
  output bp_in_type bp_in,
  input mem_out_type prefetch_out,
  output mem_in_type prefetch_in,
  input fetch_in_type a,
  input fetch_in_type d,
  output fetch_out_type y,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  fetch_reg_type r,rin = init_fetch_reg;
  fetch_reg_type v = init_fetch_reg;

  always_comb begin

    v = r;

    v.valid = ~(a.d.stall | a.e.stall | a.m.stall | d.w.clear);
    v.fence = d.d.fence;
    v.stall = v.stall | a.d.stall | a.e.stall | a.m.stall | d.w.clear;
    v.clear = d.w.clear;

    bp_in.get_pc = d.d.pc;
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
    bp_in.clear = v.clear;

    if (csr_out.exception == 1) begin
      v.pc = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.pc = csr_out.mepc;
    end else if (d.e.jump == 1 && d.f.taken == 0) begin
      v.pc = d.e.address;
    end else if (d.e.jump == 0 && d.f.taken == 1) begin
      v.pc = d.d.npc;
    end else if (d.e.jump == 1 && d.f.taken == 1 && |(d.e.address ^ d.f.pc) == 1) begin
      v.pc = d.e.address;
    end else if (bp_out.pred_return == 1) begin
      v.pc = bp_out.pred_raddr;
    end else if (bp_out.pred_uncond == 1) begin
      v.pc = bp_out.pred_baddr;
    end else if (bp_out.pred_branch == 1 && bp_out.pred_jump == 1) begin
      v.pc = bp_out.pred_baddr;
    end else if (v.stall == 0) begin
      v.pc = v.pc + ((v.instr[1:0] == 2'b11) ? 4 : 2);
    end

    v.taken = bp_out.pred_return | bp_out.pred_uncond | (bp_out.pred_branch & bp_out.pred_jump);

    prefetch_in.mem_valid = v.valid;
    prefetch_in.mem_fence = v.fence;
    prefetch_in.mem_instr = 1;
    prefetch_in.mem_addr = v.pc;
    prefetch_in.mem_wdata = 0;
    prefetch_in.mem_wstrb = 0;

    if (prefetch_out.mem_ready == 1) begin
      v.instr = prefetch_out.mem_rdata;
      v.stall = 0;
    end else begin
      v.instr = nop_instr;
      v.stall = 1;
    end

    rin = v;

    y.pc = v.pc;
    y.instr = v.instr;
    y.taken = v.taken;
    y.exception = v.exception;
    y.ecause = v.ecause;
    y.etval = v.etval;

    q.pc = r.pc;
    q.instr = r.instr;
    q.taken = r.taken;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
