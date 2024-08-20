package fetchbuffer_wires;
  timeunit 1ns; timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(fetchbuffer_depth - 1);

  typedef struct packed {
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
  } fetchbuffer_reg_in_type;

  typedef struct packed {
    logic [47 : 0] rdata0;
    logic [47 : 0] rdata1;
    logic [47 : 0] rdata2;
    logic [47 : 0] rdata3;
  } fetchbuffer_reg_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import fetchbuffer_wires::*;

module fetchbuffer_reg (
    input logic clock,
    input fetchbuffer_reg_in_type fetchbuffer_reg_in,
    output fetchbuffer_reg_out_type fetchbuffer_reg_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(fetchbuffer_depth - 1);

  logic [47:0] fetchbuffer_reg_array0[0:fetchbuffer_depth-1] = '{default: '0};
  logic [47:0] fetchbuffer_reg_array1[0:fetchbuffer_depth-1] = '{default: '0};
  logic [47:0] fetchbuffer_reg_array2[0:fetchbuffer_depth-1] = '{default: '0};
  logic [47:0] fetchbuffer_reg_array3[0:fetchbuffer_depth-1] = '{default: '0};

  logic [47:0] rdata0;
  logic [47:0] rdata1;
  logic [47:0] rdata2;
  logic [47:0] rdata3;

  always_ff @(posedge clock) begin
    if (fetchbuffer_reg_in.wen0 == 1) begin
      fetchbuffer_reg_array0[fetchbuffer_reg_in.waddr0] <= fetchbuffer_reg_in.wdata0;
    end
  end

  always_ff @(posedge clock) begin
    if (fetchbuffer_reg_in.wen1 == 1) begin
      fetchbuffer_reg_array1[fetchbuffer_reg_in.waddr1] <= fetchbuffer_reg_in.wdata1;
    end
  end

  always_ff @(posedge clock) begin
    if (fetchbuffer_reg_in.wen2 == 1) begin
      fetchbuffer_reg_array2[fetchbuffer_reg_in.waddr2] <= fetchbuffer_reg_in.wdata2;
    end
  end

  always_ff @(posedge clock) begin
    if (fetchbuffer_reg_in.wen3 == 1) begin
      fetchbuffer_reg_array3[fetchbuffer_reg_in.waddr3] <= fetchbuffer_reg_in.wdata3;
    end
  end

  always_comb begin
    rdata0 = fetchbuffer_reg_array0[fetchbuffer_reg_in.raddr0];
    rdata1 = fetchbuffer_reg_array1[fetchbuffer_reg_in.raddr1];
    rdata2 = fetchbuffer_reg_array2[fetchbuffer_reg_in.raddr2];
    rdata3 = fetchbuffer_reg_array3[fetchbuffer_reg_in.raddr3];
  end

  always_comb begin
    fetchbuffer_reg_out.rdata0 = fetchbuffer_reg_in.raddr0 == fetchbuffer_reg_in.waddr0 ? fetchbuffer_reg_in.wdata0 : rdata0;
    fetchbuffer_reg_out.rdata1 = fetchbuffer_reg_in.raddr1 == fetchbuffer_reg_in.waddr1 ? fetchbuffer_reg_in.wdata1 : rdata1;
    fetchbuffer_reg_out.rdata2 = fetchbuffer_reg_in.raddr2 == fetchbuffer_reg_in.waddr2 ? fetchbuffer_reg_in.wdata2 : rdata2;
    fetchbuffer_reg_out.rdata3 = fetchbuffer_reg_in.raddr3 == fetchbuffer_reg_in.waddr3 ? fetchbuffer_reg_in.wdata3 : rdata3;
  end

endmodule

module fetchbuffer_ctrl (
    input logic reset,
    input logic clock,
    input fetchbuffer_in_type fetchbuffer_in,
    output fetchbuffer_out_type fetchbuffer_out,
    input fetchbuffer_reg_out_type fetchbuffer_reg_out,
    output fetchbuffer_reg_in_type fetchbuffer_reg_in
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(fetchbuffer_depth - 1);
  localparam total = fetchbuffer_depth - 4;

  localparam [depth-1:0] one = 1;

  typedef struct packed {
    logic [depth+1 : 0] wid;
    logic [depth+1 : 0] rid;
    logic [depth+1 : 0] diff;
    logic [depth+1 : 0] count;
    logic [depth+1 : 0] align;
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
    logic [0 : 0] comp2;
    logic [0 : 0] comp3;
    logic [0 : 0] ready0;
    logic [0 : 0] ready1;
    logic [0 : 0] clear;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
      wid : 0,
      rid : 0,
      diff : 0,
      count : 0,
      align : 0,
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
      comp2 : 0,
      comp3 : 0,
      ready0 : 0,
      ready1 : 0,
      clear : 0,
      stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    v = r;

    if (fetchbuffer_in.clear == 1) begin
      v.wid   = 0;
      v.rid   = 0;
      v.count = 0;
      v.clear = 1;
    end

    if (r.clear == 1 && fetchbuffer_in.clear == 0 && fetchbuffer_in.ready == 1) begin
      v.rid   = {{depth{1'b0}}, fetchbuffer_in.pc[2:1]};
      v.align = {{depth{1'b0}}, fetchbuffer_in.pc[2:1]};
      v.clear = 0;
    end

    v.wen = (~fetchbuffer_in.clear) & (~r.stall) & fetchbuffer_in.ready;

    v.wdata0 = {fetchbuffer_in.pc[31:3], 3'b000, fetchbuffer_in.rdata[15:0]};
    v.wdata1 = {fetchbuffer_in.pc[31:3], 3'b010, fetchbuffer_in.rdata[31:16]};
    v.wdata2 = {fetchbuffer_in.pc[31:3], 3'b100, fetchbuffer_in.rdata[47:32]};
    v.wdata3 = {fetchbuffer_in.pc[31:3], 3'b110, fetchbuffer_in.rdata[63:48]};

    fetchbuffer_reg_in.wen0 = v.wen;
    fetchbuffer_reg_in.wen1 = v.wen;
    fetchbuffer_reg_in.wen2 = v.wen;
    fetchbuffer_reg_in.wen3 = v.wen;
    fetchbuffer_reg_in.waddr0 = v.wid[depth+1:2];
    fetchbuffer_reg_in.waddr1 = v.wid[depth+1:2];
    fetchbuffer_reg_in.waddr2 = v.wid[depth+1:2];
    fetchbuffer_reg_in.waddr3 = v.wid[depth+1:2];
    fetchbuffer_reg_in.wdata0 = v.wdata0;
    fetchbuffer_reg_in.wdata1 = v.wdata1;
    fetchbuffer_reg_in.wdata2 = v.wdata2;
    fetchbuffer_reg_in.wdata3 = v.wdata3;

    if (v.rid[1:0] == 0) begin
      fetchbuffer_reg_in.raddr0 = v.rid[depth+1:2];
      fetchbuffer_reg_in.raddr1 = v.rid[depth+1:2];
      fetchbuffer_reg_in.raddr2 = v.rid[depth+1:2];
      fetchbuffer_reg_in.raddr3 = v.rid[depth+1:2];
    end else if (v.rid[1:0] == 1) begin
      fetchbuffer_reg_in.raddr0 = v.rid[depth+1:2] + one;
      fetchbuffer_reg_in.raddr1 = v.rid[depth+1:2];
      fetchbuffer_reg_in.raddr2 = v.rid[depth+1:2];
      fetchbuffer_reg_in.raddr3 = v.rid[depth+1:2];
    end else if (v.rid[1:0] == 2) begin
      fetchbuffer_reg_in.raddr0 = v.rid[depth+1:2] + one;
      fetchbuffer_reg_in.raddr1 = v.rid[depth+1:2] + one;
      fetchbuffer_reg_in.raddr2 = v.rid[depth+1:2];
      fetchbuffer_reg_in.raddr3 = v.rid[depth+1:2];
    end else begin
      fetchbuffer_reg_in.raddr0 = v.rid[depth+1:2] + one;
      fetchbuffer_reg_in.raddr1 = v.rid[depth+1:2] + one;
      fetchbuffer_reg_in.raddr2 = v.rid[depth+1:2] + one;
      fetchbuffer_reg_in.raddr3 = v.rid[depth+1:2];
    end

    if (v.rid[1:0] == 0) begin
      v.rdata0 = fetchbuffer_reg_out.rdata0;
      v.rdata1 = fetchbuffer_reg_out.rdata1;
      v.rdata2 = fetchbuffer_reg_out.rdata2;
      v.rdata3 = fetchbuffer_reg_out.rdata3;
    end else if (v.rid[1:0] == 1) begin
      v.rdata0 = fetchbuffer_reg_out.rdata1;
      v.rdata1 = fetchbuffer_reg_out.rdata2;
      v.rdata2 = fetchbuffer_reg_out.rdata3;
      v.rdata3 = fetchbuffer_reg_out.rdata0;
    end else if (v.rid[1:0] == 2) begin
      v.rdata0 = fetchbuffer_reg_out.rdata2;
      v.rdata1 = fetchbuffer_reg_out.rdata3;
      v.rdata2 = fetchbuffer_reg_out.rdata0;
      v.rdata3 = fetchbuffer_reg_out.rdata1;
    end else begin
      v.rdata0 = fetchbuffer_reg_out.rdata3;
      v.rdata1 = fetchbuffer_reg_out.rdata0;
      v.rdata2 = fetchbuffer_reg_out.rdata1;
      v.rdata3 = fetchbuffer_reg_out.rdata2;
    end

    if (v.wen == 1) begin
      v.wid   = v.wid + 4;
      v.count = v.count + 4;
    end

    v.diff = 0;

    v.comp0 = ~(&v.rdata0[1:0]);
    v.comp1 = ~(&v.rdata1[1:0]);
    v.comp2 = ~(&v.rdata2[1:0]);
    v.comp3 = ~(&v.rdata3[1:0]);

    v.pc0 = 0;
    v.pc1 = 0;
    v.instr0 = 0;
    v.instr1 = 0;
    v.ready0 = 0;
    v.ready1 = 0;

    if (v.comp0 == 1 && v.comp1 == 1) begin
      if (v.count > v.align) begin
        v.pc0 = v.rdata0[47:16];
        v.instr0 = {16'b0, v.rdata0[15:0]};
        v.ready0 = 1;
        v.diff = 1;
      end
      if (v.count > v.align + 1) begin
        v.pc1 = v.rdata1[47:16];
        v.instr1 = {16'b0, v.rdata1[15:0]};
        v.ready1 = 1;
        v.diff = 2;
      end
    end
    if (v.comp0 == 1 && v.comp1 == 0) begin
      if (v.count > v.align) begin
        v.pc0 = v.rdata0[47:16];
        v.instr0 = {16'b0, v.rdata0[15:0]};
        v.ready0 = 1;
        v.diff = 1;
      end
      if (v.count > v.align + 2) begin
        v.pc1 = v.rdata1[47:16];
        v.instr1 = {v.rdata2[15:0], v.rdata1[15:0]};
        v.ready1 = 1;
        v.diff = 3;
      end
    end
    if (v.comp0 == 0 && v.comp2 == 1) begin
      if (v.count > v.align + 1) begin
        v.pc0 = v.rdata0[47:16];
        v.instr0 = {v.rdata1[15:0], v.rdata0[15:0]};
        v.ready0 = 1;
        v.diff = 2;
      end
      if (v.count > v.align + 2) begin
        v.pc1 = v.rdata2[47:16];
        v.instr1 = {16'b0, v.rdata2[15:0]};
        v.ready1 = 1;
        v.diff = 3;
      end
    end
    if (v.comp0 == 0 && v.comp2 == 0) begin
      if (v.count > v.align + 1) begin
        v.pc0 = v.rdata0[47:16];
        v.instr0 = {v.rdata1[15:0], v.rdata0[15:0]};
        v.ready0 = 1;
        v.diff = 2;
      end
      if (v.count > v.align + 3) begin
        v.pc1 = v.rdata2[47:16];
        v.instr1 = {v.rdata3[15:0], v.rdata2[15:0]};
        v.ready1 = 1;
        v.diff = 4;
      end
    end

    if (fetchbuffer_in.stall == 1) begin
      v.diff   = 0;
      v.ready0 = 0;
      v.ready1 = 0;
    end

    v.count = v.count - v.diff;
    v.rid   = v.rid + v.diff;

    v.stall = 0;

    if (v.count > total) begin
      v.stall = 1;
    end

    fetchbuffer_out.pc0 = v.ready0 ? v.pc0 : 32'hFFFFFFFF;
    fetchbuffer_out.pc1 = v.ready1 ? v.pc1 : 32'hFFFFFFFF;
    fetchbuffer_out.instr0 = v.ready0 ? v.instr0 : 0;
    fetchbuffer_out.instr1 = v.ready1 ? v.instr1 : 0;
    fetchbuffer_out.ready0 = v.ready0;
    fetchbuffer_out.ready1 = v.ready1;
    fetchbuffer_out.stall = ~v.wen;

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

module fetchbuffer (
    input logic reset,
    input logic clock,
    input fetchbuffer_in_type fetchbuffer_in,
    output fetchbuffer_out_type fetchbuffer_out
);
  timeunit 1ns; timeprecision 1ps;

  fetchbuffer_reg_in_type  fetchbuffer_reg_in;
  fetchbuffer_reg_out_type fetchbuffer_reg_out;

  fetchbuffer_reg fetchbuffer_reg_comp (
      .clock(clock),
      .fetchbuffer_reg_in(fetchbuffer_reg_in),
      .fetchbuffer_reg_out(fetchbuffer_reg_out)
  );

  fetchbuffer_ctrl fetchbuffer_ctrl_comp (
      .reset(reset),
      .clock(clock),
      .fetchbuffer_in(fetchbuffer_in),
      .fetchbuffer_out(fetchbuffer_out),
      .fetchbuffer_reg_in(fetchbuffer_reg_in),
      .fetchbuffer_reg_out(fetchbuffer_reg_out)
  );

endmodule
