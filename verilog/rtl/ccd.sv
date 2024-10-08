import wires::*;
import constants::*;

module ccd #(
    parameter clock_rate
) (
    input logic reset,
    input logic clock,
    input logic clock_per,
    input mem_in_type mem_in,
    output mem_out_type mem_out,
    output mem_in_type mem_per_in,
    input mem_out_type mem_per_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(clock_rate);

  localparam [depth-1:0] full = clock_rate - 1;
  localparam [depth-1:0] one = 1;

  logic [depth-1:0] count;

  logic [63 : 0] memory_fast_rdata;
  logic [0 : 0] memory_fast_ready;

  initial begin
    count = 0;
  end

  always_comb begin

    if (mem_in.mem_valid == 1) begin
      mem_per_in.mem_valid = mem_in.mem_valid;
      mem_per_in.mem_mode  = mem_in.mem_mode;
      mem_per_in.mem_instr = mem_in.mem_instr;
      mem_per_in.mem_addr  = mem_in.mem_addr;
      mem_per_in.mem_wdata = mem_in.mem_wdata;
      mem_per_in.mem_wstrb = mem_in.mem_wstrb;
    end else begin
      mem_per_in.mem_valid = 0;
      mem_per_in.mem_mode  = 0;
      mem_per_in.mem_instr = 0;
      mem_per_in.mem_addr  = 0;
      mem_per_in.mem_wdata = 0;
      mem_per_in.mem_wstrb = 0;
    end

    mem_out.mem_rdata = memory_fast_rdata;
    mem_out.mem_error = 0;
    mem_out.mem_ready = memory_fast_ready;

  end

  always_ff @(posedge clock) begin
    if (count == full[depth-1:0]) begin
      count <= 0;
    end else begin
      count <= count + one;
    end
  end

  always_ff @(posedge clock) begin
    if (count == full[depth-1:0] && mem_per_out.mem_ready == 1) begin
      memory_fast_rdata <= mem_per_out.mem_rdata;
      memory_fast_ready <= mem_per_out.mem_ready;
    end else begin
      memory_fast_rdata <= 0;
      memory_fast_ready <= 0;
    end
  end

endmodule
