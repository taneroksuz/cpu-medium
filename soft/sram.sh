#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export ITER=$4
export PYTHON=$5
export OFFSET=$6 # 0x4000
export BASEDIR=$7

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/sram

mkdir ${BASEDIR}/build/sram

mkdir ${BASEDIR}/build/sram/elf
mkdir ${BASEDIR}/build/sram/dump
mkdir ${BASEDIR}/build/sram/coe
mkdir ${BASEDIR}/build/sram/dat
mkdir ${BASEDIR}/build/sram/mif
mkdir ${BASEDIR}/build/sram/hex

make -f ${BASEDIR}/soft/src/sram/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/sram/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/sram
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/sram
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/sram
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/sram
done

shopt -s nullglob
for filename in ${BASEDIR}/build/sram/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/sram/dump/
done
