import configure::*;
import wires::*;
import fp_cons::*;
import fp_wire::*;

module fpu_decode
(
  input fp_decode_in_type fp_decode_in,
  output fp_decode_out_type fp_decode_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] instr;

  logic [31 : 0] imm;

  logic [4  : 0] waddr;
  logic [4  : 0] raddr1;
  logic [4  : 0] raddr2;
  logic [4  : 0] raddr3;

  logic [0  : 0] wren;
  logic [0  : 0] rden1;

  logic [0  : 0] fp_wren;
  logic [0  : 0] fp_rden1;
  logic [0  : 0] fp_rden2;
  logic [0  : 0] fp_rden3;

  logic [0  : 0] fp_load;
  logic [0  : 0] fp_store;

  logic [0  : 0] fp;

  fp_operation_type fp_op;

  logic [0  : 0] valid;

  always_comb begin

    instr = fp_decode_in.instr;

    imm_i = {{20{instr[31]}},instr[31:20]};
    imm_s = {{20{instr[31]}},instr[31:25],instr[11:7]};

    opcode = instr[6:0];
    funct3 = instr[14:12];
    funct7 = instr[31:25];
    rm = instr[14:12];

    imm = 0;

    waddr = instr[11:7];
    raddr1 = instr[19:15];
    raddr2 = instr[24:20];
    raddr3 = instr[31:27];

    wren = 0;
    rden1 = 0;

    fp_wren = 0;
    fp_rden1 = 0;
    fp_rden2 = 0;
    fp_rden3 = 0;

    fp_load = 0;
    fp_store = 0;

    fp = 0;

    fp_op = init_fp_operation;

    valid = 1;

    case (opcode)
      opcode_fload | opcode_fstore : begin
        if (opcode[5] == 0) begin
          imm = imm_i;
          rden1 = 1;
          fp_rden2 = 1;
          fp_load = 1;
          fp = 1;
        end else if (opcode[5] == 1) begin
          imm = imm_s;
          rden1 = 1;
          fp_wren = 1;
          fp_store = 1;
          fp = 1;
        end
      end
      opcode_fp : begin
        case (funct7[6:2]) 
          funct_fadd | funct_fsub | funct_fmul | funct_fdiv : begin
            fp_wren = 1;
            fp_rden1 = 1;
            fp_rden2 = 1;
            fp = 1;
            if (funct7[3:2] == 0) begin
              fp_op.fadd = 1;
            end else if (funct7[3:2] == 1) begin
              fp_op.fsub = 1;
            end else if (funct7[3:2] == 2) begin
              fp_op.fmul = 1;
            end else if (funct7[3:2] == 3) begin
              fp_op.fdiv = 1;
            end
          end
          funct_fsqrt : begin
            fp_wren = 1;
            fp_rden1 = 1;
            fp = 1;
            fp_op.fsqrt = 1;
          end
          funct_fsgnj : begin
            fp_wren = 1;
            fp_rden1 = 1;
            fp_rden2 = 1;
            fp = 1;
            fp_op.fsgnj = 1;
          end
          funct_fmax : begin
            fp_wren = 1;
            fp_rden1 = 1;
            fp_rden2 = 1;
            fp = 1;
            fp_op.fmax = 1;
          end
          funct_fcmp : begin
            fp_wren = 1;
            fp_rden1 = 1;
            fp_rden2 = 1;
            fp = 1;
            fp_op.fcmp = 1;
          end
          funct_fmv_f2i | funct_fmv_i2f : begin
            if (v.funct7[3] == 0) begin
              wren = 1;
              fp_rden1 = 1;
              fp = 1;
              if (rm == 0) begin
                fp_op.fmv_f2i = 1;
              end else if (rm == 1) begin
                fp_op.fclass = 1;
              end
            end else if (v.funct7[3] == 1) begin
              rden1 = 1;
              fp_wren = 1;
              fp = 1;
              fp_op.fmv_i2f = 1;
            end
          end
          funct_fcvt_f2i | funct_fcvt_i2f : begin
            if (v.funct7[3] == 0) begin
              wren = 1;
              fp_rden1 = 1;
              fp = 1;
              fp_op.fcvt_f2i = 1;
            end else if (v.funct7[3] == 1) begin
              rden1 = 1;
              fp_wren = 1;
              fp = 1;
              fp_op.fcvt_i2f = 1;
            end
          end
          default : valid = 0;
        endcase
      end
      opcode_fmadd | opcode_fmsub | opcode_fnmsub | opcode_fnmadd : begin
        fp_wren = 1;
        fp_rden1 = 1;
        fp_rden2 = 1;
        fp_rden3 = 1;
        fp = 1;
        if (opcode[3:2] == 0) begin
          fp_op.fmadd = 1;
        end else if (opcode[3:2] == 1) begin
          fp_op.fmsub = 1;
        end else if (opcode[3:2] == 2) begin
          fp_op.fnmsub = 1;
        end else if (opcode[3:2] == 3) begin
          fp_op.fnmadd = 1;
        end
      end
      default : valid = 0;
    endcase

    fp_decode_out.imm = imm;
    fp_decode_out.waddr = waddr;
    fp_decode_out.raddr1 = raddr1;
    fp_decode_out.raddr2 = raddr2;
    fp_decode_out.raddr3 = raddr3;
    fp_decode_out.wren = wren;
    fp_decode_out.rden1 = rden1;
    fp_decode_out.fp_wren = fp_wren;
    fp_decode_out.fp_rden1 = fp_rden1;
    fp_decode_out.fp_rden2 = fp_rden2;
    fp_decode_out.fp_rden3 = fp_rden3;
    fp_decode_out.fp_load = fp_load;
    fp_decode_out.fp_store = fp_store;
    fp_decode_out.fp = fp;
    fp_decode_out.valid = valid;
    fp_decode_out.fp_op = fp_op;

  end

endmodule

module fpu
(
  input logic rst,
  input logic clk,
  input fpu_in_type fpu_in,
  output fpu_out_type fpu_out
);
  timeunit 1ns;
  timeprecision 1ps;

endmodule
