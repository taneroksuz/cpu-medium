#include "encoding.h"
#include <stdint.h>

#define CYCLES_PER_SECONDS 50000000
#define UART_BASE_ADDRESS 0x1000000
#define MTIMECMP 0x2004000
#define MTIMECMP4 0x2004004
#define MTIME 0x200BFF8
#define MTIME4 0x200BFFC

#define TIMER_COUNT 0x8000

void putch(char ch)
{
  *((volatile char*)UART_BASE_ADDRESS) = ch;
}

void increase_timer_interrupt(long long counter)
{
  unsigned int volatile * const port_mtimecmp = (unsigned int *) MTIMECMP;
  unsigned int volatile * const port_mtimecmp4 = (unsigned int *) MTIMECMP4;
  unsigned int volatile * const port_mtime = (unsigned int *) MTIME;
  unsigned int volatile * const port_mtime4 = (unsigned int *) MTIME4;
  unsigned int val_mtimecmp = *port_mtimecmp;
  unsigned int val_mtimecmp4 = *port_mtimecmp4;
  unsigned int val_mtime = *port_mtime;
  unsigned int val_mtime4 = *port_mtime4;
  unsigned long long new_mtimecmp = val_mtime4;
  new_mtimecmp = (new_mtimecmp << 32) + val_mtime;
  new_mtimecmp += counter;
  *port_mtimecmp = new_mtimecmp & 0xFFFFFFFF;
  *port_mtimecmp4 = (new_mtimecmp >> 32) & 0xFFFFFFFF;
}

void handle_timer_interrupt()
{
  increase_timer_interrupt(TIMER_COUNT);

  static unsigned int min = 0;
  static unsigned int sec = 0;
  unsigned char min1,min0;
  unsigned char sec1,sec0;

  min1 = '0' + min / 10;
  min0 = '0' + min % 10;
  sec1 = '0' + sec / 10;
  sec0 = '0' + sec % 10;
  putch(27);
  putch('[');
  putch('2');
  putch('J');
  putch(27);
  putch('[');
  putch('H');
  putch(min1);
  putch(min0);
  putch(':');
  putch(sec1);
  putch(sec0);
  putch('\r');
  putch('\n');
  sec = sec + 1;
  if ((sec % 60) == 0)
  {
    min = min + 1;
    sec = 0;
  }
  if ((min % 60) == 0)
  {
    min = 0;
  }
}

void init_timer_interrupt()
{
  increase_timer_interrupt(TIMER_COUNT);

  uintptr_t address;

  __asm__("la %0,_mtvec" : "=r"(address));

  write_csr(mtvec,address);

  unsigned int val;

  val = 0;

  val |= MSTATUS_MIE;

  write_csr(mstatus,val);

  val = 0;

  val |= MIP_MTIP;

  write_csr(mie,val);
}

int main()
{
  init_timer_interrupt();

  while(1);
}
