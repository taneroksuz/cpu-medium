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
  output csr_memory_in_type csr_min,
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

    v.wren = d.e.wren;
    v.waddr = d.e.waddr;
    v.load = d.e.load;
    v.store = d.e.store;
    v.fence = d.e.fence;
    v.wdata = d.e.wdata;
    v.byteenable = d.e.byteenable;
    v.lsu_op = d.e.lsu_op;

    if (d.m.stall == 1) begin
      v = r;
    end

    v.clear = d.w.clear;

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

    if ((v.stall | v.clear) == 1) begin
      v.wren = 0;
      v.clear = 0;
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

    csr_min.valid = 0;
    csr_min.exception = 0;
    csr_min.epc = 0;
    csr_min.ecause = 0;
    csr_min.etval = 0;
    
    rin = v;

    y.stall = v.stall;
    y.clear = v.clear;

    q.stall = r.stall;
    q.clear = r.clear;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_memory_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
