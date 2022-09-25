import constants::*;
import wires::*;

module execute_stage
(
  input logic rst,
  input logic clk,
  input alu_out_type alu_out,
  output alu_in_type alu_in,
  input agu_out_type agu_out,
  output agu_in_type agu_in,
  input bcu_out_type bcu_out,
  output bcu_in_type bcu_in,
  input csr_alu_out_type csr_alu_out,
  output csr_alu_in_type csr_alu_in,
  input div_out_type div_out,
  output div_in_type div_in,
  input mul_out_type mul_out,
  output mul_in_type mul_in,
  input bit_alu_out_type bit_alu_out,
  output bit_alu_in_type bit_alu_in,
  input bit_clmul_out_type bit_clmul_out,
  output bit_clmul_in_type bit_clmul_in,
  input register_out_type register_out,
  input fp_register_out_type fp_register_out,
  input forwarding_out_type forwarding_out,
  output forwarding_register_in_type forwarding_rin,
  output forwarding_execute_in_type forwarding_ein,
  input fp_forwarding_out_type fp_forwarding_out,
  output fp_forwarding_register_in_type fp_forwarding_rin,
  output fp_forwarding_execute_in_type fp_forwarding_ein,
  input csr_out_type csr_out,
  input execute_in_type a,
  input execute_in_type d,
  output execute_out_type y,
  output execute_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  execute_reg_type r,rin = init_execute_reg;
  execute_reg_type v = init_execute_reg;

  always_comb begin

    v = r;

    v.pc = d.d.pc;
    v.npc = d.d.npc;
    v.imm = d.d.imm;
    v.wren = d.d.wren;
    v.rden1 = d.d.rden1;
    v.rden2 = d.d.rden2;
    v.cwren = d.d.cwren;
    v.crden = d.d.crden;
    v.fwren = d.d.fwren;
    v.frden1 = d.d.frden1;
    v.frden2 = d.d.frden2;
    v.frden3 = d.d.frden3;
    v.waddr = d.d.waddr;
    v.raddr1 = d.d.raddr1;
    v.raddr2 = d.d.raddr2;
    v.raddr3 = d.d.raddr3;
    v.caddr = d.d.caddr;
    v.auipc = d.d.auipc;
    v.lui = d.d.lui;
    v.jal = d.d.jal;
    v.jalr = d.d.jalr;
    v.branch = d.d.branch;
    v.load = d.d.load;
    v.store = d.d.store;
    v.nop = d.d.nop;
    v.csreg = d.d.csreg;
    v.division = d.d.division;
    v.mult = d.d.mult;
    v.bitm = d.d.bitm;
    v.bitc = d.d.bitc;
    v.fence = d.d.fence;
    v.ecall = d.d.ecall;
    v.ebreak = d.d.ebreak;
    v.mret = d.d.mret;
    v.wfi = d.d.wfi;
    v.fmt = d.d.fmt;
    v.rm = d.d.rm;
    v.fp = d.d.fp;
    v.valid = d.d.valid;
    v.cdata = d.d.cdata;
    v.return_pop = d.d.return_pop;
    v.return_push = d.d.return_push;
    v.jump_uncond = d.d.jump_uncond;
    v.jump_rest = d.d.jump_rest;
    v.taken = d.d.taken;
    v.exception = d.d.exception;
    v.ecause = d.d.ecause;
    v.etval = d.d.etval;
    v.alu_op = d.d.alu_op;
    v.bcu_op = d.d.bcu_op;
    v.lsu_op = d.d.lsu_op;
    v.csr_op = d.d.csr_op;
    v.div_op = d.d.div_op;
    v.mul_op = d.d.mul_op;
    v.bit_op = d.d.bit_op;
    v.fpu_op = d.d.fpu_op;

    forwarding_rin.rden1 = v.rden1;
    forwarding_rin.rden2 = v.rden2;
    forwarding_rin.raddr1 = v.raddr1;
    forwarding_rin.raddr2 = v.raddr2;
    forwarding_rin.rdata1 = register_out.rdata1;
    forwarding_rin.rdata2 = register_out.rdata2;

    v.rdata1 = forwarding_out.data1;
    v.rdata2 = forwarding_out.data2;

    fp_forwarding_rin.rden1 = v.frden1;
    fp_forwarding_rin.rden2 = v.frden2;
    fp_forwarding_rin.rden3 = v.frden3;
    fp_forwarding_rin.raddr1 = v.raddr1;
    fp_forwarding_rin.raddr2 = v.raddr2;
    fp_forwarding_rin.raddr3 = v.raddr3;
    fp_forwarding_rin.rdata1 = fp_register_out.rdata1;
    fp_forwarding_rin.rdata2 = fp_register_out.rdata2;
    fp_forwarding_rin.rdata3 = fp_register_out.rdata3;

    v.frdata1 = fp_forwarding_out.data1;
    v.frdata2 = fp_forwarding_out.data2;
    v.frdata3 = fp_forwarding_out.data3;

    if ((d.e.stall | d.m.stall) == 1) begin
      v = r;
      v.wren = v.wren_b;
      v.cwren = v.cwren_b;
      v.fwren = v.fwren_b;
      v.branch = v.branch_b;
      v.load = v.load_b;
      v.store = v.store_b;
      v.fload = v.fload_b;
      v.fstore = v.fstore_b;
      v.csreg = v.csreg_b;
      v.division = v.division_b;
      v.mult = v.mult_b;
      v.bitm = v.bitm_b;
      v.bitc = v.bitc_b;
      v.fence = v.fence_b;
      v.ecall = v.ecall_b;
      v.ebreak = v.ebreak_b;
      v.mret = v.mret_b;
      v.wfi = v.wfi_b;
      v.fp = v.fp_b;
      v.jump = v.jump_b;
      v.valid = v.valid_b;
      v.return_pop = v.return_pop_b;
      v.return_push = v.return_push_b;
      v.jump_uncond = v.jump_uncond_b;
      v.jump_rest = v.jump_rest_b;
      v.taken = v.taken_b;
      v.exception = v.exception_b;
    end

    v.clear = csr_out.exception | csr_out.mret | d.e.jump | d.w.clear;

    v.stall = 0;

    v.enable = ~(d.e.stall | a.m.stall | v.clear | d.w.clear);

    alu_in.rdata1 = v.rdata1;
    alu_in.rdata2 = v.rdata2;
    alu_in.imm = v.imm;
    alu_in.sel = v.rden2;
    alu_in.alu_op = v.alu_op;

    v.wdata = alu_out.result;

    bcu_in.rdata1 = v.rdata1;
    bcu_in.rdata2 = v.rdata2;
    bcu_in.enable = v.branch;
    bcu_in.bcu_op = v.bcu_op;

    v.jump = v.jal | v.jalr | bcu_out.branch;

    agu_in.rdata1 = v.rdata1;
    agu_in.imm = v.imm;
    agu_in.pc = v.pc;
    agu_in.auipc = v.auipc;
    agu_in.jal = v.jal;
    agu_in.jalr = v.jalr;
    agu_in.branch = v.branch;
    agu_in.load = v.load;
    agu_in.store = v.store;
    agu_in.lsu_op = v.lsu_op;

    v.address = agu_out.address;
    v.byteenable = agu_out.byteenable;

    if (v.exception == 0) begin
      v.exception = agu_out.exception;
      v.ecause = agu_out.ecause;
      v.etval = agu_out.etval;
      if (v.exception == 1) begin
        if (v.load == 1) begin
          v.load = 0;
          v.wren = 0;
        end else if (v.store == 1) begin
          v.store = 0;
        end else if (v.jump == 1) begin
          v.jump = 0;
          v.wren = 0;
        end
      end
    end

    v.sdata = (v.fstore == 1) ? v.frdata2 : v.rdata2;

    mul_in.rdata1 = v.rdata1;
    mul_in.rdata2 = v.rdata2;
    mul_in.mul_op = v.mul_op;

    v.mdata = mul_out.result;

    bit_alu_in.rdata1 = v.rdata1;
    bit_alu_in.rdata2 = v.rdata2;
    bit_alu_in.imm = v.imm;
    bit_alu_in.sel = v.rden2;
    bit_alu_in.bit_op = v.bit_op;

    v.bdata = bit_alu_out.result;

    div_in.rdata1 = v.rdata1;
    div_in.rdata2 = v.rdata2;
    div_in.enable = v.division & v.enable;
    div_in.div_op = v.div_op;

    v.ddata = div_out.result;
    v.dready = div_out.ready;

    bit_clmul_in.rdata1 = v.rdata1;
    bit_clmul_in.rdata2 = v.rdata2;
    bit_clmul_in.enable = v.bitc & v.enable;
    bit_clmul_in.op = v.bit_op.bit_zbc;

    v.bcdata = bit_clmul_out.result;
    v.bcready = bit_clmul_out.ready;

    if (v.auipc == 1) begin
      v.wdata = v.address;
    end else if (v.lui == 1) begin
      v.wdata = v.imm;
    end else if (v.jal == 1) begin
      v.wdata = v.npc;
    end else if (v.jalr == 1) begin
      v.wdata = v.npc;
    end else if (v.crden == 1) begin
      v.wdata = v.cdata;
    end else if (v.division == 1) begin
      v.wdata = v.ddata;
    end else if (v.mult == 1) begin
      v.wdata = v.mdata;
    end else if (v.bitm == 1) begin
        v.wdata = v.bdata;
    end else if (v.bitc == 1) begin
        v.wdata = v.bcdata;
    end

    csr_alu_in.cdata = v.cdata;
    csr_alu_in.rdata1 = v.rdata1;
    csr_alu_in.imm = v.imm;
    csr_alu_in.sel = v.rden1;
    csr_alu_in.csr_op = v.csr_op;

    v.cdata = csr_alu_out.cdata;

    if (v.division == 1) begin
      if (v.dready == 0) begin
        v.stall = ~(a.m.stall);
      end
    end else if (v.bitc == 1) begin
      if (v.bcready == 0) begin
        v.stall = ~(a.m.stall);
      end
    end

    v.wren_b = v.wren;
    v.cwren_b = v.cwren;
    v.fwren_b = v.fwren;
    v.branch_b = v.branch;
    v.load_b = v.load;
    v.store_b = v.store;
    v.fload_b = v.fload;
    v.fstore_b = v.fstore;
    v.csreg_b = v.csreg;
    v.division_b = v.division;
    v.mult_b = v.mult;
    v.bitm_b = v.bitm;
    v.bitc_b = v.bitc;
    v.fence_b = v.fence;
    v.ecall_b = v.ecall;
    v.ebreak_b = v.ebreak;
    v.mret_b = v.mret;
    v.wfi_b = v.wfi;
    v.fp_b = v.fp;
    v.jump_b = v.jump;
    v.valid_b = v.valid;
    v.return_pop_b = v.return_pop;
    v.return_push_b = v.return_push;
    v.jump_uncond_b = v.jump_uncond;
    v.jump_rest_b = v.jump_rest;
    v.taken_b = v.taken;
    v.exception_b = v.exception;

    if ((v.stall | a.m.stall | v.clear) == 1) begin
      v.wren = 0;
      v.cwren = 0;
      v.fwren = 0;
      v.branch = 0;
      v.load = 0;
      v.store = 0;
      v.fload = 0;
      v.fstore = 0;
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
      v.jump = 0;
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

    if (v.nop == 1) begin
      v.valid = 0;
    end

    rin = v;

    forwarding_ein.wren = r.wren;
    forwarding_ein.waddr = r.waddr;
    forwarding_ein.wdata = r.wdata;

    fp_forwarding_ein.wren = r.fwren;
    fp_forwarding_ein.waddr = r.waddr;
    fp_forwarding_ein.wdata = r.fdata;

    y.pc = v.pc;
    y.npc = v.npc;
    y.wren = v.wren;
    y.cwren = v.cwren;
    y.fwren = v.fwren;
    y.waddr = v.waddr;
    y.caddr = v.caddr;
    y.branch = v.branch;
    y.load = v.load;
    y.store = v.store;
    y.fload = v.fload;
    y.fstore = v.fstore;
    y.csreg = v.csreg;
    y.division = v.division;
    y.mult = v.mult;
    y.bitm = v.bitm;
    y.bitc = v.bitc;
    y.fence = v.fence;
    y.fmt = v.fmt;
    y.rm = v.rm;
    y.fp = v.fp;
    y.valid = v.valid;
    y.jump = v.jump;
    y.wdata = v.wdata;
    y.cdata = v.cdata;
    y.fdata = v.fdata;
    y.sdata = v.sdata;
    y.address = v.address;
    y.byteenable = v.byteenable;
    y.mret = v.mret;
    y.return_pop = v.return_pop;
    y.return_push = v.return_push;
    y.jump_uncond = v.jump_uncond;
    y.jump_rest = v.jump_rest;
    y.taken = v.taken;
    y.exception = v.exception;
    y.ecause = v.ecause;
    y.etval = v.etval;
    y.stall = v.stall;
    y.clear = v.clear;
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
    q.wren = r.wren;
    q.cwren = r.cwren;
    q.fwren = r.fwren;
    q.waddr = r.waddr;
    q.caddr = r.caddr;
    q.branch = r.branch;
    q.load = r.load;
    q.store = r.store;
    q.fload = r.fload;
    q.fstore = r.fstore;
    q.csreg = r.csreg;
    q.division = r.division;
    q.mult = r.mult;
    q.bitm = r.bitm;
    q.bitc = r.bitc;
    q.fence = r.fence;
    q.fmt = r.fmt;
    q.rm = r.rm;
    q.fp = r.fp;
    q.valid = r.valid;
    q.jump = r.jump;
    q.wdata = r.wdata;
    q.cdata = r.cdata;
    q.fdata = r.fdata;
    q.sdata = r.sdata;
    q.address = r.address;
    q.byteenable = r.byteenable;
    q.mret = r.mret;
    q.return_pop = r.return_pop;
    q.return_push = r.return_push;
    q.jump_uncond = r.jump_uncond;
    q.jump_rest = r.jump_rest;
    q.taken = r.taken;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;
    q.stall = r.stall;
    q.clear = r.clear;
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
      r <= init_execute_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
