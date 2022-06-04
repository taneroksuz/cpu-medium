#include "encoding.h"
#include <stdint.h>

#define CYCLES_PER_SECONDS 50000000
#define UART_BASE_ADDRESS 0x1000000

void putch(char ch)
{
  *((volatile char*)UART_BASE_ADDRESS) = ch;
}

int main()
{
  unsigned int min = 0;
  unsigned int sec = 0;
  unsigned char min1,min0;
  unsigned char sec1,sec0;
  unsigned long cycle;

  cycle = read_csr(mcycle);

  while (1)
  {
    if ((read_csr(mcycle) - cycle) >= CYCLES_PER_SECONDS)
    {
      cycle = read_csr(mcycle);
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
  }
}
