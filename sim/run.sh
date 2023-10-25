#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

cd $BASEDIR/sim/work

start=`date +%s`

$VERILATOR --binary --trace --trace-structs --Wno-UNSIGNED --Wno-UNOPTFLAT --top soc -f $BASEDIR/sim/files.f 2>&1 > /dev/null

if [ "$DUMP" = "1" ]
then
  obj_dir/Vsoc +MAXTIME=$MAXTIME +REGFILE=$PROGRAM.txt +FILENAME=$PROGRAM.vcd
else
  obj_dir/Vsoc +MAXTIME=$MAXTIME
fi

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
