package configure;

  timeunit 1ns;
  timeprecision 1ps;

  parameter prefetch_depth = 4;
  parameter writebuffer_depth = 4;

  parameter bram_depth = 18;

  parameter itim_enable = 1;
  parameter itim_width = 2;
  parameter itim_depth = 10;

  parameter dtim_enable = 1;
  parameter dtim_width = 2;
  parameter dtim_depth = 10;

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

  parameter debug_base_addr = 32'h4000000;
  parameter debug_top_addr  = 32'h400C000;

  parameter plic_base_addr = 32'h0C000000;
  parameter plic_top_addr  = 32'h10000000;

endpackage
