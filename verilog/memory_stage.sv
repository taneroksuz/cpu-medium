import constants::*;
import wires::*;

module memory_stage
(
  input logic rst,
  input logic clk,
  input lsu_out_type lsu_out,
  output lsu_in_type lsu_in,
  input mem_out_type writebuffer_out,
  output mem_in_type writebuffer_in,
  output forwarding_memory_in_type forwarding_min,
  output register_write_in_type register_win,
  input csr_out_type csr_out,
  output csr_write_in_type csr_win,
  output csr_exception_in_type csr_ein,
  input memory_in_type a,
  input memory_in_type d,
  output memory_out_type y,
  output memory_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  memory_reg_type r,rin = init_memory_reg;
  memory_reg_type v = init_memory_reg;

  always_comb begin

    v = r;

    v.pc = d.e.pc;
    v.wren = d.e.wren;
    v.cwren = d.e.cwren;
    v.waddr = d.e.waddr;
    v.caddr = d.e.caddr;
    v.load = d.e.load;
    v.store = d.e.store;
    v.fence = d.e.fence;
    v.wdata = d.e.wdata;
    v.cdata = d.e.cdata;
    v.valid = d.e.valid;
    v.mret = d.e.mret;
    v.fence = d.e.fence;
    v.byteenable = d.e.byteenable;
    v.exception = d.e.exception;
    v.ecause = d.e.ecause;
    v.etval = d.e.etval;
    v.alu_op = d.e.alu_op;
    v.bcu_op = d.e.bcu_op;
    v.lsu_op = d.e.lsu_op;
    v.csr_op = d.e.csr_op;
    v.div_op = d.e.div_op;
    v.mul_op = d.e.mul_op;
    v.bit_op = d.e.bit_op;

    if (d.m.stall == 1) begin
      v = r;
      v.wren = v.wren_b;
      v.cwren = v.cwren_b;
      v.valid = v.valid_b;
      v.mret = v.mret_b;
      v.fence = v.fence_b;
      v.exception = v.exception_b;
    end

    v.clear = csr_out.exception | csr_out.mret | d.w.clear;

    v.stall = 0;

    writebuffer_in.mem_valid = a.e.load | a.e.store | a.e.fence;
    writebuffer_in.mem_fence = a.e.fence;
    writebuffer_in.mem_instr = 0;
    writebuffer_in.mem_addr = a.e.address;
    writebuffer_in.mem_wdata = store_data(a.e.sdata,a.e.lsu_op.lsu_sb,a.e.lsu_op.lsu_sh,a.e.lsu_op.lsu_sw);
    writebuffer_in.mem_wstrb = (a.e.load == 1) ? 4'h0 : a.e.byteenable;

    lsu_in.ldata = writebuffer_out.mem_rdata;
    lsu_in.byteenable = v.byteenable;
    lsu_in.lsu_op = v.lsu_op;

    v.ldata = lsu_out.result;

    if (v.load == 1 | v.store == 1 | v.fence == 1) begin
      if (writebuffer_out.mem_ready == 0) begin
        v.stall = 1;
      end else if (writebuffer_out.mem_ready == 1) begin
        v.wren = v.load & |v.waddr;
        v.wdata = v.ldata;
      end
    end

    v.wren_b = v.wren;
    v.cwren_b = v.cwren;
    v.valid_b = v.valid;
    v.mret_b = v.mret;
    v.fence_b = v.fence;
    v.exception_b = v.exception;

    if ((v.stall | v.clear) == 1) begin
      v.wren = 0;
      v.cwren = 0;
      v.valid = 0;
      v.mret = 0;
      v.fence = 0;
      v.exception = 0;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    forwarding_min.wren = v.wren;
    forwarding_min.waddr = v.waddr;
    forwarding_min.wdata = v.wdata;

    register_win.wren = v.wren;
    register_win.waddr = v.waddr;
    register_win.wdata = v.wdata;

    csr_win.cwren = v.cwren;
    csr_win.cwaddr = v.caddr;
    csr_win.cdata = v.cdata;

    csr_ein.valid = v.valid;
    csr_ein.mret = v.mret;
    csr_ein.exception = v.exception;
    csr_ein.epc = v.pc;
    csr_ein.ecause = v.ecause;
    csr_ein.etval = v.etval;
    
    rin = v;

    y.cwren = v.cwren;
    y.mret = v.mret;
    y.fence = v.fence;
    y.exception = v.exception;
    y.stall = v.stall;
    y.clear = v.clear;

    y.cwren_b = v.cwren_b;
    y.mret_b = v.mret_b;
    y.fence_b = v.fence_b;
    y.exception_b = v.exception_b;

    q.cwren = r.cwren;
    q.mret = r.mret;
    q.fence = r.fence;
    q.exception = r.exception;
    q.stall = r.stall;
    q.clear = r.clear;

    q.cwren_b = r.cwren_b;
    q.mret_b = r.mret_b;
    q.fence_b = r.fence_b;
    q.exception_b = r.exception_b;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_memory_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
