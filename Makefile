default: simulate

export VERILATOR ?= verilator
export VERIBLE ?= verible
export PYTHON ?= python3
export SERIAL ?= /dev/ttyUSB0
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export BENCHMARK ?= benchmark

export QUARTUS_VER ?= 23.1
export QUARTUS_BIN ?= $(HOME)/intelFPGA_lite/$(QUARTUS_VER)std/quartus/bin/
export QUESTA_BIN ?= $(HOME)/intelFPGA_lite/$(QUARTUS_VER)std/questa_fse/bin/

export VIVADO_VER ?=2023.2
export VIVADO_BIN ?= $(HOME)/Xilinx/Vivado/$(VIVADO_VER)/bin

export SRAM_SIZE ?= 0x80000# Altera -> 0x80000, Xilinx -> 0x40000

export RISCV ?= /opt/rv32imfdcb
export ARCH ?= rv32imfdc_zba_zbb_zbc_zbs_zicsr_zifencei
export ABI ?= ilp32d

export MAXTIME ?= 10000000
export DUMP ?= 0# "1" on, "0" off

compile:
	benchmark/riscv-tests.sh
	benchmark/coremark.sh
	benchmark/whetstone.sh
	benchmark/free-rtos.sh
	benchmark/isa.sh
	benchmark/rom.sh

parse:
	check/run.sh

vsim:
	sim/vsim/run.sh

xsim:
	sim/xsim/run.sh

quartus:
	fpga/quartus/run.sh

vivado:
	fpga/vivado/run.sh

program:
	serial/transfer.sh

tool:
	tools/riscv.sh
	tools/verible.sh
	tools/verilator.sh
