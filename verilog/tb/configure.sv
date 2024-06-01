package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter buffer_depth = 8;
  parameter hazard_depth = 4;

  parameter tim_width = 32;
  parameter tim_depth = 8192;

  parameter ram_cycle = 0;
  parameter ram_depth = 262144;

  parameter fpu_enable = 1;

  parameter btac_enable = 1;
  parameter branchtarget_depth = 64;
  parameter branchhistory_depth = 1024;

  parameter rom_base_addr = 32'h0;
  parameter rom_top_addr  = 32'h80;

  parameter print_base_addr = 32'h1000000;
  parameter print_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter tim0_base_addr = 32'h10000000;
  parameter tim0_top_addr  = 32'h10100000;

  parameter tim1_base_addr = 32'h20000000;
  parameter tim1_top_addr  = 32'h20100000;

  parameter ram_base_addr = 32'h80000000;
  parameter ram_top_addr  = 32'h90000000;

  parameter clk_freq = 1000000000; // 1GHz
  parameter rtc_freq = 100000000; // 100MHz

  parameter clk_divider_rtc = (clk_freq/rtc_freq)/2-1;

endpackage
