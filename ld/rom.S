#include "encoding.h"

#define UART_TX 0x1000000
#define UART_RX 0x1000004
#define SRAM_BASE 0x80000000
#define SRAM_SIZE 0x80000

#define MIE_MEIE 0x800

  .global _start
_start:
  li  x1, 0
  li  x2, 0
  li  x3, 0
  li  x4, 0
  li  x5, 0
  li  x6, 0
  li  x7, 0
  li  x8, 0
  li  x9, 0
  li  x10,0
  li  x11,0
  li  x12,0
  li  x13,0
  li  x14,0
  li  x15,0
  li  x16,0
  li  x17,0
  li  x18,0
  li  x19,0
  li  x20,0
  li  x21,0
  li  x22,0
  li  x23,0
  li  x24,0
  li  x25,0
  li  x26,0
  li  x27,0
  li  x28,0
  li  x29,0
  li  x30,0
  li  x31,0

  li t0, MSTATUS_FS | MSTATUS_XS | MSTATUS_VS
  csrs mstatus, t0

  li t0, MSTATUS_MIE
  csrs mstatus, t0

  li t0, MIE_MEIE
  csrs mie, t0

  la t0, trap_entry
  csrw mtvec, t0

  la t0, UART_RX
  la t1, SRAM_BASE

  la t2, 0
  la t3, SRAM_SIZE

loop:

  j loop

  .align 2

trap_entry:

  # uart irpt
  la t5, 0x80000018

  csrr t6, mcause
  bne t5, t6, loop

copy_firmware:

  lb t4,0(t0)
  sb t4,0(t1)

  addi t1,t1,1
  addi t2,t2,1

  bge t2,t3,init

  mret

init:

  la ra, SRAM_BASE

  jalr zero, 0(ra)