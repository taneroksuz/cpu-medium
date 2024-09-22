package configure;
  timeunit 1ns; timeprecision 1ps;

  // fpga -> 0
  parameter simulation = 1;

  parameter buffer_depth = 4;

  parameter hazard_depth = 4;

  parameter tim_width = 32;
  parameter tim_depth = 2048;

  // xilinx -> 0 altera -> 1
  parameter ram_type = 0;
  parameter ram_depth = 131072;

  parameter pmp_region = 8;

  parameter fpu_enable = 1;

  parameter btac_enable = 1;
  parameter branchtarget_depth = 512;
  parameter branchhistory_depth = 1024;

  parameter rom_base_addr = 32'h00;
  parameter rom_mask_addr = 32'h7F;

  parameter qspi_base_addr = 32'h100000;
  parameter qspi_mask_addr = 32'h0FFFFF;

  parameter uart_tx_base_addr = 32'h1000000;
  parameter uart_tx_mask_addr = 32'h0000003;

  parameter uart_rx_base_addr = 32'h1000004;
  parameter uart_rx_mask_addr = 32'h0000007;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_mask_addr = 32'h000FFFF;

  parameter itim_base_addr = 32'h10000000;
  parameter itim_mask_addr = 32'h000FFFFF;

  parameter dtim_base_addr = 32'h20000000;
  parameter dtim_mask_addr = 32'h000FFFFF;

  parameter ram_base_addr = 32'h80000000;
  parameter ram_mask_addr = 32'h000FFFFF;

  parameter rom_top_addr = 32'h80;

  parameter uart_tx_top_addr = 32'h1000004;

  parameter uart_rx_top_addr = 32'h1000008;

  parameter clint_top_addr = 32'h200C000;

  parameter clic_top_addr = 32'h3005000;

  parameter itim_top_addr = 32'h10080000;

  parameter dtim_top_addr = 32'h20080000;

  parameter ram_top_addr = 32'h80100000;

  parameter clk_freq = 100000000;  // 100MHz
  parameter per_freq = 10000000;  // 10MHz
  parameter rtc_freq = 1000000;  // 1MHz
  parameter baudrate = 115200;

  parameter clk_divider_per = clk_freq / per_freq;
  parameter clk_divider_rtc = clk_freq / rtc_freq;
  parameter clk_divider_bit = clk_freq / baudrate;

endpackage