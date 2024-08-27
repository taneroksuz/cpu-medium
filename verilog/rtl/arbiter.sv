import wires::*;
import constants::*;

module arbiter (
    input logic reset,
    input logic clock,
    input mem_in_type imem_in,
    output mem_out_type imem_out,
    input mem_in_type dmem_in,
    output mem_out_type dmem_out,
    output mem_in_type mem_in,
    input mem_out_type mem_out
);
  timeunit 1ns; timeprecision 1ps;

  parameter [1:0] no_access = 0;
  parameter [1:0] instr_access = 1;
  parameter [1:0] data_access = 2;

  typedef struct packed {
    logic [1:0]  access_type;
    logic [0:0]  mem_valid;
    logic [0:0]  mem_instr;
    logic [31:0] mem_addr;
    logic [63:0] mem_wdata;
    logic [7:0]  mem_wstrb;
    logic [0:0]  mem_error;
    logic [0:0]  dmem_valid;
    logic [0:0]  dmem_instr;
    logic [31:0] dmem_addr;
    logic [63:0] dmem_wdata;
    logic [7:0]  dmem_wstrb;
    logic [0:0]  imem_valid;
    logic [0:0]  imem_instr;
    logic [31:0] imem_addr;
    logic [63:0] imem_wdata;
    logic [7:0]  imem_wstrb;
  } reg_type;

  parameter reg_type init_reg = '{
      access_type : no_access,
      mem_valid : 1,
      mem_instr : 1,
      mem_addr : 0,
      mem_wdata : 0,
      mem_wstrb : 0,
      mem_error : 0,
      dmem_valid : 0,
      dmem_instr : 0,
      dmem_addr : 0,
      dmem_wdata : 0,
      dmem_wstrb : 0,
      imem_valid : 0,
      imem_instr : 0,
      imem_addr : 0,
      imem_wdata : 0,
      imem_wstrb : 0
  };

  reg_type r, rin;
  reg_type v;

  always_comb begin

    v = r;

    if (mem_out.mem_ready == 1) begin
      v.access_type = no_access;
    end

    if (dmem_in.mem_valid == 1) begin
      v.dmem_valid = dmem_in.mem_valid;
      v.dmem_instr = dmem_in.mem_instr;
      v.dmem_addr  = dmem_in.mem_addr;
      v.dmem_wdata = dmem_in.mem_wdata;
      v.dmem_wstrb = dmem_in.mem_wstrb;
    end

    if (imem_in.mem_valid == 1) begin
      v.imem_valid = imem_in.mem_valid;
      v.imem_instr = imem_in.mem_instr;
      v.imem_addr  = imem_in.mem_addr;
      v.imem_wdata = imem_in.mem_wdata;
      v.imem_wstrb = imem_in.mem_wstrb;
    end

    if (v.access_type == no_access) begin
      if (v.dmem_valid == 1) begin
        v.access_type = data_access;
        v.mem_valid = v.dmem_valid;
        v.mem_instr = v.dmem_instr;
        v.mem_addr = v.dmem_addr;
        v.mem_wdata = v.dmem_wdata;
        v.mem_wstrb = v.dmem_wstrb;
        v.dmem_valid = 0;
        v.dmem_instr = 0;
        v.dmem_addr = 0;
        v.dmem_wdata = 0;
        v.dmem_wstrb = 0;
      end else if (v.imem_valid == 1) begin
        v.access_type = instr_access;
        v.mem_valid = v.imem_valid;
        v.mem_instr = v.imem_instr;
        v.mem_addr = v.imem_addr;
        v.mem_wdata = v.imem_wdata;
        v.mem_wstrb = v.imem_wstrb;
        v.imem_valid = 0;
        v.imem_instr = 0;
        v.imem_addr = 0;
        v.imem_wdata = 0;
        v.imem_wstrb = 0;
      end
    end

    if (v.access_type != no_access) begin
      mem_in.mem_valid = v.mem_valid;
      mem_in.mem_instr = v.mem_instr;
      mem_in.mem_addr  = v.mem_addr;
      mem_in.mem_wdata = v.mem_wdata;
      mem_in.mem_wstrb = v.mem_wstrb;
    end else begin
      mem_in.mem_valid = 0;
      mem_in.mem_instr = 0;
      mem_in.mem_addr  = 0;
      mem_in.mem_wdata = 0;
      mem_in.mem_wstrb = 0;
    end

    rin = v;

    if (r.access_type == instr_access) begin
      imem_out.mem_ready = mem_out.mem_ready;
      imem_out.mem_rdata = mem_out.mem_rdata;
    end else begin
      imem_out.mem_ready = 0;
      imem_out.mem_rdata = 0;
    end

    if (r.access_type == data_access) begin
      dmem_out.mem_ready = mem_out.mem_ready;
      dmem_out.mem_rdata = mem_out.mem_rdata;
    end else begin
      dmem_out.mem_ready = 0;
      dmem_out.mem_rdata = 0;
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
