import configure::*;
import wires::*;

module top
(
  input  CLK100MHZ,
  input  CPU_RESETN,
  input  UART_TXD_IN,
  output UART_RXD_OUT,
  output LED16_B,
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

  mem_in_type  ram_in;
  mem_out_type ram_out;
  mem_in_type  dram_in;
  mem_out_type dram_out;

  initial begin
    SCLK = 0;
    MOSI = 0;
    MISO = 0;
    SS = 0;
  end

  pll pll_cpu_comp (
    .clk_in1(CLK100MHZ),
    .resetn(CPU_RESETN),
    .clk_out1(CLOCK_DDR),
    .clk_out2(CLOCK_CPU),
    .locked(LOCKED)
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
      .ram_in(ram_in),
      .ram_out(ram_out)
  );

  always_ff @(posedge CLOCK_CPU) begin
    dram_in <= ram_in;
    ram_out <= dram_out;
  end

  dram dram_comp (
      .clk_200MHz_i(CLOCK_DDR),
      .rst_i(RESET),
      .dram_in(dram_in),
      .dram_out(dram_out),
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
      .ddr2_dqs_n(ddr2_dqs_n),
      .ddr2_complete(LED16_B)
  );

endmodule