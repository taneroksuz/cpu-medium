# Wolv Z7 CPU core #

Wolv Z7 CPU core supports currently only riscv32-imfcb instruction set architecture and is implemented with 5-stage pipeline and Harvard bus architecture. It contains dynamic branch prediction (gshare), instruction and data tightly integrated memory together with fetch and store buffer.

## Dhrystone Benchmark ##
| Cycles | Dhrystone/s/MHz | DMIPS/s/MHz | Iteration |
| ------ | --------------- | ----------- | --------- |
|    432 |            2313 |        1.32 |      1000 |

## Coremark Benchmark ##
| Cycles | Iteration/s/MHz | Iteration |
| ------ | --------------- | --------- |
| 355861 |            2.81 |        10 |

Documentation will be expanded in the future.
