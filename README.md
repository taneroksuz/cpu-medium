# Wolv Z7 CPU core #

Wolv Z7 CPU core supports currently only riscv32-imfb instruction set architecture and is implemented with 6-stage in-order superscalar pipeline and Harvard bus architecture. It contains branch target address cache, instruction and data tightly integrated memory.

## Dhrystone Benchmark ##
| Cycles | Dhrystone/s/MHz | DMIPS/s/MHz | Iteration |
| ------ | --------------- | ----------- | --------- |
|    255 |            3917 |        2.23 |      1000 |

## Coremark Benchmark ##
| Cycles | Iteration/s/MHz | Iteration |
| ------ | --------------- | --------- |
| 268021 |            3.73 |        10 |

Documentation will be expanded in the future.
