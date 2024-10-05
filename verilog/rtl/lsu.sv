import wires::*;

module lsu (
    input  lsu_in_type  lsu_in,
    output lsu_out_type lsu_out
);
  timeunit 1ns; timeprecision 1ps;

  logic [63:0] ldata;
  logic [ 7:0] data_b;
  logic [15:0] data_h;
  logic [31:0] data_w;
  logic [63:0] data_d;

  always_comb begin

    data_b = 0;
    data_h = 0;
    data_w = 0;
    data_d = 0;
    if (lsu_in.byteenable == 8'h01) begin
      data_b = lsu_in.ldata[7:0];
    end
    if (lsu_in.byteenable == 8'h02) begin
      data_b = lsu_in.ldata[15:8];
    end
    if (lsu_in.byteenable == 8'h04) begin
      data_b = lsu_in.ldata[23:16];
    end
    if (lsu_in.byteenable == 8'h08) begin
      data_b = lsu_in.ldata[31:24];
    end
    if (lsu_in.byteenable == 8'h10) begin
      data_b = lsu_in.ldata[39:32];
    end
    if (lsu_in.byteenable == 8'h20) begin
      data_b = lsu_in.ldata[47:40];
    end
    if (lsu_in.byteenable == 8'h40) begin
      data_b = lsu_in.ldata[55:48];
    end
    if (lsu_in.byteenable == 8'h80) begin
      data_b = lsu_in.ldata[63:56];
    end
    if (lsu_in.byteenable == 8'h03) begin
      data_h = lsu_in.ldata[15:0];
    end
    if (lsu_in.byteenable == 8'h0C) begin
      data_h = lsu_in.ldata[31:16];
    end
    if (lsu_in.byteenable == 8'h30) begin
      data_h = lsu_in.ldata[47:32];
    end
    if (lsu_in.byteenable == 8'hC0) begin
      data_h = lsu_in.ldata[63:48];
    end
    if (lsu_in.byteenable == 8'h0F) begin
      data_w = lsu_in.ldata[31:0];
    end
    if (lsu_in.byteenable == 8'hF0) begin
      data_w = lsu_in.ldata[63:32];
    end
    if (lsu_in.byteenable == 8'hFF) begin
      data_d = lsu_in.ldata[63:0];
    end

    ldata = 0;
    if (lsu_in.lsu_op.lsu_lb == 1) begin
      ldata = {{56{data_b[7]}}, data_b};
    end
    if (lsu_in.lsu_op.lsu_lh == 1) begin
      ldata = {{48{data_h[15]}}, data_h};
    end
    if (lsu_in.lsu_op.lsu_lw == 1) begin
      ldata = {{32{data_w[31]}}, data_w};
    end
    if (lsu_in.lsu_op.lsu_ld == 1) begin
      ldata = data_d;
    end
    if (lsu_in.lsu_op.lsu_lbu == 1) begin
      ldata = {56'b0, data_b};
    end
    if (lsu_in.lsu_op.lsu_lhu == 1) begin
      ldata = {48'b0, data_h};
    end
    if (lsu_in.lsu_op.lsu_lwu == 1) begin
      ldata = {32'b0, data_w};
    end

    lsu_out.result = ldata;

  end

endmodule
