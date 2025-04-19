import configure::*;

module top
(
  input  CLK100MHZ,
  input  CPU_RESETN,
  input  UART_TXD_IN,
  output UART_RXD_OUT,
  input  [11 : 0] device_temp_i,
  output [12 : 0] ddr2_addr,
  output [ 2 : 0] ddr2_ba,
  output          ddr2_ras_n,
  output          ddr2_cas_n,
  output          ddr2_we_n,
  output [ 0 : 0] ddr2_ck_p,
  output [ 0 : 0] ddr2_ck_n,
  output [ 0 : 0] ddr2_cke,
  output [ 0 : 0] ddr2_cs_n,
  output [ 1 : 0] ddr2_dm,
  output [ 0 : 0] ddr2_odt,
  inout  [15 : 0] ddr2_dq,
  inout  [ 1 : 0] ddr2_dqs_p,
  inout  [ 1 : 0] ddr2_dqs_n
);

  timeunit 1ns; timeprecision 1ps;

  logic CLOCK_CPU;
  logic CLOCK_PER;
  logic CLOCK_DDR;
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
    .clk_out3(CLOCK_DDR),
    .locked(LOCKED)
  );

  assign RESET = LOCKED & CPU_RESETN;

  ram2ddr ram2ddr_comp (
      .reset(RESET),
      .clock(CLOCK_DDR),
      .device_temp_i(device_temp_i),
      .ram_cen(SRAM_CE_n),
      .ram_oen(SRAM_OE_n),
      .ram_wen(SRAM_WE_n),
      .ram_ub(SRAM_UB_n),
      .ram_lb(SRAM_LB_n),
      .ram_dq(SRAM_D),
      .ram_a(SRAM_A),
      .ddr2_addr(ddr2_addr),
      .ddr2_ba(ddr2_ba),
      .ddr2_ras_n(ddr2_ras_n),
      .ddr2_cas_n(ddr2_cas_n),
      .ddr2_we_n(ddr2_we_n),
      .ddr2_ck_p(ddr2_ck_p),
      .ddr2_ck_n(ddr2_ck_n),
      .ddr2_cke(ddr2_cke),
      .ddr2_cs_n(ddr2_cs_n),
      .ddr2_dm(ddr2_dm),
      .ddr2_odt(ddr2_odt),
      .ddr2_dq(ddr2_dq),
      .ddr2_dqs_p(ddr2_dqs_p),
      .ddr2_dqs_n(ddr2_dqs_n)
  );

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