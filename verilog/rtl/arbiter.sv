import wires::*;
import constants::*;

module arbiter (
    input logic reset,
    input logic clock,
    input mem_in_type imem0_in,
    input mem_in_type imem1_in,
    output mem_out_type imem0_out,
    output mem_out_type imem1_out,
    input mem_in_type dmem0_in,
    input mem_in_type dmem1_in,
    output mem_out_type dmem0_out,
    output mem_out_type dmem1_out,
    output mem_in_type mem_in,
    input mem_out_type mem_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam [2:0] no_access = 0;
  localparam [2:0] instr0_access = 1;
  localparam [2:0] instr1_access = 2;
  localparam [2:0] data0_access = 3;
  localparam [2:0] data1_access = 4;

  typedef struct packed {
    logic [2:0] access_type;
    mem_in_type mem_in;
    mem_in_type imem0_in;
    mem_in_type imem1_in;
    mem_in_type dmem0_in;
    mem_in_type dmem1_in;
  } reg_type;

  localparam reg_type init_reg = '{default: 0};

  reg_type r, rin;
  reg_type v;

  always_comb begin

    v = r;

    if (mem_out.mem_ready == 1) begin
      v.access_type = no_access;
    end else begin
      v.mem_in = init_mem_in;
    end

    if (dmem0_in.mem_valid == 1) begin
      v.dmem0_in = dmem0_in;
    end
    if (dmem1_in.mem_valid == 1) begin
      v.dmem1_in = dmem1_in;
    end

    if (imem0_in.mem_valid == 1) begin
      v.imem0_in = imem0_in;
    end
    if (imem1_in.mem_valid == 1) begin
      v.imem1_in = imem1_in;
    end

    if (v.access_type == no_access) begin
      if (v.dmem0_in.mem_valid == 1) begin
        v.access_type = data0_access;
        v.mem_in = v.dmem0_in;
        v.dmem0_in = init_mem_in;
      end else if (v.dmem1_in.mem_valid == 1) begin
        v.access_type = data1_access;
        v.mem_in = v.dmem1_in;
        v.dmem1_in = init_mem_in;
      end else if (v.imem0_in.mem_valid == 1) begin
        v.access_type = instr0_access;
        v.mem_in = v.imem0_in;
        v.imem0_in = init_mem_in;
      end else if (v.imem1_in.mem_valid == 1) begin
        v.access_type = instr1_access;
        v.mem_in = v.imem1_in;
        v.imem1_in = init_mem_in;
      end
    end

    if (v.access_type != no_access) begin
      mem_in = v.mem_in;
    end else begin
      mem_in = init_mem_in;
    end

    rin = v;

    if (r.access_type == data0_access) begin
      dmem0_out = mem_out;
    end else begin
      dmem0_out = init_mem_out;
    end
    if (r.access_type == data1_access) begin
      dmem1_out = mem_out;
    end else begin
      dmem1_out = init_mem_out;
    end

    if (r.access_type == instr0_access) begin
      imem0_out = mem_out;
    end else begin
      imem0_out = init_mem_out;
    end
    if (r.access_type == instr1_access) begin
      imem1_out = mem_out;
    end else begin
      imem1_out = init_mem_out;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
