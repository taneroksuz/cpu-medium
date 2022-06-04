import wires::*;

module mul
(
  input logic rst,
  input logic clk,
  input mul_in_type mul_in,
  output mul_out_type mul_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic signed [32:0] op1;
  logic signed [32:0] op2;

  logic signed [65:0] result;

  mul_op_type mul_op;

  logic [0:0] op1_signed;
  logic [0:0] op2_signed;

  always_comb begin

    op1 = {1'b0,mul_in.rdata1};
    op2 = {1'b0,mul_in.rdata2};
    mul_op = mul_in.mul_op;
    op1_signed = mul_op.muls | mul_op.mulh |
                   mul_op.mulhsu;
    op2_signed = mul_op.muls | mul_op.mulh;
    if (op1_signed == 1) begin
      op1[32] = op1[31];
    end
    if (op2_signed == 1) begin
      op2[32] = op2[31];
    end
    result = op1*op2;
    if (mul_op.muls == 1) begin
      mul_out.result = result[31:0];
    end else begin
      mul_out.result = result[63:32];
    end

  end

endmodule
