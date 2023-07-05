import constants::*;
import wires::*;

module execute_stage
(
  input logic reset,
  input logic clock,
  input alu_out_type alu0_out,
  output alu_in_type alu0_in,
  input alu_out_type alu1_out,
  output alu_in_type alu1_in,
  input agu_out_type agu0_out,
  output agu_in_type agu0_in,
  input agu_out_type agu1_out,
  output agu_in_type agu1_in,
  input bcu_out_type bcu0_out,
  output bcu_in_type bcu0_in,
  input bcu_out_type bcu1_out,
  output bcu_in_type bcu1_in,
  input csr_alu_out_type csr_alu_out,
  output csr_alu_in_type csr_alu_in,
  input div_out_type div_out,
  output div_in_type div_in,
  input mul_out_type mul_out,
  output mul_in_type mul_in,
  input bit_alu_out_type bit_alu0_out,
  output bit_alu_in_type bit_alu0_in,
  input bit_alu_out_type bit_alu1_out,
  output bit_alu_in_type bit_alu1_in,
  input bit_clmul_out_type bit_clmul_out,
  output bit_clmul_in_type bit_clmul_in,
  input fp_execute_out_type fp_execute_out,
  output fp_execute_in_type fp_execute_in,
  input register_out_type register0_out,
  input register_out_type register1_out,
  input fp_register_out_type fp_register_out,
  input forwarding_out_type forwarding0_out,
  input forwarding_out_type forwarding1_out,
  output forwarding_register_in_type forwarding0_rin,
  output forwarding_register_in_type forwarding1_rin,
  input fp_forwarding_out_type fp_forwarding_out,
  output fp_forwarding_register_in_type fp_forwarding_rin,
  input csr_out_type csr_out,
  input btac_out_type btac_out,
  input execute_in_type a,
  input execute_in_type d,
  output execute_out_type y,
  output execute_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  execute_reg_type r,rin;
  execute_reg_type v;

  always_comb begin

    v = r;

    v.calc0 = d.i.calc0;
    v.calc1 = d.i.calc1;

    forwarding0_rin.rden1 = v.calc0.op.rden1;
    forwarding0_rin.rden2 = v.calc0.op.rden2;
    forwarding0_rin.raddr1 = v.calc0.raddr1;
    forwarding0_rin.raddr2 = v.calc0.raddr2;
    forwarding0_rin.rdata1 = register0_out.rdata1;
    forwarding0_rin.rdata2 = register0_out.rdata2;

    v.calc0.rdata1 = forwarding0_out.data1;
    v.calc0.rdata2 = forwarding0_out.data2;

    forwarding1_rin.rden1 = v.calc1.op.rden1;
    forwarding1_rin.rden2 = v.calc1.op.rden2;
    forwarding1_rin.raddr1 = v.calc1.raddr1;
    forwarding1_rin.raddr2 = v.calc1.raddr2;
    forwarding1_rin.rdata1 = register1_out.rdata1;
    forwarding1_rin.rdata2 = register1_out.rdata2;

    v.calc1.rdata1 = forwarding1_out.data1;
    v.calc1.rdata2 = forwarding1_out.data2;

    fp_forwarding_rin.rden1 = v.calc0.op.frden1 | v.calc1.op.frden1;
    fp_forwarding_rin.rden2 = v.calc0.op.frden2 | v.calc1.op.frden2;
    fp_forwarding_rin.rden3 = v.calc0.op.frden3 | v.calc1.op.frden3;
    fp_forwarding_rin.raddr1 = v.calc0.op.frden1 ? v.calc0.raddr1 : v.calc1.raddr1;
    fp_forwarding_rin.raddr2 = v.calc0.op.frden2 ? v.calc0.raddr2 : v.calc1.raddr2;
    fp_forwarding_rin.raddr3 = v.calc0.op.frden3 ? v.calc0.raddr3 : v.calc1.raddr3;
    fp_forwarding_rin.rdata1 = fp_register_out.rdata1;
    fp_forwarding_rin.rdata2 = fp_register_out.rdata2;
    fp_forwarding_rin.rdata3 = fp_register_out.rdata3;

    v.calc0.frdata1 = fp_forwarding_out.data1;
    v.calc0.frdata2 = fp_forwarding_out.data2;
    v.calc0.frdata3 = fp_forwarding_out.data3;

    v.calc1.frdata1 = fp_forwarding_out.data1;
    v.calc1.frdata2 = fp_forwarding_out.data2;
    v.calc1.frdata3 = fp_forwarding_out.data3;

    if ((v.calc0.op.fpu & v.calc0.op.rden1) == 1) begin
      v.calc0.frdata1 = v.calc0.rdata1;
    end

    if ((v.calc1.op.fpu & v.calc1.op.rden1) == 1) begin
      v.calc1.frdata1 = v.calc1.rdata1;
    end

    if ((d.e.stall | d.m.stall) == 1) begin
      v = r;
      v.calc0.op = r.calc0.op_b;
      v.calc1.op = r.calc1.op_b;
    end

    v.stall = 0;

    v.clear = d.e.calc0.op.exception | d.e.calc0.op.mret | csr_out.trap | csr_out.mret | btac_out.pred_miss | d.w.clear;

    v.enable = ~(d.e.stall | a.m.stall | v.clear);

    alu0_in.rdata1 = v.calc0.rdata1;
    alu0_in.rdata2 = v.calc0.rdata2;
    alu0_in.imm = v.calc0.imm;
    alu0_in.sel = v.calc0.op.rden2;
    alu0_in.alu_op = v.calc0.alu_op;

    v.calc0.wdata = alu0_out.result;

    alu1_in.rdata1 = v.calc1.rdata1;
    alu1_in.rdata2 = v.calc1.rdata2;
    alu1_in.imm = v.calc1.imm;
    alu1_in.sel = v.calc1.op.rden2;
    alu1_in.alu_op = v.calc1.alu_op;

    v.calc1.wdata = alu1_out.result;

    bcu0_in.rdata1 = v.calc0.rdata1;
    bcu0_in.rdata2 = v.calc0.rdata2;
    bcu0_in.enable = v.calc0.op.branch;
    bcu0_in.bcu_op = v.calc0.bcu_op;

    v.calc0.op.jump = v.calc0.op.jal | v.calc0.op.jalr | bcu0_out.branch;

    bcu1_in.rdata1 = v.calc1.rdata1;
    bcu1_in.rdata2 = v.calc1.rdata2;
    bcu1_in.enable = v.calc1.op.branch;
    bcu1_in.bcu_op = v.calc1.bcu_op;

    v.calc1.op.jump = v.calc1.op.jal | v.calc1.op.jalr | bcu1_out.branch;

    agu0_in.rdata1 = v.calc0.rdata1;
    agu0_in.imm = v.calc0.imm;
    agu0_in.pc = v.calc0.pc;
    agu0_in.auipc = v.calc0.op.auipc;
    agu0_in.jal = v.calc0.op.jal;
    agu0_in.jalr = v.calc0.op.jalr;
    agu0_in.branch = v.calc0.op.branch;
    agu0_in.load = v.calc0.op.load | v.calc0.op.fload;
    agu0_in.store = v.calc0.op.store | v.calc0.op.fstore;
    agu0_in.lsu_op = v.calc0.lsu_op;

    v.calc0.address = agu0_out.address;
    v.calc0.byteenable = agu0_out.byteenable;

    agu1_in.rdata1 = v.calc1.rdata1;
    agu1_in.imm = v.calc1.imm;
    agu1_in.pc = v.calc1.pc;
    agu1_in.auipc = v.calc1.op.auipc;
    agu1_in.jal = v.calc1.op.jal;
    agu1_in.jalr = v.calc1.op.jalr;
    agu1_in.branch = v.calc1.op.branch;
    agu1_in.load = v.calc1.op.load;
    agu1_in.store = v.calc1.op.store;
    agu1_in.lsu_op = v.calc1.lsu_op;

    v.calc1.address = agu1_out.address;
    v.calc1.byteenable = agu1_out.byteenable;

    if (v.calc0.op.exception == 1) begin
      v.calc0.op.exception = 1;
      v.calc0.ecause = except_illegal_instruction;
      v.calc0.etval = v.calc0.instr;
    end else if (v.calc0.op.ebreak == 1) begin
      v.calc0.op.exception = 1;
      v.calc0.ecause = except_breakpoint;
      v.calc0.etval = v.calc0.instr;
    end else if (v.calc0.op.ecall == 1) begin
      v.calc0.op.exception = 1;
      v.calc0.ecause = except_env_call_mach;
      v.calc0.etval = v.calc0.instr;
    end else begin
      v.calc0.op.exception = agu0_out.exception;
      v.calc0.ecause = agu0_out.ecause;
      v.calc0.etval = agu0_out.etval;
      if (v.calc0.op.exception == 1) begin
        if ((v.calc0.op.load | v.calc0.op.fload) == 1) begin
          v.calc0.op.load = 0;
          v.calc0.op.fload = 0;
          v.calc0.op.wren = 0;
        end else if ((v.calc0.op.store | v.calc0.op.fstore) == 1) begin
          v.calc0.op.store = 0;
          v.calc0.op.fstore = 0;
        end else if (v.calc0.op.jump == 1) begin
          v.calc0.op.jump = 0;
          v.calc0.op.wren = 0;
        end
      end
    end

    if (v.calc1.op.exception == 1) begin
      v.calc1.op.exception = 1;
      v.calc1.ecause = except_illegal_instruction;
      v.calc1.etval = v.calc1.instr;
    end else if (v.calc1.op.ebreak == 1) begin
      v.calc1.op.exception = 1;
      v.calc1.ecause = except_breakpoint;
      v.calc1.etval = v.calc1.instr;
    end else if (v.calc1.op.ecall == 1) begin
      v.calc1.op.exception = 1;
      v.calc1.ecause = except_env_call_mach;
      v.calc1.etval = v.calc1.instr;
    end else begin
      v.calc1.op.exception = agu1_out.exception;
      v.calc1.ecause = agu1_out.ecause;
      v.calc1.etval = agu1_out.etval;
      if (v.calc1.op.exception == 1) begin
        if ((v.calc1.op.load | v.calc1.op.fload) == 1) begin
          v.calc1.op.load = 0;
          v.calc1.op.fload = 0;
          v.calc1.op.wren = 0;
        end else if ((v.calc1.op.store | v.calc1.op.fstore) == 1) begin
          v.calc1.op.store = 0;
          v.calc1.op.fstore = 0;
        end else if (v.calc1.op.jump == 1) begin
          v.calc1.op.jump = 0;
          v.calc1.op.wren = 0;
        end
      end
    end

    v.calc0.sdata = (v.calc0.op.fstore == 1) ? v.calc0.frdata2 : v.calc0.rdata2;
    v.calc1.sdata = (v.calc1.op.fstore == 1) ? v.calc1.frdata2 : v.calc1.rdata2;

    mul_in.rdata1 = v.calc0.op.mult ? v.calc0.rdata1 : v.calc1.rdata1;
    mul_in.rdata2 = v.calc0.op.mult ? v.calc0.rdata2 : v.calc1.rdata2;
    mul_in.mul_op = v.calc0.op.mult ? v.calc0.mul_op : v.calc1.mul_op;

    v.calc0.mdata = mul_out.result;
    v.calc1.mdata = mul_out.result;

    bit_alu0_in.rdata1 = v.calc0.rdata1;
    bit_alu0_in.rdata2 = v.calc0.rdata2;
    bit_alu0_in.imm = v.calc0.imm;
    bit_alu0_in.sel = v.calc0.op.rden2;
    bit_alu0_in.bit_op = v.calc0.bit_op;

    v.calc0.bdata = bit_alu0_out.result;

    bit_alu1_in.rdata1 = v.calc1.rdata1;
    bit_alu1_in.rdata2 = v.calc1.rdata2;
    bit_alu1_in.imm = v.calc1.imm;
    bit_alu1_in.sel = v.calc1.op.rden2;
    bit_alu1_in.bit_op = v.calc1.bit_op;

    v.calc1.bdata = bit_alu1_out.result;

    div_in.rdata1 = v.calc0.op.division ? v.calc0.rdata1 : v.calc1.rdata1;
    div_in.rdata2 = v.calc0.op.division ? v.calc0.rdata2 : v.calc1.rdata2;
    div_in.div_op = v.calc0.op.division ? v.calc0.div_op : v.calc1.div_op;
    div_in.enable = (v.calc0.op.division | v.calc1.op.division) & v.enable;

    v.calc0.ddata = div_out.result;
    v.calc1.ddata = div_out.result;
    v.calc0.dready = div_out.ready;
    v.calc1.dready = div_out.ready;

    bit_clmul_in.rdata1 = v.calc0.op.bitc ? v.calc0.rdata1 : v.calc1.rdata1;
    bit_clmul_in.rdata2 = v.calc0.op.bitc ? v.calc0.rdata2 : v.calc1.rdata2;
    bit_clmul_in.op = v.calc0.op.bitc ? v.calc0.bit_op.bit_zbc : v.calc1.bit_op.bit_zbc;
    bit_clmul_in.enable = (v.calc0.op.bitc | v.calc1.op.bitc) & v.enable;

    v.calc0.bcdata = bit_clmul_out.result;
    v.calc1.bcdata = bit_clmul_out.result;
    v.calc0.bcready = bit_clmul_out.ready;
    v.calc1.bcready = bit_clmul_out.ready;

    fp_execute_in.data1 = v.calc0.op.fpu ? v.calc0.frdata1 : v.calc1.frdata1;
    fp_execute_in.data2 = v.calc0.op.fpu ? v.calc0.frdata2 : v.calc1.frdata2;
    fp_execute_in.data3 = v.calc0.op.fpu ? v.calc0.frdata3 : v.calc1.frdata3;
    fp_execute_in.fpu_op = v.calc0.op.fpu ? v.calc0.fpu_op : v.calc1.fpu_op;
    fp_execute_in.fmt = v.calc0.op.fpu ? v.calc0.fmt : v.calc1.fmt;
    fp_execute_in.rm = v.calc0.op.fpu ? v.calc0.rm : v.calc1.rm;
    fp_execute_in.enable = (v.calc0.op.fpu | v.calc1.op.fpu) & v.enable;

    v.calc0.fdata = fp_execute_out.result;
    v.calc1.fdata = fp_execute_out.result;
    v.calc0.flags = fp_execute_out.flags;
    v.calc1.flags = fp_execute_out.flags;
    v.calc0.fready = fp_execute_out.ready;
    v.calc1.fready = fp_execute_out.ready;

    if (v.calc0.op.auipc == 1) begin
      v.calc0.wdata = v.calc0.address;
    end else if (v.calc0.op.lui == 1) begin
      v.calc0.wdata = v.calc0.imm;
    end else if (v.calc0.op.jal == 1) begin
      v.calc0.wdata = v.calc0.npc;
    end else if (v.calc0.op.jalr == 1) begin
      v.calc0.wdata = v.calc0.npc;
    end else if (v.calc0.op.crden == 1) begin
      v.calc0.wdata = v.calc0.cdata;
    end else if (v.calc0.op.division == 1) begin
      v.calc0.wdata = v.calc0.ddata;
    end else if (v.calc0.op.mult == 1) begin
      v.calc0.wdata = v.calc0.mdata;
    end else if (v.calc0.op.bitm == 1) begin
      v.calc0.wdata = v.calc0.bdata;
    end else if (v.calc0.op.bitc == 1) begin
      v.calc0.wdata = v.calc0.bcdata;
    end else if (v.calc0.op.fpu == 1) begin
      v.calc0.wdata = v.calc0.fdata;
    end

    if (v.calc1.op.auipc == 1) begin
      v.calc1.wdata = v.calc1.address;
    end else if (v.calc1.op.lui == 1) begin
      v.calc1.wdata = v.calc1.imm;
    end else if (v.calc1.op.jal == 1) begin
      v.calc1.wdata = v.calc1.npc;
    end else if (v.calc1.op.jalr == 1) begin
      v.calc1.wdata = v.calc1.npc;
    end else if (v.calc1.op.crden == 1) begin
      v.calc1.wdata = v.calc1.cdata;
    end else if (v.calc1.op.division == 1) begin
      v.calc1.wdata = v.calc1.ddata;
    end else if (v.calc1.op.mult == 1) begin
      v.calc1.wdata = v.calc1.mdata;
    end else if (v.calc1.op.bitm == 1) begin
      v.calc1.wdata = v.calc1.bdata;
    end else if (v.calc1.op.bitc == 1) begin
      v.calc1.wdata = v.calc1.bcdata;
    end else if (v.calc1.op.fpu == 1) begin
      v.calc1.wdata = v.calc1.fdata;
    end

    csr_alu_in.cdata = v.calc0.op.csreg ? v.calc0.cdata : v.calc1.cdata;
    csr_alu_in.rdata1 = v.calc0.op.csreg ? v.calc0.rdata1 : v.calc1.rdata1;
    csr_alu_in.imm = v.calc0.op.csreg ? v.calc0.imm : v.calc1.imm;
    csr_alu_in.sel = v.calc0.op.csreg ? v.calc0.op.rden1 : v.calc1.op.rden1;
    csr_alu_in.csr_op = v.calc0.op.csreg ? v.calc0.csr_op : v.calc1.csr_op;

    v.calc0.cdata = csr_alu_out.cdata;
    v.calc1.cdata = csr_alu_out.cdata;

    if (v.calc0.op.division == 1) begin
      if (v.calc0.dready == 0) begin
        v.stall = ~(a.m.stall);
      end
    end else if (v.calc0.op.bitc == 1) begin
      if (v.calc0.bcready == 0) begin
        v.stall = ~(a.m.stall);
      end
    end else if (v.calc0.op.fpuc == 1) begin
      if (v.calc0.fready == 0) begin
        v.stall = ~(a.m.stall);
      end
    end

    if (v.calc1.op.division == 1) begin
      if (v.calc1.dready == 0) begin
        v.stall = ~(a.m.stall);
      end
    end else if (v.calc1.op.bitc == 1) begin
      if (v.calc1.bcready == 0) begin
        v.stall = ~(a.m.stall);
      end
    end else if (v.calc1.op.fpuc == 1) begin
      if (v.calc1.fready == 0) begin
        v.stall = ~(a.m.stall);
      end
    end

    v.calc0.op_b = v.calc0.op;
    v.calc1.op_b = v.calc1.op;

    if ((v.calc0.op.fence | v.calc0.op.exception | v.calc0.op.mret | v.calc0.op.jump) == 1) begin
      v.calc1 = init_calculation;
    end

    if ((v.stall | a.m.stall) == 1) begin
      v.calc0.op = init_operation;
      v.calc1.op = init_operation;
    end

    if (v.clear == 1) begin
      v.calc0 = init_calculation;
      v.calc1 = init_calculation;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    rin = v;

    y.calc0 = v.calc0;
    y.calc1 = v.calc1;
    y.stall = v.stall;

    q.calc0 = r.calc0;
    q.calc1 = r.calc1;
    q.stall = r.stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_execute_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
