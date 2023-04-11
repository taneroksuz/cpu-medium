import wires::*;
import constants::*;

module arbiter(
  input logic reset,
  input logic clock,
  input logic [0  : 0] imemory_valid,
  input logic [0  : 0] imemory_instr,
  input logic [31 : 0] imemory_addr ,
  input logic [31 : 0] imemory_wdata,
  input logic [3  : 0] imemory_wstrb,
  output logic [31  : 0] imemory_rdata,
  output logic [0   : 0] imemory_ready,
  input logic [0  : 0] dmemory_valid,
  input logic [0  : 0] dmemory_instr,
  input logic [31 : 0] dmemory_addr ,
  input logic [31 : 0] dmemory_wdata,
  input logic [3  : 0] dmemory_wstrb,
  output logic [31  : 0] dmemory_rdata,
  output logic [0   : 0] dmemory_ready,
  output logic [0  : 0] memory_valid,
  output logic [0  : 0] memory_instr,
  output logic [31 : 0] memory_addr,
  output logic [31 : 0] memory_wdata,
  output logic [3  : 0] memory_wstrb,
  input logic [31  : 0] memory_rdata,
  input logic [0   : 0] memory_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  parameter [1:0] no_access = 0;
  parameter [1:0] instr_access = 1;
  parameter [1:0] data_access = 2;

  typedef struct packed{
    logic [1:0] access_type;
    logic [0:0] mem_valid;
    logic [0:0] mem_instr;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0] mem_wstrb;
    logic [0:0] mem_error;
    logic [0:0] dmem_valid;
    logic [0:0] dmem_instr;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [3:0] dmem_wstrb;
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
    dmem_wstrb : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    if (memory_ready == 1) begin
      v.access_type = no_access;
    end
    
    if (dmemory_valid == 1) begin
      v.dmem_valid = dmemory_valid;
      v.dmem_instr = dmemory_instr;
      v.dmem_addr = dmemory_addr;
      v.dmem_wdata = dmemory_wdata;
      v.dmem_wstrb = dmemory_wstrb;
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
      end else if (imemory_valid == 1) begin
        v.access_type = instr_access;
        v.mem_valid = imemory_valid;
        v.mem_instr = imemory_instr;
        v.mem_addr = imemory_addr;
        v.mem_wdata = imemory_wdata;
        v.mem_wstrb = imemory_wstrb;
      end
    end

    if (v.access_type != no_access) begin
      memory_valid = v.mem_valid;
      memory_instr = v.mem_instr;
      memory_addr = v.mem_addr;
      memory_wdata = v.mem_wdata;
      memory_wstrb = v.mem_wstrb;
    end else begin
      memory_valid = 0;
      memory_instr = 0;
      memory_addr = 0;
      memory_wdata = 0;
      memory_wstrb = 0;
    end

    rin = v;

    if (r.access_type == instr_access) begin
      imemory_ready = memory_ready;
      imemory_rdata = memory_rdata;
    end else begin
      imemory_ready = 0;
      imemory_rdata = 0;
    end

    if (r.access_type == data_access) begin
      dmemory_ready = memory_ready;
      dmemory_rdata = memory_rdata;
    end else begin
      dmemory_ready = 0;
      dmemory_rdata = 0;
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
