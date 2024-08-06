import wires::*;
import functions::*;

module alu (
    input  alu_in_type  alu_in,
    output alu_out_type alu_out
);
  timeunit 1ns; timeprecision 1ps;

  logic [31 : 0] rdata2;
  logic [31 : 0] result;

  always_comb begin

    rdata2 = multiplexer(alu_in.imm, alu_in.rdata2, alu_in.sel);
    result = 0;

    if (alu_in.alu_op.alu_add == 1) begin
      result = alu_in.rdata1 + rdata2;
    end else if (alu_in.alu_op.alu_sub == 1) begin
      result = alu_in.rdata1 - rdata2;
    end else if (alu_in.alu_op.alu_sll == 1) begin
      result = alu_in.rdata1 << rdata2[4:0];
    end else if (alu_in.alu_op.alu_srl == 1) begin
      result = alu_in.rdata1 >> rdata2[4:0];
    end else if (alu_in.alu_op.alu_sra == 1) begin
      result = $signed(alu_in.rdata1) >>> rdata2[4:0];
    end else if (alu_in.alu_op.alu_slt == 1) begin
      result[0] = $signed(alu_in.rdata1) < $signed(rdata2);
    end else if (alu_in.alu_op.alu_sltu == 1) begin
      result[0] = alu_in.rdata1 < rdata2;
    end else if (alu_in.alu_op.alu_and == 1) begin
      result = alu_in.rdata1 & rdata2;
    end else if (alu_in.alu_op.alu_or == 1) begin
      result = alu_in.rdata1 | rdata2;
    end else if (alu_in.alu_op.alu_xor == 1) begin
      result = alu_in.rdata1 ^ rdata2;
    end

    alu_out.result = result;

  end

endmodule
