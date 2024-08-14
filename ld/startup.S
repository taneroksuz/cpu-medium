# See LICENSE for license details.

#include "encoding.h"

#ifdef __riscv64
# define LREG ld
# define SREG sd
# define REGBYTES 8
#else
# define LREG lw
# define SREG sw
# define REGBYTES 4
#endif

  .section ".text.init"
  .global _start
_start:

  # initialize stack pointer
  la sp, _stack

  # copy text section

  la t0, __load_start_text
  la t1, __load_stop_text

  la t2, __tim0_start
  la t3, __tim0_end

copy_text:
  LREG t4,0(t0)
  SREG t4,0(t2)
  addi t0,t0,REGBYTES
  addi t2,t2,REGBYTES
  blt t0,t1,copy_text

  # copy data section

  la t0, __load_start_data
  la t1, __load_stop_data

  la t2, __tim1_start
  la t3, __tim1_end

copy_data:
  LREG t4,0(t0)
  SREG t4,0(t2)
  addi t0,t0,REGBYTES
  addi t2,t2,REGBYTES
  blt t0,t1,copy_data

  call main
  tail exit

.section ".tohost","aw",@progbits
.align 6
.globl tohost
tohost: .dword 0
.align 6
.globl fromhost
fromhost: .dword 0
