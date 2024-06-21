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
  localparam full = clock_rate-1;

  localparam [depth-1:0] one = 1;

  logic [depth-1:0] count;

  logic [31 : 0] memory_fast_rdata;
  logic [0  : 0] memory_fast_ready;

  initial begin
    count = 0;
  end

  always_comb begin

    if (memory_valid == 1) begin
      memory_slow_valid = memory_valid;
      memory_slow_instr = memory_instr;
      memory_slow_addr = memory_addr;
      memory_slow_wdata = memory_wdata;
      memory_slow_wstrb = memory_wstrb;
    end else begin
      memory_slow_valid = 0;
      memory_slow_instr = 0;
      memory_slow_addr = 0;
      memory_slow_wdata = 0;
      memory_slow_wstrb = 0;
    end

    memory_rdata = memory_fast_rdata;
    memory_ready = memory_fast_ready;

  end

  always_ff @(posedge clock) begin
    if (count == full[depth-1:0]) begin
      count <= 0;
    end else begin
      count <= count + one;
    end
  end

  always_ff @(posedge clock) begin
    if (count == full[depth-1:0] && memory_slow_ready == 1) begin
      memory_fast_rdata <= memory_slow_rdata;
      memory_fast_ready <= memory_slow_ready;
    end else begin
      memory_fast_rdata <= 0;
      memory_fast_ready <= 0;
    end
  end

endmodule
