package buffer_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(buffer_depth-1);

  typedef struct packed{
    logic [0 : 0] wen0;
    logic [0 : 0] wen1;
    logic [0 : 0] wen2;
    logic [0 : 0] wen3;
    logic [depth-1 : 0] waddr0;
    logic [depth-1 : 0] waddr1;
    logic [depth-1 : 0] waddr2;
    logic [depth-1 : 0] waddr3;
    logic [depth-1 : 0] raddr0;
    logic [depth-1 : 0] raddr1;
    logic [depth-1 : 0] raddr2;
    logic [depth-1 : 0] raddr3;
    logic [47 : 0] wdata0;
    logic [47 : 0] wdata1;
    logic [47 : 0] wdata2;
    logic [47 : 0] wdata3;
  } buffer_reg_in_type;

  typedef struct packed{
    logic [47 : 0] rdata0;
    logic [47 : 0] rdata1;
    logic [47 : 0] rdata2;
    logic [47 : 0] rdata3;
  } buffer_reg_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import buffer_wires::*;

module buffer_reg
(
  input logic clock,
  input buffer_reg_in_type buffer_reg_in,
  output buffer_reg_out_type buffer_reg_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(buffer_depth-1);

  logic [47:0] buffer_reg_array0[0:buffer_depth-1] = '{default:'0};
  logic [47:0] buffer_reg_array1[0:buffer_depth-1] = '{default:'0};
  logic [47:0] buffer_reg_array2[0:buffer_depth-1] = '{default:'0};
  logic [47:0] buffer_reg_array3[0:buffer_depth-1] = '{default:'0};

  always_ff @(posedge clock) begin
    if (buffer_reg_in.wen0 == 1) begin
      buffer_reg_array0[buffer_reg_in.waddr0] <= buffer_reg_in.wdata0;
    end
  end

  always_ff @(posedge clock) begin
    if (buffer_reg_in.wen1 == 1) begin
      buffer_reg_array1[buffer_reg_in.waddr1] <= buffer_reg_in.wdata1;
    end
  end

  always_ff @(posedge clock) begin
    if (buffer_reg_in.wen2 == 1) begin
      buffer_reg_array2[buffer_reg_in.waddr2] <= buffer_reg_in.wdata2;
    end
  end

  always_ff @(posedge clock) begin
    if (buffer_reg_in.wen3 == 1) begin
      buffer_reg_array3[buffer_reg_in.waddr3] <= buffer_reg_in.wdata3;
    end
  end

  assign buffer_reg_out.rdata0 = buffer_reg_array0[buffer_reg_in.raddr0];
  assign buffer_reg_out.rdata1 = buffer_reg_array1[buffer_reg_in.raddr1];
  assign buffer_reg_out.rdata2 = buffer_reg_array2[buffer_reg_in.raddr2];
  assign buffer_reg_out.rdata3 = buffer_reg_array3[buffer_reg_in.raddr3];

endmodule

module buffer_ctrl
(
  input logic reset,
  input logic clock,
  input buffer_in_type buffer_in,
  output buffer_out_type buffer_out,
  input buffer_reg_out_type buffer_reg_out,
  output buffer_reg_in_type buffer_reg_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(buffer_depth-1);
  localparam total = buffer_depth-4;

  localparam [depth-1:0] one = 1;

  typedef struct packed{
    logic [depth+1 : 0] wid;
    logic [depth+1 : 0] rid;
    logic [depth+1 : 0] diff;
    logic [depth+1 : 0] incr;
    logic [depth+1 : 0] count;
    logic [47 : 0] wdata0;
    logic [47 : 0] wdata1;
    logic [47 : 0] wdata2;
    logic [47 : 0] wdata3;
    logic [47 : 0] rdata0;
    logic [47 : 0] rdata1;
    logic [47 : 0] rdata2;
    logic [47 : 0] rdata3;
    logic [31 : 0] pc0;
    logic [31 : 0] pc1;
    logic [31 : 0] instr0;
    logic [31 : 0] instr1;
    logic [0 : 0] wen;
    logic [0 : 0] comp0;
    logic [0 : 0] comp1;
    logic [0 : 0] ready0;
    logic [0 : 0] ready1;
    logic [0 : 0] clear;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    wid : 0,
    rid : 0,
    diff : 0,
    incr : 0,
    count : 0,
    wdata0 : 0,
    wdata1 : 0,
    wdata2 : 0,
    wdata3 : 0,
    rdata0 : 0,
    rdata1 : 0,
    rdata2 : 0,
    rdata3 : 0,
    pc0 : 0,
    pc1 : 0,
    instr0 : 0,
    instr1 : 0,
    wen : 0,
    comp0 : 0,
    comp1 : 0,
    ready0 : 0,
    ready1 : 0,
    clear : 0,
    stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    v = r;

    v.incr = 4;

    if (buffer_in.clear == 1) begin
      v.wid = 0;
      v.rid = 0;
      v.count = 0;
      v.clear = 1;
    end

    if (r.clear == 1 && buffer_in.ready == 1) begin
      v.clear = 0;
      if (buffer_in.pc[2:1] == 0) begin
        v.incr = 4;
      end
      if (buffer_in.pc[2:1] == 1) begin
        v.incr = 3;
      end
      if (buffer_in.pc[2:1] == 2) begin
        v.incr = 2;
      end
      if (buffer_in.pc[2:1] == 3) begin
        v.incr = 1;
      end
    end

    v.wen = (~v.clear) & (~r.stall) & buffer_in.ready;

    v.wdata0 = {buffer_in.pc[31:3],3'b000,buffer_in.rdata[15:0]};
    v.wdata1 = {buffer_in.pc[31:3],3'b010,buffer_in.rdata[31:16]};
    v.wdata2 = {buffer_in.pc[31:3],3'b100,buffer_in.rdata[47:32]};
    v.wdata3 = {buffer_in.pc[31:3],3'b110,buffer_in.rdata[63:48]};

    buffer_reg_in.wen0 = v.wen;
    buffer_reg_in.wen1 = v.wen;
    buffer_reg_in.wen2 = v.wen;
    buffer_reg_in.wen3 = v.wen;
    buffer_reg_in.waddr0 = v.wid[depth+1:2];
    buffer_reg_in.waddr1 = v.wid[depth+1:2];
    buffer_reg_in.waddr2 = v.wid[depth+1:2];
    buffer_reg_in.waddr3 = v.wid[depth+1:2];
    buffer_reg_in.wdata0 = v.wdata0;
    buffer_reg_in.wdata1 = v.wdata1;
    buffer_reg_in.wdata2 = v.wdata2;
    buffer_reg_in.wdata3 = v.wdata3;

    if (v.rid[1:0] == 0) begin
      buffer_reg_in.raddr0 = v.rid[depth+1:2];
      buffer_reg_in.raddr1 = v.rid[depth+1:2];
      buffer_reg_in.raddr2 = v.rid[depth+1:2];
      buffer_reg_in.raddr3 = v.rid[depth+1:2];
      if (v.wid[depth+1:2] == v.rid[depth+1:2]) begin
        v.rdata0 = v.wdata0;
        v.rdata1 = v.wdata1;
        v.rdata2 = v.wdata2;
        v.rdata3 = v.wdata3;
      end else begin
        v.rdata0 = buffer_reg_out.rdata0;
        v.rdata1 = buffer_reg_out.rdata1;
        v.rdata2 = buffer_reg_out.rdata2;
        v.rdata3 = buffer_reg_out.rdata3;
      end
    end else if (v.rid[1:0] == 1) begin
      buffer_reg_in.raddr0 = v.rid[depth+1:2] + one;
      buffer_reg_in.raddr1 = v.rid[depth+1:2];
      buffer_reg_in.raddr2 = v.rid[depth+1:2];
      buffer_reg_in.raddr3 = v.rid[depth+1:2];
      if (v.wid[depth+1:2] == v.rid[depth+1:2]) begin
        v.rdata0 = v.wdata1;
        v.rdata1 = v.wdata2;
        v.rdata2 = v.wdata3;
        v.rdata3 = v.wdata0;
      end else if (v.wid[depth+1:2] == v.rid[depth+1:2] + one) begin
        v.rdata0 = buffer_reg_out.rdata1;
        v.rdata1 = buffer_reg_out.rdata2;
        v.rdata2 = buffer_reg_out.rdata3;
        v.rdata3 = v.wdata0;
      end else begin
        v.rdata0 = buffer_reg_out.rdata1;
        v.rdata1 = buffer_reg_out.rdata2;
        v.rdata2 = buffer_reg_out.rdata3;
        v.rdata3 = buffer_reg_out.rdata0;
      end
    end else if (v.rid[1:0] == 2) begin
      buffer_reg_in.raddr0 = v.rid[depth+1:2] + one;
      buffer_reg_in.raddr1 = v.rid[depth+1:2] + one;
      buffer_reg_in.raddr2 = v.rid[depth+1:2];
      buffer_reg_in.raddr3 = v.rid[depth+1:2];
      if (v.wid[depth+1:2] == v.rid[depth+1:2]) begin
        v.rdata0 = v.wdata2;
        v.rdata1 = v.wdata3;
        v.rdata2 = v.wdata0;
        v.rdata3 = v.wdata1;
      end else if (v.wid[depth+1:2] == v.rid[depth+1:2] + one) begin
        v.rdata0 = buffer_reg_out.rdata2;
        v.rdata1 = buffer_reg_out.rdata3;
        v.rdata2 = v.wdata0;
        v.rdata3 = v.wdata1;
      end else begin
        v.rdata0 = buffer_reg_out.rdata2;
        v.rdata1 = buffer_reg_out.rdata3;
        v.rdata2 = buffer_reg_out.rdata0;
        v.rdata3 = buffer_reg_out.rdata1;
      end
    end else begin
      buffer_reg_in.raddr0 = v.rid[depth+1:2] + one;
      buffer_reg_in.raddr1 = v.rid[depth+1:2] + one;
      buffer_reg_in.raddr2 = v.rid[depth+1:2] + one;
      buffer_reg_in.raddr3 = v.rid[depth+1:2];
      if (v.wid[depth+1:2] == v.rid[depth+1:2]) begin
        v.rdata0 = v.wdata3;
        v.rdata1 = v.wdata0;
        v.rdata2 = v.wdata1;
        v.rdata3 = v.wdata2;
      end else if (v.wid[depth+1:2] == v.rid[depth+1:2] + one) begin
        v.rdata0 = buffer_reg_out.rdata3;
        v.rdata1 = v.wdata0;
        v.rdata2 = v.wdata1;
        v.rdata3 = v.wdata2;
      end else begin
        v.rdata0 = buffer_reg_out.rdata3;
        v.rdata1 = buffer_reg_out.rdata0;
        v.rdata2 = buffer_reg_out.rdata1;
        v.rdata3 = buffer_reg_out.rdata2;
      end
    end

    if (v.wen == 1) begin
      v.wid = v.wid + 4;
      v.count = v.count + v.incr;
    end

    v.diff = 0;

    v.pc0 = 0;
    v.pc1 = 0;
    v.instr0 = 0;
    v.instr1 = 0;

    v.comp0 = 0;
    v.comp1 = 0;
    v.ready0 = 0;
    v.ready1 = 0;

    if (v.count > 0) begin
      v.pc0 = v.rdata0[47:16];
      v.instr0[15:0] = v.rdata0[15:0];
      v.comp0 = ~(&v.rdata0[1:0]);
      v.ready0 = v.comp0;
      v.diff = v.comp0 ? 1 : 0;
    end
    if (v.count > 1) begin
      if (v.comp0 == 0) begin
        v.instr0[31:16] = v.rdata1[15:0];
        v.ready0 = 1;
        v.diff = 2;
      end
      if (v.comp0 == 1) begin
        v.pc1 = v.rdata1[47:16];
        v.instr1[15:0] = v.rdata1[15:0];
        v.comp1 = ~(&v.rdata1[1:0]);
        v.ready1 = v.comp1;
        v.diff = v.comp1 ? 2 : 1;
      end
    end
    if (v.count > 2) begin
      if (v.comp0 == 1 && v.comp1 == 0) begin
        v.instr1[31:16] = v.rdata2[15:0];
        v.ready1 = 1;
        v.diff = 3;
      end
      if (v.comp0 == 0 && v.comp1 == 0) begin
        v.pc1 = v.rdata2[47:16];
        v.instr1[15:0] = v.rdata2[15:0];
        v.comp1 = ~(&v.rdata2[1:0]);
        v.ready1 = v.comp1;
        v.diff = v.comp1 ? 3 : 2;
      end
    end
    if (v.count > 3) begin
      if (v.comp0 == 0 && v.comp1 == 0) begin
        v.instr1[31:16] = v.rdata3[15:0];
        v.ready1 = 1;
        v.diff = 4;
      end
    end

    if (buffer_in.stall == 1) begin
      v.diff = 0;
      v.ready0 = 0;
      v.ready1 = 0;
    end

    v.count = v.count - v.diff;
    v.rid = v.rid + v.diff;

    v.stall = 0;

    if (v.count > total) begin
      v.stall = 1;
    end

    buffer_out.pc0 = v.ready0 ? v.pc0 : 32'hFFFFFFFF;
    buffer_out.pc1 = v.ready1 ? v.pc1 : 32'hFFFFFFFF;
    buffer_out.instr0 = v.ready0 ? v.instr0 : 0;
    buffer_out.instr1 = v.ready1 ? v.instr1 : 0;
    buffer_out.ready0 = v.ready0;
    buffer_out.ready1 = v.ready1;
    buffer_out.stall = v.stall;

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

module buffer
(
  input logic reset,
  input logic clock,
  input buffer_in_type buffer_in,
  output buffer_out_type buffer_out
);
  timeunit 1ns;
  timeprecision 1ps;

  buffer_reg_in_type buffer_reg_in;
  buffer_reg_out_type buffer_reg_out;

  buffer_reg buffer_reg_comp
  (
    .clock (clock),
    .buffer_reg_in (buffer_reg_in),
    .buffer_reg_out (buffer_reg_out)
  );

  buffer_ctrl buffer_ctrl_comp
  (
    .reset (reset),
    .clock (clock),
    .buffer_in (buffer_in),
    .buffer_out (buffer_out),
    .buffer_reg_in (buffer_reg_in),
    .buffer_reg_out (buffer_reg_out)
  );

endmodule
