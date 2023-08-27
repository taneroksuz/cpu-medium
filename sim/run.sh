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

declare -A benchmark=([bootloader]=1 [coremark]=1 [csmith]=1 [dhrystone]=1 [sram]=1 [timer]=1 [whetstone]=1)
declare -A verification=([compliance]=1 [isa]=1)

start=`date +%s`

if [ "$TOOL" = 'verilator' ]
then
  $VERILATOR --binary --trace --trace-structs --Wno-UNSIGNED --Wno-UNOPTFLAT --top soc -f $BASEDIR/sim/files.f 2>&1 > /dev/null
elif [ "$TOOL" = 'vivado' ]
then
  $XVLOG -sv -f $BASEDIR/sim/files.f 2>&1 > /dev/null
  $XELAB -top soc -snapshot soc_snapshot 2>&1 > /dev/null
elif [ "$TOOL" = 'questa' ]
then
  $VLOG -sv -svinputport=relaxed -f $BASEDIR/sim/files.f 2>&1 > /dev/null
fi

if [[ -n "${benchmark[$PROGRAM]}" ]]
then
  cp $BASEDIR/build/$PROGRAM/dat/$PROGRAM.dat bram.dat
  cp $BASEDIR/build/$PROGRAM/elf/$PROGRAM.host host.dat
  if [ "$TOOL" = 'verilator' ]
  then
    if [ "$DUMP" = 'on' ]
    then
      obj_dir/Vsoc +MAXTIME=$MAXTIME +REGFILE=$PROGRAM.txt +FILENAME=$PROGRAM.vcd
    else
      obj_dir/Vsoc +MAXTIME=$MAXTIME
    fi
  elif [ "$TOOL" = 'vivado' ]
  then
    if [ "$DUMP" = 'on' ]
    then
      $XSIM soc_snapshot --tclbatch $BASEDIR/sim/xsim_cfg.tcl --wdb $PROGRAM.wdb --testplusarg REGFILE=$PROGRAM.txt --testplusarg MAXTIME=$MAXTIME
    else
      $XSIM soc_snapshot -R --testplusarg MAXTIME=$MAXTIME
    fi
  elif [ "$TOOL" = 'questa' ]
  then
    if [ "$DUMP" = 'on' ]
    then
      $VSIM -c soc -do $BASEDIR/sim/vsim_cfg.do +MAXTIME=$MAXTIME +REGFILE=$PROGRAM.txt -wlf $PROGRAM.wlf -voptargs="\+acc"
    else
      $VSIM -c soc -do "run -all" +MAXTIME=$MAXTIME
    fi
  fi
elif [[ -n "${verification[$PROGRAM]}" ]]
then
  for filename in $BASEDIR/build/$PROGRAM/dat/*.dat; do
    filename=${filename##*/}
    filename=${filename%.dat}
    echo -e "${BLUE}${filename}${NC}"
    cp $BASEDIR/build/$PROGRAM/dat/$filename.dat bram.dat
    cp $BASEDIR/build/$PROGRAM/elf/$filename.host host.dat
    if [ "$TOOL" = 'verilator' ]
    then
      if [ "$DUMP" = 'on' ]
      then
        obj_dir/Vsoc +MAXTIME=$MAXTIME +REGFILE=$filename.txt +FILENAME=$filename.vcd
      else
        obj_dir/Vsoc +MAXTIME=$MAXTIME
      fi
    elif [ "$TOOL" = 'vivado' ]
    then
      if [ "$DUMP" = 'on' ]
      then
        $XSIM soc_snapshot --tclbatch $BASEDIR/sim/xsim_cfg.tcl --wdb $filename.wdb --testplusarg REGFILE=$filename.txt --testplusarg MAXTIME=$MAXTIME
      else
        $XSIM soc_snapshot -R --testplusarg MAXTIME=$MAXTIME
      fi
    elif [ "$TOOL" = 'questa' ]
    then
      if [ "$DUMP" = 'on' ]
      then
        $VSIM -c soc -do $BASEDIR/sim/vsim_cfg.do +MAXTIME=$MAXTIME +REGFILE=$filename.txt -wlf $filename.wlf -voptargs="\+acc"
      else
        $VSIM -c soc -do "run -all" +MAXTIME=$MAXTIME
      fi
    fi
  done
else
  subpath=${PROGRAM%/dat*}
  filename=${PROGRAM##*/}
  filename=${filename%.dat}
  cp $BASEDIR/$subpath/dat/$filename.dat bram.dat
  cp $BASEDIR/$subpath/elf/$filename.host host.dat
  if [ "$TOOL" = 'verilator' ]
  then
    if [ "$DUMP" = 'on' ]
    then
      obj_dir/Vsoc +MAXTIME=$MAXTIME +REGFILE=$filename.txt +FILENAME=$filename.vcd
    else
      obj_dir/Vsoc +MAXTIME=$MAXTIME
    fi
  elif [ "$TOOL" = 'vivado' ]
  then
    if [ "$DUMP" = 'on' ]
    then
      $XSIM soc_snapshot --tclbatch $BASEDIR/sim/xsim_cfg.tcl --wdb $filename.wdb --testplusarg REGFILE=$filename.txt --testplusarg MAXTIME=$MAXTIME
    else
      $XSIM soc_snapshot -R --testplusarg MAXTIME=$MAXTIME
    fi
  elif [ "$TOOL" = 'questa' ]
  then
    if [ "$DUMP" = 'on' ]
    then
      $VSIM -c soc -do $BASEDIR/sim/vsim_cfg.do +MAXTIME=$MAXTIME +REGFILE=$filename.txt -wlf $filename.wlf -voptargs="\+acc"
    else
      $VSIM -c soc -do "run -all" +MAXTIME=$MAXTIME
    fi
  fi
fi

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
