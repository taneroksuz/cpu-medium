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

rm -rf ${BASEDIR}/build/timer

mkdir ${BASEDIR}/build/timer

mkdir ${BASEDIR}/build/timer/elf
mkdir ${BASEDIR}/build/timer/dump
mkdir ${BASEDIR}/build/timer/coe
mkdir ${BASEDIR}/build/timer/dat
mkdir ${BASEDIR}/build/timer/mif
mkdir ${BASEDIR}/build/timer/hex

make -f ${BASEDIR}/soft/src/timer/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/timer/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/timer
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/timer
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/timer
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/timer
done

shopt -s nullglob
for filename in ${BASEDIR}/build/timer/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/timer/dump/
done
