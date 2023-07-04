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

  instruction_type buffer [0:hazard_depth-1];
  instruction_type buffer_reg [0:hazard_depth-1];

  typedef struct packed{
    instruction_type instr0;
    instruction_type instr1;
    calculation_type calc0;
    calculation_type calc1;
    logic [depth-1 : 0] wid;
    logic [depth-1 : 0] rid;
    logic [depth : 0] count;
    logic [1 : 0] pass;
    logic [0 : 0] dual;
    logic [0 : 0] single;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    instr0 : init_instruction,
    instr1 : init_instruction,
    calc0 : init_calculation,
    calc1 : init_calculation,
    wid : 0,
    rid : 0,
    count : 0,
    pass : 0,
    dual : 0,
    single : 0,
    stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    buffer = buffer_reg;

    v = r;

    v.pass = 0;
    v.stall = 0;

    if (hazard_in.clear == 1) begin
      v.count = 0;
      v.wid = 0;
      v.rid = 0;
    end else if (r.stall == 0) begin
      if (hazard_in.instr0.op.valid == 1) begin
        buffer[v.wid] = hazard_in.instr0;
        v.count = v.count + 1;
        v.wid = v.wid + 1;
      end
      if (hazard_in.instr1.op.valid == 1) begin
        buffer[v.wid] = hazard_in.instr1;
        v.count = v.count + 1;
        v.wid = v.wid + 1;
      end
    end

    v.instr0 = v.count > 0 ? buffer[v.rid] : init_instruction;
    v.instr1 = v.count > 1 ? buffer[v.rid+1] : init_instruction;

    v.calc0 = init_calculation;
    v.calc1 = init_calculation;

    v.calc0.pc = v.instr0.pc;
    v.calc0.npc = v.instr0.npc;
    v.calc0.instr = v.instr0.instr;
    v.calc0.imm = v.instr0.imm;
    v.calc0.waddr = v.instr0.waddr;
    v.calc0.raddr1 = v.instr0.raddr1;
    v.calc0.raddr2 = v.instr0.raddr2;
    v.calc0.raddr3 = v.instr0.raddr3;
    v.calc0.caddr = v.instr0.caddr;
    v.calc0.fmt = v.instr0.fmt;
    v.calc0.rm = v.instr0.rm;
    v.calc0.op = v.instr0.op;
    v.calc0.op_b = v.instr0.op_b;
    v.calc0.alu_op = v.instr0.alu_op;
    v.calc0.bcu_op = v.instr0.bcu_op;
    v.calc0.lsu_op = v.instr0.lsu_op;
    v.calc0.csr_op = v.instr0.csr_op;
    v.calc0.div_op = v.instr0.div_op;
    v.calc0.mul_op = v.instr0.mul_op;
    v.calc0.bit_op = v.instr0.bit_op;
    v.calc0.fpu_op = v.instr0.fpu_op;

    v.calc1.pc = v.instr1.pc;
    v.calc1.npc = v.instr1.npc;
    v.calc1.instr = v.instr1.instr;
    v.calc1.imm = v.instr1.imm;
    v.calc1.waddr = v.instr1.waddr;
    v.calc1.raddr1 = v.instr1.raddr1;
    v.calc1.raddr2 = v.instr1.raddr2;
    v.calc1.raddr3 = v.instr1.raddr3;
    v.calc1.caddr = v.instr1.caddr;
    v.calc1.fmt = v.instr1.fmt;
    v.calc1.rm = v.instr1.rm;
    v.calc1.op = v.instr1.op;
    v.calc1.op_b = v.instr1.op_b;
    v.calc1.alu_op = v.instr1.alu_op;
    v.calc1.bcu_op = v.instr1.bcu_op;
    v.calc1.lsu_op = v.instr1.lsu_op;
    v.calc1.csr_op = v.instr1.csr_op;
    v.calc1.div_op = v.instr1.div_op;
    v.calc1.mul_op = v.instr1.mul_op;
    v.calc1.bit_op = v.instr1.bit_op;
    v.calc1.fpu_op = v.instr1.fpu_op;

    v.single = v.calc1.op.fence | v.calc1.op.mret | v.calc1.op.wfi;

    v.dual = ((v.calc0.op.load | v.calc0.op.store) & (v.calc1.op.load | v.calc1.op.store));
    v.dual = v.dual | ((v.calc0.op.load | v.calc0.op.store) & (v.calc1.op.fload | v.calc1.op.fstore));
    v.dual = v.dual | ((v.calc0.op.fload | v.calc0.op.fstore) & (v.calc1.op.load | v.calc1.op.store));
    v.dual = v.dual | ((v.calc0.op.fload | v.calc0.op.fstore) & (v.calc1.op.fload | v.calc1.op.fstore));
    v.dual = v.dual | (v.calc0.op.fpu & v.calc1.op.fpu);
    v.dual = v.dual | (v.calc0.op.division & v.calc1.op.division);
    v.dual = v.dual | (v.calc0.op.mult & v.calc1.op.mult);
    v.dual = v.dual | (v.calc0.op.bitc & v.calc1.op.bitc);
    v.dual = v.dual | (v.calc0.op.csreg & v.calc1.op.csreg);

    if (v.single == 1) begin
      v.pass = 1;
    end else if (v.dual == 0) begin
      v.pass = 2;
      if (v.calc0.op.wren == 1) begin
        if (v.calc1.op.rden1 == 1 && v.calc1.raddr1 == v.calc0.waddr) begin
          v.pass = 1;
        end
        if (v.calc1.op.rden2 == 1 && v.calc1.raddr2 == v.calc0.waddr) begin
          v.pass = 1;
        end
      end
      if (v.calc0.op.fwren == 1) begin
        if (v.calc1.op.frden1 == 1 && v.calc1.raddr1 == v.calc0.waddr) begin
          v.pass = 1;
        end
        if (v.calc1.op.frden2 == 1 && v.calc1.raddr2 == v.calc0.waddr) begin
          v.pass = 1;
        end
        if (v.calc1.op.frden3 == 1 && v.calc1.raddr3 == v.calc0.waddr) begin
          v.pass = 1;
        end
      end
    end else begin
      v.pass = 1;
    end

    if (hazard_in.stall == 1) begin
      v.pass = 0;
    end

    if (v.count < {1'b0,v.pass}) begin
      v.pass = v.count[depth-1:0];
    end

    v.count = v.count - v.pass;
    v.rid = v.rid + v.pass;

    if (v.count > total) begin
      v.stall = 1;
    end else begin
      v.stall = 0;
    end

    hazard_out.calc0 = v.pass > 0 ? v.calc0 : init_calculation;
    hazard_out.calc1 = v.pass > 1 ? v.calc1 : init_calculation;
    hazard_out.stall = v.stall;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      buffer_reg <= '{default:init_instruction};
      r <= init_reg;
    end else begin
      buffer_reg <= buffer;
      r <= rin;
    end
  end

endmodule
