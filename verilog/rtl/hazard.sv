package hazard_wires;
  timeunit 1ns; timeprecision 1ps;

  import configure::*;
  import wires::*;

  localparam depth = $clog2(hazard_depth - 1);

  typedef struct packed {
    logic [0 : 0] wen0;
    logic [0 : 0] wen1;
    logic [depth-1 : 0] waddr0;
    logic [depth-1 : 0] waddr1;
    logic [depth-1 : 0] raddr0;
    logic [depth-1 : 0] raddr1;
    instruction_type wdata0;
    instruction_type wdata1;
  } hazard_reg_in_type;

  typedef struct packed {
    instruction_type rdata0;
    instruction_type rdata1;
  } hazard_reg_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import hazard_wires::*;

module hazard_reg (
    input logic clock,
    input hazard_reg_in_type hazard_reg_in,
    output hazard_reg_out_type hazard_reg_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(hazard_depth - 1);

  instruction_type hazard_reg_array0[0:hazard_depth-1] = '{default: '0};
  instruction_type hazard_reg_array1[0:hazard_depth-1] = '{default: '0};

  always_ff @(posedge clock) begin
    if (hazard_reg_in.wen0 == 1) begin
      hazard_reg_array0[hazard_reg_in.waddr0] <= hazard_reg_in.wdata0;
    end
  end

  always_ff @(posedge clock) begin
    if (hazard_reg_in.wen1 == 1) begin
      hazard_reg_array1[hazard_reg_in.waddr1] <= hazard_reg_in.wdata1;
    end
  end

  assign hazard_reg_out.rdata0 = hazard_reg_array0[hazard_reg_in.raddr0];
  assign hazard_reg_out.rdata1 = hazard_reg_array1[hazard_reg_in.raddr1];

endmodule

module hazard_ctrl (
    input logic reset,
    input logic clock,
    input hazard_in_type hazard_in,
    output hazard_out_type hazard_out,
    input hazard_reg_out_type hazard_reg_out,
    output hazard_reg_in_type hazard_reg_in
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(hazard_depth - 1);
  localparam total = hazard_depth - 2;

  localparam [depth-1:0] one = 1;

  typedef struct packed {
    instruction_type wdata0;
    instruction_type wdata1;
    instruction_type instr0;
    instruction_type instr1;
    calculation_type calc0;
    calculation_type calc1;
    logic [depth-1 : 0] wid;
    logic [depth : 0] rid;
    logic [depth : 0] diff;
    logic [depth : 0] count;
    logic [0 : 0] wen;
    logic [0 : 0] single;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
      wdata0 : init_instruction,
      wdata1 : init_instruction,
      instr0 : init_instruction,
      instr1 : init_instruction,
      calc0 : init_calculation,
      calc1 : init_calculation,
      wid : 0,
      rid : 0,
      diff : 0,
      count : 0,
      wen : 0,
      single : 0,
      stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    v = r;

    if (hazard_in.clear == 1) begin
      v.wid   = 0;
      v.rid   = 0;
      v.count = 0;
    end

    v.wen = (~hazard_in.clear) & (~r.stall) & (hazard_in.instr0.op.valid | hazard_in.instr1.op.valid);
    v.wdata0 = hazard_in.instr0;
    v.wdata1 = hazard_in.instr1;

    hazard_reg_in.wen0 = v.wen;
    hazard_reg_in.wen1 = v.wen;
    hazard_reg_in.waddr0 = v.wid;
    hazard_reg_in.waddr1 = v.wid;
    hazard_reg_in.wdata0 = v.wdata0;
    hazard_reg_in.wdata1 = v.wdata1;

    if (v.rid[0] == 0) begin
      hazard_reg_in.raddr0 = v.rid[depth:1];
      hazard_reg_in.raddr1 = v.rid[depth:1];
      if (v.wid == v.rid[depth:1]) begin
        v.instr0 = v.wdata0;
        v.instr1 = v.wdata1;
      end else begin
        v.instr0 = hazard_reg_out.rdata0;
        v.instr1 = hazard_reg_out.rdata1;
      end
    end else begin
      hazard_reg_in.raddr0 = v.rid[depth:1] + one;
      hazard_reg_in.raddr1 = v.rid[depth:1];
      if (v.wid == v.rid[depth:1]) begin
        v.instr0 = v.wdata1;
        v.instr1 = v.wdata0;
      end else if (v.wid == v.rid[depth:1] + one) begin
        v.instr0 = hazard_reg_out.rdata1;
        v.instr1 = v.wdata0;
      end else begin
        v.instr0 = hazard_reg_out.rdata1;
        v.instr1 = hazard_reg_out.rdata0;
      end
    end

    if (v.wen == 1) begin
      v.wid   = v.wid + 1;
      v.count = v.count + 2;
    end

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
    v.calc0.pred = v.instr0.pred;

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
    v.calc1.pred = v.instr1.pred;

    v.single = v.calc0.op.fence | v.calc0.op.mret | v.calc0.op.wfi | v.calc1.op.fence | v.calc1.op.mret | v.calc1.op.wfi;
    v.single = v.single | (v.calc0.op.fpunit & v.calc1.op.fpunit);
    v.single = v.single | (v.calc0.op.division & v.calc1.op.division);
    v.single = v.single | (v.calc0.op.mult & v.calc1.op.mult);
    v.single = v.single | (v.calc0.op.bitc & v.calc1.op.bitc);
    v.single = v.single | (v.calc0.op.csreg & v.calc1.op.csreg);
    v.single = v.single | (v.calc0.op.fpuf & v.calc1.op.csreg & (v.calc1.caddr == csr_fflags || v.calc1.caddr == csr_fcsr));

    if (v.count > 1) begin
      if (v.single == 1) begin
        v.diff = 1;
      end else begin
        v.diff = 2;
        if (v.calc0.op.wren == 1) begin
          if (v.calc1.op.rden1 == 1 && v.calc1.raddr1 == v.calc0.waddr) begin
            v.diff = 1;
          end
          if (v.calc1.op.rden2 == 1 && v.calc1.raddr2 == v.calc0.waddr) begin
            v.diff = 1;
          end
        end
        if (v.calc0.op.fwren == 1) begin
          if (v.calc1.op.frden1 == 1 && v.calc1.raddr1 == v.calc0.waddr) begin
            v.diff = 1;
          end
          if (v.calc1.op.frden2 == 1 && v.calc1.raddr2 == v.calc0.waddr) begin
            v.diff = 1;
          end
          if (v.calc1.op.frden3 == 1 && v.calc1.raddr3 == v.calc0.waddr) begin
            v.diff = 1;
          end
        end
      end
    end else if (v.count > 0) begin
      v.diff = 1;
    end else begin
      v.diff = 0;
    end

    if (hazard_in.stall == 1) begin
      v.diff = 0;
    end

    v.count = v.count - v.diff;
    v.rid   = v.rid + v.diff;

    v.stall = 0;

    if (v.count > total) begin
      v.stall = 1;
    end

    hazard_out.calc0 = v.diff > 0 ? v.calc0 : init_calculation;
    hazard_out.calc1 = v.diff > 1 ? v.calc1 : init_calculation;
    hazard_out.stall = v.stall;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module hazard (
    input logic reset,
    input logic clock,
    input hazard_in_type hazard_in,
    output hazard_out_type hazard_out
);
  timeunit 1ns; timeprecision 1ps;

  hazard_reg_in_type  hazard_reg_in;
  hazard_reg_out_type hazard_reg_out;

  hazard_reg hazard_reg_comp (
      .clock(clock),
      .hazard_reg_in(hazard_reg_in),
      .hazard_reg_out(hazard_reg_out)
  );

  hazard_ctrl hazard_ctrl_comp (
      .reset(reset),
      .clock(clock),
      .hazard_in(hazard_in),
      .hazard_out(hazard_out),
      .hazard_reg_in(hazard_reg_in),
      .hazard_reg_out(hazard_reg_out)
  );

endmodule
