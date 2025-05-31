import configure::*;
import wires::*;

module top
(
  input           CLOCK,
  input           KEY,
  input           UART_RX,
  output          UART_TX,
  output          SRAM_CE_n,
  output          SRAM_WE_n,
  output          SRAM_OE_n,
  output          SRAM_UB_n,
  output          SRAM_LB_n,
  inout  [15 : 0] SRAM_D,
  output [17 : 0] SRAM_A
);

  timeunit 1ns; timeprecision 1ps;

  wire CLOCK_CPU;
  wire LOCKED;
  wire RESET;

  wire SCLK;
  wire MOSI;
  wire MISO;
  wire SS;

  verify_out_type VER0_OUT /* synthesis keep */;
  verify_out_type VER1_OUT /* synthesis keep */;

  initial begin
    MISO = 0;
  end

  pll pll_cpu_comp (
    .refclk(CLOCK),
    .rst(~KEY),
    .outclk_0(CLOCK_CPU),
    .locked(LOCKED)
  );

  assign RESET = LOCKED & KEY;

  soc soc_comp (
      .reset(RESET),
      .clock(CLOCK_CPU),
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
      .sram_addr(SRAM_A),
      .ver0_out(VER0_OUT),
      .ver1_out(VER1_OUT)
  );

endmodule