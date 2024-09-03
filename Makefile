default: simulate

export VERILATOR ?= verilator
export VERIBLE ?= verible
export PYTHON ?= python3
export SERIAL ?= /dev/ttyUSB0
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export BENCHMARK ?= benchmark

export RISCV ?= /opt/rv32imfdcb
export ARCH ?= rv32imfdc_zba_zbb_zbc_zbs_zicsr_zifencei
export ABI ?= ilp32d
export CPU ?= wolv-z7

export MAXTIME ?= 10000000
export DUMP ?= 0# "1" on, "0" off

simulate:
	sim/run.sh

compile:
	benchmark/riscv-tests.sh
	benchmark/coremark.sh
	benchmark/whetstone.sh
	benchmark/free-rtos.sh
	benchmark/isa.sh

parse:
	check/run.sh

program:
	serial/transfer.sh
