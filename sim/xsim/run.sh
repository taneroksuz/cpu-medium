#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

rm -rf $BASEDIR/sim/xsim/output/*

if [ ! -d "$BASEDIR/sim/xsim/work" ]; then
  mkdir $BASEDIR/sim/xsim/work
fi

rm -rf $BASEDIR/sim/xsim/work/*

cd $BASEDIR/sim/xsim/work

start=`date +%s`

$XVLOG --sv $BASEDIR/verilog/conf/configure.sv \
            $BASEDIR/verilog/rtl/constants.sv \
            $BASEDIR/verilog/rtl/functions.sv \
            $BASEDIR/fpu/verilog/src/lzc/lzc_wire.sv \
            $BASEDIR/fpu/verilog/src/lzc/lzc_4.sv \
            $BASEDIR/fpu/verilog/src/lzc/lzc_8.sv \
            $BASEDIR/fpu/verilog/src/lzc/lzc_16.sv \
            $BASEDIR/fpu/verilog/src/lzc/lzc_32.sv \
            $BASEDIR/fpu/verilog/src/lzc/lzc_64.sv \
            $BASEDIR/fpu/verilog/src/lzc/lzc_128.sv \
            $BASEDIR/fpu/verilog/src/lzc/lzc_256.sv \
            $BASEDIR/fpu/verilog/src/float/fp_wire.sv \
            $BASEDIR/fpu/verilog/src/float/fp_ext.sv \
            $BASEDIR/fpu/verilog/src/float/fp_cmp.sv \
            $BASEDIR/fpu/verilog/src/float/fp_max.sv \
            $BASEDIR/fpu/verilog/src/float/fp_sgnj.sv \
            $BASEDIR/fpu/verilog/src/float/fp_cvt.sv \
            $BASEDIR/fpu/verilog/src/float/fp_fma.sv \
            $BASEDIR/fpu/verilog/src/float/fp_mac.sv \
            $BASEDIR/fpu/verilog/src/float/fp_fdiv.sv \
            $BASEDIR/fpu/verilog/src/float/fp_rnd.sv \
            $BASEDIR/fpu/verilog/src/float/fp_exe.sv \
            $BASEDIR/fpu/verilog/src/float/fp_unit.sv \
            $BASEDIR/verilog/rtl/wires.sv \
            $BASEDIR/verilog/rtl/bit_alu.sv \
            $BASEDIR/verilog/rtl/bit_clmul.sv \
            $BASEDIR/verilog/rtl/btac.sv \
            $BASEDIR/verilog/rtl/alu.sv \
            $BASEDIR/verilog/rtl/agu.sv \
            $BASEDIR/verilog/rtl/bcu.sv \
            $BASEDIR/verilog/rtl/lsu.sv \
            $BASEDIR/verilog/rtl/csr_alu.sv \
            $BASEDIR/verilog/rtl/mul.sv \
            $BASEDIR/verilog/rtl/div.sv \
            $BASEDIR/verilog/rtl/compress.sv \
            $BASEDIR/verilog/rtl/decoder.sv \
            $BASEDIR/verilog/rtl/register.sv \
            $BASEDIR/verilog/rtl/csr.sv \
            $BASEDIR/verilog/rtl/buffer.sv \
            $BASEDIR/verilog/rtl/hazard.sv \
            $BASEDIR/verilog/rtl/forwarding.sv \
            $BASEDIR/verilog/rtl/fetch_stage.sv \
            $BASEDIR/verilog/rtl/decode_stage.sv \
            $BASEDIR/verilog/rtl/issue_stage.sv \
            $BASEDIR/verilog/rtl/execute_stage.sv \
            $BASEDIR/verilog/rtl/memory_stage.sv \
            $BASEDIR/verilog/rtl/writeback_stage.sv \
            $BASEDIR/verilog/rtl/fpu.sv \
            $BASEDIR/verilog/rtl/arbiter.sv \
            $BASEDIR/verilog/rtl/cdc.sv \
            $BASEDIR/verilog/rtl/clint.sv \
            $BASEDIR/verilog/rtl/tim.sv \
            $BASEDIR/verilog/rtl/cpu.sv \
            $BASEDIR/verilog/rtl/rom.sv \
            $BASEDIR/verilog/rtl/ram.sv \
            $BASEDIR/verilog/rtl/spi.sv \
            $BASEDIR/verilog/rtl/uart_rx.sv \
            $BASEDIR/verilog/rtl/uart_tx.sv \
            $BASEDIR/verilog/rtl/soc.sv \
            $BASEDIR/verilog/tb/testbench.sv

$XELAB -top testbench -snapshot testbench_snapshot

cp $BASEDIR/riscv/$PROGRAM.riscv $BASEDIR/sim/xsim/output/$PROGRAM.riscv

FILE=$BASEDIR/sim/xsim/output/$PROGRAM

${RISCV}/bin/riscv32-unknown-elf-nm -A ${FILE}.riscv | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > ${FILE}.host
${RISCV}/bin/riscv32-unknown-elf-objcopy -O binary ${FILE}.riscv ${FILE}.bin
$PYTHON $BASEDIR/py/bin2dat.py --input ${FILE}.riscv --address 0x0 --offset 0x100000
cp ${FILE}.dat ram.dat
cp ${FILE}.host host.dat
if [ "$DUMP" = "1" ]
then
  $XSIM testbench_snapshot -testplusarg "MAXTIME=$MAXTIME" -testplusarg "REGFILE=${FILE}.reg" -testplusarg "CSRFILE=${FILE}.csr" -testplusarg "MEMFILE=${FILE}.mem" -testplusarg "FREGFILE=${FILE}.freg" -tclbatch $BASEDIR/sim/xsim/run.tcl --wdb ${FILE}.wdb
else
  $XSIM testbench_snapshot -R -testplusarg "MAXTIME=$MAXTIME"
fi

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
