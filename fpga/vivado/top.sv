import configure::*;
import wires::*;

module top
(
  input  CLK100MHZ,
  input  CPU_RESETN,
  input  UART_TXD_IN,
  output UART_RXD_OUT
);

  timeunit 1ns; timeprecision 1ps;

  wire CLOCK_CPU;
  wire LOCKED;
  wire RESET;

  wire SCLK;
  wire MOSI;
  wire MISO;
  wire SS;

  wire SRAM_CE_n;
  wire SRAM_WE_n;
  wire SRAM_OE_n;
  wire SRAM_UB_n;
  wire SRAM_LB_n;
  wire [15 : 0] SRAM_D;
  wire [17 : 0] SRAM_A;

  (* keep = "true" *) verify_out_type VER0_OUT;
  (* keep = "true" *) verify_out_type VER1_OUT;

  initial begin
    MISO = 0;
  end

  pll pll_cpu_comp (
    .clk_in1(CLK100MHZ),
    .reset(~CPU_RESETN),
    .clk_out1(CLOCK_CPU),
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
      .sram_addr(SRAM_A),
      .ver0_out(VER0_OUT),
      .ver1_out(VER1_OUT)
  );

endmodule