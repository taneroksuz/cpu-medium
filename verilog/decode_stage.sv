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
  input fp_decode_out_type fp_decode0_out,
  output fp_decode_in_type fp_decode0_in,
  input fp_decode_out_type fp_decode1_out,
  output fp_decode_in_type fp_decode1_in,
  input csr_out_type csr_out,
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

    v.taken = d.f.taken;
    v.taddr = d.f.taddr;
    v.tpc = d.f.tpc;

    v.instr0.pc = a.f.ready ? d.f.pc : -1;
    v.instr1.pc = a.f.ready ? (d.f.pc + 4) : -1;
    v.instr0.instr = a.f.ready ? a.f.rdata[31:0] : nop_instr;
    v.instr1.instr = a.f.ready ? a.f.rdata[63:32] : nop_instr;

    if ((d.i.stall | d.e.stall | d.m.stall) == 1) begin
      v = r;
    end

    v.instr0.npc = v.instr0.pc + 4;
    v.instr1.npc = v.instr1.pc + 4;

    v.stall = 0;

    v.clear = csr_out.trap | csr_out.mret | btac_out.pred_branch | btac_out.pred_miss | d.w.clear;

    v.instr0.waddr = v.instr0.instr[11:7];
    v.instr0.raddr1 = v.instr0.instr[19:15];
    v.instr0.raddr2 = v.instr0.instr[24:20];
    v.instr0.raddr3 = v.instr0.instr[31:27];
    v.instr0.caddr = v.instr0.instr[31:20];

    v.instr1.waddr = v.instr1.instr[11:7];
    v.instr1.raddr1 = v.instr1.instr[19:15];
    v.instr1.raddr2 = v.instr1.instr[24:20];
    v.instr1.raddr3 = v.instr1.instr[31:27];
    v.instr1.caddr = v.instr1.instr[31:20];

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

    v.instr1.fmt = 0;
    v.instr1.rm = 0;
    v.instr1.op.fwren = 0;
    v.instr1.op.frden1 = 0;
    v.instr1.op.frden2 = 0;
    v.instr1.op.frden3 = 0;
    v.instr1.op.fload = 0;
    v.instr1.op.fstore = 0;
    v.instr1.op.fpu = 0;
    v.instr1.op.fpuc = 0;
    v.instr1.op.fpuf = 0;
    v.instr1.fpu_op = init_fp_operation;

    decoder0_in.instr = v.instr0.instr;

    v.instr0.instr_str = decoder0_out.instr_str;
    v.instr0.imm = decoder0_out.imm;
    v.instr0.op.wren = decoder0_out.wren;
    v.instr0.op.rden1 = decoder0_out.rden1;
    v.instr0.op.rden2 = decoder0_out.rden2;
    v.instr0.op.cwren = decoder0_out.cwren;
    v.instr0.op.crden = decoder0_out.crden;
    v.instr0.op.alu = decoder0_out.alu;
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

    decoder1_in.instr = v.instr1.instr;

    v.instr1.instr_str = decoder1_out.instr_str;
    v.instr1.imm = decoder1_out.imm;
    v.instr1.op.wren = decoder1_out.wren;
    v.instr1.op.rden1 = decoder1_out.rden1;
    v.instr1.op.rden2 = decoder1_out.rden2;
    v.instr1.op.cwren = decoder1_out.cwren;
    v.instr1.op.crden = decoder1_out.crden;
    v.instr1.op.alu = decoder1_out.alu;
    v.instr1.op.auipc = decoder1_out.auipc;
    v.instr1.op.lui = decoder1_out.lui;
    v.instr1.op.jal = decoder1_out.jal;
    v.instr1.op.jalr = decoder1_out.jalr;
    v.instr1.op.branch = decoder1_out.branch;
    v.instr1.op.load = decoder1_out.load;
    v.instr1.op.store = decoder1_out.store;
    v.instr1.op.nop = decoder1_out.nop;
    v.instr1.op.csreg = decoder1_out.csreg;
    v.instr1.op.division = decoder1_out.division;
    v.instr1.op.mult = decoder1_out.mult;
    v.instr1.op.bitm = decoder1_out.bitm;
    v.instr1.op.bitc = decoder1_out.bitc;
    v.instr1.op.fence = decoder1_out.fence;
    v.instr1.op.ecall = decoder1_out.ecall;
    v.instr1.op.ebreak = decoder1_out.ebreak;
    v.instr1.op.mret = decoder1_out.mret;
    v.instr1.op.wfi = decoder1_out.wfi;
    v.instr1.op.valid = decoder1_out.valid;
    v.instr1.alu_op = decoder1_out.alu_op;
    v.instr1.bcu_op = decoder1_out.bcu_op;
    v.instr1.lsu_op = decoder1_out.lsu_op;
    v.instr1.csr_op = decoder1_out.csr_op;
    v.instr1.div_op = decoder1_out.div_op;
    v.instr1.mul_op = decoder1_out.mul_op;
    v.instr1.bit_op = decoder1_out.bit_op;

    fp_decode0_in.instr = v.instr0.instr;

    if (fp_decode0_out.valid == 1) begin
      v.instr0.instr_str = fp_decode0_out.instr_str;
      v.instr0.imm = fp_decode0_out.imm;
      v.instr0.fmt = fp_decode0_out.fmt;
      v.instr0.rm = fp_decode0_out.rm;
      v.instr0.op.wren = fp_decode0_out.wren;
      v.instr0.op.rden1 = fp_decode0_out.rden1;
      v.instr0.op.fwren = fp_decode0_out.fwren;
      v.instr0.op.frden1 = fp_decode0_out.frden1;
      v.instr0.op.frden2 = fp_decode0_out.frden2;
      v.instr0.op.frden3 = fp_decode0_out.frden3;
      v.instr0.op.fload = fp_decode0_out.fload;
      v.instr0.op.fstore = fp_decode0_out.fstore;
      v.instr0.op.fpu = fp_decode0_out.fpu;
      v.instr0.op.fpuc = fp_decode0_out.fpuc;
      v.instr0.op.fpuf = fp_decode0_out.fpuf;
      v.instr0.op.valid = fp_decode0_out.valid;
      v.instr0.lsu_op = fp_decode0_out.lsu_op;
      v.instr0.fpu_op = fp_decode0_out.fpu_op;
    end

    fp_decode1_in.instr = v.instr1.instr;

    if (fp_decode1_out.valid == 1) begin
      v.instr1.instr_str = fp_decode1_out.instr_str;
      v.instr1.imm = fp_decode1_out.imm;
      v.instr1.fmt = fp_decode1_out.fmt;
      v.instr1.rm = fp_decode1_out.rm;
      v.instr1.op.wren = fp_decode1_out.wren;
      v.instr1.op.rden1 = fp_decode1_out.rden1;
      v.instr1.op.fwren = fp_decode1_out.fwren;
      v.instr1.op.frden1 = fp_decode1_out.frden1;
      v.instr1.op.frden2 = fp_decode1_out.frden2;
      v.instr1.op.frden3 = fp_decode1_out.frden3;
      v.instr1.op.fload = fp_decode1_out.fload;
      v.instr1.op.fstore = fp_decode1_out.fstore;
      v.instr1.op.fpu = fp_decode1_out.fpu;
      v.instr1.op.fpuc = fp_decode1_out.fpuc;
      v.instr1.op.fpuf = fp_decode1_out.fpuf;
      v.instr1.op.valid = fp_decode1_out.valid;
      v.instr1.lsu_op = fp_decode1_out.lsu_op;
      v.instr1.fpu_op = fp_decode1_out.fpu_op;
    end

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

    if (v.instr1.op.valid == 0) begin
      v.instr1.op.exception = 1;
      v.instr1.ecause = except_illegal_instruction;
      v.instr1.etval = v.instr1.instr;
    end else if (v.instr1.op.ebreak == 1) begin
      v.instr1.op.exception = 1;
      v.instr1.ecause = except_breakpoint;
      v.instr1.etval = v.instr1.instr;
    end else if (v.instr1.op.ecall == 1) begin
      v.instr1.op.exception = 1;
      v.instr1.ecause = except_env_call_mach;
      v.instr1.etval = v.instr1.instr;
    end

    if ((v.stall | a.e.stall | a.m.stall) == 1) begin
      v.instr0.op = init_operation;
      v.instr1.op = init_operation;
    end

    if (v.clear == 1) begin
      v.instr0 = init_instruction;
      v.instr1 = init_instruction;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    rin = v;

    y.instr0 = v.instr0;
    y.instr1 = v.instr1;
    y.swap = v.swap;
    y.taken = v.taken;
    y.taddr = v.taddr;
    y.tpc = v.tpc;
    y.stall = v.stall;

    q.instr0 = r.instr0;
    q.instr1 = r.instr1;
    q.swap = r.swap;
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
