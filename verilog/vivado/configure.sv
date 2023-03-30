package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter fetchbuffer_depth = 4;
  parameter storebuffer_depth = 4;

  parameter fpu_enable = 1;

  parameter itim_enable = 1;
  parameter itim_width = 2;
  parameter itim_depth = 10;

  parameter dtim_enable = 1;
  parameter dtim_width = 2;
  parameter dtim_depth = 10;

  parameter bp_enable = 1;
  parameter btb_depth = 6;
  parameter bht_depth = 6;
  parameter ras_depth = 2;

  parameter rom_base_addr = 32'h0;
  parameter rom_top_addr  = 32'h80;

  parameter itim_base_addr = 32'h0;
  parameter itim_top_addr  = 32'h4000;

  parameter dtim_base_addr = 32'h4000;
  parameter dtim_top_addr  = 32'h8000;

  parameter uart_base_addr = 32'h1000000;
  parameter uart_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter axi_base_addr = 32'h80000000;
  parameter axi_top_addr  = 32'h90000000;

  parameter clk_freq = 25000000; // 25MHz
  parameter rtc_freq = 32768; // 32768Hz
  parameter baudrate = 115200;

  parameter clk_divider_rtc = (clk_freq/rtc_freq)/2-1;
  parameter clks_per_bit = clk_freq/baudrate-1;

endpackage
