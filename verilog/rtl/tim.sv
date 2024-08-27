package tim_wires;
  timeunit 1ns; timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(tim_depth - 1);
  localparam width = $clog2(tim_width - 1);

  typedef struct packed {
    logic [0 : 0] en0;
    logic [0 : 0] en1;
    logic [depth-1 : 0] addr0;
    logic [depth-1 : 0] addr1;
    logic [7 : 0] strb0;
    logic [7 : 0] strb1;
    logic [63 : 0] data0;
    logic [63 : 0] data1;
  } tim_ram_in_type;

  typedef struct packed {
    logic [63 : 0] data0;
    logic [63 : 0] data1;
  } tim_ram_out_type;

  typedef tim_ram_in_type tim_vec_in_type[tim_width];
  typedef tim_ram_out_type tim_vec_out_type[tim_width];

  localparam tim_vec_in_type init_tim_vec_in = '{default: 0};
  localparam tim_vec_out_type init_tim_vec_out = '{default: 0};

endpackage

import configure::*;
import wires::*;
import tim_wires::*;

module tim_ram (
    input logic clock,
    input tim_ram_in_type tim_ram_in,
    output tim_ram_out_type tim_ram_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(tim_depth - 1);
  localparam width = $clog2(tim_width - 1);

  generate

    if (ram_type == 0) begin

      logic [63 : 0] tim_ram[0:tim_depth-1] = '{default: '0};

      always_ff @(posedge clock) begin
        if (tim_ram_in.en0 == 1) begin
          if (tim_ram_in.strb0[0]) tim_ram[tim_ram_in.addr0][7:0] <= tim_ram_in.data0[7:0];
          if (tim_ram_in.strb0[1]) tim_ram[tim_ram_in.addr0][15:8] <= tim_ram_in.data0[15:8];
          if (tim_ram_in.strb0[2]) tim_ram[tim_ram_in.addr0][23:16] <= tim_ram_in.data0[23:16];
          if (tim_ram_in.strb0[3]) tim_ram[tim_ram_in.addr0][31:24] <= tim_ram_in.data0[31:24];
          if (tim_ram_in.strb0[4]) tim_ram[tim_ram_in.addr0][39:32] <= tim_ram_in.data0[39:32];
          if (tim_ram_in.strb0[5]) tim_ram[tim_ram_in.addr0][47:40] <= tim_ram_in.data0[47:40];
          if (tim_ram_in.strb0[6]) tim_ram[tim_ram_in.addr0][55:48] <= tim_ram_in.data0[55:48];
          if (tim_ram_in.strb0[7]) tim_ram[tim_ram_in.addr0][63:56] <= tim_ram_in.data0[63:56];
          tim_ram_out.data0 <= tim_ram[tim_ram_in.addr0];
        end else begin
          tim_ram_out.data0 <= 0;
        end
        if (tim_ram_in.en1 == 1) begin
          if (tim_ram_in.strb1[0]) tim_ram[tim_ram_in.addr1][7:0] <= tim_ram_in.data1[7:0];
          if (tim_ram_in.strb1[1]) tim_ram[tim_ram_in.addr1][15:8] <= tim_ram_in.data1[15:8];
          if (tim_ram_in.strb1[2]) tim_ram[tim_ram_in.addr1][23:16] <= tim_ram_in.data1[23:16];
          if (tim_ram_in.strb1[3]) tim_ram[tim_ram_in.addr1][31:24] <= tim_ram_in.data1[31:24];
          if (tim_ram_in.strb1[4]) tim_ram[tim_ram_in.addr1][39:32] <= tim_ram_in.data1[39:32];
          if (tim_ram_in.strb1[5]) tim_ram[tim_ram_in.addr1][47:40] <= tim_ram_in.data1[47:40];
          if (tim_ram_in.strb1[6]) tim_ram[tim_ram_in.addr1][55:48] <= tim_ram_in.data1[55:48];
          if (tim_ram_in.strb1[7]) tim_ram[tim_ram_in.addr1][63:56] <= tim_ram_in.data1[63:56];
          tim_ram_out.data1 <= tim_ram[tim_ram_in.addr1];
        end else begin
          tim_ram_out.data1 <= 0;
        end
      end

    end

    if (ram_type == 1) begin

      logic [7 : 0][7 : 0] tim_ram[0:tim_depth-1] = '{default: '0};

      always_ff @(posedge clock) begin
        if (tim_ram_in.en0 == 1) begin
          if (tim_ram_in.strb0[0]) tim_ram[tim_ram_in.addr0][0] <= tim_ram_in.data0[0];
          if (tim_ram_in.strb0[1]) tim_ram[tim_ram_in.addr0][1] <= tim_ram_in.data0[1];
          if (tim_ram_in.strb0[2]) tim_ram[tim_ram_in.addr0][2] <= tim_ram_in.data0[2];
          if (tim_ram_in.strb0[3]) tim_ram[tim_ram_in.addr0][3] <= tim_ram_in.data0[3];
          if (tim_ram_in.strb0[4]) tim_ram[tim_ram_in.addr0][4] <= tim_ram_in.data0[4];
          if (tim_ram_in.strb0[5]) tim_ram[tim_ram_in.addr0][5] <= tim_ram_in.data0[5];
          if (tim_ram_in.strb0[6]) tim_ram[tim_ram_in.addr0][6] <= tim_ram_in.data0[6];
          if (tim_ram_in.strb0[7]) tim_ram[tim_ram_in.addr0][7] <= tim_ram_in.data0[7];
          tim_ram_out.data0 <= tim_ram[tim_ram_in.addr0];
        end else begin
          tim_ram_out.data0 <= 0;
        end
        if (tim_ram_in.en1 == 1) begin
          if (tim_ram_in.strb1[0]) tim_ram[tim_ram_in.addr1][0] <= tim_ram_in.data1[0];
          if (tim_ram_in.strb1[1]) tim_ram[tim_ram_in.addr1][1] <= tim_ram_in.data1[1];
          if (tim_ram_in.strb1[2]) tim_ram[tim_ram_in.addr1][2] <= tim_ram_in.data1[2];
          if (tim_ram_in.strb1[3]) tim_ram[tim_ram_in.addr1][3] <= tim_ram_in.data1[3];
          if (tim_ram_in.strb1[4]) tim_ram[tim_ram_in.addr1][4] <= tim_ram_in.data1[4];
          if (tim_ram_in.strb1[5]) tim_ram[tim_ram_in.addr1][5] <= tim_ram_in.data1[5];
          if (tim_ram_in.strb1[6]) tim_ram[tim_ram_in.addr1][6] <= tim_ram_in.data1[6];
          if (tim_ram_in.strb1[7]) tim_ram[tim_ram_in.addr1][7] <= tim_ram_in.data1[7];
          tim_ram_out.data1 <= tim_ram[tim_ram_in.addr1];
        end else begin
          tim_ram_out.data1 <= 0;
        end
      end

    end

  endgenerate

endmodule

module tim_ctrl (
    input logic reset,
    input logic clock,
    input tim_vec_out_type dvec_out,
    output tim_vec_in_type dvec_in,
    input mem_in_type tim0_in,
    input mem_in_type tim1_in,
    output mem_out_type tim0_out,
    output mem_out_type tim1_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(tim_depth - 1);
  localparam width = $clog2(tim_width - 1);

  typedef struct packed {
    logic [width-1:0] wid0;
    logic [width-1:0] wid1;
    logic [depth-1:0] did0;
    logic [depth-1:0] did1;
    logic [63:0] data0;
    logic [63:0] data1;
    logic [7:0] strb0;
    logic [7:0] strb1;
    logic [0:0] valid0;
    logic [0:0] valid1;
  } front_type;

  parameter front_type init_reg = 0;

  front_type r, rin;
  front_type v;

  always_comb begin

    v = r;

    v.valid0 = 0;
    v.valid1 = 0;
    v.strb0 = 0;
    v.strb1 = 0;

    if (tim0_in.mem_valid == 1) begin
      v.valid0 = tim0_in.mem_valid;
      v.strb0  = tim0_in.mem_wstrb;
      v.data0  = tim0_in.mem_wdata;
      v.did0   = tim0_in.mem_addr[(depth+width+2):(width+3)];
      v.wid0   = tim0_in.mem_addr[(width+2):3];
    end

    if (tim1_in.mem_valid == 1) begin
      v.valid1 = tim1_in.mem_valid;
      v.strb1  = tim1_in.mem_wstrb;
      v.data1  = tim1_in.mem_wdata;
      v.did1   = tim1_in.mem_addr[(depth+width+2):(width+3)];
      v.wid1   = tim1_in.mem_addr[(width+2):3];
    end

    dvec_in = init_tim_vec_in;

    // Write data
    dvec_in[v.wid0].en0 = v.valid0;
    dvec_in[v.wid1].en1 = v.valid1;
    dvec_in[v.wid0].strb0 = v.strb0;
    dvec_in[v.wid1].strb1 = v.strb1;
    dvec_in[v.wid0].addr0 = v.did0;
    dvec_in[v.wid1].addr1 = v.did1;
    dvec_in[v.wid0].data0 = v.data0;
    dvec_in[v.wid1].data1 = v.data1;

    rin = v;

    tim0_out.mem_rdata = dvec_out[r.wid0].data0;
    tim0_out.mem_ready = r.valid0;

    tim1_out.mem_rdata = dvec_out[r.wid1].data1;
    tim1_out.mem_ready = r.valid1;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module tim (
    input logic reset,
    input logic clock,
    input mem_in_type tim0_in,
    input mem_in_type tim1_in,
    output mem_out_type tim0_out,
    output mem_out_type tim1_out
);
  timeunit 1ns; timeprecision 1ps;

  tim_vec_in_type  dvec_in;
  tim_vec_out_type dvec_out;

  generate

    genvar i;

    for (i = 0; i < tim_width; i = i + 1) begin : tim_ram
      tim_ram tim_ram_comp (
          .clock(clock),
          .tim_ram_in(dvec_in[i]),
          .tim_ram_out(dvec_out[i])
      );
    end

  endgenerate

  tim_ctrl tim_ctrl_comp (
      .reset(reset),
      .clock(clock),
      .dvec_out(dvec_out),
      .dvec_in(dvec_in),
      .tim0_in(tim0_in),
      .tim1_in(tim1_in),
      .tim0_out(tim0_out),
      .tim1_out(tim1_out)
  );

endmodule
