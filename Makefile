default: none

export VERILATOR ?= /opt/verilator/bin/verilator
export PYTHON ?= /usr/bin/python3
export SERIAL ?= /dev/ttyUSB0
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export MAXTIME ?= 10000000
export DUMP ?= 0# "1" on, "0" off

simulate:
	sim/run.sh

send:
	serial/transfer.sh

all: generate simulate
