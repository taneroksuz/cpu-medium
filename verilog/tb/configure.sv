package configure;

  timeunit 1ns;
  timeprecision 1ps;

  parameter hazard_depth = 4;

  parameter bram_depth = 262144;

  parameter fpu_enable = 1;

  parameter itim_width = 4;
  parameter itim_depth = 8192;

  parameter dtim_width = 4;
  parameter dtim_depth = 8192;

  parameter btac_enable = 1;
  parameter branchtarget_depth = 64;

  parameter bram_base_addr = 32'h000000;
  parameter bram_top_addr  = 32'h100000;

  parameter itim_base_addr = 32'h000000;
  parameter itim_top_addr  = 32'h100000;

  parameter dtim_base_addr = 32'h000000;
  parameter dtim_top_addr  = 32'h100000;

  parameter print_base_addr = 32'h1000000;
  parameter print_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter clk_freq = 1000000000; // 1GHz
  parameter rtc_freq = 100000000; // 100MHz

  parameter clk_divider_rtc = (clk_freq/rtc_freq)/2-1;

endpackage
