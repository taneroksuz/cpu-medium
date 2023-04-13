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
  input mem_out_type imem_out,
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

    v.pc = v.npc;

    if (imem_out.mem_ready == 1) begin
      v.instr = imem_out.mem_rdata;
      v.stall = 0;
    end else begin
      v.instr = nop_instr;
      v.stall = 1;
    end

    if (v.busy == 1) begin
      v.instr = nop_instr;
      v.stall = 1;
    end

    if (imem_out.mem_ready == 1) begin
      v.busy = 0;
      v.spec = 0;
    end

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
    bp_in.clear = d.w.clear;

    if (csr_out.trap == 1) begin
      v.npc = csr_out.mtvec;
      v.spec = 1;
    end else if (csr_out.mret == 1) begin
      v.npc = csr_out.mepc;
      v.spec = 1;
    end else if (d.e.jump == 1) begin
      v.npc = d.e.address;
      v.spec = 1;
    //end else if (bp_out.pred_return == 1) begin
    //  v.npc = bp_out.pred_raddr;
    //  v.spec = 1;
    //end else if (bp_out.pred_uncond == 1) begin
    //  v.npc = bp_out.pred_baddr;
    //  v.spec = 1;
    //end else if (bp_out.pred_branch == 1 && bp_out.pred_jump == 1) begin
    //  v.npc = bp_out.pred_baddr;
    //  v.spec = 1;
    end else if (d.d.fence == 1) begin
      v.npc = d.d.npc;
      v.spec = 1;
    end else if ((v.stall | a.d.stall | a.e.stall | a.m.stall) == 0) begin
      v.npc = v.pc + ((v.instr[1:0] == 2'b11) ? 4 : 2);
      v.spec = 0;
    end

    if (imem_out.mem_ready == 0) begin
      v.busy = v.spec;
    end

    if (v.spec == 1) begin
      v.instr = nop_instr;
    end

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = d.d.fence;
    imem_in.mem_spec = v.spec;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.npc;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    y.pc = v.pc;
    y.instr = v.instr;
    y.exception = v.exception;
    y.ecause = v.ecause;
    y.etval = v.etval;
    y.stall = v.stall;

    q.pc = r.pc;
    q.instr = r.instr;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;
    q.stall = r.stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
