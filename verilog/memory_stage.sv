import constants::*;
import wires::*;
import functions::*;

module memory_stage
(
  input logic reset,
  input logic clock,
  input lsu_out_type lsu0_out,
  output lsu_in_type lsu0_in,
  input lsu_out_type lsu1_out,
  output lsu_in_type lsu1_in,
  input dtim_out_type dmem0_out,
  output dtim_in_type dmem0_in,
  input dtim_out_type dmem1_out,
  output dtim_in_type dmem1_in,
  output forwarding_memory_in_type forwarding0_min,
  output forwarding_memory_in_type forwarding1_min,
  output fp_forwarding_memory_in_type fp_forwarding_min,
  input csr_out_type csr_out,
  output csr_write_in_type csr_win,
  output csr_exception_in_type csr_ein,
  input fp_csr_out_type fp_csr_out,
  output fp_csr_write_in_type fp_csr_win,
  output fp_csr_exception_in_type fp_csr_ein,
  input memory_in_type a,
  input memory_in_type d,
  output memory_out_type y,
  output memory_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  memory_reg_type r,rin;
  memory_reg_type v;

  always_comb begin

    v = r;

    v.instr0 = d.e.instr0;
    v.instr1 = d.e.instr1;
    v.swap = d.e.swap;

    if (d.m.stall == 1) begin
      v = r;
      v.instr0.op = r.instr0.op_b;
      v.instr1.op = r.instr1.op_b;
    end

    v.stall = 0;

    v.clear = csr_out.trap | csr_out.mret | d.w.clear;

    dmem0_in.mem_valid = a.e.instr0.op.load | a.e.instr0.op.store | a.e.instr0.op.fload | a.e.instr0.op.fstore | a.e.instr0.op.fence;
    dmem0_in.mem_fence = a.e.instr0.op.fence;
    dmem0_in.mem_spec = 0;
    dmem0_in.mem_instr = 0;
    dmem0_in.mem_addr = a.e.instr0.address;
    dmem0_in.mem_wdata = store_data(a.e.instr0.sdata,a.e.instr0.lsu_op.lsu_sb,a.e.instr0.lsu_op.lsu_sh,a.e.instr0.lsu_op.lsu_sw);
    dmem0_in.mem_wstrb = (a.e.instr0.op.load | a.e.instr0.op.fload) == 1 ? 4'h0 : a.e.instr0.byteenable;

    dmem1_in.mem_valid = a.e.instr1.op.load | a.e.instr1.op.store;
    dmem1_in.mem_fence = 0;
    dmem1_in.mem_spec = 0;
    dmem1_in.mem_instr = 0;
    dmem1_in.mem_addr = a.e.instr1.address;
    dmem1_in.mem_wdata = store_data(a.e.instr1.sdata,a.e.instr1.lsu_op.lsu_sb,a.e.instr1.lsu_op.lsu_sh,a.e.instr1.lsu_op.lsu_sw);
    dmem1_in.mem_wstrb = a.e.instr1.op.load == 1 ? 4'h0 : a.e.instr1.byteenable;

    lsu0_in.ldata = dmem0_out.mem_rdata;
    lsu0_in.byteenable = v.instr0.byteenable;
    lsu0_in.lsu_op = v.instr0.lsu_op;

    v.instr0.ldata = lsu0_out.result;

    lsu1_in.ldata = dmem1_out.mem_rdata;
    lsu1_in.byteenable = v.instr1.byteenable;
    lsu1_in.lsu_op = v.instr1.lsu_op;

    v.instr1.ldata = lsu1_out.result;

    if (v.instr0.op.load == 1) begin
      v.instr0.wdata = v.instr0.ldata;
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.instr0.op.store == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.instr0.op.fload == 1) begin
      v.instr0.fdata = v.instr0.ldata;
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.instr0.op.fstore == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.instr0.op.fence == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end

    if (v.instr1.op.load == 1) begin
      v.instr1.wdata = v.instr1.ldata;
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.instr1.op.store == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end

    v.instr0.op_b = v.instr0.op;
    v.instr1.op_b = v.instr1.op;

    forwarding0_min.wren = v.instr0.op.wren;
    forwarding0_min.waddr = v.instr0.waddr;
    forwarding0_min.wdata = v.instr0.wdata;

    forwarding1_min.wren = v.instr1.op.wren;
    forwarding1_min.waddr = v.instr1.waddr;
    forwarding1_min.wdata = v.instr1.wdata;

    fp_forwarding_min.wren = v.instr0.op.fwren;
    fp_forwarding_min.waddr = v.instr0.waddr;
    fp_forwarding_min.wdata = v.instr0.fdata;

    if (v.swap == 0 && v.instr0.op.fence == 1) begin
      v.instr1 = init_instruction_basic;
    end

    if ((v.stall | v.clear) == 1) begin
      v.instr0.op = init_operation_complex;
      v.instr1.op = init_operation_basic;
    end

    if (v.instr0.op_b.fence == 1) begin
      v.instr0.op.fence = 1;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    csr_win.cwren = v.instr0.op.cwren;
    csr_win.cwaddr = v.instr0.caddr;
    csr_win.cdata = v.instr0.cdata;

    csr_ein.valid = v.instr0.op.valid | v.instr1.op.valid;
    csr_ein.mret = v.instr0.op.mret;
    csr_ein.exception = v.instr0.op.exception;
    csr_ein.epc = v.instr0.op.exception ? v.instr0.pc : v.instr1.pc;
    csr_ein.ecause = v.instr0.op.exception ? v.instr0.ecause : v.instr1.ecause;
    csr_ein.etval = v.instr0.op.exception ? v.instr0.etval : v.instr1.etval;

    fp_csr_win.cwren = v.instr0.op.cwren;
    fp_csr_win.cwaddr = v.instr0.caddr;
    fp_csr_win.cdata = v.instr0.cdata;

    fp_csr_ein.fpu = v.instr0.op.fpuf;
    fp_csr_ein.fflags = v.instr0.flags;
    
    rin = v;

    y.instr0 = v.instr0;
    y.instr1 = v.instr1;
    y.swap = v.swap;
    y.stall = v.stall;

    q.instr0 = r.instr0;
    q.instr1 = r.instr1;
    q.swap = r.swap;
    q.stall = r.stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_memory_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
