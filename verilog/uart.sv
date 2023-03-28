import configure::*;
import wires::*;

module uart
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] uart_valid,
  input logic [0   : 0] uart_instr,
  input logic [31  : 0] uart_addr,
  input logic [31  : 0] uart_wdata,
  input logic [3   : 0] uart_wstrb,
  output logic [31 : 0] uart_rdata,
  output logic [0  : 0] uart_ready,
  input logic uart_rx,
  output logic uart_tx
);
  timeunit 1ns;
  timeprecision 1ps;

  typedef struct packed{
    logic [3  : 0] state_tx;
    logic [9  : 0] data_tx;
    logic [31 : 0] counter_tx;
    logic [0  : 0] ready_tx;
  } register_tx_type;

  register_tx_type init_tx_register = '{
    state_tx : 0,
    data_tx : 10'h3FF,
    counter_tx : 0,
    ready_tx : 0
  };

  typedef struct packed{
    logic [0  : 0] state_re;
    logic [3  : 0] state_rx;
    logic [7  : 0] data_re;
    logic [8  : 0] data_rx;
    logic [31 : 0] counter_rx;
    logic [0  : 0] ready_re;
    logic [0  : 0] ready_rx;
  } register_rx_type;

  register_rx_type init_rx_register = '{
    state_re : 0,
    state_rx : 0,
    data_re : 0,
    data_rx : 0,
    counter_rx : 0,
    ready_re : 0,
    ready_rx : 0
  };

  register_tx_type r_tx,rin_tx,v_tx;
  register_rx_type r_rx,rin_rx,v_rx;

  always_comb begin

    v_tx = r_tx;

    v_tx.counter_tx = v_tx.counter_tx + 1;

    v_tx.ready_tx = 0;

    if (uart_valid == 1 && |uart_wstrb == 1 && v_tx.state_tx == 0) begin
      v_tx.data_tx = {1'b1,uart_wdata[7:0],1'b0};
      v_tx.state_tx = 1;
    end

    case (r_tx.state_tx)
      0 : begin
        v_tx.counter_tx = 0;
      end
      10 : begin
        if (r_tx.counter_tx > clks_per_bit) begin
          v_tx.state_tx = 0;
          v_tx.counter_tx = 0;
          v_tx.ready_tx = 1;
        end
      end
      default : begin
        if (r_tx.counter_tx > clks_per_bit) begin
          v_tx.data_tx = {1'b1,v_tx.data_tx[9:1]};
          v_tx.state_tx = v_tx.state_tx + 4'h1;
          v_tx.counter_tx = 0;
        end
      end
    endcase;

    rin_tx = v_tx;

    uart_tx = r_tx.data_tx[0];

  end

  always_comb begin

    v_rx = r_rx;

    v_rx.counter_rx = v_rx.counter_rx + 1;

    v_rx.ready_re = 0;
    v_rx.ready_rx = 0;

    if (uart_valid == 1 && |uart_wstrb == 0 && v_rx.state_rx == 0) begin
      v_rx.state_re = 1;
    end

    case (r_rx.state_rx)
      0 : begin
        if (uart_rx == 0) begin
          v_rx.state_rx = 1;
        end
        v_rx.counter_rx = 0;
      end
      9 : begin
        if (r_rx.counter_rx > clks_per_bit) begin
          v_rx.state_rx = 0;
          v_rx.counter_rx = 0;
          v_rx.ready_rx = 1;
        end
      end
      default : begin
        if (r_rx.counter_rx > clks_per_bit) begin
          v_rx.data_rx = {uart_rx,v_rx.data_rx[8:1]};
          v_rx.state_rx = v_rx.state_rx + 4'h1;
          v_rx.counter_rx = 0;
        end
      end
    endcase;

    if (r_rx.state_re == 1 && r_rx.ready_rx == 1) begin
      v_rx.state_re = 0;
      v_rx.ready_re = 1;
      v_rx.data_re = r_rx.data_rx[8:1];
    end

    rin_rx = v_rx;

  end

  assign uart_rdata = {24'b0,r_rx.data_re};
  assign uart_ready = r_tx.ready_tx | r_rx.ready_re;

  always_ff @ (posedge clock) begin
    if (reset == 0) begin
      r_tx <= init_tx_register;
      r_rx <= init_rx_register;
    end else begin
      r_tx <= rin_tx;
      r_rx <= rin_rx;
    end
  end

endmodule
