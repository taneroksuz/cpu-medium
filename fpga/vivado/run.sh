#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

cd ${BASEDIR}/fpga/vivado

$VIVADO_BIN/vivado -nojournal -mode batch -source synthesis.tcl

$VIVADO_BIN/vivado -nojournal -mode batch -source program.tcl