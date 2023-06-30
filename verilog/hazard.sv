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

  logic [63 : 0] buffer [0:hazard_depth-1];
  logic [63 : 0] buffer_reg [0:hazard_depth-1];

  logic [depth : 0] count;
  logic [depth : 0] count_reg;

  logic [depth-1 : 0] wid;
  logic [depth-1 : 0] wid_reg;
  logic [depth-1 : 0] rid;
  logic [depth-1 : 0] rid_reg;

  logic [0 : 0] stall;
  logic [0 : 0] stall_reg;

  logic [0 : 0] swap;

  logic [depth-1 : 0] get;

  logic [31 : 0] pc [0:1];
  logic [31 : 0] npc [0:1];
  logic [31 : 0] instr [0:1];

  logic [6 : 0] opcode [0:1];
  logic [2 : 0] funct3 [0:1];
  logic [6 : 0] funct7 [0:1];

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
  
  logic [0 : 0] basic [0:1];
  logic [0 : 0] complex [0:1];

  logic [0 : 0] nonzero_waddr [0:1];
  logic [0 : 0] nonzero_raddr1 [0:1];

  always_comb begin

    buffer = buffer_reg;
    count = count_reg;
    wid = wid_reg;
    rid = rid_reg;
    stall = stall_reg;
    
    if (hazard_in.clear == 1) begin
      count = 0;
      wid = 0;
      rid = 0;
    end else if (stall == 0 && hazard_in.ready == 1) begin
      buffer[wid] = {hazard_in.pc,hazard_in.rdata[31:0]};
      buffer[wid+1] = {hazard_in.pc+4,hazard_in.rdata[63:32]};
      count = count + 2;
      wid = wid + 2;
    end

    pc[0] = count > 0 ? buffer[rid][63:32] : 0;
    pc[1] = count > 1 ? buffer[rid+1][63:32] : 0;

    instr[0] = count > 0 ? buffer[rid][31:0] : nop_instr;
    instr[1] = count > 1 ? buffer[rid+1][31:0] : nop_instr;

    npc[0] = pc[0] + ((instr[0][1:0] == 2'b11) ? 4 : 2);
    npc[1] = pc[1] + ((instr[1][1:0] == 2'b11) ? 4 : 2);

    opcode = {instr[0][6:0],instr[1][6:0]};
    funct3 = {instr[0][14:12],instr[1][14:12]};
    funct7 = {instr[0][31:25],instr[1][31:25]};

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

    basic = '{default:'0};
    complex = '{default:'0};

    nonzero_waddr = {|waddr[0],|waddr[1]};
    nonzero_raddr1 = {|raddr1[0],|raddr1[1]};

    case (opcode[0])
      opcode_lui : begin
        complex[0] = 1;
        wren[0] = nonzero_waddr[0];
      end
      opcode_auipc : begin
        complex[0] = 1;
        wren[0] = nonzero_waddr[0];
      end
      opcode_jal : begin
        complex[0] = 1;
        wren[0] = nonzero_waddr[0];
      end
      opcode_jalr : begin
        complex[0] = 1;
        wren[0] = nonzero_waddr[0];
        rden1[0] = 1;
      end
      opcode_branch : begin
        complex[0] = 1;
        rden1[0] = 1;
        rden2[0] = 1;
      end
      opcode_load : begin
        complex[0] = 1;
        wren[0] = nonzero_waddr[0];
        rden1[0] = 1;
      end
      opcode_store : begin
        complex[0] = 1;
        rden1[0] = 1;
        rden2[0] = 1;
      end
      opcode_immediate : begin
        case (funct3[0])
          funct_add : begin
            basic[0] = 1;
          end
          funct_slt : begin
            basic[0] = 1;
          end
          funct_sltu : begin
            basic[0] = 1;
          end
          funct_and : begin
            basic[0] = 1;
          end
          funct_or : begin
            basic[0] = 1;
          end
          funct_xor : begin
            basic[0] = 1;
          end
          funct_sll : begin
            if (funct7[0] == 7'b0000000) begin
              basic[0] = 1;
            end else begin
              complex[0] = 1;
            end
          end 
          funct_srl : begin
            if (funct7[0] == 7'b0000000) begin
              basic[0] = 1;
            end else if (funct7[0] == 7'b0100000) begin
              basic[0] = 1;
            end else begin
              complex[0] = 1;
            end
          end
          default : begin
            complex[0] = 1;
          end
        endcase
        wren[0] = nonzero_waddr[0];
        rden1[0] = 1;
      end
      opcode_register : begin
        if (funct7[0] == 7'b0000000) begin
          case (funct3[0])
            funct_add : begin
              basic[0] = 1;
            end
            funct_sll : begin
              basic[0] = 1;
            end
            funct_srl : begin
              basic[0] = 1;
            end
            funct_slt : begin
              basic[0] = 1;
            end
            funct_sltu : begin
              basic[0] = 1;
            end
            funct_and : begin
              basic[0] = 1;
            end
            funct_or : begin
              basic[0] = 1;
            end
            funct_xor : begin
              basic[0] = 1;
            end
            default : begin
              complex[0] = 1;
            end
          endcase;
        end else if (funct7[0] == 7'b0100000) begin
          case (funct3[0])
            funct_add : begin
              basic[0] = 1;
            end
            funct_srl : begin
              basic[0] = 1;
            end
            default : begin
              complex[0] = 1;
            end
          endcase;
        end else begin
          complex[0] = 1;
        end
        wren[0] = nonzero_waddr[0];
        rden1[0] = 1;
        rden2[0] = 1;
      end
      opcode_fence : begin
        complex[0] = 1;
      end
      opcode_system : begin
        complex[0] = 1;
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
        complex[0] = 1;
        rden1[0] = 1;
        fwren[0] = 1;
      end
      opcode_fstore : begin
        complex[0] = 1;
        rden1[0] = 1;
        frden1[0] = 1;
      end
      opcode_fp : begin
        case (funct7[0][6:2])
          funct_fadd : begin
            complex[0] = 1;
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fsub : begin
            complex[0] = 1;
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fmul : begin
            complex[0] = 1;
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fdiv : begin
            complex[0] = 1;
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fsqrt : begin
            complex[0] = 1;
            fwren[0] = 1;
            frden1[0] = 1;
          end
          funct_fsgnj : begin
            complex[0] = 1;
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fminmax : begin
            complex[0] = 1;
            fwren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fcomp : begin
            complex[0] = 1;
            wren[0] = 1;
            frden1[0] = 1;
            frden2[0] = 1;
          end
          funct_fmv_f2i : begin
            complex[0] = 1;
            wren[0] = 1;
            frden1[0] = 1;
          end
          funct_fmv_i2f : begin
            complex[0] = 1;
            rden1[0] = 1;
            fwren[0] = 1;
          end
          funct_fconv_f2i : begin
            complex[0] = 1;
            wren[0] = 1;
            frden1[0] = 1;
          end
          funct_fconv_i2f : begin
            complex[0] = 1;
            rden1[0] = 1;
            fwren[0] = 1;
          end
          default : begin
          end
        endcase
      end
      opcode_fmadd : begin
        complex[0] = 1;
        fwren[0] = 1;
        frden1[0] = 1;
        frden2[0] = 1;
        frden3[0] = 1;
      end
      opcode_fmsub : begin
        complex[0] = 1;
        fwren[0] = 1;
        frden1[0] = 1;
        frden2[0] = 1;
        frden3[0] = 1;
      end
      opcode_fnmsub : begin
        complex[0] = 1;
        fwren[0] = 1;
        frden1[0] = 1;
        frden2[0] = 1;
        frden3[0] = 1;
      end
      opcode_fnmadd : begin
        complex[0] = 1;
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
        complex[1] = 1;
        wren[1] = nonzero_waddr[1];
      end
      opcode_auipc : begin
        complex[1] = 1;
        wren[1] = nonzero_waddr[1];
      end
      opcode_jal : begin
        complex[1] = 1;
        wren[1] = nonzero_waddr[1];
      end
      opcode_jalr : begin
        complex[1] = 1;
        wren[1] = nonzero_waddr[1];
        rden1[1] = 1;
      end
      opcode_branch : begin
        complex[1] = 1;
        rden1[1] = 1;
        rden2[1] = 1;
      end
      opcode_load : begin
        complex[1] = 1;
        wren[1] = nonzero_waddr[1];
        rden1[1] = 1;
      end
      opcode_store : begin
        complex[1] = 1;
        rden1[1] = 1;
        rden2[1] = 1;
      end
      opcode_immediate : begin
        case (funct3[1])
          funct_add : begin
            basic[1] = 1;
          end
          funct_slt : begin
            basic[1] = 1;
          end
          funct_sltu : begin
            basic[1] = 1;
          end
          funct_and : begin
            basic[1] = 1;
          end
          funct_or : begin
            basic[1] = 1;
          end
          funct_xor : begin
            basic[1] = 1;
          end
          funct_sll : begin
            if (funct7[1] == 7'b0000000) begin
              basic[1] = 1;
            end else begin
              complex[1] = 1;
            end
          end 
          funct_srl : begin
            if (funct7[1] == 7'b0000000) begin
              basic[1] = 1;
            end else if (funct7[1] == 7'b0100000) begin
              basic[1] = 1;
            end else begin
              complex[1] = 1;
            end
          end
          default : begin
            complex[1] = 1;
          end
        endcase
        wren[1] = nonzero_waddr[1];
        rden1[1] = 1;
      end
      opcode_register : begin
        if (funct7[1] == 7'b0000000) begin
          case (funct3[1])
            funct_add : begin
              basic[1] = 1;
            end
            funct_sll : begin
              basic[1] = 1;
            end
            funct_srl : begin
              basic[1] = 1;
            end
            funct_slt : begin
              basic[1] = 1;
            end
            funct_sltu : begin
              basic[1] = 1;
            end
            funct_and : begin
              basic[1] = 1;
            end
            funct_or : begin
              basic[1] = 1;
            end
            funct_xor : begin
              basic[1] = 1;
            end
            default : begin
              complex[1] = 1;
            end
          endcase;
        end else if (funct7[1] == 7'b0100000) begin
          case (funct3[1])
            funct_add : begin
              basic[1] = 1;
            end
            funct_srl : begin
              basic[1] = 1;
            end
            default : begin
              complex[1] = 1;
            end
          endcase;
        end else begin
          complex[1] = 1;
        end
        wren[1] = nonzero_waddr[1];
        rden1[1] = 1;
        rden2[1] = 1;
      end
      opcode_fence : begin
        complex[1] = 1;
      end
      opcode_system : begin
        complex[1] = 1;
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
        complex[1] = 1;
        rden1[1] = 1;
        fwren[1] = 1;
      end
      opcode_fstore : begin
        complex[1] = 1;
        rden1[1] = 1;
        frden1[1] = 1;
      end
      opcode_fp : begin
        case (funct7[1][6:2])
          funct_fadd : begin
            complex[1] = 1;
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fsub : begin
            complex[1] = 1;
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fmul : begin
            complex[1] = 1;
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fdiv : begin
            complex[1] = 1;
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fsqrt : begin
            complex[1] = 1;
            fwren[1] = 1;
            frden1[1] = 1;
          end
          funct_fsgnj : begin
            complex[1] = 1;
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fminmax : begin
            complex[1] = 1;
            fwren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fcomp : begin
            complex[1] = 1;
            wren[1] = 1;
            frden1[1] = 1;
            frden2[1] = 1;
          end
          funct_fmv_f2i : begin
            complex[1] = 1;
            wren[1] = 1;
            frden1[1] = 1;
          end
          funct_fmv_i2f : begin
            complex[1] = 1;
            rden1[1] = 1;
            fwren[1] = 1;
          end
          funct_fconv_f2i : begin
            complex[1] = 1;
            wren[1] = 1;
            frden1[1] = 1;
          end
          funct_fconv_i2f : begin
            complex[1] = 1;
            rden1[1] = 1;
            fwren[1] = 1;
          end
          default : begin
          end
        endcase
      end
      opcode_fmadd : begin
        complex[1] = 1;
        fwren[1] = 1;
        frden1[1] = 1;
        frden2[1] = 1;
        frden3[1] = 1;
      end
      opcode_fmsub : begin
        complex[1] = 1;
        fwren[1] = 1;
        frden1[1] = 1;
        frden2[1] = 1;
        frden3[1] = 1;
      end
      opcode_fnmsub : begin
        complex[1] = 1;
        fwren[1] = 1;
        frden1[1] = 1;
        frden2[1] = 1;
        frden3[1] = 1;
      end
      opcode_fnmadd : begin
        complex[1] = 1;
        fwren[1] = 1;
        frden1[1] = 1;
        frden2[1] = 1;
        frden3[1] = 1;
      end
      default : begin
      end
    endcase

    if (basic[0] == 1 && basic[1] == 1) begin
      get = 2;
      if (wren[0] == 1) begin
        if (rden1[1] == 1 && raddr1[1] == waddr[0]) begin
          get = 1;
        end
        if (rden2[1] == 1 && raddr2[1] == waddr[0]) begin
          get = 1;
        end
      end
    end else if (complex[0] == 1 && basic[1] == 1) begin
      get = 2;
      if (wren[0] == 1) begin
        if (rden1[1] == 1 && raddr1[1] == waddr[0]) begin
          get = 1;
        end
        if (rden2[1] == 1 && raddr2[1] == waddr[0]) begin
          get = 1;
        end
      end
    end else if (basic[0] == 1 && complex[1] == 1) begin
      get = 2;
      if (wren[0] == 1) begin
        if (rden1[1] == 1 && raddr1[1] == waddr[0]) begin
          get = 1;
        end
        if (rden2[1] == 1 && raddr2[1] == waddr[0]) begin
          get = 1;
        end
      end
    end else if (complex[0] == 1 && complex[1] == 1) begin
      get = 1;
    end else if (complex[0] == 1 || basic[0] == 1) begin
      get = 1;
    end else if (complex[0] == 0 && basic[0] == 0) begin
      get = 1;
    end else begin
      get = 0;
    end

    if (hazard_in.stall == 1) begin
      get = 0;
    end

    if (count < {1'b0,get}) begin
      get = count[depth-1:0];
    end

    count = count - get;
    rid = rid + get;

    if (count > total) begin
      stall = 1;
    end else begin
      stall = 0;
    end

    swap = get > 1 ? basic[0] & complex[1] : 0;

    hazard_out.pc0 = get > 0 ? (swap == 0 ? pc[0] : pc[1]) : 0;
    hazard_out.pc1 = get > 1 ? (swap == 0 ? pc[1] : pc[0]) : 0;
    hazard_out.npc0 = get > 0 ? (swap == 0 ? npc[0] : npc[1]) : 0;
    hazard_out.npc1 = get > 1 ? (swap == 0 ? npc[1] : npc[0]) : 0;
    hazard_out.instr0 = get > 0 ? (swap == 0 ? instr[0] : instr[1]) : nop_instr;
    hazard_out.instr1 = get > 1 ? (swap == 0 ? instr[1] : instr[0]) : nop_instr;
    hazard_out.swap = swap;
    hazard_out.stall = stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      buffer_reg <= '{default:'0};
      count_reg <= 0;
      wid_reg <= 0;
      rid_reg <= 0;
      stall_reg <= 0;
    end else begin
      buffer_reg <= buffer;
      count_reg <= count;
      wid_reg <= wid;
      rid_reg <= rid;
      stall_reg <= stall;
    end
  end

endmodule
