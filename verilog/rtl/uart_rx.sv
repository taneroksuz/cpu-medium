import configure::*;
import wires::*;

module uart_rx #(
    parameter clock_rate
) (
    input logic reset,
    input logic clock,
    input mem_in_type uart_in,
    output mem_out_type uart_out,
    output logic irpt,
    input logic rx
);
  timeunit 1ns; timeprecision 1ps;

  localparam full = clock_rate - 1;

  typedef struct packed {
    logic [0 : 0]  state_re;
    logic [3 : 0]  state;
    logic [7 : 0]  data_re;
    logic [8 : 0]  data;
    logic [31 : 0] counter;
    logic [0 : 0]  ready_re;
    logic [0 : 0]  ready;
    logic [0 : 0]  irpt_re;
    logic [0 : 0]  irpt;
  } register_type;

  register_type init_register = '{
      state_re : 0,
      state : 0,
      data_re : 0,
      data : 0,
      counter : 0,
      ready_re : 0,
      ready : 0,
      irpt_re : 0,
      irpt : 0
  };

  register_type r, rin, v;

  always_comb begin

    v = r;

    v.counter = v.counter + 1;

    v.ready_re = 0;
    v.ready = 0;

    if (uart_in.mem_valid == 1 && |uart_in.mem_wstrb == 0 && v.state == 0) begin
      v.state_re = 1;
    end

    if (uart_in.mem_valid == 1 && |uart_in.mem_wstrb == 0 && v.irpt == 1) begin
      v.irpt_re = 1;
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
          v.state   = 0;
          v.counter = 0;
          v.ready   = 1;
          v.irpt    = 1;
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

    if (r.state_re == 1 && r.ready == 1) begin
      v.ready_re = 1;
      v.state_re = 0;
      v.data_re  = r.data[8:1];
    end

    if (r.irpt_re == 1 && r.irpt == 1) begin
      v.ready_re = 1;
      v.irpt_re = 0;
      v.irpt = 0;
      v.data_re = r.data[8:1];
    end

    rin = v;

  end

  assign uart_out.mem_rdata = {56'b0, r.data_re};
  assign uart_out.mem_ready = r.ready_re;

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
