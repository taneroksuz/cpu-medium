import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic rst,
  input logic clk,
  input csr_out_type csr_out,
  input mem_out_type prefetch_out,
  output mem_in_type prefetch_in,
  input fetch_in_type a,
  input fetch_in_type d,
  output fetch_out_type y,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  fetch_reg_type r,rin = init_fetch_reg;
  fetch_reg_type v = init_fetch_reg;

  always_comb begin

    v = r;

    v.valid = ~(a.d.stall | a.e.stall | a.m.stall | d.w.clear);
    v.fence = d.d.fence;
    v.stall = v.stall | a.d.stall | a.e.stall | a.m.stall | d.w.clear;

    if (csr_out.exception == 1) begin
      v.pc = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.pc = csr_out.mepc;
    end else if (d.e.jump == 1) begin
      v.pc = d.e.address;
    end else if (v.stall == 0) begin
      v.pc = v.pc + ((v.instr[1:0] == 2'b11) ? 4 : 2);
    end

    prefetch_in.mem_valid = v.valid;
    prefetch_in.mem_fence = v.fence;
    prefetch_in.mem_instr = 1;
    prefetch_in.mem_addr = v.pc;
    prefetch_in.mem_wdata = 0;
    prefetch_in.mem_wstrb = 0;

    if (prefetch_out.mem_ready == 1) begin
      v.instr = prefetch_out.mem_rdata;
      v.stall = 0;
    end else begin
      v.instr = nop_instr;
      v.stall = 1;
    end

    rin = v;

    y.pc = v.pc;
    y.instr = v.instr;
    y.exception = v.exception;
    y.ecause = v.ecause;
    y.etval = v.etval;

    q.pc = r.pc;
    q.instr = r.instr;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
