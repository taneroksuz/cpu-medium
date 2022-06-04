import configure::*;
import wires::*;

module debug
#(
)
(
  input logic rst,
  input logic clk,
  input logic rtc,
  input logic [0   : 0] debug_valid,
  input logic [0   : 0] debug_instr,
  input logic [31  : 0] debug_addr,
  input logic [31  : 0] debug_wdata,
  input logic [3   : 0] debug_wstrb,
  output logic [31 : 0] debug_rdata,
  output logic [0  : 0] debug_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] rdata = 0;
  logic [0  : 0] ready = 0;

  assign debug_rdata = rdata;
  assign debug_ready = ready;

endmodule
