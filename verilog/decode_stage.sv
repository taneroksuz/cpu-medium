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

    v.clear = csr_out.trap | csr_out.mret | bp_out.pred_branch | bp_out.pred_miss | bp_out.pred_return | d.e.instr0.op.jump | d.m.instr0.op.fence | d.w.clear;

    v.instr0.waddr = v.instr0.instr[11:7];
    v.instr0.raddr1 = v.instr0.instr[19:15];
    v.instr0.raddr2 = v.instr0.instr[24:20];
    v.instr0.raddr3 = v.instr0.instr[31:27];
    v.instr0.caddr = v.instr0.instr[31:20];

    v.instr0.fmt = 0;
    v.instr0.rm = 0;
    v.instr0.op.fwren = 0;
    v.instr0.op.frden1 = 0;
    v.instr0.op.frden2 = 0;
    v.instr0.op.frden3 = 0;
    v.instr0.op.fload = 0;
    v.instr0.op.fstore = 0;
    v.instr0.op.fpu = 0;
    v.instr0.op.fpuc = 0;
    v.instr0.op.fpuf = 0;
    v.instr0.fpu_op = init_fp_operation;

    v.instr0.npc = v.instr0.pc + ((v.instr0.instr[1:0] == 2'b11) ? 4 : 2);

    decoder_in.instr = v.instr0.instr;

    v.instr0.imm = decoder_out.imm;
    v.instr0.op.wren = decoder_out.wren;
    v.instr0.op.rden1 = decoder_out.rden1;
    v.instr0.op.rden2 = decoder_out.rden2;
    v.instr0.op.cwren = decoder_out.cwren;
    v.instr0.op.crden = decoder_out.crden;
    v.instr0.op.auipc = decoder_out.auipc;
    v.instr0.op.lui = decoder_out.lui;
    v.instr0.op.jal = decoder_out.jal;
    v.instr0.op.jalr = decoder_out.jalr;
    v.instr0.op.branch = decoder_out.branch;
    v.instr0.op.load = decoder_out.load;
    v.instr0.op.store = decoder_out.store;
    v.instr0.op.nop = decoder_out.nop;
    v.instr0.op.csreg = decoder_out.csreg;
    v.instr0.op.division = decoder_out.division;
    v.instr0.op.mult = decoder_out.mult;
    v.instr0.op.bitm = decoder_out.bitm;
    v.instr0.op.bitc = decoder_out.bitc;
    v.instr0.op.fence = decoder_out.fence;
    v.instr0.op.ecall = decoder_out.ecall;
    v.instr0.op.ebreak = decoder_out.ebreak;
    v.instr0.op.mret = decoder_out.mret;
    v.instr0.op.wfi = decoder_out.wfi;
    v.instr0.op.return_pop = decoder_out.return_pop;
    v.instr0.op.return_push = decoder_out.return_push;
    v.instr0.op.jump_uncond = decoder_out.jump_uncond;
    v.instr0.op.jump_rest = decoder_out.jump_rest;
    v.instr0.op.valid = decoder_out.valid;
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
      v.instr0.fmt = fp_decode_out.fmt;
      v.instr0.rm = fp_decode_out.rm;
      v.instr0.op.wren = fp_decode_out.wren;
      v.instr0.op.rden1 = fp_decode_out.rden1;
      v.instr0.op.fwren = fp_decode_out.fwren;
      v.instr0.op.frden1 = fp_decode_out.frden1;
      v.instr0.op.frden2 = fp_decode_out.frden2;
      v.instr0.op.frden3 = fp_decode_out.frden3;
      v.instr0.op.fload = fp_decode_out.fload;
      v.instr0.op.fstore = fp_decode_out.fstore;
      v.instr0.op.fpu = fp_decode_out.fpu;
      v.instr0.op.fpuc = fp_decode_out.fpuc;
      v.instr0.op.fpuf = fp_decode_out.fpuf;
      v.instr0.op.valid = fp_decode_out.valid;
      v.instr0.lsu_op = fp_decode_out.lsu_op;
      v.instr0.fpu_op = fp_decode_out.fpu_op;
    end

    if (csr_out.fs == 2'b00) begin
      v.instr0.fmt = 0;
      v.instr0.rm = 0;
      v.instr0.op.fwren = 0;
      v.instr0.op.frden1 = 0;
      v.instr0.op.frden2 = 0;
      v.instr0.op.frden3 = 0;
      v.instr0.op.fload = 0;
      v.instr0.op.fstore = 0;
      v.instr0.op.fpu = 0;
      v.instr0.op.fpuc = 0;
      v.instr0.op.fpuf = 0;
    end

    if (v.instr0.rm == 3'b111) begin
      v.instr0.rm = fp_csr_out.frm;
    end

    register_rin.rden1 = v.instr0.op.rden1;
    register_rin.rden2 = v.instr0.op.rden2;
    register_rin.raddr1 = v.instr0.raddr1;
    register_rin.raddr2 = v.instr0.raddr2;

    fp_register_rin.rden1 = v.instr0.op.frden1;
    fp_register_rin.rden2 = v.instr0.op.frden2;
    fp_register_rin.rden3 = v.instr0.op.frden3;
    fp_register_rin.raddr1 = v.instr0.raddr1;
    fp_register_rin.raddr2 = v.instr0.raddr2;
    fp_register_rin.raddr3 = v.instr0.raddr3;

    if (v.instr0.op.valid == 0) begin
      v.instr0.op.exception = 1;
      v.instr0.ecause = except_illegal_instruction;
      v.instr0.etval = v.instr0.instr;
    end else if (v.instr0.op.ebreak == 1) begin
      v.instr0.op.exception = 1;
      v.instr0.ecause = except_breakpoint;
      v.instr0.etval = v.instr0.instr;
    end else if (v.instr0.op.ecall == 1) begin
      v.instr0.op.exception = 1;
      v.instr0.ecause = except_env_call_mach;
      v.instr0.etval = v.instr0.instr;
    end

    if (a.e.instr0.op.cwren == 1 || a.m.instr0.op.cwren == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.op.division == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.op.bitc == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.op.fpuc == 1) begin
      v.stall = 1;
    end else if (v.instr0.op.crden == 1 && (v.instr0.caddr == csr_fflags || v.instr0.caddr == csr_fcsr) && (a.e.instr0.op.fpuf == 1 || a.m.instr0.op.fpuf == 1)) begin
      v.stall = 1;
    end else if (a.e.instr0.op.load == 1 && ((v.instr0.op.rden1 == 1 && a.e.instr0.waddr == v.instr0.raddr1) || (v.instr0.op.rden2 == 1 && a.e.instr0.waddr == v.instr0.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.instr0.op.fload == 1 && ((v.instr0.op.frden1 == 1 && a.e.instr0.waddr == v.instr0.raddr1) || (v.instr0.op.frden2 == 1 && a.e.instr0.waddr == v.instr0.raddr2) || (v.instr0.op.frden3 == 1 && a.e.instr0.waddr == v.instr0.raddr3))) begin 
      v.stall = 1;
    end

    if ((v.stall | a.e.stall | a.m.stall | a.e.instr0.op.jump | a.e.instr0.op.fence | a.e.instr0.op.mret | a.e.instr0.op.exception | v.clear) == 1) begin
      v.instr0.op = init_operation_complex;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    csr_rin.crden = v.instr0.op.crden;
    csr_rin.craddr = v.instr0.caddr;

    fp_csr_rin.crden = v.instr0.op.crden;
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
