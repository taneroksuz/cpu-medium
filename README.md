# Wolv Z7 CPU core #

Wolv Z7 CPU core supports currently only riscv32-imfcb instruction set architecture and is implemented with 5-stage pipeline and Harvard bus architecture. It contains dynamic branch prediction (gshare), instruction and data tightly integrated memory.

## Dhrystone Benchmark ##
| Cycles | Dhrystone/s/MHz | DMIPS/s/MHz | Iteration |
| ------ | --------------- | ----------- | --------- |
|    411 |            2431 |        1.38 |      1000 |

## Coremark Benchmark ##
| Cycles | Iteration/s/MHz | Iteration |
| ------ | --------------- | --------- |
| 333325 |            3.00 |        10 |

Documentation will be expanded in the future.
