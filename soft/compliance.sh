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

rm -rf ${BASEDIR}/build/compliance
mkdir ${BASEDIR}/build/compliance

mkdir ${BASEDIR}/build/compliance/elf
mkdir ${BASEDIR}/build/compliance/dump
mkdir ${BASEDIR}/build/compliance/coe
mkdir ${BASEDIR}/build/compliance/dat
mkdir ${BASEDIR}/build/compliance/mif
mkdir ${BASEDIR}/build/compliance/hex
mkdir ${BASEDIR}/build/compliance/ref

if [ -d "${BASEDIR}/soft/src/riscv-compliance" ]; then
  rm -rf ${BASEDIR}/soft/src/riscv-compliance
fi

git clone https://github.com/riscv/riscv-compliance.git ${BASEDIR}/soft/src/riscv-compliance

cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/env/*.h ${BASEDIR}/soft/src/compliance/env/

cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/C/src/* ${BASEDIR}/soft/src/compliance/asm/rv32c/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/I/src/* ${BASEDIR}/soft/src/compliance/asm/rv32i/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv64i_m/K_unratified/src/* ${BASEDIR}/soft/src/compliance/asm/rv32b/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/M/src/* ${BASEDIR}/soft/src/compliance/asm/rv32m/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/Zifencei/src/* ${BASEDIR}/soft/src/compliance/asm/rv32z/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/privilege/src/* ${BASEDIR}/soft/src/compliance/asm/rv32p/

cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/C/references/* ${BASEDIR}/soft/src/compliance/ref/rv32c/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/I/references/* ${BASEDIR}/soft/src/compliance/ref/rv32i/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv64i_m/K_unratified/references/* ${BASEDIR}/soft/src/compliance/ref/rv32b/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/M/references/* ${BASEDIR}/soft/src/compliance/ref/rv32m/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/Zifencei/references/* ${BASEDIR}/soft/src/compliance/ref/rv32z/
cp -r ${BASEDIR}/soft/src/riscv-compliance/riscv-test-suite/rv32i_m/privilege/references/* ${BASEDIR}/soft/src/compliance/ref/rv32p/

for path in ${BASEDIR}/soft/src/compliance/ref/*; do
  dirname=$(basename $path)
  prefix="${dirname}-"
  for file in $path/*.reference_output; do
    cp $file ${BASEDIR}/build/compliance/ref/${prefix}$(basename $file)
  done
done

make -f ${BASEDIR}/soft/src/compliance/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/compliance/elf/rv32*.dump; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/compliance
  ${PYTHON} ${ELF2DAT} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/compliance
  ${PYTHON} ${ELF2MIF} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/compliance
  ${PYTHON} ${ELF2HEX} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/compliance
done

shopt -s nullglob
for filename in ${BASEDIR}/build/compliance/elf/rv32*.dump; do
  mv ${filename} ${BASEDIR}/build/compliance/dump/
done
