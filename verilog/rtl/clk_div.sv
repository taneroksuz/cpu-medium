import wires::*;
import constants::*;

module clk_div
#(
  parameter clock_rate
)
(
  input  logic reset,
  input  logic clock,
  output logic clock_slow
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(clock_rate);
  localparam half = clock_rate/2-1;

  localparam [depth-1:0] one = 1;

  logic [depth-1:0] count;

  initial begin
    count = 0;
    clock_slow = 1;
  end

  always_ff @(posedge clock) begin
    if (count == half[depth-1:0]) begin
      count <= 0;
      clock_slow <= ~clock_slow;
    end else begin
      count <= count + one;
    end
  end

endmodule
