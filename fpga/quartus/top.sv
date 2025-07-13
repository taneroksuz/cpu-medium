import configure::*;
import wires::*;

module top
(
  input           CLOCK_50_B5B,
  input  [ 3 : 0] KEY,
  output [ 9 : 0] LEDR,
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

  logic CLOCK_CPU;
  logic LOCKED;
  logic RESET;

  logic SCLK;
  logic MOSI;
  logic MISO;
  logic SS;

  mem_in_type  ram_in;
  mem_out_type ram_out;

  initial begin
    SCLK = 0;
    MOSI = 0;
    MISO = 0;
    SS = 0;
  end

  pll pll_cpu_comp (
    .refclk(CLOCK_50_B5B),
    .rst(~KEY[0]),
    .outclk_0(CLOCK_CPU),
    .locked(LOCKED)
  );

  assign RESET = LOCKED & KEY[0];

  soc soc_comp (
      .reset(RESET),
      .clock(CLOCK_CPU),
      .sclk(SCLK),
      .mosi(MOSI),
      .miso(MISO),
      .ss(SS),
      .rx(UART_RX),
      .tx(UART_TX),
      .ram_in(ram_in),
      .ram_out(ram_out)
  );

  logic [9:0] REG_LED = 0;

  always_ff @(posedge CLOCK_CPU) begin
    if (RESET == 0) begin
      REG_LED <= 0;
    end else begin
      if (ram_in.mem_valid) begin
        REG_LED[9:0] <= ram_in.mem_addr[18:9];
      end
    end
  end

  assign LEDR = REG_LED;

  sram #(
      .clock_rate(clk_divider_per)
  ) sram_comp (
      .reset(RESET),
      .clock(CLOCK_CPU),
      .sram_in(ram_in),
      .sram_out(ram_out),
      .sram_ce_n(SRAM_CE_n),
      .sram_we_n(SRAM_WE_n),
      .sram_oe_n(SRAM_OE_n),
      .sram_ub_n(SRAM_UB_n),
      .sram_lb_n(SRAM_LB_n),
      .sram_dq(SRAM_D),
      .sram_addr(SRAM_A)
  );

endmodule