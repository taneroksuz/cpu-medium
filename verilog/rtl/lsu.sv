import wires::*;

module lsu
(
  input lsu_in_type lsu_in,
  output lsu_out_type lsu_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] ldata;
  logic [7:0]  data_b;
  logic [15:0] data_h;
  logic [31:0] data_w;

  always_comb begin

    data_b = 0;
    data_h = 0;
    data_w = 0;
    if (lsu_in.byteenable == 4'h1) begin
      data_b = lsu_in.ldata[7:0];
    end
    if (lsu_in.byteenable == 4'h2) begin
      data_b = lsu_in.ldata[15:8];
    end
    if (lsu_in.byteenable == 4'h4) begin
      data_b = lsu_in.ldata[23:16];
    end
    if (lsu_in.byteenable == 4'h8) begin
      data_b = lsu_in.ldata[31:24];
    end
    if (lsu_in.byteenable == 4'h3) begin
      data_h = lsu_in.ldata[15:0];
    end
    if (lsu_in.byteenable == 4'hC) begin
      data_h = lsu_in.ldata[31:16];
    end
    if (lsu_in.byteenable == 4'hF) begin
      data_w = lsu_in.ldata;
    end

    ldata = 0;
    if (lsu_in.lsu_op.lsu_lb == 1) begin
      ldata = {{24{data_b[7]}},data_b};
    end
    if (lsu_in.lsu_op.lsu_lh == 1) begin
      ldata = {{16{data_h[15]}},data_h};
    end
    if (lsu_in.lsu_op.lsu_lw == 1) begin
      ldata = data_w;
    end
    if (lsu_in.lsu_op.lsu_lbu == 1) begin
      ldata = {24'b0,data_b};
    end
    if (lsu_in.lsu_op.lsu_lhu == 1) begin
      ldata = {16'b0,data_h};
    end

    lsu_out.result = ldata;

  end

endmodule
