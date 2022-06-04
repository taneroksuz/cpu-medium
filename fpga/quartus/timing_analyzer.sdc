#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports clk]

create_generated_clock \
  -divide_by 2 \
  -source [get_ports {clk}] \
  -name clk_pll \
  [get_pins {clk_pll|q}]

create_generated_clock \
  -divide_by 1525 \
  -source [get_ports {clk}] \
  -name rtc \
  [get_pins {rtc|q}]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks
derive_clock_uncertainty
