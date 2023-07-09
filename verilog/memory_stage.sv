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

    v.calc0 = d.e.calc0;
    v.calc1 = d.e.calc1;

    v.pred = d.e.pred;

    if (d.m.stall == 1) begin
      v = r;
      v.calc0.op = r.calc0.op_b;
      v.calc1.op = r.calc1.op_b;
      v.pred = r.pred_b;
    end

    v.stall = 0;

    v.clear = csr_out.trap | csr_out.mret | d.w.clear;

    if ((a.e.calc0.op.load | a.e.calc0.op.store | a.e.calc0.op.fload | a.e.calc0.op.fstore | a.e.calc0.op.fence) == 1) begin
      dmem0_in.mem_valid = a.e.calc0.op.load | a.e.calc0.op.store | a.e.calc0.op.fload | a.e.calc0.op.fstore | a.e.calc0.op.fence;
      dmem0_in.mem_fence = a.e.calc0.op.fence;
      dmem0_in.mem_spec = 0;
      dmem0_in.mem_instr = 0;
      dmem0_in.mem_addr = a.e.calc0.address;
      dmem0_in.mem_wdata = store_data(a.e.calc0.sdata,a.e.calc0.lsu_op.lsu_sb,a.e.calc0.lsu_op.lsu_sh,a.e.calc0.lsu_op.lsu_sw);
      dmem0_in.mem_wstrb = (a.e.calc0.op.load | a.e.calc0.op.fload) == 1 ? 4'h0 : a.e.calc0.byteenable;
    end else begin
      dmem0_in.mem_valid = a.e.calc1.op.load | a.e.calc1.op.store | a.e.calc1.op.fload | a.e.calc1.op.fstore | a.e.calc1.op.fence;
      dmem0_in.mem_fence = a.e.calc1.op.fence;
      dmem0_in.mem_spec = 0;
      dmem0_in.mem_instr = 0;
      dmem0_in.mem_addr = a.e.calc1.address;
      dmem0_in.mem_wdata = store_data(a.e.calc1.sdata,a.e.calc1.lsu_op.lsu_sb,a.e.calc1.lsu_op.lsu_sh,a.e.calc1.lsu_op.lsu_sw);
      dmem0_in.mem_wstrb = (a.e.calc1.op.load | a.e.calc1.op.fload) == 1 ? 4'h0 : a.e.calc1.byteenable;
    end

    dmem1_in.mem_valid = 0;
    dmem1_in.mem_fence = 0;
    dmem1_in.mem_spec = 0;
    dmem1_in.mem_instr = 0;
    dmem1_in.mem_addr = 0;
    dmem1_in.mem_wdata = 0;
    dmem1_in.mem_wstrb = 0;

    lsu0_in.ldata = dmem0_out.mem_rdata;
    lsu0_in.byteenable = v.calc0.byteenable;
    lsu0_in.lsu_op = v.calc0.lsu_op;

    v.calc0.ldata = lsu0_out.result;

    lsu1_in.ldata = dmem0_out.mem_rdata;
    lsu1_in.byteenable = v.calc1.byteenable;
    lsu1_in.lsu_op = v.calc1.lsu_op;

    v.calc1.ldata = lsu1_out.result;

    if (v.calc0.op.load == 1) begin
      v.calc0.wdata = v.calc0.ldata;
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.calc0.op.store == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.calc0.op.fload == 1) begin
      v.calc0.fdata = v.calc0.ldata;
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.calc0.op.fstore == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.calc0.op.fence == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end

    if (v.calc1.op.load == 1) begin
      v.calc1.wdata = v.calc1.ldata;
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.calc1.op.store == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.calc1.op.fload == 1) begin
      v.calc1.fdata = v.calc1.ldata;
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.calc1.op.fstore == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end else if (v.calc1.op.fence == 1) begin
      v.stall = ~(dmem0_out.mem_ready);
    end

    v.calc0.op_b = v.calc0.op;
    v.calc1.op_b = v.calc1.op;

    v.pred_b = v.pred;

    forwarding0_min.wren = v.calc0.op.wren;
    forwarding0_min.waddr = v.calc0.waddr;
    forwarding0_min.wdata = v.calc0.wdata;

    forwarding1_min.wren = v.calc1.op.wren;
    forwarding1_min.waddr = v.calc1.waddr;
    forwarding1_min.wdata = v.calc1.wdata;

    fp_forwarding_min.wren = v.calc0.op.fwren | v.calc1.op.fwren;
    fp_forwarding_min.waddr = v.calc0.op.fwren ? v.calc0.waddr : v.calc1.waddr;
    fp_forwarding_min.wdata = v.calc0.op.fwren ? v.calc0.fdata : v.calc1.fdata;

    if (v.calc0.op.fence == 1) begin
      v.calc1 = init_calculation;
    end

    if (v.stall == 1) begin
      v.calc0.op = init_operation;
      v.calc1.op = init_operation;
    end

    if (v.clear == 1) begin
      v.calc0 = init_calculation;
      v.calc1 = init_calculation;
    end

    if (v.calc0.op_b.fence == 1) begin
      v.calc0.op.fence = 1;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    csr_win.cwren = v.calc0.op.cwren | v.calc1.op.cwren;
    csr_win.cwaddr = v.calc0.op.cwren ? v.calc0.caddr : v.calc1.caddr;
    csr_win.cdata = v.calc0.op.cwren ? v.calc0.cdata : v.calc1.cdata;

    csr_ein.valid = v.calc0.op.valid | v.calc1.op.valid;
    csr_ein.mret = v.calc0.op.mret;
    csr_ein.exception = v.calc0.op.exception | v.calc1.op.exception;
    csr_ein.epc = v.calc0.op.exception ? v.calc0.pc : v.calc1.pc;
    csr_ein.ecause = v.calc0.op.exception ? v.calc0.ecause : v.calc1.ecause;
    csr_ein.etval = v.calc0.op.exception ? v.calc0.etval : v.calc1.etval;

    fp_csr_win.cwren = v.calc0.op.cwren | v.calc1.op.cwren;
    fp_csr_win.cwaddr = v.calc0.op.cwren ? v.calc0.caddr : v.calc1.caddr;
    fp_csr_win.cdata = v.calc0.op.cwren ? v.calc0.cdata : v.calc1.cdata;

    fp_csr_ein.fpu = v.calc0.op.fpuf | v.calc1.op.fpuf;
    fp_csr_ein.fflags = v.calc0.op.fpuf ? v.calc0.flags : v.calc1.flags;
    
    rin = v;

    y.calc0 = v.calc0;
    y.calc1 = v.calc1;
    y.pred = v.pred;
    y.stall = v.stall;

    q.calc0 = r.calc0;
    q.calc1 = r.calc1;
    q.pred = r.pred;
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
