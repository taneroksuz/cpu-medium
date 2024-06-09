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
  logic [7  : 0] byteenable;
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
        0 : byteenable = 8'hFF;
        default : misalign = 1;
      endcase
    end

    if (dmem_access == 1) begin
      if (agu_in.lsu_op.lsu_sb == 1 || agu_in.lsu_op.lsu_lb == 1 || agu_in.lsu_op.lsu_lbu == 1) begin
        case (address[2:0])
          0 : byteenable = 8'h01;
          1 : byteenable = 8'h02;
          2 : byteenable = 8'h04;
          3 : byteenable = 8'h08;
          4 : byteenable = 8'h10;
          5 : byteenable = 8'h20;
          6 : byteenable = 8'h40;
          7 : byteenable = 8'h80;
          default : misalign = 1;
        endcase
      end
      if (agu_in.lsu_op.lsu_sh == 1 || agu_in.lsu_op.lsu_lh == 1 || agu_in.lsu_op.lsu_lhu == 1) begin
        case (address[2:0])
          0 : byteenable = 8'h03;
          2 : byteenable = 8'h0C;
          4 : byteenable = 8'h30;
          6 : byteenable = 8'hC0;
          default : misalign = 1;
        endcase
      end
      if (agu_in.lsu_op.lsu_sw == 1 || agu_in.lsu_op.lsu_lw == 1) begin
        case (address[2:0])
          0 : byteenable = 8'h0F;
          4 : byteenable = 8'hF0;
          default : misalign = 1;
        endcase
      end
      if (agu_in.lsu_op.lsu_sd == 1 || agu_in.lsu_op.lsu_ld == 1) begin
        case (address[2:0])
          0 : byteenable = 8'hFF;
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
