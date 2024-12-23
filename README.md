# CPU-MEDIUM

This cpu is 6-stage in-order dual issue superscalar processor with floating point unit.

## SPECIFICATIONS

### Architecture
- RV32-IMFDCB
- Fast multiplication unit
- Slow division unit
- FPU with single and double precision
- Fast and slow option for FDIV and FSQRT instruction
- Branch target cache with bimodal branch predictor
### Memory
- Harvard bus architecture
- Instruction and Data Tightly Integrated Memory
### Peripheral
- UART
- Baudrate 115200
- Start Bit
- Stop Bit
- 8 Data Bits
- No Parity Bit

## TOOLS

The installation scripts of necessary tools are located in directory **tools**. These scripts need **root** permission in order to install packages and tools for simulation and testcase generation.

## USAGE

1. Clone the repository:
```console
git clone --recurse-submodules https://github.com/taneroksuz/cpu-medium.git
```

2. Install necessary tools for compilation and simulation:
```console
make tool
```

3. Compile some benchmarks:
```console
make compile
```

4. Compiled executable files are located in **riscv** and dumped files are located in **dump**. Select an executable and run simulation:
```console
make verilator PROGRAM=coremark
```

5. Run simulation with <u>debug</u> feature:
```console
make verilator DUMP=1
```

6. Run simulation with <u>short period of time</u> (e.g 1us, default 10ms):
```console
make verilator MAXTIME=1000
```

7. The simulation results together with <u>debug</u> informations are located in **sim/verilator/output**.

## BENCHMARKS

### Coremark Benchmark
| Cycles | Iteration/s/MHz | Iteration |
| ------ | --------------- | --------- |
| 192443 |            5.20 |        10 |
