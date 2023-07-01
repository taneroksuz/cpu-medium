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
    logic [depth-1 : 0] wid;
    logic [depth-1 : 0] rid;
    logic [depth : 0] count;
    logic [1 : 0] complex;
    logic [1 : 0] basic;
    logic [1 : 0] pass;
    logic [0 : 0] swap;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    instr0 : init_instruction,
    instr1 : init_instruction,
    wid : 0,
    rid : 0,
    count : 0,
    complex : 0,
    basic : 0,
    pass : 0,
    swap : 0,
    stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    buffer = buffer_reg;

    v = r;

    v.stall = 0;

    if (hazard_in.clear == 0) begin
      if (hazard_in.instr0.op.valid == 1 && hazard_in.instr0.op.nop == 0) begin
        buffer[v.wid] = hazard_in.instr0;
        v.count = v.count + 1;
        v.wid = v.wid + 1;
      end
      if (hazard_in.instr1.op.valid == 1 && hazard_in.instr1.op.nop == 0) begin
        buffer[v.wid] = hazard_in.instr1;
        v.count = v.count + 1;
        v.wid = v.wid + 1;
      end
    end else begin
      v.count = 0;
      v.wid = 0;
      v.rid = 0;
    end

    v.instr0 = v.count > 0 ? buffer[v.rid] : init_instruction;
    v.instr1 = v.count > 1 ? buffer[v.rid+1] : init_instruction;

    v.basic[0] = v.instr0.op.alu | v.instr0.op.jal | v.instr0.op.jalr | v.instr0.op.jalr | v.instr0.op.branch | v.instr0.op.auipc | v.instr0.op.lui;
    v.basic[1] = v.instr1.op.alu | v.instr1.op.jal | v.instr1.op.jalr | v.instr1.op.jalr | v.instr1.op.branch | v.instr1.op.auipc | v.instr1.op.lui;

    v.complex[0] = v.instr0.op.load | v.instr0.op.store | v.instr0.op.division | v.instr0.op.mult | v.instr0.op.bitm | v.instr0.op.bitc;
    v.complex[0] = v.complex[0] | v.instr0.op.fload | v.instr0.op.fstore | v.instr0.op.fpu | v.instr0.op.csreg | v.instr0.op.fence;
    v.complex[0] = v.complex[0] | v.instr0.op.ecall | v.instr0.op.ebreak | v.instr0.op.mret | v.instr0.op.wfi;
    v.complex[1] = v.instr1.op.load | v.instr1.op.store | v.instr1.op.division | v.instr1.op.mult | v.instr1.op.bitm | v.instr1.op.bitc;
    v.complex[1] = v.complex[1] | v.instr1.op.fload | v.instr1.op.fstore | v.instr1.op.fpu | v.instr1.op.csreg | v.instr1.op.fence;
    v.complex[1] = v.complex[1] | v.instr1.op.ecall | v.instr1.op.ebreak | v.instr1.op.mret | v.instr1.op.wfi;

    if ((v.basic[0] == 1 && v.basic[1] == 1) || (v.complex[0] == 1 && v.basic[1] == 1) || (v.basic[0] == 1 && v.complex[1] == 1)) begin
      v.pass = 2;
      if (v.instr0.op.wren == 1) begin
        if (v.instr1.op.rden1 == 1 && v.instr1.raddr1 == v.instr0.waddr) begin
          v.pass = 1;
        end
        if (v.instr1.op.rden2 == 1 && v.instr1.raddr2 == v.instr0.waddr) begin
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

    v.swap = v.pass > 1 ? v.basic[0] & v.complex[1] : 0;

    hazard_out.instr0 = v.pass > 0 ? (v.swap == 0 ? v.instr0 : v.instr1) : init_instruction;
    hazard_out.instr1 = v.pass > 1 ? (v.swap == 1 ? v.instr0 : v.instr1) : init_instruction;
    hazard_out.swap = v.swap;
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
