#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export PYTHON=$4
export OFFSET=$5
export BASEDIR=$6

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/isa
mkdir ${BASEDIR}/build/isa

mkdir ${BASEDIR}/build/isa/elf
mkdir ${BASEDIR}/build/isa/dump
mkdir ${BASEDIR}/build/isa/coe
mkdir ${BASEDIR}/build/isa/dat
mkdir ${BASEDIR}/build/isa/mif
mkdir ${BASEDIR}/build/isa/hex

if [ -d "${BASEDIR}/soft/src/riscv-tests" ]; then
  rm -rf ${BASEDIR}/soft/src/riscv-tests
fi

git clone https://github.com/riscv/riscv-tests.git ${BASEDIR}/soft/src/riscv-tests

cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv32mi/*.S ${BASEDIR}/soft/src/isa/rv32mi/
cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv32si/*.S ${BASEDIR}/soft/src/isa/rv32si/
cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv32ui/*.S ${BASEDIR}/soft/src/isa/rv32ui/
cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv32uc/*.S ${BASEDIR}/soft/src/isa/rv32uc/
cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv32um/*.S ${BASEDIR}/soft/src/isa/rv32um/

cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv64mi/*.S ${BASEDIR}/soft/src/isa/rv64mi/
cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv64si/*.S ${BASEDIR}/soft/src/isa/rv64si/
cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv64ui/*.S ${BASEDIR}/soft/src/isa/rv64ui/
cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv64uc/*.S ${BASEDIR}/soft/src/isa/rv64uc/
cp -r ${BASEDIR}/soft/src/riscv-tests/isa/rv64um/*.S ${BASEDIR}/soft/src/isa/rv64um/

make -f ${BASEDIR}/soft/src/isa/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/isa/elf/rv32*.dump; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/isa
  ${PYTHON} ${ELF2DAT} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/isa
  ${PYTHON} ${ELF2MIF} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/isa
  ${PYTHON} ${ELF2HEX} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/isa
done

shopt -s nullglob
for filename in ${BASEDIR}/build/isa/elf/rv32*.dump; do
  mv ${filename} ${BASEDIR}/build/isa/dump/
done
