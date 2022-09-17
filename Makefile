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
	soft/compile.sh --riscv ${RISCV} --march ${MARCH} --mabi ${MABI} --iter ${ITER} --python ${PYTHON} --offset ${OFFSET} --basedir ${BASEDIR} --aapg ${AAPG} --ovp ${OVP} --csmith ${CSMITH} --csmith_incl ${CSMITH_INCL} --gcc ${GCC} --config ${CONFIG} --program ${PROGRAM}

simulate:
	sim/run.sh --basedir ${BASEDIR} --verilator ${VERILATOR} --systemc ${SYSTEMC} --program ${PROGRAM} --cycles ${CYCLES} --wave ${WAVE}

all: generate simulate
