package configure;
  timeunit 1ns; timeprecision 1ps;

  parameter hardware = 0;

  parameter buffer_depth = 4;

  parameter hazard_depth = 4;

  parameter tim_width = 32;
  parameter tim_depth = 2048;

  parameter sram_depth = 131072;

  parameter ram_type = 0;

  parameter pmp_region = 8;

  parameter fpu_enable = 1;

  parameter btac_enable = 1;
  parameter branchtarget_depth = 512;
  parameter branchhistory_depth = 1024;

  parameter rom_base_addr = 32'h00;
  parameter rom_mask_addr = 32'h7F;

  parameter spi_base_addr = 32'h100000;
  parameter spi_mask_addr = 32'h0FFFFF;

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

  parameter sram_base_addr = 32'h80000000;
  parameter sram_mask_addr = 32'h000FFFFF;

  parameter cpu_freq = 1000000000;  // 1GHz
  parameter per_freq = 200000000;   // 200MHz
  parameter rtc_freq = 1000000;     // 1MHz
  parameter baudrate = 115200;

  parameter clk_divider_per = cpu_freq / per_freq;
  parameter clk_divider_rtc = cpu_freq / rtc_freq;
  parameter clk_divider_bit = cpu_freq / baudrate;

endpackage
