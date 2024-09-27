import configure::*;

module top
(
  input  CLK100MHZ,
  input  CPU_RESETN,
  input  UART_TXD_IN,
  output UART_RXD_OUT
);

  timeunit 1ns; timeprecision 1ps;

  logic CLOCK_CPU;
  logic CLOCK_PER;
  logic LOCKED;
  logic RESET;

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

  pll pll_cpu_comp (
    .clk_in1(CLK100MHZ),
    .reset(~CPU_RESETN),
    .clk_out1(CLOCK_CPU),
    .clk_out2(CLOCK_PER),
    .locked(LOCKED)
  );

  sram_memory sram_memory_comp (
      .CLOCK(CLOCK_CPU),
      .SRAM_CE_n(SRAM_CE_n),
      .SRAM_WE_n(SRAM_WE_n),
      .SRAM_OE_n(SRAM_OE_n),
      .SRAM_UB_n(SRAM_UB_n),
      .SRAM_LB_n(SRAM_LB_n),
      .SRAM_D(SRAM_D),
      .SRAM_A(SRAM_A)
  );

  assign RESET = LOCKED & CPU_RESETN;

  soc soc_comp (
      .reset(RESET),
      .clock(CLOCK_CPU),
      .clock_per(CLOCK_PER),
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