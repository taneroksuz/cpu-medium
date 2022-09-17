default: none

VERILATOR ?= /opt/verilator/bin/verilator
SYSTEMC ?= /opt/systemc
RISCV ?= /opt/riscv/bin/riscv32-unknown-elf-
MARCH ?= rv32imc_zba_zbb_zbc_zbs_zicsr_zifencei
MABI ?= ilp32
ITER ?= 10
CSMITH ?= /opt/csmith
CSMITH_INCL ?= $(shell ls -d $(CSMITH)/include/csmith-* | head -n1)
GCC ?= /usr/bin/gcc
PYTHON ?= /usr/bin/python3
BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OVP ?= riscv-ovpsim-plus-bitmanip-tests.zip
OFFSET ?= 0x100000 # Number of dwords in blockram (address range is OFFSET * 8)
PROGRAM ?= dhrystone
AAPG ?= aapg
CONFIG ?= integer
CYCLES ?= 10000000000
FPGA ?= quartus # tb vivado quartus
WAVE ?= off # "on" for saving dump file

generate:
	@if [ ${TEST} = "isa" ]; \
	then \
		soft/isa.sh ${RISCV} ${MARCH} ${MABI} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "compliance" ]; \
	then \
		soft/compliance.sh ${RISCV} ${MARCH} ${MABI} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "ovp" ]; \
	then \
		soft/ovp.sh ${RISCV} ${MARCH} ${MABI} ${XLEN} ${PYTHON} ${OFFSET} ${BASEDIR} ${OVP}; \
	elif [ ${TEST} = "dhrystone" ]; \
	then \
		soft/dhrystone.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "coremark" ]; \
	then \
		soft/coremark.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "csmith" ]; \
	then \
		soft/csmith.sh ${RISCV} ${MARCH} ${MABI} ${GCC} ${CSMITH} ${CSMITH_INCL} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "uart" ]; \
	then \
		soft/uart.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "timer" ]; \
	then \
		soft/timer.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "sram" ]; \
	then \
		soft/sram.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "aapg" ]; \
	then \
		soft/aapg.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR} ${AAPG} ${CONFIG}; \
	fi

simulate:
	sim/run.sh --basedir ${BASEDIR} --verilator ${VERILATOR} --systemc ${SYSTEMC} --program ${PROGRAM} --cycles ${CYCLES} --wave ${WAVE}

all: generate simulate
