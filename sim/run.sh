#!/bin/bash
set -e

while [[ $# -gt 0 ]]; do
  case $1 in
    --basedir) 
      DIR="$2"
      shift
      shift
      ;;
    --verilator)
      VERILATOR="$2"
      shift
      shift
      ;;
    --systemc)
      SYSTEMC="$2"
      shift
      shift
      ;;
    --program)
      PROGRAM="$2"
      shift
      shift
      ;;
    --cycles)
      CYCLES="$2"
      shift
      shift
      ;;
    --wave)
      WAVE="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown commandline arguments: $1 -> $2"
      exit 1
  esac
done

if [ ! -d "$DIR/sim/work" ]; then
  mkdir $DIR/sim/work
fi

rm -rf $DIR/sim/work/*

export SYSTEMC_LIBDIR=$SYSTEMC/lib-linux64/
export SYSTEMC_INCLUDE=$SYSTEMC/include/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC/lib-linux64/

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

cd $DIR/sim/work

start=`date +%s`
if [ "$WAVE" = 'on' ]
then
	${VERILATOR} --sc -Wno-UNOPTFLAT -Wno-UNSIGNED --trace -trace-max-array 128 --trace-structs -f ${DIR}/sim/files.f --top-module soc --exe ${DIR}/verilog/tb/soc.cpp
	make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
  if [ "$PROGRAM" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat bram.dat
    cp $DIR/build/dhrystone/elf/dhrystone.host host.dat
  	obj_dir/Vsoc $CYCLES dhrystone 2> /dev/null
  elif [ "$PROGRAM" = 'whetstone' ]
  then
    cp $DIR/build/whetstone/dat/whetstone.dat bram.dat
    cp $DIR/build/whetstone/elf/whetstone.host host.dat
  	obj_dir/Vsoc $CYCLES whetstone 2> /dev/null
  elif [ "$PROGRAM" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat bram.dat
    cp $DIR/build/coremark/elf/coremark.host host.dat
  	obj_dir/Vsoc $CYCLES coremark 2> /dev/null
  elif [ "$PROGRAM" = 'aapg' ]
  then
    cp $DIR/build/aapg/dat/aapg.dat bram.dat
    cp $DIR/build/aapg/elf/aapg.host host.dat
  	obj_dir/Vsoc $CYCLES aapg 2> /dev/null
  elif [ "$PROGRAM" = 'riscv-dv' ]
  then
    cp $DIR/build/riscv-dv/dat/riscv-dv.dat bram.dat
    cp $DIR/build/riscv-dv/elf/riscv-dv.host host.dat
  	obj_dir/Vsoc $CYCLES riscv-dv 2> /dev/null
  elif [ "$PROGRAM" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat bram.dat
    cp $DIR/build/csmith/elf/csmith.host host.dat
  	obj_dir/Vsoc $CYCLES csmith 2> /dev/null
  elif [ "$PROGRAM" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat bram.dat
    cp $DIR/build/torture/elf/torture.host host.dat
  	obj_dir/Vsoc $CYCLES torture 2> /dev/null
  elif [ "$PROGRAM" = 'uart' ]
  then
    cp $DIR/build/uart/dat/uart.dat bram.dat
    cp $DIR/build/uart/elf/uart.host host.dat
  	obj_dir/Vsoc $CYCLES uart 2> /dev/null
  elif [ "$PROGRAM" = 'timer' ]
  then
    cp $DIR/build/timer/dat/timer.dat bram.dat
    cp $DIR/build/timer/elf/timer.host host.dat
  	obj_dir/Vsoc $CYCLES timer 2> /dev/null
  elif [ "$PROGRAM" = 'sram' ]
  then
    cp $DIR/build/sram/dat/sram.dat bram.dat
    cp $DIR/build/sram/elf/sram.host host.dat
  	obj_dir/Vsoc $CYCLES sram 2> /dev/null
  elif [ "$PROGRAM" = 'compliance' ]
  then
    for filename in $DIR/build/compliance/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/compliance/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
    done
  elif [ "$PROGRAM" = 'ovp' ]
  then
    for filename in $DIR/build/ovp/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/ovp/elf/${filename}.host host.dat
      cp $DIR/build/ovp/elf/${filename}.begin_signature begin_signature.dat
      cp $DIR/build/ovp/elf/${filename}.end_signature end_signature.dat
      cp $DIR/build/ovp/ref/${filename}.reference_output reference.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
      if [ "$(diff --color reference.dat signature.dat)" != "" ]
      then
        echo "${red}RESULTS NOT OK${reset}"
      else
        echo "${green}RESULTS OK${reset}"
      fi
    done
  elif [ "$PROGRAM" = 'isa' ]
  then
    for filename in $DIR/build/isa/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/isa/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
    done
  else
    cp $DIR/$PROGRAM bram.dat
    filename="$PROGRAM"
    dirname="$PROGRAM"
    filename=${filename##*/}
    filename=${filename%.dat}
    subpath=${dirname%/dat*}
    cp $DIR/${subpath}/elf/${filename}.host host.dat
    if [ -e $DIR/${subpath}/elf/${filename}.begin_signature ]
    then
      cp $DIR/${subpath}/elf/${filename}.begin_signature begin_signature.dat
    fi
    if [ -e $DIR/${subpath}/elf/${filename}.end_signature ]
    then
      cp $DIR/${subpath}/elf/${filename}.end_signature end_signature.dat
    fi
    if [ -e $DIR/${subpath}/ref/${filename}.reference_output ]
    then
      cp $DIR/${subpath}/ref/${filename}.reference_output reference.dat
    fi
    obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
    if [ -f "reference.dat" ]
    then
      if [ "$(diff --color reference.dat signature.dat)" != "" ]
      then
        echo "${red}RESULTS NOT OK${reset}"
      else
        echo "${green}RESULTS OK${reset}"
      fi
    fi
  fi
else
	${VERILATOR} --sc -Wno-UNOPTFLAT -Wno-UNSIGNED -f ${DIR}/sim/files.f --top-module soc --exe ${DIR}/verilog/tb/soc.cpp
	make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
  if [ "$PROGRAM" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat bram.dat
    cp $DIR/build/dhrystone/elf/dhrystone.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'whetstone' ]
  then
    cp $DIR/build/whetstone/dat/whetstone.dat bram.dat
    cp $DIR/build/whetstone/elf/whetstone.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat bram.dat
    cp $DIR/build/coremark/elf/coremark.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'aapg' ]
  then
    cp $DIR/build/aapg/dat/aapg.dat bram.dat
    cp $DIR/build/aapg/elf/aapg.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'riscv-dv' ]
  then
    cp $DIR/build/riscv-dv/dat/riscv-dv.dat bram.dat
    cp $DIR/build/riscv-dv/elf/riscv-dv.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat bram.dat
    cp $DIR/build/csmith/elf/csmith.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat bram.dat
    cp $DIR/build/torture/elf/torture.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'uart' ]
  then
    cp $DIR/build/uart/dat/uart.dat bram.dat
    cp $DIR/build/uart/elf/uart.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'timer' ]
  then
    cp $DIR/build/timer/dat/timer.dat bram.dat
    cp $DIR/build/timer/elf/timer.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'sram' ]
  then
    cp $DIR/build/sram/dat/sram.dat bram.dat
    cp $DIR/build/sram/elf/sram.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'compliance' ]
  then
    for filename in $DIR/build/compliance/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/compliance/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES 2> /dev/null
    done
  elif [ "$PROGRAM" = 'ovp' ]
  then
    for filename in $DIR/build/ovp/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/ovp/elf/${filename}.host host.dat
      cp $DIR/build/ovp/elf/${filename}.begin_signature begin_signature.dat
      cp $DIR/build/ovp/elf/${filename}.end_signature end_signature.dat
      cp $DIR/build/ovp/ref/${filename}.reference_output reference.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES 2> /dev/null
      if [ "$(diff --color reference.dat signature.dat)" != "" ]
      then
        echo "${red}RESULTS NOT OK${reset}"
      else
        echo "${green}RESULTS OK${reset}"
      fi
    done
  elif [ "$PROGRAM" = 'isa' ]
  then
    for filename in $DIR/build/isa/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/isa/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES 2> /dev/null
    done
  else
    cp $DIR/$PROGRAM bram.dat
    filename="$PROGRAM"
    dirname="$PROGRAM"
    filename=${filename##*/}
    filename=${filename%.dat}
    subpath=${dirname%/dat*}
    cp $DIR/${subpath}/elf/${filename}.host host.dat
    if [ -e $DIR/${subpath}/elf/${filename}.begin_signature ]
    then
      cp $DIR/${subpath}/elf/${filename}.begin_signature begin_signature.dat
    fi
    if [ -e $DIR/${subpath}/elf/${filename}.end_signature ]
    then
      cp $DIR/${subpath}/elf/${filename}.end_signature end_signature.dat
    fi
    if [ -e $DIR/${subpath}/ref/${filename}.reference_output ]
    then
      cp $DIR/${subpath}/ref/${filename}.reference_output reference.dat
    fi
    obj_dir/Vsoc $CYCLES 2> /dev/null
    if [ -f "reference.dat" ]
    then
      if [ "$(diff --color reference.dat signature.dat)" != "" ]
      then
        echo "${red}RESULTS NOT OK${reset}"
      else
        echo "${green}RESULTS OK${reset}"
      fi
    fi
  fi
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
