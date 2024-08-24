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
    logic [97 : 0] wdata0;
    logic [97 : 0] wdata1;
  } storebuffer_reg_in_type;

  typedef struct packed {
    logic [97 : 0] rdata0;
    logic [97 : 0] rdata1;
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

  logic [97:0] storebuffer_reg_array[0:storebuffer_depth-1] = '{default: '0};

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
    input storebuffer_in_type storebuffer0_in,
    input storebuffer_in_type storebuffer1_in,
    output storebuffer_out_type storebuffer0_out,
    output storebuffer_out_type storebuffer1_out,
    input storebuffer_reg_out_type storebuffer_reg_out,
    output storebuffer_reg_in_type storebuffer_reg_in,
    input mem_out_type dmem0_out,
    input mem_out_type dmem1_out,
    output mem_in_type dmem0_in,
    output mem_in_type dmem1_in
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(storebuffer_depth - 1);

  localparam [depth-1:0] one = 1;

  typedef struct packed {
    logic [depth-1 : 0] raddr0;
    logic [depth-1 : 0] raddr1;
    logic [depth-1 : 0] waddr0;
    logic [depth-1 : 0] waddr1;
    logic [31 : 0] addr0;
    logic [31 : 0] addr1;
    logic [97 : 0] wdata0;
    logic [97 : 0] wdata1;
    logic [97 : 0] rdata0;
    logic [97 : 0] rdata1;
    logic [0 : 0] wren0;
    logic [0 : 0] wren1;
    logic [0 : 0] clear;
    logic [0 : 0] stall;
  } front_type;

  typedef struct packed {
    logic [31 : 0] mem_addr0;
    logic [31 : 0] mem_addr1;
    logic [63 : 0] mem_rdata0;
    logic [63 : 0] mem_rdata1;
    logic [63 : 0] mem_wdata0;
    logic [63 : 0] mem_wdata1;
    logic [0 : 0] mem_valid0;
    logic [0 : 0] mem_valid1;
    logic [0 : 0] mem_store0;
    logic [0 : 0] mem_store1;
    logic [0 : 0] mem_ready0;
    logic [0 : 0] mem_ready1;
  } back_type;

  localparam front_type init_front = 0;
  localparam back_type init_back = 0;

  front_type r_f, rin_f, v_f;
  back_type r_b, rin_b, v_b;

  always_comb begin

    v_f = r_f;

    if (storebuffer0_in.mem_valid == 1) begin

    end

    if (storebuffer1_in.mem_valid == 1) begin

    end

    storebuffer_reg_in.raddr0 = v_f.raddr0;
    storebuffer_reg_in.raddr1 = v_f.raddr1;

    storebuffer_reg_in.wen0 = v_f.wren0;
    storebuffer_reg_in.wen1 = v_f.wren1;
    storebuffer_reg_in.waddr0 = v_f.waddr0;
    storebuffer_reg_in.waddr1 = v_f.waddr1;
    storebuffer_reg_in.wdata0 = v_f.wdata0;
    storebuffer_reg_in.wdata1 = v_f.wdata1;

    v_f.rdata0 = storebuffer_reg_out.rdata0;
    v_f.rdata1 = storebuffer_reg_out.rdata1;

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.mem_rdata0 = dmem0_out.mem_rdata;
    v_b.mem_rdata1 = dmem1_out.mem_rdata;
    v_b.mem_ready0 = dmem0_out.mem_ready;
    v_b.mem_ready1 = dmem1_out.mem_ready;

    rin_b = v_b;

    dmem0_in.mem_valid = v_b.mem_valid0;
    dmem1_in.mem_valid = v_b.mem_valid1;
    dmem0_in.mem_instr = 0;
    dmem1_in.mem_instr = 0;
    dmem0_in.mem_store = v_b.mem_store0;
    dmem1_in.mem_store = v_b.mem_store1;
    dmem0_in.mem_addr = v_b.mem_addr0;
    dmem1_in.mem_addr = v_b.mem_addr1;
    dmem0_in.mem_wdata = v_b.mem_wdata0;
    dmem1_in.mem_wdata = v_b.mem_wdata1;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r_f <= init_front;
      r_b <= init_back;
    end else begin
      r_f <= rin_f;
      r_b <= rin_b;
    end
  end

endmodule

module storebuffer (
    input logic reset,
    input logic clock,
    input storebuffer_in_type storebuffer0_in,
    input storebuffer_in_type storebuffer1_in,
    output storebuffer_out_type storebuffer0_out,
    output storebuffer_out_type storebuffer1_out,
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
      .storebuffer_reg_in(storebuffer_reg_in),
      .storebuffer_reg_out(storebuffer_reg_out),
      .dmem0_out(dmem0_out),
      .dmem1_out(dmem1_out),
      .dmem0_in(dmem0_in),
      .dmem1_in(dmem1_in)
  );

endmodule
