import constants::*;
import wires::*;
import functions::*;
import fp_wire::*;

module decode_stage
(
  input logic reset,
  input logic clock,
  input decoder_out_type decoder0_out,
  output decoder_in_type decoder0_in,
  input decoder_out_type decoder1_out,
  output decoder_in_type decoder1_in,
  input fp_decode_out_type fp_decode_out,
  output fp_decode_in_type fp_decode_in,
  output register_read_in_type register0_rin,
  output register_read_in_type register1_rin,
  output fp_register_read_in_type fp_register_rin,
  input csr_out_type csr_out,
  output csr_read_in_type csr_rin,
  input fp_csr_out_type fp_csr_out,
  output fp_csr_read_in_type fp_csr_rin,
  input btac_out_type btac_out,
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
    v.instr0.npc = d.b.npc0;
    v.instr1.pc = d.b.pc1;
    v.instr1.npc = d.b.npc1;
    v.instr0.instr = d.b.instr0;
    v.instr1.instr = d.b.instr1;
  
    v.taken = d.b.taken;
    v.taddr = d.b.taddr;
    v.tpc = d.b.tpc;

    if ((d.d.stall | d.e.stall | d.m.stall) == 1) begin
      v = r;
    end

    v.stall = 0;

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

    decoder0_in.instr = v.instr0.instr;

    v.instr0.imm = decoder0_out.imm;
    v.instr0.op.wren = decoder0_out.wren;
    v.instr0.op.rden1 = decoder0_out.rden1;
    v.instr0.op.rden2 = decoder0_out.rden2;
    v.instr0.op.cwren = decoder0_out.cwren;
    v.instr0.op.crden = decoder0_out.crden;
    v.instr0.op.auipc = decoder0_out.auipc;
    v.instr0.op.lui = decoder0_out.lui;
    v.instr0.op.jal = decoder0_out.jal;
    v.instr0.op.jalr = decoder0_out.jalr;
    v.instr0.op.branch = decoder0_out.branch;
    v.instr0.op.load = decoder0_out.load;
    v.instr0.op.store = decoder0_out.store;
    v.instr0.op.nop = decoder0_out.nop;
    v.instr0.op.csreg = decoder0_out.csreg;
    v.instr0.op.division = decoder0_out.division;
    v.instr0.op.mult = decoder0_out.mult;
    v.instr0.op.bitm = decoder0_out.bitm;
    v.instr0.op.bitc = decoder0_out.bitc;
    v.instr0.op.fence = decoder0_out.fence;
    v.instr0.op.ecall = decoder0_out.ecall;
    v.instr0.op.ebreak = decoder0_out.ebreak;
    v.instr0.op.mret = decoder0_out.mret;
    v.instr0.op.wfi = decoder0_out.wfi;
    v.instr0.op.valid = decoder0_out.valid;
    v.instr0.alu_op = decoder0_out.alu_op;
    v.instr0.bcu_op = decoder0_out.bcu_op;
    v.instr0.lsu_op = decoder0_out.lsu_op;
    v.instr0.csr_op = decoder0_out.csr_op;
    v.instr0.div_op = decoder0_out.div_op;
    v.instr0.mul_op = decoder0_out.mul_op;
    v.instr0.bit_op = decoder0_out.bit_op;

    v.instr1.waddr = v.instr1.instr[11:7];
    v.instr1.raddr1 = v.instr1.instr[19:15];
    v.instr1.raddr2 = v.instr1.instr[24:20];

    decoder1_in.instr = v.instr1.instr;

    v.instr1.imm = decoder1_out.imm;
    v.instr1.op.wren = decoder1_out.wren;
    v.instr1.op.rden1 = decoder1_out.rden1;
    v.instr1.op.rden2 = decoder1_out.rden2;
    v.instr1.op.nop = decoder1_out.nop;
    v.instr1.op.valid = decoder1_out.valid;
    v.instr1.alu_op = decoder1_out.alu_op;

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

    register0_rin.rden1 = v.instr0.op.rden1;
    register0_rin.rden2 = v.instr0.op.rden2;
    register0_rin.raddr1 = v.instr0.raddr1;
    register0_rin.raddr2 = v.instr0.raddr2;

    register1_rin.rden1 = v.instr1.op.rden1;
    register1_rin.rden2 = v.instr1.op.rden2;
    register1_rin.raddr1 = v.instr1.raddr1;
    register1_rin.raddr2 = v.instr1.raddr2;

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
    end else if (a.e.instr0.op.load == 1 && ((v.instr1.op.rden1 == 1 && a.e.instr0.waddr == v.instr1.raddr1) || (v.instr1.op.rden2 == 1 && a.e.instr0.waddr == v.instr1.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.instr0.op.fload == 1 && ((v.instr0.op.frden1 == 1 && a.e.instr0.waddr == v.instr0.raddr1) || (v.instr0.op.frden2 == 1 && a.e.instr0.waddr == v.instr0.raddr2) || (v.instr0.op.frden3 == 1 && a.e.instr0.waddr == v.instr0.raddr3))) begin 
      v.stall = 1;
    end

    if ((v.stall | a.e.stall | a.m.stall | a.e.instr0.op.fence | csr_out.trap | csr_out.mret | btac_out.pred_branch | btac_out.pred_miss | btac_out.pred_rest | d.w.clear) == 1) begin
      v.instr0.op = init_operation_complex;
      v.instr1.op = init_operation_basic;
    end

    if (d.w.clear == 1) begin
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
    y.taken = v.taken;
    y.taddr = v.taddr;
    q.tpc = r.tpc;
    y.stall = v.stall;

    q.instr0 = r.instr0;
    q.instr1 = r.instr1;
    q.taken = r.taken;
    q.taddr = r.taddr;
    q.tpc = r.tpc;
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
