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
  output forwarding_execute_in_type forwarding_ein,
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
    v.waddr = d.d.waddr;
    v.raddr1 = d.d.raddr1;
    v.raddr2 = d.d.raddr2;
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
    v.valid = d.d.valid;
    v.rdata1 = d.d.rdata1;
    v.rdata2 = d.d.rdata2;
    v.cdata = d.d.cdata;
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

    if ((d.e.stall | d.m.stall) == 1) begin
      v = r;
      v.wren = v.wren_b;
      v.cwren = v.cwren_b;
      v.load = v.load_b;
      v.store = v.store_b;
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
      v.jump = v.jump_b;
      v.valid = v.valid_b;
      v.exception = v.exception_b;
    end

    v.clear = csr_out.exception | csr_out.mret | d.e.jump | d.w.clear;

    v.stall = 0;

    v.enable = ~(d.e.stall | a.m.stall | d.w.clear);

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

    v.sdata = v.rdata2;

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
    v.load_b = v.load;
    v.store_b = v.store;
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
    v.jump_b = v.jump;
    v.valid_b = v.valid;
    v.exception_b = v.exception;

    if ((v.stall | a.m.stall | v.clear) == 1) begin
      v.wren = 0;
      v.cwren = 0;
      v.load = 0;
      v.store = 0;
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
      v.jump = 0;
      v.valid = 0;
      v.exception = 0;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    if (v.nop == 1) begin
      v.valid = 0;
    end

    forwarding_ein.wren = v.wren;
    forwarding_ein.waddr = v.waddr;
    forwarding_ein.wdata = v.wdata;

    rin = v;

    y.pc = v.pc;
    y.wren = v.wren;
    y.cwren = v.cwren;
    y.waddr = v.waddr;
    y.caddr = v.caddr;
    y.branch = v.branch;
    y.load = v.load;
    y.store = v.store;
    y.csreg = v.csreg;
    y.division = v.division;
    y.mult = v.mult;
    y.bitm = v.bitm;
    y.bitc = v.bitc;
    y.fence = v.fence;
    y.jump = v.jump;
    y.valid = v.valid;
    y.wdata = v.wdata;
    y.cdata = v.cdata;
    y.sdata = v.sdata;
    y.address = v.address;
    y.byteenable = v.byteenable;
    y.mret = v.mret;
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

    y.wren_b = v.wren_b;
    y.cwren_b = v.cwren_b;
    y.load_b = v.load_b;
    y.store_b = v.store_b;
    y.csreg_b = v.csreg_b;
    y.division_b = v.division_b;
    y.mult_b = v.mult_b;
    y.bitm_b = v.bitm_b;
    y.bitc_b = v.bitc_b;
    y.fence_b = v.fence_b;
    y.ecall_b = v.ecall_b;
    y.ebreak_b = v.ebreak_b;
    y.mret_b = v.mret_b;
    y.wfi_b = v.wfi_b;
    y.jump_b = v.jump_b;
    y.valid_b = v.valid_b;
    y.exception_b = v.exception_b;

    q.pc = r.pc;
    q.wren = r.wren;
    q.cwren = r.cwren;
    q.waddr = r.waddr;
    q.caddr = r.caddr;
    q.branch = r.branch;
    q.load = r.load;
    q.store = r.store;
    q.csreg = r.csreg;
    q.division = r.division;
    q.mult = r.mult;
    q.bitm = r.bitm;
    q.bitc = r.bitc;
    q.fence = r.fence;
    q.jump = r.jump;
    q.valid = r.valid;
    q.wdata = r.wdata;
    q.cdata = r.cdata;
    q.sdata = r.sdata;
    q.address = r.address;
    q.byteenable = r.byteenable;
    q.mret = r.mret;
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

    q.wren_b = r.wren_b;
    q.cwren_b = r.cwren_b;
    q.load_b = r.load_b;
    q.store_b = r.store_b;
    q.csreg_b = r.csreg_b;
    q.division_b = r.division_b;
    q.mult_b = r.mult_b;
    q.bitm_b = r.bitm_b;
    q.bitc_b = r.bitc_b;
    q.fence_b = r.fence_b;
    q.ecall_b = r.ecall_b;
    q.ebreak_b = r.ebreak_b;
    q.mret_b = r.mret_b;
    q.wfi_b = r.wfi_b;
    q.jump_b = r.jump_b;
    q.valid_b = r.valid_b;
    q.exception_b = r.exception_b;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_execute_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
