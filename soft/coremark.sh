#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export ITER=$4
export PYTHON=$5
export OFFSET=$6
export BASEDIR=$7

if [ ! -d "$BASEDIR/soft/src/coremark" ]; then
  git clone https://github.com/eembc/coremark.git $BASEDIR/soft/src/coremark
fi

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/coremark

mkdir ${BASEDIR}/build/coremark

mkdir ${BASEDIR}/build/coremark/elf
mkdir ${BASEDIR}/build/coremark/dump
mkdir ${BASEDIR}/build/coremark/coe
mkdir ${BASEDIR}/build/coremark/dat
mkdir ${BASEDIR}/build/coremark/mif
mkdir ${BASEDIR}/build/coremark/hex

make -f ${BASEDIR}/soft/src/coremark_portme/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/coremark/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/coremark
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/coremark
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/coremark
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/coremark
done

shopt -s nullglob
for filename in ${BASEDIR}/build/coremark/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/coremark/dump/
done
