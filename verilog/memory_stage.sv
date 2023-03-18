import constants::*;
import wires::*;
import functions::*;

module memory_stage
(
  input logic reset,
  input logic clock,
  input lsu_out_type lsu_out,
  output lsu_in_type lsu_in,
  input mem_out_type storebuffer_out,
  output mem_in_type storebuffer_in,
  output forwarding_memory_in_type forwarding_min,
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

    v.pc = d.e.pc;
    v.wren = d.e.wren;
    v.cwren = d.e.cwren;
    v.fwren = d.e.fwren;
    v.waddr = d.e.waddr;
    v.caddr = d.e.caddr;
    v.load = d.e.load;
    v.store = d.e.store;
    v.fload = d.e.fload;
    v.fstore = d.e.fstore;
    v.fence = d.e.fence;
    v.wdata = d.e.wdata;
    v.cdata = d.e.cdata;
    v.fdata = d.e.fdata;
    v.fpu = d.e.fpu;
    v.fpuf = d.e.fpuf;
    v.valid = d.e.valid;
    v.mret = d.e.mret;
    v.byteenable = d.e.byteenable;
    v.exception = d.e.exception;
    v.ecause = d.e.ecause;
    v.etval = d.e.etval;
    v.flags = d.e.flags;
    v.alu_op = d.e.alu_op;
    v.bcu_op = d.e.bcu_op;
    v.lsu_op = d.e.lsu_op;
    v.csr_op = d.e.csr_op;
    v.div_op = d.e.div_op;
    v.mul_op = d.e.mul_op;
    v.bit_op = d.e.bit_op;
    v.fpu_op = d.e.fpu_op;

    if (d.m.stall == 1) begin
      v = r;
      v.wren = v.wren_b;
      v.cwren = v.cwren_b;
      v.fwren = v.fwren_b;
      v.fpu = v.fpu_b;
      v.fpuf = v.fpuf_b;
      v.valid = v.valid_b;
      v.mret = v.mret_b;
      v.fence = v.fence_b;
      v.exception = v.exception_b;
    end

    v.clear = csr_out.trap | csr_out.mret | d.w.clear;

    v.stall = 0;

    storebuffer_in.mem_valid = a.e.load | a.e.store | a.e.fload | a.e.fstore | a.e.fence;
    storebuffer_in.mem_fence = a.e.fence;
    storebuffer_in.mem_instr = 0;
    storebuffer_in.mem_addr = a.e.address;
    storebuffer_in.mem_wdata = store_data(a.e.sdata,a.e.lsu_op.lsu_sb,a.e.lsu_op.lsu_sh,a.e.lsu_op.lsu_sw);
    storebuffer_in.mem_wstrb = ((a.e.load | a.e.fload) == 1) ? 4'h0 : a.e.byteenable;

    lsu_in.ldata = storebuffer_out.mem_rdata;
    lsu_in.byteenable = v.byteenable;
    lsu_in.lsu_op = v.lsu_op;

    v.ldata = lsu_out.result;

    if (v.load == 1) begin
      v.wdata = v.ldata;
      v.stall = ~(storebuffer_out.mem_ready);
    end else if (v.store == 1) begin
      v.stall = ~(storebuffer_out.mem_ready);
    end else if (v.fload == 1) begin
      v.fdata = v.ldata;
      v.stall = ~(storebuffer_out.mem_ready);
    end else if (v.fstore == 1) begin
      v.stall = ~(storebuffer_out.mem_ready);
    end else if (v.fence == 1) begin
      v.stall = ~(storebuffer_out.mem_ready);
    end

    v.wren_b = v.wren;
    v.cwren_b = v.cwren;
    v.fwren_b = v.fwren;
    v.fpu_b = v.fpu;
    v.fpuf_b = v.fpuf;
    v.valid_b = v.valid;
    v.mret_b = v.mret;
    v.fence_b = v.fence;
    v.exception_b = v.exception;

    if ((v.stall | v.clear) == 1) begin
      v.wren = 0;
      v.cwren = 0;
      v.fwren = 0;
      v.fpu = 0;
      v.fpuf = 0;
      v.valid = 0;
      v.mret = 0;
      v.fence = 0;
      v.exception = 0;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    csr_win.cwren = v.cwren;
    csr_win.cwaddr = v.caddr;
    csr_win.cdata = v.cdata;

    csr_ein.valid = v.valid;
    csr_ein.mret = v.mret;
    csr_ein.exception = v.exception;
    csr_ein.epc = v.pc;
    csr_ein.ecause = v.ecause;
    csr_ein.etval = v.etval;

    fp_csr_win.cwren = v.cwren;
    fp_csr_win.cwaddr = v.caddr;
    fp_csr_win.cdata = v.cdata;

    fp_csr_ein.fpu = v.fpuf;
    fp_csr_ein.fflags = v.flags;

    forwarding_min.wren = v.wren;
    forwarding_min.waddr = v.waddr;
    forwarding_min.wdata = v.wdata;

    fp_forwarding_min.wren = v.fwren;
    fp_forwarding_min.waddr = v.waddr;
    fp_forwarding_min.wdata = v.fdata;
    
    rin = v;

    y.wren = v.wren;
    y.cwren = v.cwren;
    y.fwren = v.fwren;
    y.waddr = v.waddr;
    y.wdata = v.wdata;
    y.fdata = v.fdata;
    y.fpu = v.fpu;
    y.fpuf = v.fpuf;
    y.mret = v.mret;
    y.fence = v.fence;
    y.exception = v.exception;
    y.stall = v.stall;
    y.clear = v.clear;

    q.wren = r.wren;
    q.cwren = r.cwren;
    q.fwren = r.fwren;
    q.waddr = r.waddr;
    q.wdata = r.wdata;
    q.fdata = r.fdata;
    q.cwren = r.cwren;
    q.fpu = r.fpu;
    q.fpuf = r.fpuf;
    q.mret = r.mret;
    q.fence = r.fence;
    q.exception = r.exception;
    q.stall = r.stall;
    q.clear = r.clear;

  end

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      r <= init_memory_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
