package storebuffer_wires;
  timeunit 1ns; timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(storebuffer_depth - 1);

  typedef struct packed {
    logic [depth-1 : 0] raddr0;
    logic [depth-1 : 0] raddr1;
    logic [0 : 0] wen0;
    logic [0 : 0] wen1;
    logic [depth-1 : 0] waddr0;
    logic [depth-1 : 0] waddr1;
    logic [95 : 0] wdata0;
    logic [95 : 0] wdata1;
  } storebuffer_reg_in_type;

  typedef struct packed {
    logic [95 : 0] rdata0;
    logic [95 : 0] rdata1;
  } storebuffer_reg_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import storebuffer_wires::*;

module storebuffer_reg (
    input logic clock,
    input storebuffer_reg_in_type storebuffer_reg_in,
    output storebuffer_reg_out_type storebuffer_reg_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(storebuffer_depth - 1);

  logic [95:0] storebuffer_reg_array[0:storebuffer_depth-1] = '{default: '0};

  always_ff @(posedge clock) begin
    if (storebuffer_reg_in.wen0 == 1) begin
      storebuffer_reg_array[storebuffer_reg_in.waddr0] <= storebuffer_reg_in.wdata0;
    end
    if (storebuffer_reg_in.wen1 == 1) begin
      storebuffer_reg_array[storebuffer_reg_in.waddr1] <= storebuffer_reg_in.wdata1;
    end
  end

  always_comb begin
    if (storebuffer_reg_in.raddr0 == storebuffer_reg_in.waddr0) begin
      storebuffer_reg_out.rdata0 = storebuffer_reg_in.wdata0;
    end else if (storebuffer_reg_in.raddr0 == storebuffer_reg_in.waddr1) begin
      storebuffer_reg_out.rdata0 = storebuffer_reg_in.wdata1;
    end else begin
      storebuffer_reg_out.rdata0 = storebuffer_reg_array[storebuffer_reg_in.raddr0];
    end
    if (storebuffer_reg_in.raddr1 == storebuffer_reg_in.waddr0) begin
      storebuffer_reg_out.rdata1 = storebuffer_reg_in.wdata0;
    end else if (storebuffer_reg_in.raddr1 == storebuffer_reg_in.waddr1) begin
      storebuffer_reg_out.rdata1 = storebuffer_reg_in.wdata1;
    end else begin
      storebuffer_reg_out.rdata1 = storebuffer_reg_array[storebuffer_reg_in.raddr1];
    end
  end

endmodule

module storebuffer_ctrl (
    input logic reset,
    input logic clock,
    input mem_in_type storebuffer0_in,
    input mem_in_type storebuffer1_in,
    output mem_out_type storebuffer0_out,
    output mem_out_type storebuffer1_out,
    input mem_out_type dmem0_out,
    input mem_out_type dmem1_out,
    output mem_in_type dmem0_in,
    output mem_in_type dmem1_in,
    input storebuffer_reg_out_type storebuffer_reg_out,
    output storebuffer_reg_in_type storebuffer_reg_in
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(storebuffer_depth - 1);

  localparam [depth-1:0] one = 1;

  typedef struct packed {
    logic [depth-1 : 0] raddr0;
    logic [depth-1 : 0] raddr1;
    logic [depth-1 : 0] waddr0;
    logic [depth-1 : 0] waddr1;
    logic [95 : 0] wdata0;
    logic [95 : 0] wdata1;
    logic [95 : 0] rdata0;
    logic [95 : 0] rdata1;
    logic [63 : 0] mem_rdata0;
    logic [63 : 0] mem_rdata1;
    logic [0 : 0] mem_ready0;
    logic [0 : 0] mem_ready1;
    logic [0 : 0] wren0;
    logic [0 : 0] wren1;
    logic [0 : 0] clear;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
      waddr0 : 0,
      waddr1 : 0,
      raddr0 : 0,
      raddr1 : 0,
      wdata0 : 0,
      wdata1 : 0,
      rdata0 : 0,
      rdata1 : 0,
      mem_rdata0 : 0,
      mem_rdata1 : 0,
      mem_ready0 : 0,
      mem_ready1 : 0,
      wren0 : 0,
      wren1 : 0,
      clear : 0,
      stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    v = r;

    storebuffer_reg_in.raddr0 = v.raddr0;
    storebuffer_reg_in.raddr1 = v.raddr1;

    storebuffer_reg_in.wen0 = v.wren0;
    storebuffer_reg_in.wen1 = v.wren1;
    storebuffer_reg_in.waddr0 = v.waddr0;
    storebuffer_reg_in.waddr1 = v.waddr1;
    storebuffer_reg_in.wdata0 = v.wdata0;
    storebuffer_reg_in.wdata1 = v.wdata1;

    v.rdata0 = storebuffer_reg_out.rdata0;
    v.rdata1 = storebuffer_reg_out.rdata1;

    storebuffer0_out.mem_rdata = v.mem_rdata0;
    storebuffer0_out.mem_ready = v.mem_ready0;
    storebuffer1_out.mem_rdata = v.mem_rdata1;
    storebuffer1_out.mem_ready = v.mem_ready1;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module storebuffer (
    input logic reset,
    input logic clock,
    input mem_in_type storebuffer0_in,
    input mem_in_type storebuffer1_in,
    output mem_out_type storebuffer0_out,
    output mem_out_type storebuffer1_out,
    input mem_out_type dmem0_out,
    input mem_out_type dmem1_out,
    output mem_in_type dmem0_in,
    output mem_in_type dmem1_in
);
  timeunit 1ns; timeprecision 1ps;

  storebuffer_reg_in_type  storebuffer_reg_in;
  storebuffer_reg_out_type storebuffer_reg_out;

  storebuffer_reg storebuffer_reg_comp (
      .clock(clock),
      .storebuffer_reg_in(storebuffer_reg_in),
      .storebuffer_reg_out(storebuffer_reg_out)
  );

  storebuffer_ctrl storebuffer_ctrl_comp (
      .reset(reset),
      .clock(clock),
      .storebuffer0_in(storebuffer0_in),
      .storebuffer1_in(storebuffer1_in),
      .storebuffer0_out(storebuffer0_out),
      .storebuffer1_out(storebuffer1_out),
      .dmem0_out(dmem0_out),
      .dmem1_out(dmem1_out),
      .dmem0_in(dmem0_in),
      .dmem1_in(dmem1_in),
      .storebuffer_reg_in(storebuffer_reg_in),
      .storebuffer_reg_out(storebuffer_reg_out)
  );

endmodule
