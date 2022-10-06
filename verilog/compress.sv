import constants::*;
import wires::*;

module compress
(
  input compress_in_type compress_in,
  output compress_out_type compress_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] instr;

  logic [31 : 0] imm_lwsp;
  logic [31 : 0] imm_swsp;
  logic [31 : 0] imm_lswr;

  logic [31 : 0] imm_j;
  logic [31 : 0] imm_b;
  logic [31 : 0] imm_w;
  logic [31 : 0] imm_i;
  logic [31 : 0] imm_u;
  logic [31 : 0] imm_p;

  logic [31 : 0] imm;

  logic [4  : 0] shamt;

  logic [1  : 0] opcode;
  logic [2  : 0] funct3;
  logic [0  : 0] funct4;
  logic [1  : 0] funct6;
  logic [1  : 0] funct8;
  logic [2  : 0] funct9;

  logic [4  : 0] waddr;
  logic [4  : 0] raddr1;
  logic [4  : 0] raddr2;

  logic [0  : 0] wren;
  logic [0  : 0] rden1;
  logic [0  : 0] rden2;

  logic [0  : 0] fwren;
  logic [0  : 0] frden1;
  logic [0  : 0] frden2;
  logic [0  : 0] frden3;
  logic [0  : 0] fload;
  logic [0  : 0] fstore;
  logic [0  : 0] fpu;

  logic [0  : 0] lui;
  logic [0  : 0] jal;
  logic [0  : 0] jalr;
  logic [0  : 0] branch;
  logic [0  : 0] load;
  logic [0  : 0] store;
  logic [0  : 0] ebreak;
  logic [0  : 0] valid;

  alu_op_type alu_op;
  bcu_op_type bcu_op;
  lsu_op_type lsu_op;

  logic [0  : 0] nonzero_imm_j;
  logic [0  : 0] nonzero_imm_b;
  logic [0  : 0] nonzero_imm_w;
  logic [0  : 0] nonzero_imm_i;
  logic [0  : 0] nonzero_imm_u;
  logic [0  : 0] nonzero_imm_p;

  logic [0  : 0] nonzero_shamt;

  always_comb begin

    instr = compress_in.instr;

    imm_lwsp = {24'b0,instr[3:2],instr[12],instr[6:4],2'b0};
    imm_swsp = {24'b0,instr[8:7],instr[12:9],2'b0};
    imm_lswr = {25'b0,instr[5],instr[12:10],instr[6],2'b0};

    imm_j = {{20{instr[12]}},instr[12],instr[8],instr[10:9],instr[6],instr[7],instr[2],instr[11],instr[5:3],1'b0};
    imm_b = {{23{instr[12]}},instr[12],instr[6:5],instr[2],instr[11:10],instr[4:3],1'b0};
    imm_w = {22'b0,instr[10:7],instr[12:11],instr[5],instr[6],2'b0};
    imm_i = {{26{instr[12]}},instr[12],instr[6:2]};
    imm_u = {{14{instr[12]}},instr[12],instr[6:2],12'b0};
    imm_p = {{22{instr[12]}},instr[12],instr[4:3],instr[5],instr[2],instr[6],4'b0};

    imm = 0;

    shamt = instr[6:2];

    opcode = instr[1:0];
    funct3 = instr[15:13];
    funct4 = instr[12];
    funct6 = instr[11:10];
    funct8 = instr[6:5];
    funct9 = {instr[12],instr[6:5]};

    waddr = instr[11:7];
    raddr1 = instr[11:7];
    raddr2 = instr[6:2];

    wren = 0;
    rden1 = 0;
    rden2 = 0;

    fwren = 0;
    frden1 = 0;
    frden2 = 0;
    frden3 = 0;
    fload = 0;
    fstore = 0;
    fpu = 0;

    lui = 0;
    jal = 0;
    jalr = 0;
    branch = 0;
    load = 0;
    store = 0;
    ebreak = 0;
    valid = 1;

    alu_op = init_alu_op;
    bcu_op = init_bcu_op;
    lsu_op = init_lsu_op;

    nonzero_imm_j = |imm_j;
    nonzero_imm_b = |imm_b;
    nonzero_imm_w = |imm_w;
    nonzero_imm_i = |imm_i;
    nonzero_imm_u = |imm_u;
    nonzero_imm_p = |imm_p;

    nonzero_shamt = |shamt;

    case(opcode)
      opcode_c0 : begin
        case(funct3)
          c0_addispn : begin
            imm = imm_w;
            waddr = {2'b01,instr[4:2]};
            raddr1 = 2;
            wren = nonzero_imm_w;
            rden1 = nonzero_imm_w;
            alu_op.alu_add = nonzero_imm_w;
            valid = nonzero_imm_w;
          end
          c0_lw : begin
            imm = imm_lswr;
            waddr = {2'b01,instr[4:2]};
            raddr1 = {2'b01,instr[9:7]};
            wren = 1;
            rden1 = 1;
            load = 1;
            lsu_op.lsu_lw = 1;
          end
          c0_flw : begin
            imm = imm_lswr;
            waddr = {2'b01,instr[4:2]};
            raddr1 = {2'b01,instr[9:7]};
            fwren = 1;
            rden1 = 1;
            fload = 1;
            fpu = 1;
            lsu_op.lsu_lw = 1;
          end
          c0_sw : begin
            imm = imm_lswr;
            raddr1 = {2'b01,instr[9:7]};
            raddr2 = {2'b01,instr[4:2]};
            rden1 = 1;
            rden2 = 1;
            store = 1;
            lsu_op.lsu_sw = 1;
          end
          c0_fsw : begin
            imm = imm_lswr;
            raddr1 = {2'b01,instr[9:7]};
            raddr2 = {2'b01,instr[4:2]};
            rden1 = 1;
            frden2 = 1;
            fstore = 1;
            fpu = 1;
            lsu_op.lsu_sw = 1;
          end
          default : valid = 0;
        endcase
      end
      opcode_c1 : begin
        case(funct3)
          c1_addi : begin
            imm = imm_i;
            wren = nonzero_imm_i;
            rden1 = nonzero_imm_i;
            alu_op.alu_add = nonzero_imm_i;
          end
          c1_jal : begin
            imm = imm_j;
            wren = 1;
            waddr = 1;
            jal = 1;
          end
          c1_li : begin
            imm = imm_i;
            wren = 1;
            alu_op.alu_add = 1;
          end
          c1_lui : begin
            if (raddr1 == 2) begin
              imm = imm_p;
              wren = nonzero_imm_p;
              rden1 = nonzero_imm_p;
              alu_op.alu_add = nonzero_imm_p;
              valid = nonzero_imm_p;
            end else begin
              imm = imm_u;
              wren = nonzero_imm_u;
              rden1 = nonzero_imm_u;
              lui = nonzero_imm_u;
              valid = nonzero_imm_u;
            end
          end
          c1_alu : begin
            waddr[4:3] = 2'b01;
            raddr1[4:3] = 2'b01;
            raddr2[4:3] = 2'b01;
            case(funct6)
              0 : begin
                imm = {27'b0,shamt};
                wren = nonzero_shamt;
                rden1 = nonzero_shamt;
                alu_op.alu_srl = nonzero_shamt;
                valid = nonzero_shamt;
              end
              1 : begin
                imm = {27'b0,shamt};
                wren = nonzero_shamt;
                rden1 = nonzero_shamt;
                alu_op.alu_sra = nonzero_shamt;
                valid = nonzero_shamt;
              end
              2 : begin
                imm = imm_i;
                wren = 1;
                rden1 = 1;
                alu_op.alu_and = 1;
              end
              3 : begin
                case(funct9)
                  0 : begin
                    wren = 1;
                    rden1 = 1;
                    rden2 = 1;
                    alu_op.alu_sub = 1;
                  end
                  1 : begin
                    wren = 1;
                    rden1 = 1;
                    rden2 = 1;
                    alu_op.alu_xor = 1;
                  end
                  2 : begin
                    wren = 1;
                    rden1 = 1;
                    rden2 = 1;
                    alu_op.alu_or = 1;
                  end
                  3 : begin
                    wren = 1;
                    rden1 = 1;
                    rden2 = 1;
                    alu_op.alu_and = 1;
                  end
                  default : valid = 0;
                endcase
              end
              default : valid = 0;
            endcase;
          end
          c1_j : begin
            imm = imm_j;
            waddr = 0;
            jal = 1;
          end
          c1_beqz : begin
            imm = imm_b;
            rden1 = 1;
            rden2 = 1;
            raddr1 = {2'b01,instr[9:7]};
            raddr2 = 0;
            branch = 1;
            bcu_op.bcu_beq = 1;
          end
          c1_bnez : begin
            imm = imm_b;
            rden1 = 1;
            rden2 = 1;
            raddr1 = {2'b01,instr[9:7]};
            raddr2 = 0;
            branch = 1;
            bcu_op.bcu_bne = 1;
          end
          default : valid = 0;
        endcase
      end
      opcode_c2 : begin
        case(funct3)
          c2_slli : begin
            imm = {27'b0,shamt};
            wren = nonzero_shamt;
            rden1 = nonzero_shamt;
            alu_op.alu_sll = nonzero_shamt;
            valid = nonzero_shamt;
          end
          c2_lwsp : begin
            imm = imm_lwsp;
            wren = 1;
            rden1 = 1;
            raddr1 = 2;
            load = 1;
            lsu_op.lsu_lw = 1;
          end
          c2_flwsp : begin
            imm = imm_lwsp;
            fwren = 1;
            rden1 = 1;
            raddr1 = 2;
            fload = 1;
            fpu = 1;
            lsu_op.lsu_lw = 1;
          end
          c2_alu : begin
            case (funct4)
              0 : begin
                if (|raddr1 == 1) begin
                  if (|raddr2 == 0) begin
                    rden1 = 1;
                    waddr = 0;
                    jalr = 1;
                  end else if (|raddr2 == 1) begin
                    wren = 1;
                    rden2 = 1;
                    alu_op.alu_add = 1;
                  end
                end
              end
              1 : begin
                if (|raddr1 == 0) begin
                  if (|raddr2 == 0) begin
                    ebreak = 1;
                  end
                end else if (|raddr1 == 1) begin
                  if (|raddr2 == 0) begin
                    wren = 1;
                    rden1 = 1;
                    waddr = 1;
                    jalr = 1;
                  end else if (|raddr2 == 1) begin
                    wren = 1;
                    rden1 = 1;
                    rden2 = 1;
                    alu_op.alu_add = 1;
                  end
                end
              end
              default : valid = 0;
            endcase
          end
          c2_swsp : begin
            imm = imm_swsp;
            rden1 = 1;
            rden2 = 1;
            raddr1 = 2;
            store = 1;
            lsu_op.lsu_sw = 1;
          end
          c2_fswsp : begin
            imm = imm_swsp;
            rden1 = 1;
            frden2 = 1;
            raddr1 = 2;
            fstore = 1;
            fpu = 1;
            lsu_op.lsu_sw = 1;
          end
          default : valid = 0;
        endcase
      end
      default : valid = 0;
    endcase

    compress_out.imm = imm;
    compress_out.waddr = waddr;
    compress_out.raddr1 = raddr1;
    compress_out.raddr2 = raddr2;
    compress_out.wren = wren;
    compress_out.rden1 = rden1;
    compress_out.rden2 = rden2;
    compress_out.fwren = fwren;
    compress_out.frden1 = frden1;
    compress_out.frden2 = frden2;
    compress_out.frden3 = frden3;
    compress_out.lui = lui;
    compress_out.jal = jal;
    compress_out.jalr = jalr;
    compress_out.branch = branch;
    compress_out.load = load;
    compress_out.store = store;
    compress_out.fload = fload;
    compress_out.fstore = fstore;
    compress_out.fpu = fpu;
    compress_out.ebreak = ebreak;
    compress_out.valid = valid;
    compress_out.alu_op = alu_op;
    compress_out.bcu_op = bcu_op;
    compress_out.lsu_op = lsu_op;

  end

endmodule
