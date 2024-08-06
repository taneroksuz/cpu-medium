import configure::*;

module top (
    input  logic reset,
    input  logic clock,
    input  logic uart_rx,
    output logic uart_tx
);

  timeunit 1ns; timeprecision 1ps;

  logic clock_slow;

  logic [0 : 0] uart_valid;
  logic [0 : 0] uart_instr;
  logic [31 : 0] uart_addr;
  logic [31 : 0] uart_wdata;
  logic [3 : 0] uart_wstrb;
  logic [31 : 0] uart_rdata;
  logic [0 : 0] uart_ready;

  clk_div #(
      .clock_rate(clk_divider_slow)
  ) clk_div_comp (
      .reset(reset),
      .clock(clock),
      .clock_slow(clock_slow)
  );

  soc soc_comp (
      .reset(reset),
      .clock(clock),
      .clock_slow(clock_slow),
      .uart_valid(uart_valid),
      .uart_instr(uart_instr),
      .uart_addr(uart_addr),
      .uart_wdata(uart_wdata),
      .uart_wstrb(uart_wstrb),
      .uart_rdata(uart_rdata),
      .uart_ready(uart_ready)
  );

  uart uart_comp (
      .reset(reset),
      .clock(clock),
      .uart_valid(uart_valid),
      .uart_instr(uart_instr),
      .uart_addr(uart_addr),
      .uart_wdata(uart_wdata),
      .uart_wstrb(uart_wstrb),
      .uart_rdata(uart_rdata),
      .uart_ready(uart_ready),
      .uart_rx(uart_rx),
      .uart_tx(uart_tx)
  );

endmodule
