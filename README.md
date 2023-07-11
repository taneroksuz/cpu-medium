# Wolv Z7 CPU core #

Wolv Z7 CPU core supports currently only riscv32-imfb instruction set architecture and is implemented with 6-stage in-order superscalar pipeline and Harvard bus architecture. It contains branch target address cache with bimodal branch predictor, instruction and data tightly integrated memory.

## Dhrystone Benchmark ##
| Cycles | Dhrystone/s/MHz | DMIPS/s/MHz | Iteration |
| ------ | --------------- | ----------- | --------- |
|    210 |            4753 |        2.71 |      1000 |

## Coremark Benchmark ##
| Cycles | Iteration/s/MHz | Iteration |
| ------ | --------------- | --------- |
| 257341 |            3.89 |        10 |

Documentation will be expanded in the future.
