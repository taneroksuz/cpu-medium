package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter prefetch_depth = 4;
  parameter writebuffer_depth = 4;

  parameter bram_depth = 11;

  parameter itim_enable = 1;
  parameter itim_width = 2;
  parameter itim_depth = 10;

  parameter dtim_enable = 1;
  parameter dtim_width = 2;
  parameter dtim_depth = 10;

  parameter bram_base_addr = 32'h0;
  parameter bram_top_addr  = 32'h2000;

  parameter itim_base_addr = 32'h0;
  parameter itim_top_addr  = 32'h1000;

  parameter dtim_base_addr = 32'h1000;
  parameter dtim_top_addr  = 32'h2000;

  parameter uart_base_addr = 32'h1000000;
  parameter uart_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter plic_base_addr = 32'h0C000000;
  parameter plic_top_addr  = 32'h10000000;

  parameter clk_freq = 50000000; // 50MHz
  parameter clk_pll = 25000000; // 25MHz
  parameter rtc_freq = 32768; // 32768Hz
  parameter baudrate = 115200;

  parameter clk_divider_pll = (clk_freq/clk_pll)/2-1;
  parameter clk_divider_rtc = (clk_freq/rtc_freq)/2-1;
  parameter clks_per_bit = clk_pll/baudrate-1;

endpackage
