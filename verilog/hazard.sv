import configure::*;
import constants::*;
import wires::*;

module hazard
(
  input logic reset,
  input logic clock,
  input hazard_in_type hazard_in,
  output hazard_out_type hazard_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(hazard_depth-1);
  localparam total = 2**(depth-1);

  logic [31 : 0] buffer [0:hazard_depth-1];
  logic [31 : 0] buffer_reg [0:hazard_depth-1];

  logic [depth-1 : 0] wid;
  logic [depth-1 : 0] wid_reg;
  logic [depth-1 : 0] rid;
  logic [depth-1 : 0] rid_reg;

  logic [depth-1 : 0] count;
  logic [depth-1 : 0] count_reg;

  logic [31 : 0] instr [0:1];

  logic [6 : 0] opcode [0:1];
  logic [2 : 0] funct3 [0:1];
  logic [4 : 0] funct5 [0:1];

  logic [4 : 0] waddr [0:1];
  logic [4 : 0] raddr1 [0:1];
  logic [4 : 0] raddr2 [0:1];
  logic [4 : 0] raddr3 [0:1];

  logic [0 : 0] wren [0:1];
  logic [0 : 0] rden1 [0:1];
  logic [0 : 0] rden2 [0:1];

  logic [0 : 0] fwren [0:1];
  logic [0 : 0] frden1 [0:1];
  logic [0 : 0] frden2 [0:1];
  logic [0 : 0] frden3 [0:1];

  logic [0 : 0] nonzero_waddr [0:1];
  logic [0 : 0] nonzero_raddr1 [0:1];

  logic [0 : 0] pass;
  logic [0 : 0] stall;

  always_comb begin

    buffer = buffer_reg;
    count = count_reg;
    wid = wid_reg;
    rid = rid_reg;

    if (hazard_in.ready == 1) begin
      buffer[wid] = hazard_in.rdata[31:0];
      buffer[wid+1] = hazard_in.rdata[63:32];
      count = count + 2;
      wid = wid + 2;
    end

    instr[0] = count > 0 ? buffer[rid] : nop_instr;
    instr[1] = count > 1 ? buffer[rid+1] : nop_instr;

    opcode = {instr[0][6:0],instr[1][6:0]};
    funct3 = {instr[0][14:12],instr[1][14:12]};
    funct5 = {instr[0][31:27],instr[1][31:27]};

    waddr = {instr[0][11:7],instr[1][11:7]};
    raddr1 = {instr[0][19:15],instr[1][19:15]};
    raddr2 = {instr[0][24:20],instr[1][24:20]};
    raddr3 = {instr[0][31:27],instr[1][31:27]};

    wren = '{default:'0};
    rden1 = '{default:'0};
    rden2 = '{default:'0};
    rden2 = '{default:'0};

    fwren = '{default:'0};
    frden1 = '{default:'0};
    frden2 = '{default:'0};
    frden3 = '{default:'0};

    nonzero_waddr = {|waddr[0],|waddr[1]};
    nonzero_raddr1 = {|raddr1[0],|raddr1[1]};

    case (opcode[0])
      opcode_lui : begin
        wren[0] = nonzero_waddr[0];
      end
      opcode_auipc : begin
        wren[0] = nonzero_waddr[0];
      end
      opcode_jal : begin
        wren[0] = nonzero_waddr[0];
      end
      opcode_jalr : begin
        wren[0] = nonzero_waddr[0];
        rden1[0] = 1;
      end
      opcode_branch : begin
        rden1[0] = 1;
        rden2[0] = 1;
      end
      opcode_load : begin
        wren[0] = nonzero_waddr[0];
        rden1[0] = 1;
      end
      opcode_store : begin
        rden1[0] = 1;
        rden2[0] = 1;
      end
      opcode_immediate : begin
        wren[0] = nonzero_waddr[0];
        rden1[0] = 1;
      end
      opcode_register : begin
        wren[0] = nonzero_waddr[0];
        rden1[0] = 1;
        rden2[0] = 1;
      end
      opcode_system : begin
        case (funct3[0])
          1 : begin
            wren[0] = nonzero_waddr[0];
            rden1[0] = 1;
          end
          2 : begin
            wren[0] = nonzero_waddr[0];
            rden1[0] = 1;
          end
          3 : begin
            wren[0] = nonzero_waddr[0];
            rden1[0] = 1;
          end
          5 : begin
            wren[0] = nonzero_waddr[0];
          end
          6 : begin
            wren[0] = nonzero_waddr[0];
          end
          7 : begin
            wren[0] = nonzero_waddr[0];
          end
          default : begin
          end
        endcase
      end
      opcode_fload : begin
        rden1[0] = 1;
        fwren[0] = 1;
      end
      opcode_fstore : begin
        rden1[0] = 1;
        frden1[0] = 1;
      end
      opcode_fp : begin
        case (funct5[0])
          funct_fadd : begin
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fsub : begin
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fmul : begin
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fdiv : begin
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fsqrt : begin
            fwren[0] = 1;
            frden1[0] = 1;
          end
          funct_fsgnj : begin
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fminmax : begin
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fcomp : begin
            wren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fmv_f2i : begin
            wren[0] = 1;
            frden1[0] = 1;
          end
          funct_fmv_i2f : begin
            rden1[0] = 1;
            fwren[0] = 1;
          end
          funct_fconv_f2i : begin
            wren[0] = 1;
            frden1[0] = 1;
          end
          funct_fconv_i2f : begin
            rden1[0] = 1;
            fwren[0] = 1;
          end
          default : begin
          end
        endcase
      end
      opcode_fmadd : begin
        fwren[0] = 1;
        frden1[0] = 1;
        frden2[0] = 1;
        frden3[0] = 1;
      end
      opcode_fmsub : begin
        fwren[0] = 1;
        frden1[0] = 1;
        frden2[0] = 1;
        frden3[0] = 1;
      end
      opcode_fnmsub : begin
        fwren[0] = 1;
        frden1[0] = 1;
        frden2[0] = 1;
        frden3[0] = 1;
      end
      opcode_fnmadd : begin
        fwren[0] = 1;
        frden1[0] = 1;
        frden2[0] = 1;
        frden3[0] = 1;
      end
      default : begin
      end
    endcase

    case (opcode[1])
      opcode_lui : begin
        wren[1] = nonzero_waddr[1];
      end
      opcode_auipc : begin
        wren[1] = nonzero_waddr[1];
      end
      opcode_jal : begin
        wren[1] = nonzero_waddr[1];
      end
      opcode_jalr : begin
        wren[1] = nonzero_waddr[1];
        rden1[1] = 1;
      end
      opcode_branch : begin
        rden1[1] = 1;
        rden2[1] = 1;
      end
      opcode_load : begin
        wren[1] = nonzero_waddr[1];
        rden1[1] = 1;
      end
      opcode_store : begin
        rden1[1] = 1;
        rden2[1] = 1;
      end
      opcode_immediate : begin
        wren[1] = nonzero_waddr[1];
        rden1[1] = 1;
      end
      opcode_register : begin
        wren[1] = nonzero_waddr[1];
        rden1[1] = 1;
        rden2[1] = 1;
      end
      opcode_system : begin
        case (funct3[1])
          1 : begin
            wren[1] = nonzero_waddr[1];
            rden1[1] = 1;
          end
          2 : begin
            wren[1] = nonzero_waddr[1];
            rden1[1] = 1;
          end
          3 : begin
            wren[1] = nonzero_waddr[1];
            rden1[1] = 1;
          end
          5 : begin
            wren[1] = nonzero_waddr[1];
          end
          6 : begin
            wren[1] = nonzero_waddr[1];
          end
          7 : begin
            wren[1] = nonzero_waddr[1];
          end
          default : begin
          end
        endcase
      end
      opcode_fload : begin
        rden1[1] = 1;
        fwren[1] = 1;
      end
      opcode_fstore : begin
        rden1[1] = 1;
        frden1[1] = 1;
      end
      opcode_fp : begin
        case (funct5[1])
          funct_fadd : begin
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fsub : begin
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fmul : begin
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fdiv : begin
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fsqrt : begin
            fwren[1] = 1;
            frden1[1] = 1;
          end
          funct_fsgnj : begin
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fminmax : begin
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fcomp : begin
            wren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fmv_f2i : begin
            wren[1] = 1;
            frden1[1] = 1;
          end
          funct_fmv_i2f : begin
            rden1[1] = 1;
            fwren[1] = 1;
          end
          funct_fconv_f2i : begin
            wren[1] = 1;
            frden1[1] = 1;
          end
          funct_fconv_i2f : begin
            rden1[1] = 1;
            fwren[1] = 1;
          end
          default : begin
          end
        endcase
      end
      opcode_fmadd : begin
        fwren[1] = 1;
        frden1[1] = 1;
        frden2[1] = 1;
        frden3[1] = 1;
      end
      opcode_fmsub : begin
        fwren[1] = 1;
        frden1[1] = 1;
        frden2[1] = 1;
        frden3[1] = 1;
      end
      opcode_fnmsub : begin
        fwren[1] = 1;
        frden1[1] = 1;
        frden2[1] = 1;
        frden3[1] = 1;
      end
      opcode_fnmadd : begin
        fwren[1] = 1;
        frden1[1] = 1;
        frden2[1] = 1;
        frden3[1] = 1;
      end
      default : begin
      end
    endcase

    if (count > total) begin
      stall = 1;
    end else begin
      stall = 0;
    end

    pass = 1;

    if (wren[0] == 1) begin
      if (rden1[1] == 1 && raddr1[1] == waddr[0]) begin
        pass = 0;
      end
      if (rden2[1] == 1 && raddr2[1] == waddr[0]) begin
        pass = 0;
      end
    end

    if (fwren[0] == 1) begin
      if (frden1[1] == 1 && raddr1[1] == waddr[0]) begin
        pass = 0;
      end
      if (frden2[1] == 1 && raddr2[1] == waddr[0]) begin
        pass = 0;
      end
      if (frden3[1] == 1 && raddr3[1] == waddr[0]) begin
        pass = 0;
      end
    end

    if (pass == 0) begin
      instr[1] = nop_instr;
      count = count - 1;
      rid = rid + 1;
    end else begin
      count = count - 2;
      rid = rid + 2;
    end

    hazard_out.instr0 = instr[0];
    hazard_out.instr1 = instr[1];
    hazard_out.stall = stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      buffer_reg <= '{default:'0};
      count_reg <= 0;
      wid_reg <= 0;
      rid_reg <= 0;
    end else begin
      buffer_reg <= buffer;
      count_reg <= count;
      wid_reg <= wid;
      rid_reg <= rid;
    end
  end

endmodule
