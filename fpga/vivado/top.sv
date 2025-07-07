import configure::*;

module top
(
  input  CLK100MHZ,
  input  CPU_RESETN,
  input  UART_TXD_IN,
  output UART_RXD_OUT,
  output [12:0] ddr2_addr,
  output [2:0]  ddr2_ba,
  output        ddr2_ras_n,
  output        ddr2_cas_n,
  output        ddr2_we_n,
  output        ddr2_ck_p,
  output        ddr2_ck_n,
  output        ddr2_cke,
  output        ddr2_cs_n,
  output [1:0]  ddr2_dm,
  output        ddr2_odt,
  inout  [15:0] ddr2_dq,
  inout  [1:0]  ddr2_dqs_p,
  inout  [1:0]  ddr2_dqs_n
);

  timeunit 1ns; timeprecision 1ps;

  logic CLOCK_DDR;
  logic CLOCK_CPU;
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
  logic [15 : 0] SRAM_D_i;
  logic [15 : 0] SRAM_D_o;
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
    .clk_out1(CLOCK_DDR),
    .clk_out2(CLOCK_CPU),
    .locked(LOCKED)
  );

  assign RESET = LOCKED & CPU_RESETN;

  assign SRAM_D = (SRAM_CE_n & SRAM_OE_n) ? SRAM_D_o : 16'bz;
  assign SRAM_D_i = (SRAM_CE_n & SRAM_WE_n) ? SRAM_D : 16'bz;

  ram2ddr ram2ddr_comp (
      .clk_200MHz_i(CLOCK_DDR),
      .rst_i(RESET),
      .ram_a(SRAM_A),
      .ram_dq_i(SRAM_D_i),
      .ram_dq_o(SRAM_D_o),
      .ram_cen(SRAM_CE_n),
      .ram_oen(SRAM_OE_n),
      .ram_wen(SRAM_WE_n),
      .ram_ub(SRAM_UB_n),
      .ram_lb(SRAM_LB_n),
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