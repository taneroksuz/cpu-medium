import constants::*;
import wires::*;
import functions::*;

module decode_stage
(
  input logic rst,
  input logic clk,
  input decoder_out_type decoder_out,
  output decoder_in_type decoder_in,
  input compress_out_type compress_out,
  output compress_in_type compress_in,
  input fp_decode_out_type fp_decode_out,
  output fp_decode_in_type fp_decode_in,
  output register_read_in_type register_rin,
  output fp_register_read_in_type fp_register_rin,
  input csr_out_type csr_out,
  output csr_read_in_type csr_rin,
  input decode_in_type a,
  input decode_in_type d,
  output decode_out_type y,
  output decode_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  decode_reg_type r,rin = init_decode_reg;
  decode_reg_type v = init_decode_reg;

  always_comb begin

    v = r;

    v.pc = d.f.pc;
    v.instr = d.f.instr;
    v.taken = d.f.taken;
    v.exception = d.f.exception;
    v.ecause = d.f.ecause;
    v.etval = d.f.etval;

    // if ((d.d.stall | d.e.stall | d.m.stall) == 1) begin
    //   v = r;
    // end

    v.clear = csr_out.exception | csr_out.mret | d.w.clear;

    if (d.e.jump == 1 && d.f.taken == 0) begin
      v.clear = 1;
    end else if (d.e.jump == 0 && d.f.taken == 1) begin
      v.clear = 1;
    end else if (d.e.jump == 1 && d.f.taken == 1 && |(d.e.address ^ d.f.pc) == 1) begin
      v.clear = 1;
    end

    v.stall = 0;

    v.waddr = v.instr[11:7];
    v.raddr1 = v.instr[19:15];
    v.raddr2 = v.instr[24:20];
    v.raddr3 = v.instr[31:27];
    v.caddr = v.instr[31:20];

    decoder_in.instr = v.instr;

    v.imm = decoder_out.imm;
    v.wren = decoder_out.wren;
    v.rden1 = decoder_out.rden1;
    v.rden2 = decoder_out.rden2;
    v.cwren = decoder_out.cwren;
    v.crden = decoder_out.crden;
    v.auipc = decoder_out.auipc;
    v.lui = decoder_out.lui;
    v.jal = decoder_out.jal;
    v.jalr = decoder_out.jalr;
    v.branch = decoder_out.branch;
    v.load = decoder_out.load;
    v.store = decoder_out.store;
    v.nop = decoder_out.nop;
    v.csreg = decoder_out.csreg;
    v.division = decoder_out.division;
    v.mult = decoder_out.mult;
    v.bitm = decoder_out.bitm;
    v.bitc = decoder_out.bitc;
    v.fence = decoder_out.fence;
    v.ecall = decoder_out.ecall;
    v.ebreak = decoder_out.ebreak;
    v.mret = decoder_out.mret;
    v.wfi = decoder_out.wfi;
    v.valid = decoder_out.valid;
    v.alu_op = decoder_out.alu_op;
    v.bcu_op = decoder_out.bcu_op;
    v.lsu_op = decoder_out.lsu_op;
    v.csr_op = decoder_out.csr_op;
    v.div_op = decoder_out.div_op;
    v.mul_op = decoder_out.mul_op;
    v.bit_op = decoder_out.bit_op;

    compress_in.instr = v.instr;

    if (compress_out.valid == 1) begin
      v.imm = compress_out.imm;
      v.waddr = compress_out.waddr;
      v.raddr1 = compress_out.raddr1;
      v.raddr2 = compress_out.raddr2;
      v.wren = compress_out.wren;
      v.rden1 = compress_out.rden1;
      v.rden2 = compress_out.rden2;
      v.lui = compress_out.lui;
      v.jal = compress_out.jal;
      v.jalr = compress_out.jalr;
      v.branch = compress_out.branch;
      v.load = compress_out.load;
      v.store = compress_out.store;
      v.ebreak = compress_out.ebreak;
      v.valid = compress_out.valid;
      v.alu_op = compress_out.alu_op;
      v.bcu_op = compress_out.bcu_op;
      v.lsu_op = compress_out.lsu_op;
    end

    fp_decode_in.instr = v.instr;

    v.fwren = 0;
    v.frden1 = 0;
    v.frden2 = 0;
    v.fload = 0;
    v.fstore = 0;

    if (fp_decode_out.valid == 1) begin
      v.imm = fp_decode_out.imm;
      v.wren = fp_decode_out.wren;
      v.rden1 = fp_decode_out.rden1;
      v.fwren = fp_decode_out.fwren;
      v.frden1 = fp_decode_out.frden1;
      v.frden2 = fp_decode_out.frden2;
      v.frden3 = fp_decode_out.frden3;
      v.fload = fp_decode_out.fload;
      v.fstore = fp_decode_out.fstore;
      v.fmt = fp_decode_out.fmt;
      v.rm = fp_decode_out.rm;
      v.fp = fp_decode_out.fp;
      v.valid = fp_decode_out.valid;
      v.lsu_op = fp_decode_out.lsu_op;
      v.fpu_op = fp_decode_out.fpu_op;
    end

    v.link_waddr = (v.waddr == 1 || v.waddr == 5) ? 1 : 0;
    v.link_raddr1 = (v.raddr1 == 1 || v.raddr1 == 5) ? 1 : 0;
    v.equal_waddr_raddr1 = (v.waddr == v.raddr1) ? 1 : 0;
    v.zero_waddr = (v.waddr == 0) ? 1 : 0;

    v.return_pop = 0;
    v.return_push = 0;
    v.jump_uncond = 0;
    v.jump_rest = 0;

    if (v.jal == 1) begin
      if (v.link_waddr == 1) begin
        v.return_push = 1;
      end else if (v.zero_waddr == 1) begin
        v.jump_uncond = 1;
      end else begin
        v.jump_rest = 1;
      end
    end

    if (v.jalr == 1) begin
      if (v.link_waddr == 0 && v.link_raddr1 == 1) begin
        v.return_pop = 1;
      end else if (v.link_waddr == 1 && v.link_raddr1 == 0) begin
        v.return_push = 1;
      end else if (v.link_waddr == 1 && v.link_raddr1 == 1) begin
        if (v.equal_waddr_raddr1 == 1) begin
          v.return_push = 1;
        end else if (v.equal_waddr_raddr1 == 0) begin
          v.return_pop = 1;
          v.return_push = 1;
        end
      end else begin
        v.jump_rest = 1;
      end
    end

    v.npc = v.pc + ((v.instr[1:0] == 2'b11) ? 4 : 2);

    register_rin.rden1 = v.rden1;
    register_rin.rden2 = v.rden2;
    register_rin.raddr1 = v.raddr1;
    register_rin.raddr2 = v.raddr2;

    fp_register_rin.rden1 = v.frden1;
    fp_register_rin.rden2 = v.frden2;
    fp_register_rin.rden3 = v.frden3;
    fp_register_rin.raddr1 = v.raddr1;
    fp_register_rin.raddr2 = v.raddr2;
    fp_register_rin.raddr3 = v.raddr3;

    if (v.valid == 0) begin
      v.exception = 1;
      v.ecause = except_illegal_instruction;
      v.etval = v.instr;
    end else if (v.ebreak == 1) begin
      v.exception = 1;
      v.ecause = except_breakpoint;
      v.etval = v.instr;
    end else if (v.ecall == 1) begin
      v.exception = 1;
      v.ecause = except_env_call_mach;
      v.etval = v.instr;
    end

    if (a.e.cwren == 1 || a.m.cwren == 1) begin
      v.stall = 1;
    end else if (a.e.mret == 1 || a.m.mret == 1) begin
      v.stall = 1;
    end else if (a.e.fence == 1 || a.m.fence == 1) begin
      v.stall = 1;
    end else if (a.e.division == 1) begin
      v.stall = 1;
    end else if (a.e.bitc == 1) begin
      v.stall = 1;
    end else if (a.e.load == 1 && ((v.rden1 == 1 && a.e.waddr == v.raddr1) || (v.rden2 == 1 && a.e.waddr == v.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.fload == 1 && ((v.frden1 == 1 && a.e.waddr == v.raddr1) || (v.frden2 == 1 && a.e.waddr == v.raddr2) || (v.frden3 == 1 && a.e.waddr == v.raddr3))) begin 
      v.stall = 1;
    end

    if ((v.stall | a.e.stall | a.m.stall | v.clear) == 1) begin
      v.wren = 0;
      v.cwren = 0;
      v.fwren = 0;
      v.auipc = 0;
      v.lui = 0;
      v.jal = 0;
      v.jalr = 0;
      v.branch = 0;
      v.load = 0;
      v.store = 0;
      v.fload = 0;
      v.fstore = 0;
      v.nop = 0;
      v.csreg = 0;
      v.division = 0;
      v.mult = 0;
      v.bitm = 0;
      v.bitc = 0;
      v.fence = 0;
      v.ecall = 0;
      v.ebreak = 0;
      v.mret = 0;
      v.wfi = 0;
      v.fp = 0;
      v.valid = 0;
      v.return_pop = 0;
      v.return_push = 0;
      v.jump_uncond = 0;
      v.jump_rest = 0;
      v.taken = 0;
      v.exception = 0;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    csr_rin.crden = v.crden;
    csr_rin.craddr = v.caddr;

    v.cdata = csr_out.cdata;

    rin = v;

    y.pc = v.pc;
    y.npc = v.npc;
    y.imm = v.imm;
    y.wren = v.wren;
    y.rden1 = v.rden1;
    y.rden2 = v.rden2;
    y.cwren = v.cwren;
    y.crden = v.crden;
    y.fwren = v.fwren;
    y.frden1 = v.frden1;
    y.frden2 = v.frden2;
    y.frden3 = v.frden3;
    y.waddr = v.waddr;
    y.raddr1 = v.raddr1;
    y.raddr2 = v.raddr2;
    y.raddr3 = v.raddr3;
    y.caddr = v.caddr;
    y.auipc = v.auipc;
    y.lui = v.lui;
    y.jal = v.jal;
    y.jalr = v.jalr;
    y.branch = v.branch;
    y.load = v.load;
    y.store = v.store;
    y.fload = v.fload;
    y.fstore = v.fstore;
    y.nop = v.nop;
    y.csreg = v.csreg;
    y.division = v.division;
    y.mult = v.mult;
    y.bitm = v.bitm;
    y.bitc = v.bitc;
    y.fence = v.fence;
    y.ecall = v.ecall;
    y.ebreak = v.ebreak;
    y.mret = v.mret;
    y.wfi = v.wfi;
    y.fmt = v.fmt;
    y.rm = v.rm;
    y.fp = v.fp;
    y.valid = v.valid;
    y.cdata = v.cdata;
    y.return_pop = v.return_pop;
    y.return_push = v.return_push;
    y.jump_uncond = v.jump_uncond;
    y.jump_rest = v.jump_rest;
    y.taken = v.taken;
    y.exception = v.exception;
    y.ecause = v.ecause;
    y.etval = v.etval;
    y.stall = v.stall;
    y.alu_op = v.alu_op;
    y.bcu_op = v.bcu_op;
    y.lsu_op = v.lsu_op;
    y.csr_op = v.csr_op;
    y.div_op = v.div_op;
    y.mul_op = v.mul_op;
    y.bit_op = v.bit_op;
    y.fpu_op = v.fpu_op;

    q.pc = r.pc;
    q.npc = r.npc;
    q.imm = r.imm;
    q.wren = r.wren;
    q.rden1 = r.rden1;
    q.rden2 = r.rden2;
    q.cwren = r.cwren;
    q.crden = r.crden;
    q.fwren = r.fwren;
    q.frden1 = r.frden1;
    q.frden2 = r.frden2;
    q.frden3 = r.frden3;
    q.waddr = r.waddr;
    q.raddr1 = r.raddr1;
    q.raddr2 = r.raddr2;
    q.raddr3 = r.raddr3;
    q.caddr = r.caddr;
    q.auipc = r.auipc;
    q.lui = r.lui;
    q.jal = r.jal;
    q.jalr = r.jalr;
    q.branch = r.branch;
    q.load = r.load;
    q.store = r.store;
    q.fload = r.fload;
    q.fstore = r.fstore;
    q.nop = r.nop;
    q.csreg = r.csreg;
    q.division = r.division;
    q.mult = r.mult;
    q.bitm = r.bitm;
    q.bitc = r.bitc;
    q.fence = r.fence;
    q.ecall = r.ecall;
    q.ebreak = r.ebreak;
    q.mret = r.mret;
    q.wfi = r.wfi;
    q.fmt = r.fmt;
    q.rm = r.rm;
    q.fp = r.fp;
    q.valid = r.valid;
    q.cdata = r.cdata;
    q.return_pop = r.return_pop;
    q.return_push = r.return_push;
    q.jump_uncond = r.jump_uncond;
    q.jump_rest = r.jump_rest;
    q.taken = r.taken;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;
    q.stall = r.stall;
    q.alu_op = r.alu_op;
    q.bcu_op = r.bcu_op;
    q.lsu_op = r.lsu_op;
    q.csr_op = r.csr_op;
    q.div_op = r.div_op;
    q.mul_op = r.mul_op;
    q.bit_op = r.bit_op;
    q.fpu_op = r.fpu_op;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_decode_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
