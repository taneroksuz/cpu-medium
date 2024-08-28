package tim_wires;
  timeunit 1ns; timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(tim_depth - 1);
  localparam width = $clog2(tim_width - 1);

  typedef struct packed {
    logic [0 : 0] en;
    logic [depth-1 : 0] addr;
    logic [7 : 0] strb;
    logic [63 : 0] data;
  } tim_ram_in_type;

  typedef struct packed {logic [63 : 0] data;} tim_ram_out_type;

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
    input tim_ram_in_type tim0_ram_in,
    input tim_ram_in_type tim1_ram_in,
    output tim_ram_out_type tim0_ram_out,
    output tim_ram_out_type tim1_ram_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(tim_depth - 1);
  localparam width = $clog2(tim_width - 1);

  generate

    if (ram_type == 0) begin

      logic [63 : 0] tim_ram[0:tim_depth-1] = '{default: '0};

      always_ff @(posedge clock) begin
        if (tim0_ram_in.en == 1) begin
          if (tim0_ram_in.strb[0]) tim_ram[tim0_ram_in.addr][7:0] <= tim0_ram_in.data[7:0];
          if (tim0_ram_in.strb[1]) tim_ram[tim0_ram_in.addr][15:8] <= tim0_ram_in.data[15:8];
          if (tim0_ram_in.strb[2]) tim_ram[tim0_ram_in.addr][23:16] <= tim0_ram_in.data[23:16];
          if (tim0_ram_in.strb[3]) tim_ram[tim0_ram_in.addr][31:24] <= tim0_ram_in.data[31:24];
          if (tim0_ram_in.strb[4]) tim_ram[tim0_ram_in.addr][39:32] <= tim0_ram_in.data[39:32];
          if (tim0_ram_in.strb[5]) tim_ram[tim0_ram_in.addr][47:40] <= tim0_ram_in.data[47:40];
          if (tim0_ram_in.strb[6]) tim_ram[tim0_ram_in.addr][55:48] <= tim0_ram_in.data[55:48];
          if (tim0_ram_in.strb[7]) tim_ram[tim0_ram_in.addr][63:56] <= tim0_ram_in.data[63:56];
          tim0_ram_out.data <= tim_ram[tim0_ram_in.addr];
        end
      end
      always_ff @(posedge clock) begin
        if (tim1_ram_in.en == 1) begin
          if (tim1_ram_in.strb[0]) tim_ram[tim1_ram_in.addr][7:0] <= tim1_ram_in.data[7:0];
          if (tim1_ram_in.strb[1]) tim_ram[tim1_ram_in.addr][15:8] <= tim1_ram_in.data[15:8];
          if (tim1_ram_in.strb[2]) tim_ram[tim1_ram_in.addr][23:16] <= tim1_ram_in.data[23:16];
          if (tim1_ram_in.strb[3]) tim_ram[tim1_ram_in.addr][31:24] <= tim1_ram_in.data[31:24];
          if (tim1_ram_in.strb[4]) tim_ram[tim1_ram_in.addr][39:32] <= tim1_ram_in.data[39:32];
          if (tim1_ram_in.strb[5]) tim_ram[tim1_ram_in.addr][47:40] <= tim1_ram_in.data[47:40];
          if (tim1_ram_in.strb[6]) tim_ram[tim1_ram_in.addr][55:48] <= tim1_ram_in.data[55:48];
          if (tim1_ram_in.strb[7]) tim_ram[tim1_ram_in.addr][63:56] <= tim1_ram_in.data[63:56];
          tim1_ram_out.data <= tim_ram[tim1_ram_in.addr];
        end
      end

    end

    if (ram_type == 1) begin

      /* synthesis syn_ramstyle = "MLAB, no_rw_check"*/

      logic [7 : 0][7 : 0] tim_ram[0:tim_depth-1] = '{default: '0};

      always_ff @(posedge clock) begin
        if (tim0_ram_in.strb[0]) tim_ram[tim0_ram_in.addr][0] <= tim0_ram_in.data[7:0];
        if (tim0_ram_in.strb[1]) tim_ram[tim0_ram_in.addr][1] <= tim0_ram_in.data[15:8];
        if (tim0_ram_in.strb[2]) tim_ram[tim0_ram_in.addr][2] <= tim0_ram_in.data[23:16];
        if (tim0_ram_in.strb[3]) tim_ram[tim0_ram_in.addr][3] <= tim0_ram_in.data[31:24];
        if (tim0_ram_in.strb[4]) tim_ram[tim0_ram_in.addr][4] <= tim0_ram_in.data[39:32];
        if (tim0_ram_in.strb[5]) tim_ram[tim0_ram_in.addr][5] <= tim0_ram_in.data[47:40];
        if (tim0_ram_in.strb[6]) tim_ram[tim0_ram_in.addr][6] <= tim0_ram_in.data[55:48];
        if (tim0_ram_in.strb[7]) tim_ram[tim0_ram_in.addr][7] <= tim0_ram_in.data[63:56];
        tim0_ram_out.data <= tim_ram[tim0_ram_in.addr];
      end
      always_ff @(posedge clock) begin
        if (tim1_ram_in.strb[0]) tim_ram[tim1_ram_in.addr][0] <= tim1_ram_in.data[7:0];
        if (tim1_ram_in.strb[1]) tim_ram[tim1_ram_in.addr][1] <= tim1_ram_in.data[15:8];
        if (tim1_ram_in.strb[2]) tim_ram[tim1_ram_in.addr][2] <= tim1_ram_in.data[23:16];
        if (tim1_ram_in.strb[3]) tim_ram[tim1_ram_in.addr][3] <= tim1_ram_in.data[31:24];
        if (tim1_ram_in.strb[4]) tim_ram[tim1_ram_in.addr][4] <= tim1_ram_in.data[39:32];
        if (tim1_ram_in.strb[5]) tim_ram[tim1_ram_in.addr][5] <= tim1_ram_in.data[47:40];
        if (tim1_ram_in.strb[6]) tim_ram[tim1_ram_in.addr][6] <= tim1_ram_in.data[55:48];
        if (tim1_ram_in.strb[7]) tim_ram[tim1_ram_in.addr][7] <= tim1_ram_in.data[63:56];
        tim1_ram_out.data <= tim_ram[tim1_ram_in.addr];
      end

    end

  endgenerate

endmodule

module tim_ctrl (
    input logic reset,
    input logic clock,
    input tim_vec_out_type dvec0_out,
    input tim_vec_out_type dvec1_out,
    output tim_vec_in_type dvec0_in,
    output tim_vec_in_type dvec1_in,
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

    dvec0_in = init_tim_vec_in;
    dvec1_in = init_tim_vec_in;

    // Write data
    dvec0_in[v.wid0].en = v.valid0;
    dvec1_in[v.wid1].en = v.valid1;
    dvec0_in[v.wid0].strb = v.strb0;
    dvec1_in[v.wid1].strb = v.strb1;
    dvec0_in[v.wid0].addr = v.did0;
    dvec1_in[v.wid1].addr = v.did1;
    dvec0_in[v.wid0].data = v.data0;
    dvec1_in[v.wid1].data = v.data1;

    rin = v;

    tim0_out.mem_rdata = dvec0_out[r.wid0].data;
    tim0_out.mem_ready = r.valid0;

    tim1_out.mem_rdata = dvec1_out[r.wid1].data;
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

  tim_vec_in_type  dvec0_in;
  tim_vec_in_type  dvec1_in;
  tim_vec_out_type dvec0_out;
  tim_vec_out_type dvec1_out;

  generate

    genvar i;

    for (i = 0; i < tim_width; i = i + 1) begin : tim_ram
      tim_ram tim_ram_comp (
          .clock(clock),
          .tim0_ram_in(dvec0_in[i]),
          .tim1_ram_in(dvec1_in[i]),
          .tim0_ram_out(dvec0_out[i]),
          .tim1_ram_out(dvec1_out[i])
      );
    end

  endgenerate

  tim_ctrl tim_ctrl_comp (
      .reset(reset),
      .clock(clock),
      .dvec0_out(dvec0_out),
      .dvec1_out(dvec1_out),
      .dvec0_in(dvec0_in),
      .dvec1_in(dvec1_in),
      .tim0_in(tim0_in),
      .tim1_in(tim1_in),
      .tim0_out(tim0_out),
      .tim1_out(tim1_out)
  );

endmodule
