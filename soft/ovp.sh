#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export PYTHON=$4
export OFFSET=$5
export BASEDIR=$6
export OVP=$7

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/ovp
mkdir ${BASEDIR}/build/ovp

mkdir ${BASEDIR}/build/ovp/elf
mkdir ${BASEDIR}/build/ovp/dump
mkdir ${BASEDIR}/build/ovp/coe
mkdir ${BASEDIR}/build/ovp/dat
mkdir ${BASEDIR}/build/ovp/mif
mkdir ${BASEDIR}/build/ovp/hex
mkdir ${BASEDIR}/build/ovp/ref

if [ -d "${BASEDIR}/soft/src/riscv-ovp" ]; then
  rm -rf ${BASEDIR}/soft/src/riscv-ovp
fi

if [ ! -f "${OVP}" ]; then
  echo "${OVP} not exist"
  exit
fi

unzip ${OVP} -d ${BASEDIR}/soft/src/riscv-ovp

cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/env/*.h ${BASEDIR}/soft/src/ovp/env/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/C/src/* ${BASEDIR}/soft/src/ovp/asm/rv32c/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/I/src/* ${BASEDIR}/soft/src/ovp/asm/rv32i/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/M/src/* ${BASEDIR}/soft/src/ovp/asm/rv32m/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/Zba/src/* ${BASEDIR}/soft/src/ovp/asm/rv32b/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/Zbb/src/* ${BASEDIR}/soft/src/ovp/asm/rv32b/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/Zbc/src/* ${BASEDIR}/soft/src/ovp/asm/rv32b/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/Zbs/src/* ${BASEDIR}/soft/src/ovp/asm/rv32b/

cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/C/references/* ${BASEDIR}/soft/src/ovp/ref/rv32c/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/I/references/* ${BASEDIR}/soft/src/ovp/ref/rv32i/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/M/references/* ${BASEDIR}/soft/src/ovp/ref/rv32m/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/Zba/references/* ${BASEDIR}/soft/src/ovp/ref/rv32b/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/Zbb/references/* ${BASEDIR}/soft/src/ovp/ref/rv32b/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/Zbc/references/* ${BASEDIR}/soft/src/ovp/ref/rv32b/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv32i_m/Zbs/references/* ${BASEDIR}/soft/src/ovp/ref/rv32b/

for path in ${BASEDIR}/soft/src/ovp/ref/*; do
  dirname=$(basename $path)
  prefix="${dirname}-"
  for file in $path/*.reference_output; do
    cp $file ${BASEDIR}/build/ovp/ref/${prefix}$(basename $file)
  done
done

make -f ${BASEDIR}/soft/src/ovp/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/ovp/elf/rv32*.dump; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/ovp
  ${PYTHON} ${ELF2DAT} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/ovp
  ${PYTHON} ${ELF2MIF} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/ovp
  ${PYTHON} ${ELF2HEX} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/ovp
done

shopt -s nullglob
for filename in ${BASEDIR}/build/ovp/elf/rv32*.dump; do
  mv ${filename} ${BASEDIR}/build/ovp/dump/
done
