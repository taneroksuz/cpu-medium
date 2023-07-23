import constants::*;
import wires::*;
import functions::*;

module agu
(
  input agu_in_type agu_in,
  output agu_out_type agu_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0  : 0] misalign;

  logic [0  : 0] exception;
  logic [3  : 0] ecause;
  logic [31 : 0] etval;

  logic [0  : 0] imem_access;
  logic [0  : 0] dmem_access;

  logic [31 : 0] address;
  logic [3  : 0] byteenable;
  logic [0  : 0] sel;

  always_comb begin

    misalign = 0;

    exception = 0;
    ecause = 0;
    etval = 0;

    imem_access = agu_in.jal | agu_in.jalr | agu_in.branch;
    dmem_access = agu_in.load | agu_in.store;

    sel = agu_in.auipc | agu_in.jal | agu_in.branch;

    address = multiplexer(agu_in.rdata1, agu_in.pc, sel) + agu_in.imm;
    address[0] = address[0] & ~agu_in.jalr;

    byteenable = 0;

    if (imem_access == 1) begin
      case (address[0])
        0 : byteenable = 4'hF;
        default : misalign = 1;
      endcase
    end

    if (dmem_access == 1) begin
      if (agu_in.lsu_op.lsu_sb == 1 || agu_in.lsu_op.lsu_lb == 1 || agu_in.lsu_op.lsu_lbu == 1) begin
        case (address[1:0])
          0 : byteenable = 4'h1;
          1 : byteenable = 4'h2;
          2 : byteenable = 4'h4;
          3 : byteenable = 4'h8;
          default : misalign = 1;
        endcase
      end
      if (agu_in.lsu_op.lsu_sh == 1 || agu_in.lsu_op.lsu_lh == 1 || agu_in.lsu_op.lsu_lhu == 1) begin
        case (address[1:0])
          0 : byteenable = 4'h3;
          2 : byteenable = 4'hC;
          default : misalign = 1;
        endcase
      end
      if (agu_in.lsu_op.lsu_sw == 1 || agu_in.lsu_op.lsu_lw == 1) begin
        case (address[1:0])
          0 : byteenable = 4'hF;
          default : misalign = 1;
        endcase
      end
    end

    if (misalign == 1) begin
      if (imem_access == 1) begin
        exception = 1;
        ecause = except_instr_addr_misalign;
        etval = address;
      end
      if (dmem_access == 1) begin
        if (agu_in.load == 1) begin
          exception = 1;
          ecause = except_load_addr_misalign;
          etval = address;
        end
        if (agu_in.store == 1) begin
          exception = 1;
          ecause = except_store_addr_misalign;
          etval = address;
        end
      end
    end

    agu_out.address = address;
    agu_out.byteenable = byteenable;

    agu_out.exception = exception;
    agu_out.ecause = ecause;
    agu_out.etval = etval;

  end

endmodule
