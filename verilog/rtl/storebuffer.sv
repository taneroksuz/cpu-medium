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
    logic [94 : 0] wdata0;
    logic [94 : 0] wdata1;
  } storebuffer_reg_in_type;

  typedef struct packed {
    logic [94 : 0] rdata0;
    logic [94 : 0] rdata1;
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

  logic [94:0] storebuffer_reg_array[0:storebuffer_depth-1] = '{default: '0};

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
    logic [63 : 0] data0;
    logic [63 : 0] data1;
    logic [94 : 0] wdata0;
    logic [94 : 0] wdata1;
    logic [94 : 0] rdata0;
    logic [94 : 0] rdata1;
    logic [7 : 0] strb0;
    logic [7 : 0] strb1;
    logic [0 : 0] wren0;
    logic [0 : 0] wren1;
    logic [0 : 0] rden0;
    logic [0 : 0] rden1;
    logic [0 : 0] valid0;
    logic [0 : 0] valid1;
    logic [0 : 0] hit0;
    logic [0 : 0] hit1;
    logic [0 : 0] miss0;
    logic [0 : 0] miss1;
    logic [0 : 0] back0;
    logic [0 : 0] back1;
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

    v_f.valid0 = 0;
    v_f.valid1 = 0;

    v_f.wren0 = 0;
    v_f.wren1 = 0;

    v_f.rden0 = 0;
    v_f.rden1 = 0;

    if (storebuffer0_in.mem_valid == 1) begin
      v_f.valid0 = storebuffer0_in.mem_valid;
      v_f.addr0 = storebuffer0_in.mem_addr;
      v_f.raddr0 = storebuffer0_in.mem_addr[depth+2:3];
      v_f.data0 = storebuffer0_in.mem_wdata;
      v_f.strb0 = storebuffer0_in.mem_wstrb;
    end

    if (storebuffer1_in.mem_valid == 1) begin
      v_f.valid1 = storebuffer1_in.mem_valid;
      v_f.addr1 = storebuffer1_in.mem_addr;
      v_f.raddr1 = storebuffer1_in.mem_addr[depth+2:3];
      v_f.data1 = storebuffer1_in.mem_wdata;
      v_f.strb1 = storebuffer1_in.mem_wstrb;
    end

    storebuffer_reg_in.raddr0 = v_f.raddr0;
    storebuffer_reg_in.raddr1 = v_f.raddr1;

    v_f.rdata0 = storebuffer_reg_out.rdata0;
    v_f.rdata1 = storebuffer_reg_out.rdata1;

    if (v_f.valid0 == 1) begin
      v_f.hit0 = v_f.rdata0[94] & |(v_f.addr0[31:3] ^ v_f.rdata0[92:64]);
      v_f.miss0 = ~v_f.hit0;
      v_f.back0 = v_f.miss0 & v_f.rdata0[93];
    end

    if (v_f.valid1 == 1) begin
      v_f.hit1 = v_f.rdata1[94] & |(v_f.addr1[31:3] ^ v_f.rdata1[92:64]);
      v_f.miss1 = ~v_f.hit1;
      v_f.back1 = v_f.miss1 & v_f.rdata1[93];
    end

    if (v_f.hit0 == 1) begin
      v_f.wren0 = |v_f.strb0;
      v_f.rden0 = ~v_f.wren0;
      v_f.waddr0 = v_f.raddr0;
      v_f.wdata0 = v_f.rdata0;
      v_f.wdata0[93] = v_f.wdata0[93] | v_f.wren0;
    end

    if (v_f.hit1 == 1) begin
      v_f.wren1 = |v_f.strb1;
      v_f.rden1 = ~v_f.wren1;
      v_f.waddr1 = v_f.raddr1;
      v_f.wdata1 = v_f.rdata1;
      v_f.wdata1[93] = v_f.wdata1[93] | v_f.wren1;
    end

    if (v_f.wren0 == 1) begin
      if (v_f.strb0[0] == 1) v_f.wdata0[7:0] = v_f.data0[7:0];
      if (v_f.strb0[1] == 1) v_f.wdata0[15:8] = v_f.data0[15:8];
      if (v_f.strb0[2] == 1) v_f.wdata0[23:16] = v_f.data0[23:16];
      if (v_f.strb0[3] == 1) v_f.wdata0[31:24] = v_f.data0[31:24];
      if (v_f.strb0[4] == 1) v_f.wdata0[39:32] = v_f.data0[39:32];
      if (v_f.strb0[5] == 1) v_f.wdata0[47:40] = v_f.data0[47:40];
      if (v_f.strb0[6] == 1) v_f.wdata0[55:48] = v_f.data0[55:48];
      if (v_f.strb0[7] == 1) v_f.wdata0[63:56] = v_f.data0[63:56];
    end

    if (v_f.wren1 == 1) begin
      if (v_f.strb1[0] == 1) v_f.wdata1[7:0] = v_f.data1[7:0];
      if (v_f.strb1[1] == 1) v_f.wdata1[15:8] = v_f.data1[15:8];
      if (v_f.strb1[2] == 1) v_f.wdata1[23:16] = v_f.data1[23:16];
      if (v_f.strb1[3] == 1) v_f.wdata1[31:24] = v_f.data1[31:24];
      if (v_f.strb1[4] == 1) v_f.wdata1[39:32] = v_f.data1[39:32];
      if (v_f.strb1[5] == 1) v_f.wdata1[47:40] = v_f.data1[47:40];
      if (v_f.strb1[6] == 1) v_f.wdata1[55:48] = v_f.data1[55:48];
      if (v_f.strb1[7] == 1) v_f.wdata1[63:56] = v_f.data1[63:56];
    end

    storebuffer_reg_in.wen0 = v_f.wren0;
    storebuffer_reg_in.wen1 = v_f.wren1;
    storebuffer_reg_in.waddr0 = v_f.waddr0;
    storebuffer_reg_in.waddr1 = v_f.waddr1;
    storebuffer_reg_in.wdata0 = v_f.wdata0;
    storebuffer_reg_in.wdata1 = v_f.wdata1;

    rin_f = v_f;

    storebuffer0_out.mem_rdata = r_f.rden0 ? r_f.rdata0[63:0] : 0;
    storebuffer1_out.mem_rdata = r_f.rden1 ? r_f.rdata1[63:0] : 0;
    storebuffer0_out.mem_ready = r_f.wren0 | r_f.rden0;
    storebuffer1_out.mem_ready = r_f.wren1 | r_f.rden1;

  end

  always_comb begin

    v_b = r_b;

    v_b.mem_rdata0 = dmem0_out.mem_rdata;
    v_b.mem_rdata1 = dmem1_out.mem_rdata;
    v_b.mem_ready0 = dmem0_out.mem_ready;
    v_b.mem_ready1 = dmem1_out.mem_ready;

    v_b.mem_valid0 = 0;
    v_b.mem_valid1 = 0;

    if ((rin_f.miss0 | rin_f.back0 | rin_f.miss1 | rin_f.back1) == 0) begin
      
    end

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
