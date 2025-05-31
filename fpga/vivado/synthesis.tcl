read_verilog -sv configure.sv
read_verilog -sv ../../verilog/rtl/constants.sv
read_verilog -sv ../../verilog/rtl/functions.sv
read_verilog -sv ../../verilog/rtl/wires.sv
read_verilog -sv ../../verilog/rtl/bit_alu.sv
read_verilog -sv ../../verilog/rtl/bit_clmul.sv
read_verilog -sv ../../verilog/rtl/btac.sv
read_verilog -sv ../../verilog/rtl/alu.sv
read_verilog -sv ../../verilog/rtl/agu.sv
read_verilog -sv ../../verilog/rtl/bcu.sv
read_verilog -sv ../../verilog/rtl/lsu.sv
read_verilog -sv ../../verilog/rtl/csr_alu.sv
read_verilog -sv ../../verilog/rtl/mul.sv
read_verilog -sv ../../verilog/rtl/div.sv
read_verilog -sv ../../verilog/rtl/compress.sv
read_verilog -sv ../../verilog/rtl/decoder.sv
read_verilog -sv ../../verilog/rtl/register.sv
read_verilog -sv ../../verilog/rtl/csr.sv
read_verilog -sv ../../verilog/rtl/buffer.sv
read_verilog -sv ../../verilog/rtl/hazard.sv
read_verilog -sv ../../verilog/rtl/forwarding.sv
read_verilog -sv ../../verilog/rtl/fetch_stage.sv
read_verilog -sv ../../verilog/rtl/decode_stage.sv
read_verilog -sv ../../verilog/rtl/issue_stage.sv
read_verilog -sv ../../verilog/rtl/execute_stage.sv
read_verilog -sv ../../verilog/rtl/memory_stage.sv
read_verilog -sv ../../verilog/rtl/writeback_stage.sv
read_verilog -sv ../../verilog/rtl/arbiter.sv
read_verilog -sv ../../verilog/rtl/clint.sv
read_verilog -sv ../../verilog/rtl/tim.sv
read_verilog -sv ../../verilog/rtl/cpu.sv
read_verilog -sv ../../verilog/rtl/sram.sv
read_verilog -sv ../../verilog/rtl/spi.sv
read_verilog -sv ../../verilog/rtl/uart_rx.sv
read_verilog -sv ../../verilog/rtl/uart_tx.sv
read_verilog -sv rom.sv
read_verilog -sv ../../verilog/rtl/soc.sv
read_verilog -sv sram_memory.sv
read_verilog pll_clk_wiz.v
read_verilog pll.v
read_verilog -sv top.sv

read_xdc top.xdc

set Cmd "synth_design -part xc7a100tcsg324-1 -top top "
append Cmd [join $argv]
eval $Cmd

opt_design
place_design
route_design

report_utilization
report_timing
write_bitstream -force top.bit