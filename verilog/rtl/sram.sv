import configure::*;
import wires::*;

module sram #(
    parameter clock_rate
) (
    input logic reset,
    input logic clock,
    input mem_in_type sram_in,
    output mem_out_type sram_out,
    output sram_ce_n,
    output sram_we_n,
    output sram_oe_n,
    output sram_ub_n,
    output sram_lb_n,
    inout [15:0] sram_dq,
    output [17:0] sram_addr
);
  timeunit 1ns; timeprecision 1ps;

  localparam full = clock_rate - 1;

  typedef struct packed {
    logic [31 : 0] counter;
    logic [63 : 0] data;
    logic [7 : 0]  strb;
    logic [15 : 0] dq;
    logic [17 : 0] addr;
    logic [0 : 0]  ce_n;
    logic [0 : 0]  we_n;
    logic [0 : 0]  oe_n;
    logic [0 : 0]  ub_n;
    logic [0 : 0]  lb_n;
    logic [1 : 0]  state;
    logic [0 : 0]  write;
    logic [0 : 0]  read;
    logic [0 : 0]  ready;
  } register_type;

  register_type init_register = 0;

  register_type r, rin, v;

  always_comb begin

    v = r;

    v.counter = v.counter + 1;
    v.ready = 0;
    v.ce_n = 1;
    v.we_n = 1;
    v.oe_n = 1;
    v.ub_n = 1;
    v.lb_n = 1;

    if (v.counter > full) begin
      if (v.write == 1) begin
        if (v.state == 3) begin
          v.ready = 1;
          v.write = 0;
        end
        if (v.state == 2) begin
          v.state = 3;
        end
        if (v.state == 1) begin
          v.state = 2;
        end
        if (v.state == 0) begin
          v.state = 1;
        end
      end
      v.counter = 0;
    end

    if (v.counter > full) begin
      if (v.read == 1) begin
        if (v.state == 1) begin
          v.data[63:48] = sram_dq;
          v.ready = 1;
          v.read = 0;
        end
        if (v.state == 2) begin
          v.data[47:32] = sram_dq;
          v.state = 3;
        end
        if (v.state == 1) begin
          v.data[31:16] = sram_dq;
          v.state = 2;
        end
        if (v.state == 0) begin
          v.data[15:0] = sram_dq;
          v.state = 1;
        end
      end
      v.counter = 0;
    end

    if (sram_in.mem_valid == 1 && sram_in.mem_addr == 0) begin
      v.addr  = sram_in.mem_addr[17:0];
      v.data  = sram_in.mem_wdata;
      v.strb  = sram_in.mem_wstrb;
      v.write = |v.strb;
      v.read  = ~v.write;
      v.state = 0;
    end

    if (v.write == 1) begin
      v.ce_n = 0;
      v.we_n = 0;
      if (v.state == 3) begin
        v.dq   = v.data[63:48];
        v.ub_n = ~v.strb[7];
        v.lb_n = ~v.strb[6];
      end
      if (v.state == 2) begin
        v.dq   = v.data[47:32];
        v.ub_n = ~v.strb[5];
        v.lb_n = ~v.strb[4];
      end
      if (v.state == 1) begin
        v.dq   = v.data[31:16];
        v.ub_n = ~v.strb[3];
        v.lb_n = ~v.strb[2];
      end
      if (v.state == 0) begin
        v.dq   = v.data[15:0];
        v.ub_n = ~v.strb[1];
        v.lb_n = ~v.strb[0];
      end
    end else if (v.read == 1) begin
      v.ce_n = 0;
      v.oe_n = 0;
      v.ub_n = 0;
      v.lb_n = 0;
    end

    rin = v;

  end

  assign sram_out.mem_rdata = r.data;
  assign sram_out.mem_error = 0;
  assign sram_out.mem_ready = r.ready;

  assign sram_ce_n = r.ce_n;
  assign sram_we_n = r.we_n;
  assign sram_oe_n = r.oe_n;
  assign sram_ub_n = r.ub_n;
  assign sram_lb_n = r.lb_n;
  assign sram_addr = r.addr;
  assign sram_dq = r.we_n == 0 ? r.dq : 16'bz;

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
