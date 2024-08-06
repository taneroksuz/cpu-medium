import wires::*;
import functions::*;

module csr_alu (
    input  csr_alu_in_type  csr_alu_in,
    output csr_alu_out_type csr_alu_out
);
  timeunit 1ns; timeprecision 1ps;

  logic [31:0] rdata1;
  logic [31:0] cdata;

  always_comb begin

    rdata1 = multiplexer(csr_alu_in.imm, csr_alu_in.rdata1, csr_alu_in.sel);
    cdata  = 0;

    if (csr_alu_in.csr_op.csrrw == 1 | csr_alu_in.csr_op.csrrwi == 1) begin
      cdata = rdata1;
    end else if (csr_alu_in.csr_op.csrrs == 1 | csr_alu_in.csr_op.csrrsi == 1) begin
      cdata = csr_alu_in.cdata | rdata1;
    end else if (csr_alu_in.csr_op.csrrc == 1 | csr_alu_in.csr_op.csrrci == 1) begin
      cdata = csr_alu_in.cdata & ~rdata1;
    end

    csr_alu_out.cdata = cdata;

  end

endmodule
