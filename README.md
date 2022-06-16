# RISCV Z7 CPU #

RISCV Z7 CPU supports currently only riscv32-imfdcb instruction set architecture and is implemented with 5-stage pipeline and Harvard bus architecture. It contains dynamic branch prediction (gshare), instruction and data tightly integrated memory together with fetch and store buffer.

## Dhrystone Benchmark ##
| Cycles | Dhrystone/s/MHz | DMIPS/s/MHz | Iteration |
| ------ | --------------- | ----------- | --------- |
|    437 |            2286 |        1.30 |      1000 |

## Coremark Benchmark ##
| Cycles | Iteration/s/MHz | Iteration |
| ------ | --------------- | --------- |
| 384699 |            2.60 |        10 |

Documentation will be expanded in the future.
