import configure::*;
import wires::*;

module uart_rx #(
    parameter clock_rate
) (
    input logic reset,
    input logic clock,
    input mem_in_type uart_in,
    output mem_out_type uart_out,
    output logic uart_irpt,
    input rx
);
  timeunit 1ns; timeprecision 1ps;

  localparam full = clock_rate - 1;

  typedef struct packed {
    logic [31 : 0] counter;
    logic [7 : 0]  rdata_re;
    logic [0 : 0]  ready_re;
    logic [3 : 0]  state;
    logic [8 : 0]  data;
    logic [0 : 0]  ready;
  } register_type;

  register_type init_register = '{
      counter : 0,
      rdata_re : 0,
      ready_re : 0,
      state : 0,
      data : 0,
      ready : 0
  };

  register_type r, rin, v;

  always_comb begin

    v = r;

    v.counter = v.counter + 1;

    v.ready_re = 0;

    if (uart_in.mem_valid == 1 && |uart_in.mem_wstrb == 0 && v.ready == 1) begin
      v.ready_re = 1;
      v.ready = 0;
    end

    case (r.state)
      0: begin
        if (rx == 0) begin
          v.state = 1;
        end
        v.counter = 0;
      end
      9: begin
        if (r.counter > full) begin
          v.rdata_re = v.data[8:1];
          v.counter  = 0;
          v.state    = 0;
          v.ready    = 1;
        end
      end
      default: begin
        if (r.counter > full) begin
          v.data = {rx, v.data[8:1]};
          v.state = v.state + 4'h1;
          v.counter = 0;
        end
      end
    endcase

    rin = v;

  end

  assign uart_out.mem_rdata = {56'b0, r.rdata_re};
  assign uart_out.mem_error = 0;
  assign uart_out.mem_ready = r.ready_re;
  assign uart_irpt = r.ready;

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
