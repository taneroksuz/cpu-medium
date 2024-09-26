import configure::*;

module top
(
  input  CLK100MHZ,
  input  CPU_RESETN,
  input  UART_TXD_IN,
  output UART_RXD_OUT
);

  timeunit 1ns; timeprecision 1ps;

  logic SCLK;
  logic MOSI;
  logic MISO;
  logic SS;

  logic SRAM_CE_n;
  logic SRAM_WE_n;
  logic SRAM_OE_n;
  logic SRAM_UB_n;
  logic SRAM_LB_n;
  logic [15 : 0] SRAM_D;
  logic [17 : 0] SRAM_A;

  initial begin
    SCLK = 0;
    MOSI = 0;
    MISO = 0;
    SS = 0;
  end

  soc soc_comp (
      .reset(CPU_RESETN),
      .clock(CLK100MHZ),
      .clock_per(CLK100MHZ),
      .sclk(SCLK),
      .mosi(MOSI),
      .miso(MISO),
      .ss(SS),
      .rx(UART_TXD_IN),
      .tx(UART_RXD_OUT),
      .sram_ce_n(SRAM_CE_n),
      .sram_we_n(SRAM_WE_n),
      .sram_oe_n(SRAM_OE_n),
      .sram_ub_n(SRAM_UB_n),
      .sram_lb_n(SRAM_LB_n),
      .sram_dq(SRAM_D),
      .sram_addr(SRAM_A)
  );

endmodule