#!/bin/bash
set -e

start=`date +%s`

${RISCV}/bin/riscv32-unknown-elf-objcopy -O binary $BASEDIR/riscv/$PROGRAM.riscv $BASEDIR/serial/output/$PROGRAM.bin
$PYTHON $BASEDIR/serial/transfer.py $SERIAL $BASEDIR/serial/output/$PROGRAM.bin $SRAM_SIZE
rm $BASEDIR/serial/output/$PROGRAM.bin

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
