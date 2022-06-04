import wires::*;

module bcu
(
  input bcu_in_type bcu_in,
  output bcu_out_type bcu_out
);
  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin

    if (bcu_in.bcu_op.bcu_beq == 1) begin
      bcu_out.branch = bcu_in.rdata1 == bcu_in.rdata2;
    end else if (bcu_in.bcu_op.bcu_bne == 1) begin
      bcu_out.branch = bcu_in.rdata1 != bcu_in.rdata2;
    end else if (bcu_in.bcu_op.bcu_blt == 1) begin
      bcu_out.branch = $signed(bcu_in.rdata1) < $signed(bcu_in.rdata2);
    end else if (bcu_in.bcu_op.bcu_bge == 1) begin
      bcu_out.branch = $signed(bcu_in.rdata1) >= $signed(bcu_in.rdata2);
    end else if (bcu_in.bcu_op.bcu_bltu == 1) begin
      bcu_out.branch = bcu_in.rdata1 < bcu_in.rdata2;
    end else if (bcu_in.bcu_op.bcu_bgeu == 1) begin
      bcu_out.branch = bcu_in.rdata1 >= bcu_in.rdata2;
    end else begin
      bcu_out.branch = 1'b0;
    end

  end

endmodule
