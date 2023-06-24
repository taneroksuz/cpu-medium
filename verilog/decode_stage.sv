import constants::*;
import wires::*;
import functions::*;
import fp_wire::*;

module decode_stage
(
  input logic reset,
  input logic clock,
  input decoder_out_type decoder_out,
  output decoder_in_type decoder_in,
  input fp_decode_out_type fp_decode_out,
  output fp_decode_in_type fp_decode_in,
  output register_read_in_type register_rin,
  output fp_register_read_in_type fp_register_rin,
  input csr_out_type csr_out,
  output csr_read_in_type csr_rin,
  input fp_csr_out_type fp_csr_out,
  output fp_csr_read_in_type fp_csr_rin,
  input bp_out_type bp_out,
  input decode_in_type a,
  input decode_in_type d,
  output decode_out_type y,
  output decode_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  decode_reg_type r,rin;
  decode_reg_type v;

  always_comb begin

    v = r;

    v.instr0.pc = d.b.pc0;
    v.instr1.pc = d.b.pc1;
    v.instr0.instr = d.b.instr0;
    v.instr1.instr = d.b.instr1;

    if ((d.d.stall | d.e.stall | d.m.stall) == 1) begin
      v = r;
    end

    v.stall = 0;

    v.clear = csr_out.trap | csr_out.mret | bp_out.pred_branch | bp_out.pred_miss | bp_out.pred_return | d.e.instr0.jump | d.m.instr0.fence | d.w.clear;

    v.instr0.waddr = v.instr0.instr[11:7];
    v.instr0.raddr1 = v.instr0.instr[19:15];
    v.instr0.raddr2 = v.instr0.instr[24:20];
    v.instr0.raddr3 = v.instr0.instr[31:27];
    v.instr0.caddr = v.instr0.instr[31:20];

    v.instr0.fwren = 0;
    v.instr0.frden1 = 0;
    v.instr0.frden2 = 0;
    v.instr0.frden3 = 0;
    v.instr0.fload = 0;
    v.instr0.fstore = 0;
    v.instr0.fmt = 0;
    v.instr0.rm = 0;
    v.instr0.fpu = 0;
    v.instr0.fpuc = 0;
    v.instr0.fpuf = 0;
    v.instr0.fpu_op = init_fp_operation;

    v.instr0.npc = v.instr0.pc + ((v.instr0.instr[1:0] == 2'b11) ? 4 : 2);

    decoder_in.instr = v.instr0.instr;

    v.instr0.imm = decoder_out.imm;
    v.instr0.wren = decoder_out.wren;
    v.instr0.rden1 = decoder_out.rden1;
    v.instr0.rden2 = decoder_out.rden2;
    v.instr0.cwren = decoder_out.cwren;
    v.instr0.crden = decoder_out.crden;
    v.instr0.auipc = decoder_out.auipc;
    v.instr0.lui = decoder_out.lui;
    v.instr0.jal = decoder_out.jal;
    v.instr0.jalr = decoder_out.jalr;
    v.instr0.branch = decoder_out.branch;
    v.instr0.load = decoder_out.load;
    v.instr0.store = decoder_out.store;
    v.instr0.nop = decoder_out.nop;
    v.instr0.csreg = decoder_out.csreg;
    v.instr0.division = decoder_out.division;
    v.instr0.mult = decoder_out.mult;
    v.instr0.bitm = decoder_out.bitm;
    v.instr0.bitc = decoder_out.bitc;
    v.instr0.fence = decoder_out.fence;
    v.instr0.ecall = decoder_out.ecall;
    v.instr0.ebreak = decoder_out.ebreak;
    v.instr0.mret = decoder_out.mret;
    v.instr0.wfi = decoder_out.wfi;
    v.instr0.return_pop = decoder_out.return_pop;
    v.instr0.return_push = decoder_out.return_push;
    v.instr0.jump_uncond = decoder_out.jump_uncond;
    v.instr0.jump_rest = decoder_out.jump_rest;
    v.instr0.valid = decoder_out.valid;
    v.instr0.alu_op = decoder_out.alu_op;
    v.instr0.bcu_op = decoder_out.bcu_op;
    v.instr0.lsu_op = decoder_out.lsu_op;
    v.instr0.csr_op = decoder_out.csr_op;
    v.instr0.div_op = decoder_out.div_op;
    v.instr0.mul_op = decoder_out.mul_op;
    v.instr0.bit_op = decoder_out.bit_op;

    fp_decode_in.instr = v.instr0.instr;

    if (fp_decode_out.valid == 1) begin
      v.instr0.imm = fp_decode_out.imm;
      v.instr0.wren = fp_decode_out.wren;
      v.instr0.rden1 = fp_decode_out.rden1;
      v.instr0.fwren = fp_decode_out.fwren;
      v.instr0.frden1 = fp_decode_out.frden1;
      v.instr0.frden2 = fp_decode_out.frden2;
      v.instr0.frden3 = fp_decode_out.frden3;
      v.instr0.fload = fp_decode_out.fload;
      v.instr0.fstore = fp_decode_out.fstore;
      v.instr0.fmt = fp_decode_out.fmt;
      v.instr0.rm = fp_decode_out.rm;
      v.instr0.fpu = fp_decode_out.fpu;
      v.instr0.fpuc = fp_decode_out.fpuc;
      v.instr0.fpuf = fp_decode_out.fpuf;
      v.instr0.valid = fp_decode_out.valid;
      v.instr0.lsu_op = fp_decode_out.lsu_op;
      v.instr0.fpu_op = fp_decode_out.fpu_op;
    end

    if (csr_out.fs == 2'b00) begin
      v.instr0.fwren = 0;
      v.instr0.frden1 = 0;
      v.instr0.frden2 = 0;
      v.instr0.frden3 = 0;
      v.instr0.fload = 0;
      v.instr0.fstore = 0;
      v.instr0.fmt = 0;
      v.instr0.rm = 0;
      v.instr0.fpu = 0;
      v.instr0.fpuc = 0;
      v.instr0.fpuf = 0;
    end

    if (v.instr0.rm == 3'b111) begin
      v.instr0.rm = fp_csr_out.frm;
    end

    register_rin.rden1 = v.instr0.rden1;
    register_rin.rden2 = v.instr0.rden2;
    register_rin.raddr1 = v.instr0.raddr1;
    register_rin.raddr2 = v.instr0.raddr2;

    fp_register_rin.rden1 = v.instr0.frden1;
    fp_register_rin.rden2 = v.instr0.frden2;
    fp_register_rin.rden3 = v.instr0.frden3;
    fp_register_rin.raddr1 = v.instr0.raddr1;
    fp_register_rin.raddr2 = v.instr0.raddr2;
    fp_register_rin.raddr3 = v.instr0.raddr3;

    if (v.instr0.valid == 0) begin
      v.instr0.exception = 1;
      v.instr0.ecause = except_illegal_instruction;
      v.instr0.etval = v.instr0.instr;
    end else if (v.instr0.ebreak == 1) begin
      v.instr0.exception = 1;
      v.instr0.ecause = except_breakpoint;
      v.instr0.etval = v.instr0.instr;
    end else if (v.instr0.ecall == 1) begin
      v.instr0.exception = 1;
      v.instr0.ecause = except_env_call_mach;
      v.instr0.etval = v.instr0.instr;
    end

    if (a.e.instr0.cwren == 1 || a.m.instr0.cwren == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.division == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.bitc == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.fpuc == 1) begin
      v.stall = 1;
    end else if (v.instr0.crden == 1 && (v.instr0.caddr == csr_fflags || v.instr0.caddr == csr_fcsr) && (a.e.instr0.fpuf == 1 || a.m.instr0.fpuf == 1)) begin
      v.stall = 1;
    end else if (a.e.instr0.load == 1 && ((v.instr0.rden1 == 1 && a.e.instr0.waddr == v.instr0.raddr1) || (v.instr0.rden2 == 1 && a.e.instr0.waddr == v.instr0.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.instr0.fload == 1 && ((v.instr0.frden1 == 1 && a.e.instr0.waddr == v.instr0.raddr1) || (v.instr0.frden2 == 1 && a.e.instr0.waddr == v.instr0.raddr2) || (v.instr0.frden3 == 1 && a.e.instr0.waddr == v.instr0.raddr3))) begin 
      v.stall = 1;
    end

    if ((v.stall | a.e.stall | a.m.stall | a.e.instr0.jump | a.e.instr0.fence | a.e.instr0.mret | a.e.instr0.exception | v.clear) == 1) begin
      v.instr0.wren = 0;
      v.instr0.cwren = 0;
      v.instr0.fwren = 0;
      v.instr0.auipc = 0;
      v.instr0.lui = 0;
      v.instr0.jal = 0;
      v.instr0.jalr = 0;
      v.instr0.branch = 0;
      v.instr0.load = 0;
      v.instr0.store = 0;
      v.instr0.fload = 0;
      v.instr0.fstore = 0;
      v.instr0.nop = 0;
      v.instr0.csreg = 0;
      v.instr0.division = 0;
      v.instr0.mult = 0;
      v.instr0.bitm = 0;
      v.instr0.bitc = 0;
      v.instr0.fence = 0;
      v.instr0.ecall = 0;
      v.instr0.ebreak = 0;
      v.instr0.mret = 0;
      v.instr0.wfi = 0;
      v.instr0.fpu = 0;
      v.instr0.fpuc = 0;
      v.instr0.fpuf = 0;
      v.instr0.valid = 0;
      v.instr0.return_pop = 0;
      v.instr0.return_push = 0;
      v.instr0.jump_uncond = 0;
      v.instr0.jump_rest = 0;
      v.instr0.exception = 0;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    csr_rin.crden = v.instr0.crden;
    csr_rin.craddr = v.instr0.caddr;

    fp_csr_rin.crden = v.instr0.crden;
    fp_csr_rin.craddr = v.instr0.caddr;

    v.instr0.cdata = (fp_csr_out.ready == 1) ? fp_csr_out.cdata : csr_out.cdata;

    rin = v;

    y.instr0 = v.instr0;
    y.instr1 = v.instr1;
    y.stall = v.stall;

    q.instr0 = r.instr0;
    q.instr1 = r.instr1;
    q.stall = r.stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_decode_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
