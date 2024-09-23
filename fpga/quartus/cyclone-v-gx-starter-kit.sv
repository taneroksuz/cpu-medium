import configure::*;

module top
(
  input           CLOCK_50_B5B,
  input  [ 3 : 0] KEY,
  input           UART_RX,
  input           UART_TX,
  output          SRAM_CE_n,
  output          SRAM_WE_n,
  output          SRAM_OE_n,
  output          SRAM_UB_n,
  output          SRAM_LB_n,
  inout  [15 : 0] SRAM_D,
  output [17 : 0] SRAM_A
);

  timeunit 1ns; timeprecision 1ps;

  logic CLOCK_PER;

  logic SCLK;
  logic MOSI;
  logic MISO;
  logic SS;

  initial begin
    CLOCK_PER = 0;
    SCLK = 0;
    MOSI = 0;
    MISO = 0;
    SS = 0;
  end

  clk_div #(
      .clock_rate(clk_divider_per)
  ) clk_div_comp (
      .reset(KEY[0]),
      .clock(CLOCK_50_B5B),
      .clock_per(CLOCK_PER)
  );

  soc soc_comp (
      .reset(KEY[0]),
      .clock(CLOCK_50_B5B),
      .clock_per(CLOCK_PER),
      .sclk(SCLK),
      .mosi(MOSI),
      .miso(MISO),
      .ss(SS),
      .rx(UART_RX),
      .tx(UART_TX),
      .sram_ce_n(SRAM_CE_n),
      .sram_we_n(SRAM_WE_n),
      .sram_oe_n(SRAM_OE_n),
      .sram_ub_n(SRAM_UB_n),
      .sram_lb_n(SRAM_LB_n),
      .sram_dq(SRAM_D),
      .sram_addr(SRAM_A)
  );

endmodule