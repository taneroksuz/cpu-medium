#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vsoc.h"

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env)
{
  vluint64_t max_sim_time = 10000000;
  const char *filename = "soc.vcd";

  if (argc >= 2)
    max_sim_time = atoi(argv[1]);
  if (argc >= 3)
    filename = argv[2];

  Verilated::commandArgs(argc, argv);
  Vsoc *dut = new Vsoc;

  Verilated::traceEverOn(true);
  VerilatedVcdC *trace = new VerilatedVcdC;
  dut->trace(trace, 0);
  trace->open(filename);

  bool finished = false;

  while (sim_time < max_sim_time)
  {
    if (sim_time < 10)
      dut->reset = 0;
    else
      dut->reset = 1;

    dut->clock ^= 1;

    dut->eval();

    trace->dump(sim_time);

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

  trace->close();
  delete dut;
  exit(EXIT_SUCCESS);
}