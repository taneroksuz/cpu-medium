default: simulate

export VERILATOR ?= /opt/verilator/bin/verilator
export PYTHON ?= /usr/bin/python3
export SERIAL ?= /dev/ttyUSB0
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export RISCV ?= /opt/rv32imfcb/bin/riscv32-unknown-elf

export MAXTIME ?= 10000000
export DUMP ?= 0# "1" on, "0" off

simulate:
	sim/run.sh

program:
	serial/transfer.sh
