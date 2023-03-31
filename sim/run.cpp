#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vsoc.h"

vluint64_t sim_time = 0;

#define TRACE

int main(int argc, char** argv, char** env)
{
  vluint64_t max_sim_time = 10000000;

  if (argc >= 2)
    max_sim_time = atoi(argv[1]);

  Verilated::commandArgs(argc, argv);
  Vsoc *dut = new Vsoc;

  bool finished = false;

  while (sim_time < max_sim_time)
  {
    if (sim_time < 10)
      dut->reset = 0;
    else
      dut->reset = 1;

    dut->clock ^= 1;

    dut->eval();

    sim_time++;

    if (Verilated::gotFinish())
    {
      finished = true;
      break;
    }
  }

  if (!finished)
  {
    std::cout << "\033[33m";
    std::cout << "TEST STOPPED" << std::endl;
    std::cout << "\033[0m";
  }

  std::cout << "simulation finished @" << sim_time << "ps" << std::endl;

  delete dut;
  exit(EXIT_SUCCESS);
}