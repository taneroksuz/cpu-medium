import wires::*;
import functions::*;

module bit_alu
(
  input bit_alu_in_type bit_alu_in,
  output bit_alu_out_type bit_alu_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] rdata1;
  logic [31 : 0] rdata2;
  logic [31 : 0] result;

  logic [1 : 0] index;
  logic [1 : 0] op;

  zba_op_type bit_zba;
  zbb_op_type bit_zbb;
  zbs_op_type bit_zbs;

  always_comb begin

    rdata1 = bit_alu_in.rdata1;
    rdata2 = multiplexer(bit_alu_in.imm,bit_alu_in.rdata2,bit_alu_in.sel);
    result = 0;

    index = 0;
    op = 0;

		bit_zba = bit_alu_in.bit_op.bit_zba;
		bit_zbb = bit_alu_in.bit_op.bit_zbb;
		bit_zbs = bit_alu_in.bit_op.bit_zbs;

		if (bit_zba.bit_sh1add == 1) begin
			index = 1;
		end else if (bit_zba.bit_sh2add == 1) begin
			index = 2;
		end else if (bit_zba.bit_sh3add == 1) begin
			index = 3;
		end

		if (bit_zbb.bit_max == 1) begin
			op = 0;
		end else if (bit_zbb.bit_maxu == 1) begin
			op = 1;
		end else if (bit_zbb.bit_min == 1) begin
			op = 2;
		end else if (bit_zbb.bit_minu == 1) begin
			op = 3;
		end

		if ((bit_zba.bit_sh1add | bit_zba.bit_sh2add | bit_zba.bit_sh3add) == 1) begin
			result = bit_shadd(rdata1,rdata2,index);
		end else if (bit_zbb.bit_andn == 1) begin
			result = bit_andn(rdata1,rdata2);
		end else if (bit_zbb.bit_orn == 1) begin
			result = bit_orn(rdata1,rdata2);
		end else if (bit_zbb.bit_xnor == 1) begin
			result = bit_xnor(rdata1,rdata2);
		end else if (bit_zbb.bit_clz == 1) begin
			result = bit_clz(rdata1);
		end else if (bit_zbb.bit_cpop == 1) begin
			result = bit_cpop(rdata1);
		end else if (bit_zbb.bit_ctz == 1) begin
			result = bit_ctz(rdata1);
		end else if ((bit_zbb.bit_max | bit_zbb.bit_maxu | bit_zbb.bit_min | bit_zbb.bit_minu) == 1) begin
			result = bit_minmax(rdata1,rdata2,op);
		end else if (bit_zbb.bit_orcb == 1) begin
			result = bit_orcb(rdata1);
		end else if (bit_zbb.bit_rev8 == 1) begin
			result = bit_rev8(rdata1);
		end else if (bit_zbb.bit_rol == 1) begin
			result = bit_rol(rdata1,rdata2);
		end else if (bit_zbb.bit_ror == 1) begin
			result = bit_ror(rdata1,rdata2);
		end else if (bit_zbb.bit_sextb == 1) begin
			result = bit_sextb(rdata1);
		end else if (bit_zbb.bit_sexth == 1) begin
			result = bit_sexth(rdata1);
		end else if (bit_zbb.bit_zexth == 1) begin
			result = bit_zexth(rdata1);
		end else if (bit_zbs.bit_bclr == 1) begin
			result = bit_bclr(rdata1,rdata2);
		end else if (bit_zbs.bit_bext == 1) begin
			result = bit_bext(rdata1,rdata2);
		end else if (bit_zbs.bit_binv == 1) begin
			result = bit_binv(rdata1,rdata2);
		end else if (bit_zbs.bit_bset == 1) begin
			result = bit_bset(rdata1,rdata2);
		end

    bit_alu_out.result = result;

  end

endmodule
