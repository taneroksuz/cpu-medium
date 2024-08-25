import configure::*;
import wires::*;

module soc (
    input  logic reset,
    input  logic clock,
    input  logic clock_slow,
    input  logic uart_rx,
    output logic uart_tx
);

  timeunit 1ns; timeprecision 1ps;

  mem_in_type imem0_in;
  mem_in_type imem1_in;

  mem_in_type dmem0_in;
  mem_in_type dmem1_in;

  mem_in_type itim0_in;
  mem_in_type itim1_in;

  mem_in_type dtim0_in;
  mem_in_type dtim1_in;

  mem_in_type rom_in;
  mem_in_type rom0_in;
  mem_in_type rom1_in;
  mem_in_type irom0_in;
  mem_in_type irom1_in;
  mem_in_type drom0_in;
  mem_in_type drom1_in;

  mem_in_type ram_in;
  mem_in_type ram0_in;
  mem_in_type ram1_in;
  mem_in_type iram0_in;
  mem_in_type iram1_in;
  mem_in_type dram0_in;
  mem_in_type dram1_in;

  mem_in_type uart_in;
  mem_in_type uart0_in;
  mem_in_type uart1_in;
  mem_in_type iuart0_in;
  mem_in_type iuart1_in;
  mem_in_type duart0_in;
  mem_in_type duart1_in;

  mem_in_type clint_in;
  mem_in_type clint0_in;
  mem_in_type clint1_in;
  mem_in_type iclint0_in;
  mem_in_type iclint1_in;
  mem_in_type dclint0_in;
  mem_in_type dclint1_in;

  mem_out_type imem0_out;
  mem_out_type imem1_out;

  mem_out_type dmem0_out;
  mem_out_type dmem1_out;

  mem_out_type itim0_out;
  mem_out_type itim1_out;

  mem_out_type dtim0_out;
  mem_out_type dtim1_out;

  mem_out_type rom_out;
  mem_out_type rom0_out;
  mem_out_type rom1_out;
  mem_out_type irom0_out;
  mem_out_type irom1_out;
  mem_out_type drom0_out;
  mem_out_type drom1_out;

  mem_out_type ram_out;
  mem_out_type ram0_out;
  mem_out_type ram1_out;
  mem_out_type iram0_out;
  mem_out_type iram1_out;
  mem_out_type dram0_out;
  mem_out_type dram1_out;

  mem_out_type uart_out;
  mem_out_type uart0_out;
  mem_out_type uart1_out;
  mem_out_type iuart0_out;
  mem_out_type iuart1_out;
  mem_out_type duart0_out;
  mem_out_type duart1_out;

  mem_out_type clint_out;
  mem_out_type clint0_out;
  mem_out_type clint1_out;
  mem_out_type iclint0_out;
  mem_out_type iclint1_out;
  mem_out_type dclint0_out;
  mem_out_type dclint1_out;

  mem_in_type tim00_in;
  mem_in_type tim01_in;
  mem_in_type tim10_in;
  mem_in_type tim11_in;

  mem_out_type tim00_out;
  mem_out_type tim01_out;
  mem_out_type tim10_out;
  mem_out_type tim11_out;

  mem_in_type ram_slow_in;
  mem_in_type uart_slow_in;

  mem_out_type ram_slow_out;
  mem_out_type uart_slow_out;

  logic [0 : 0] meip;
  logic [0 : 0] msip;
  logic [0 : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] imem0_addr;
  logic [31 : 0] imem1_addr;
  logic [31 : 0] dmem0_addr;
  logic [31 : 0] dmem1_addr;

  logic [31 : 0] ibase0_addr;
  logic [31 : 0] ibase1_addr;
  logic [31 : 0] dbase0_addr;
  logic [31 : 0] dbase1_addr;

  always_comb begin

    irom0_in = init_mem_in;
    iram0_in = init_mem_in;
    itim0_in = init_mem_in;
    iuart0_in = init_mem_in;
    iclint0_in = init_mem_in;

    irom1_in = init_mem_in;
    iram1_in = init_mem_in;
    itim1_in = init_mem_in;
    iuart1_in = init_mem_in;
    iclint1_in = init_mem_in;

    ibase0_addr = 0;
    ibase1_addr = 0;

    if (imem0_in.mem_valid == 1) begin
      if (imem0_in.mem_addr >= rom_base_addr && imem0_in.mem_addr < rom_top_addr) begin
        irom0_in = imem0_in;
        ibase0_addr = rom_base_addr;
      end else if (imem0_in.mem_addr >= ram_base_addr && imem0_in.mem_addr < ram_top_addr) begin
        iram0_in = imem0_in;
        ibase0_addr = ram_base_addr;
      end else if (imem0_in.mem_addr >= itim_base_addr && imem0_in.mem_addr < itim_top_addr) begin
        itim0_in = imem0_in;
        ibase0_addr = itim_base_addr;
      end else if (imem0_in.mem_addr >= dtim_base_addr && imem0_in.mem_addr < dtim_top_addr) begin
        itim0_in = imem0_in;
        ibase0_addr = dtim_base_addr;
      end else if (imem0_in.mem_addr >= uart_base_addr && imem0_in.mem_addr < uart_top_addr) begin
        iuart0_in   = imem0_in;
        ibase0_addr = uart_base_addr;
      end else if (imem0_in.mem_addr >= clint_base_addr && imem0_in.mem_addr < clint_top_addr) begin
        iclint0_in  = imem0_in;
        ibase0_addr = clint_base_addr;
      end
    end

    if (imem1_in.mem_valid == 1) begin
      if (imem1_in.mem_addr >= rom_base_addr && imem1_in.mem_addr < rom_top_addr) begin
        irom1_in = imem1_in;
        ibase1_addr = rom_base_addr;
      end else if (imem1_in.mem_addr >= ram_base_addr && imem1_in.mem_addr < ram_top_addr) begin
        iram1_in = imem1_in;
        ibase1_addr = ram_base_addr;
      end else if (imem1_in.mem_addr >= itim_base_addr && imem1_in.mem_addr < itim_top_addr) begin
        itim1_in = imem1_in;
        ibase1_addr = itim_base_addr;
      end else if (imem1_in.mem_addr >= dtim_base_addr && imem1_in.mem_addr < dtim_top_addr) begin
        itim1_in = imem1_in;
        ibase1_addr = dtim_base_addr;
      end else if (imem1_in.mem_addr >= uart_base_addr && imem1_in.mem_addr < uart_top_addr) begin
        iuart1_in   = imem1_in;
        ibase1_addr = uart_base_addr;
      end else if (imem1_in.mem_addr >= clint_base_addr && imem1_in.mem_addr < clint_top_addr) begin
        iclint1_in  = imem1_in;
        ibase1_addr = clint_base_addr;
      end
    end

    imem0_addr = imem0_in.mem_addr - ibase0_addr;
    imem1_addr = imem1_in.mem_addr - ibase1_addr;

    irom0_in.mem_addr = imem0_addr;
    itim0_in.mem_addr = imem0_addr;
    iram0_in.mem_addr = imem0_addr;
    iuart0_in.mem_addr = imem0_addr;
    iclint0_in.mem_addr = imem0_addr;

    irom1_in.mem_addr = imem1_addr;
    itim1_in.mem_addr = imem1_addr;
    iram1_in.mem_addr = imem1_addr;
    iuart1_in.mem_addr = imem1_addr;
    iclint1_in.mem_addr = imem1_addr;

    imem0_out = init_mem_out;
    imem1_out = init_mem_out;

    if (irom0_out.mem_ready == 1) begin
      imem0_out = irom0_out;
    end else if (iram0_out.mem_ready == 1) begin
      imem0_out = iram0_out;
    end else if (itim0_out.mem_ready == 1) begin
      imem0_out = itim0_out;
    end else if (iuart0_out.mem_ready == 1) begin
      imem0_out = iuart0_out;
    end else if (iclint0_out.mem_ready == 1) begin
      imem0_out = iclint0_out;
    end

    if (irom1_out.mem_ready == 1) begin
      imem1_out = irom1_out;
    end else if (iram1_out.mem_ready == 1) begin
      imem1_out = iram1_out;
    end else if (itim1_out.mem_ready == 1) begin
      imem1_out = itim1_out;
    end else if (iuart1_out.mem_ready == 1) begin
      imem1_out = iuart1_out;
    end else if (iclint1_out.mem_ready == 1) begin
      imem1_out = iclint1_out;
    end

  end

  always_comb begin

    drom0_in = init_mem_in;
    dram0_in = init_mem_in;
    dtim0_in = init_mem_in;
    duart0_in = init_mem_in;
    dclint0_in = init_mem_in;

    drom1_in = init_mem_in;
    dram1_in = init_mem_in;
    dtim1_in = init_mem_in;
    duart1_in = init_mem_in;
    dclint1_in = init_mem_in;

    dbase0_addr = 0;
    dbase1_addr = 0;

    if (dmem0_in.mem_valid == 1) begin
      if (dmem0_in.mem_addr >= rom_base_addr && dmem0_in.mem_addr < rom_top_addr) begin
        drom0_in = dmem0_in;
        dbase0_addr = rom_base_addr;
      end else if (dmem0_in.mem_addr >= ram_base_addr && dmem0_in.mem_addr < ram_top_addr) begin
        dram0_in = dmem0_in;
        dbase0_addr = ram_base_addr;
      end else if (dmem0_in.mem_addr >= itim_base_addr && dmem0_in.mem_addr < itim_top_addr) begin
        dtim0_in = dmem0_in;
        dbase0_addr = itim_base_addr;
      end else if (dmem0_in.mem_addr >= dtim_base_addr && dmem0_in.mem_addr < dtim_top_addr) begin
        dtim0_in = dmem0_in;
        dbase0_addr = dtim_base_addr;
      end else if (dmem0_in.mem_addr >= uart_base_addr && dmem0_in.mem_addr < uart_top_addr) begin
        duart0_in   = dmem0_in;
        dbase0_addr = uart_base_addr;
      end else if (dmem0_in.mem_addr >= clint_base_addr && dmem0_in.mem_addr < clint_top_addr) begin
        dclint0_in  = dmem0_in;
        dbase0_addr = clint_base_addr;
      end
    end

    if (dmem1_in.mem_valid == 1) begin
      if (dmem1_in.mem_addr >= rom_base_addr && dmem1_in.mem_addr < rom_top_addr) begin
        drom1_in = dmem1_in;
        dbase1_addr = rom_base_addr;
      end else if (dmem1_in.mem_addr >= ram_base_addr && dmem1_in.mem_addr < ram_top_addr) begin
        dram1_in = dmem1_in;
        dbase1_addr = ram_base_addr;
      end else if (dmem1_in.mem_addr >= itim_base_addr && dmem1_in.mem_addr < itim_top_addr) begin
        dtim1_in = dmem1_in;
        dbase1_addr = itim_base_addr;
      end else if (dmem1_in.mem_addr >= dtim_base_addr && dmem1_in.mem_addr < dtim_top_addr) begin
        dtim1_in = dmem1_in;
        dbase1_addr = dtim_base_addr;
      end else if (dmem1_in.mem_addr >= uart_base_addr && dmem1_in.mem_addr < uart_top_addr) begin
        duart1_in   = dmem1_in;
        dbase1_addr = uart_base_addr;
      end else if (dmem1_in.mem_addr >= clint_base_addr && dmem1_in.mem_addr < clint_top_addr) begin
        dclint1_in  = dmem1_in;
        dbase1_addr = clint_base_addr;
      end
    end

    dmem0_addr = dmem0_in.mem_addr - dbase0_addr;
    dmem1_addr = dmem1_in.mem_addr - dbase1_addr;

    drom0_in.mem_addr = dmem0_addr;
    dtim0_in.mem_addr = dmem0_addr;
    dram0_in.mem_addr = dmem0_addr;
    duart0_in.mem_addr = dmem0_addr;
    dclint0_in.mem_addr = dmem0_addr;

    drom1_in.mem_addr = dmem1_addr;
    dtim1_in.mem_addr = dmem1_addr;
    dram1_in.mem_addr = dmem1_addr;
    duart1_in.mem_addr = dmem1_addr;
    dclint1_in.mem_addr = dmem1_addr;

    dmem0_out = init_mem_out;
    dmem1_out = init_mem_out;

    if (drom0_out.mem_ready == 1) begin
      dmem0_out = drom0_out;
    end else if (dram0_out.mem_ready == 1) begin
      dmem0_out = dram0_out;
    end else if (dtim0_out.mem_ready == 1) begin
      dmem0_out = dtim0_out;
    end else if (duart0_out.mem_ready == 1) begin
      dmem0_out = duart0_out;
    end else if (dclint0_out.mem_ready == 1) begin
      dmem0_out = dclint0_out;
    end

    if (drom1_out.mem_ready == 1) begin
      dmem1_out = drom1_out;
    end else if (dram1_out.mem_ready == 1) begin
      dmem1_out = dram1_out;
    end else if (dtim1_out.mem_ready == 1) begin
      dmem1_out = dtim1_out;
    end else if (duart1_out.mem_ready == 1) begin
      dmem1_out = duart1_out;
    end else if (dclint1_out.mem_ready == 1) begin
      dmem1_out = dclint1_out;
    end

  end

  cpu cpu_comp (
      .reset(reset),
      .clock(clock),
      .imem0_in(imem0_in),
      .imem1_in(imem1_in),
      .imem0_out(imem0_out),
      .imem1_out(imem1_out),
      .dmem0_in(dmem0_in),
      .dmem1_in(dmem1_in),
      .dmem0_out(dmem0_out),
      .dmem1_out(dmem1_out),
      .meip(meip),
      .msip(msip),
      .mtip(mtip),
      .mtime(mtime)
  );

  arbiter arbiter_rom0_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(irom0_in),
      .imem_out(irom0_out),
      .dmem_in(drom0_in),
      .dmem_out(drom0_out),
      .mem_in(rom0_in),
      .mem_out(rom0_out)
  );

  arbiter arbiter_rom1_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(irom1_in),
      .imem_out(irom1_out),
      .dmem_in(drom1_in),
      .dmem_out(drom1_out),
      .mem_in(rom1_in),
      .mem_out(rom1_out)
  );

  arbiter arbiter_rom_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(rom0_in),
      .imem_out(rom0_out),
      .dmem_in(rom1_in),
      .dmem_out(rom1_out),
      .mem_in(rom_in),
      .mem_out(rom_out)
  );

  rom rom_comp (
      .reset  (reset),
      .clock  (clock),
      .rom_in (rom_in),
      .rom_out(rom_out)
  );

  arbiter arbiter_clint0_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iclint0_in),
      .imem_out(iclint0_out),
      .dmem_in(dclint0_in),
      .dmem_out(dclint0_out),
      .mem_in(clint0_in),
      .mem_out(clint0_out)
  );

  arbiter arbiter_clint1_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iclint1_in),
      .imem_out(iclint1_out),
      .dmem_in(dclint1_in),
      .dmem_out(dclint1_out),
      .mem_in(clint1_in),
      .mem_out(clint1_out)
  );

  arbiter arbiter_clint_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(clint0_in),
      .imem_out(clint0_out),
      .dmem_in(clint1_in),
      .dmem_out(clint1_out),
      .mem_in(clint_in),
      .mem_out(clint_out)
  );

  clint #(
      .clock_rate(clk_divider_rtc)
  ) clint_comp (
      .reset(reset),
      .clock(clock),
      .clint_in(clint_in),
      .clint_out(clint_out),
      .clint_msip(msip),
      .clint_mtip(mtip),
      .clint_mtime(mtime)
  );

  arbiter arbiter_tim00_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(itim0_in),
      .imem_out(itim0_out),
      .dmem_in(dtim0_in),
      .dmem_out(dtim0_out),
      .mem_in(tim00_in),
      .mem_out(tim00_out)
  );

  arbiter arbiter_tim01_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(itim1_in),
      .imem_out(itim1_out),
      .dmem_in(dtim1_in),
      .dmem_out(dtim1_out),
      .mem_in(tim01_in),
      .mem_out(tim01_out)
  );

  tim tim0_comp (
      .reset(reset),
      .clock(clock),
      .tim0_in(tim00_in),
      .tim1_in(tim01_in),
      .tim0_out(tim00_out),
      .tim1_out(tim01_out)
  );

  arbiter arbiter_tim10_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(itim0_in),
      .imem_out(itim0_out),
      .dmem_in(dtim0_in),
      .dmem_out(dtim0_out),
      .mem_in(tim10_in),
      .mem_out(tim10_out)
  );

  arbiter arbiter_tim11_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(itim1_in),
      .imem_out(itim1_out),
      .dmem_in(dtim1_in),
      .dmem_out(dtim1_out),
      .mem_in(tim11_in),
      .mem_out(tim11_out)
  );

  tim tim1_comp (
      .reset(reset),
      .clock(clock),
      .tim0_in(tim10_in),
      .tim1_in(tim11_in),
      .tim0_out(tim10_out),
      .tim1_out(tim11_out)
  );

  arbiter arbiter_ram0_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iram0_in),
      .imem_out(iram0_out),
      .dmem_in(dram0_in),
      .dmem_out(dram0_out),
      .mem_in(ram0_in),
      .mem_out(ram0_out)
  );

  arbiter arbiter_ram1_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iram1_in),
      .imem_out(iram1_out),
      .dmem_in(dram1_in),
      .dmem_out(dram1_out),
      .mem_in(ram1_in),
      .mem_out(ram1_out)
  );

  arbiter arbiter_ram_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(ram0_in),
      .imem_out(ram0_out),
      .dmem_in(ram1_in),
      .dmem_out(ram1_out),
      .mem_in(ram_in),
      .mem_out(ram_out)
  );

  ccd #(
      .clock_rate(clk_divider_slow)
  ) ccd_ram_comp (
      .reset(reset),
      .clock(clock),
      .clock_slow(clock_slow),
      .mem_in(ram_in),
      .mem_out(ram_out),
      .mem_slow_in(ram_slow_in),
      .mem_slow_out(ram_slow_out)
  );

  ram ram_comp (
      .reset  (reset),
      .clock  (clock_slow),
      .ram_in (ram_slow_in),
      .ram_out(ram_slow_out)
  );

  arbiter arbiter_uart0_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iuart0_in),
      .imem_out(iuart0_out),
      .dmem_in(duart0_in),
      .dmem_out(duart0_out),
      .mem_in(uart0_in),
      .mem_out(uart0_out)
  );

  arbiter arbiter_uart1_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iuart1_in),
      .imem_out(iuart1_out),
      .dmem_in(duart1_in),
      .dmem_out(duart1_out),
      .mem_in(uart1_in),
      .mem_out(uart1_out)
  );

  arbiter arbiter_uart_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(uart0_in),
      .imem_out(uart0_out),
      .dmem_in(uart1_in),
      .dmem_out(uart1_out),
      .mem_in(uart_in),
      .mem_out(uart_out)
  );

  ccd #(
      .clock_rate(clk_divider_slow)
  ) ccd_uart_comp (
      .reset(reset),
      .clock(clock),
      .clock_slow(clock_slow),
      .mem_in(uart_in),
      .mem_out(uart_out),
      .mem_slow_in(uart_slow_in),
      .mem_slow_out(uart_slow_out)
  );

  uart uart_comp (
      .reset(reset),
      .clock(clock_slow),
      .uart_in(uart_slow_in),
      .uart_out(uart_slow_out),
      .uart_rx(uart_rx),
      .uart_tx(uart_tx)
  );

endmodule
