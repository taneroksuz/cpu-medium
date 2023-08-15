import configure::*;

module print
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] print_valid,
  input logic [0   : 0] print_instr,
  input logic [31  : 0] print_addr,
  input logic [31  : 0] print_wdata,
  input logic [3   : 0] print_wstrb,
  output logic [31 : 0] print_rdata,
  output logic [0  : 0] print_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  always_ff @(posedge clock) begin

    if (print_valid == 1) begin

      $write("%c",print_wdata[7:0]);

      rdata <= 0;
      ready <= 1;

    end else begin

      rdata <= 0;
      ready <= 0;

    end

  end

  assign print_rdata = rdata;
  assign print_ready = ready;


endmodule
