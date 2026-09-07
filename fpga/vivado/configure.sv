package configure;
  timeunit 1ns; timeprecision 1ps;

  localparam HARDWARE = 1;

  localparam BUFFER_DEPTH = 4;

  localparam HAZARD_DEPTH = 4;

  localparam TIM_WIDTH = 32;
  localparam TIM_DEPTH = 1024;

  localparam RAM_DEPTH = 1;

  localparam BTAC_ENABLE = 1;
  localparam BTB_DEPTH   = 512;
  localparam BHT_DEPTH   = 1024;

  localparam ROM_BASE = 32'h00000000;
  localparam ROM_MASK = 32'hFFFFFF00;

  localparam SPI_BASE = 32'h00100000;
  localparam SPI_MASK = 32'hFFF00000;

  localparam UART_TX_BASE = 32'h01000000;
  localparam UART_TX_MASK = 32'hFFFFFFF0;

  localparam UART_RX_BASE = 32'h01000010;
  localparam UART_RX_MASK = 32'hFFFFFFF0;

  localparam CLINT_BASE = 32'h02000000;
  localparam CLINT_MASK = 32'hFFFF0000;

  localparam ITIM_BASE = 32'h10000000;
  localparam ITIM_MASK = 32'hFFF00000;

  localparam DTIM_BASE = 32'h20000000;
  localparam DTIM_MASK = 32'hFFF00000;

  localparam RAM_BASE = 32'h80000000;
  localparam RAM_MASK = 32'hFFF00000;

  localparam SYS_FREQ = 100000000;  // 100MHz

  localparam CPU_FREQ = 25000000;  // 25MHz
  localparam PER_FREQ = 5000000;   // 5MHz
  localparam RTC_FREQ = 1000000;   // 1MHz
  localparam BAUDRATE = 115200;

  localparam CLK_DIVIDER_CPU = SYS_FREQ / CPU_FREQ;
  localparam CLK_DIVIDER_PER = SYS_FREQ / PER_FREQ;
  localparam CLK_DIVIDER_RTC = CPU_FREQ / RTC_FREQ;
  localparam CLK_DIVIDER_BIT = CPU_FREQ / BAUDRATE;

endpackage
