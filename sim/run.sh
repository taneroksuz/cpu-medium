#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

rm -rf $BASEDIR/output/*

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

cd $BASEDIR/sim/work

start=`date +%s`

$VERILATOR --binary --trace --trace-structs --Wno-UNSIGNED --Wno-UNOPTFLAT --top soc -f $BASEDIR/sim/files.f 2>&1 > /dev/null

for FILE in $BASEDIR/input/*; do
  $RISCV-nm -A ${FILE%.*} | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > ${FILE%.*}.host
  $RISCV-objcopy -O binary ${FILE%.*} ${FILE%.*}.bin
  $PYTHON $BASEDIR/py/bin2dat.py --input $FILE --address 0x0 --offset 0x100000
  cp ${FILE%.*}.dat bram.dat
  cp ${FILE%.*}.host host.dat
  if [ "$DUMP" = "1" ]
  then
    obj_dir/Vsoc +MAXTIME=$MAXTIME +REGFILE=${FILE%.*}.txt +FILENAME=${FILE%.*}.vcd
    cp ${FILE%.*}.txt $BASEDIR/output/.
    cp ${FILE%.*}.vcd $BASEDIR/output/.
  else
    obj_dir/Vsoc +MAXTIME=$MAXTIME
  fi
done

rm -rf $BASEDIR/input/*

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
