#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 8 [get_ports CLOCK_125_p]
create_clock -period 20 [get_ports CLOCK_50_B5B]
create_clock -period 20 [get_ports CLOCK_50_B6A]
create_clock -period 20 [get_ports CLOCK_50_B7A]
create_clock -period 20 [get_ports CLOCK_50_B8A]

create_generated_clock -divide_by 10 -source [get_ports CLOCK_50_B5B] -name clock [get_registers clk_div:clk_div_cpu_comp|clock_per]
create_generated_clock -divide_by 10 -source [get_ports CLOCK_50_B5B] -name clock_per [get_registers clk_div:clk_div_per_comp|clock_per]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



