import wires::*;
import constants::*;

module ccd
#(
  parameter clock_rate
)
(
  input  logic reset,
  input  logic clock,
  input  logic clock_slow,
  input  logic [0  : 0] memory_valid,
  input  logic [0  : 0] memory_instr,
  input  logic [31 : 0] memory_addr,
  input  logic [31 : 0] memory_wdata,
  input  logic [3  : 0] memory_wstrb,
  output logic [31 : 0] memory_rdata,
  output logic [0  : 0] memory_ready,
  output logic [0  : 0] memory_slow_valid,
  output logic [0  : 0] memory_slow_instr,
  output logic [31 : 0] memory_slow_addr ,
  output logic [31 : 0] memory_slow_wdata,
  output logic [3  : 0] memory_slow_wstrb,
  input  logic [31 : 0] memory_slow_rdata,
  input  logic [0  : 0] memory_slow_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(clock_rate);

  logic [depth-1:0] count;
  logic [depth-1:0] count_reg;

  logic [0  : 0] memory_fast_ready;

  typedef struct packed{
    logic [0  : 0] memory_valid;
    logic [0  : 0] memory_instr;
    logic [31 : 0] memory_addr;
    logic [31 : 0] memory_wdata;
    logic [3  : 0] memory_wstrb;
    logic [31 : 0] memory_rdata;
    logic [0  : 0] memory_ready;
  } reg_type;

  parameter reg_type init_reg = '{
    memory_valid : 0,
    memory_instr : 0,
    memory_addr : 0,
    memory_wdata : 0,
    memory_wstrb : 0,
    memory_rdata : 0,
    memory_ready : 0
  };

  reg_type r,rin,v;

  always_comb begin

    count = count_reg;

    v = r;

    v.memory_valid = 0;
    v.memory_instr = 0;
    v.memory_addr = 0;
    v.memory_wdata = 0;
    v.memory_wstrb = 0;
    v.memory_rdata = 0;
    v.memory_ready = 0;

    if (memory_fast_ready == 0 && memory_slow_ready == 1) begin
      count = clock_rate[depth-1:0];
    end

    if (count == clock_rate[depth-1:0] && memory_slow_ready == 1) begin
      count = 0;
      v.memory_rdata = memory_slow_rdata;
      v.memory_ready = memory_slow_ready;
    end

    if (memory_valid == 1) begin
      v.memory_valid = memory_valid;
      v.memory_instr = memory_instr;
      v.memory_addr = memory_addr;
      v.memory_wdata = memory_wdata;
      v.memory_wstrb = memory_wstrb;
    end

    memory_slow_valid = v.memory_valid;
    memory_slow_instr = v.memory_instr;
    memory_slow_addr = v.memory_addr;
    memory_slow_wdata = v.memory_wdata;
    memory_slow_wstrb = v.memory_wstrb;

    memory_rdata = v.memory_rdata;
    memory_ready = v.memory_ready;

    count = count + 1;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      count_reg <= 0;
      memory_fast_ready <= 0;
      r <= init_reg;
    end else begin
      count_reg <= count;
      memory_fast_ready <= memory_slow_ready;
      r <= rin;
    end
  end

endmodule
