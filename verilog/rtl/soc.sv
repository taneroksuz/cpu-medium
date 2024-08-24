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
  mem_in_type irom_in;
  mem_in_type drom_in;

  mem_in_type ram_in;
  mem_in_type iram_in;
  mem_in_type dram_in;

  mem_in_type uart_in;
  mem_in_type iuart_in;
  mem_in_type duart_in;

  mem_in_type clint_in;
  mem_in_type iclint_in;
  mem_in_type dclint_in;

  mem_in_type tim00_in;
  mem_in_type tim01_in;
  mem_in_type tim10_in;
  mem_in_type tim11_in;

  mem_in_type ram_slow_in;
  mem_in_type uart_slow_in;

  mem_out_type imem0_out;
  mem_out_type imem1_out;

  mem_out_type dmem0_out;
  mem_out_type dmem1_out;

  mem_out_type itim0_out;
  mem_out_type itim1_out;

  mem_out_type dtim0_out;
  mem_out_type dtim1_out;

  mem_out_type rom_out;
  mem_out_type irom_out;
  mem_out_type drom_out;

  mem_out_type ram_out;
  mem_out_type iram_out;
  mem_out_type dram_out;

  mem_out_type uart_out;
  mem_out_type iuart_out;
  mem_out_type duart_out;

  mem_out_type clint_out;
  mem_out_type iclint_out;
  mem_out_type dclint_out;

  mem_out_type ram_slow_out;
  mem_out_type uart_slow_out;

  mem_out_type tim00_out;
  mem_out_type tim01_out;
  mem_out_type tim10_out;
  mem_out_type tim11_out;

  logic [0 : 0] meip;
  logic [0 : 0] msip;
  logic [0 : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] imem_addr;
  logic [31 : 0] dmem_addr;

  logic [31 : 0] ibase_addr;
  logic [31 : 0] dbase_addr;

  always_comb begin

    iram_in = init_mem_in;
    itim0_in = init_mem_in;
    itim1_in = init_mem_in;
    iclint_in = init_mem_in;
    iuart_in = init_mem_in;
    irom_in = init_mem_in;

    ibase_addr = 0;

    if (imem0_in.mem_valid == 1) begin
      if (imem0_in.mem_addr >= ram_base_addr && imem0_in.mem_addr < ram_top_addr) begin
        iram_in = imem0_in;
        ibase_addr = ram_base_addr;
      end else if (imem0_in.mem_addr >= tim1_base_addr && imem0_in.mem_addr < tim1_top_addr) begin
        itim1_in   = imem0_in;
        ibase_addr = tim1_base_addr;
      end else if (imem0_in.mem_addr >= tim0_base_addr && imem0_in.mem_addr < tim0_top_addr) begin
        itim0_in   = imem0_in;
        ibase_addr = tim0_base_addr;
      end else if (imem0_in.mem_addr >= clint_base_addr && imem0_in.mem_addr < clint_top_addr) begin
        iclint_in  = imem0_in;
        ibase_addr = clint_base_addr;
      end else if (imem0_in.mem_addr >= uart_base_addr && imem0_in.mem_addr < uart_top_addr) begin
        iuart_in   = imem0_in;
        ibase_addr = uart_base_addr;
      end else if (imem0_in.mem_addr >= rom_base_addr && imem0_in.mem_addr < rom_top_addr) begin
        irom_in = imem0_in;
        ibase_addr = rom_base_addr;
      end
    end

    imem_addr = imem0_in.mem_addr - ibase_addr;

    irom_in.mem_addr = imem_addr;
    iuart_in.mem_addr = imem_addr;
    iclint_in.mem_addr = imem_addr;
    itim0_in.mem_addr = imem_addr;
    itim1_in.mem_addr = imem_addr;
    iram_in.mem_addr = imem_addr;

    imem0_out = init_mem_out;

    if (irom_out.mem_ready == 1) begin
      imem0_out = irom_out;
    end else if (iuart_out.mem_ready == 1) begin
      imem0_out = iuart_out;
    end else if (iclint_out.mem_ready == 1) begin
      imem0_out = iclint_out;
    end else if (itim0_out.mem_ready == 1) begin
      imem0_out = itim0_out;
    end else if (itim1_out.mem_ready == 1) begin
      imem0_out = itim1_out;
    end else if (iram_out.mem_ready == 1) begin
      imem0_out = iram_out;
    end

  end

  always_comb begin

    dram_in = init_mem_in;
    dtim0_in = init_mem_in;
    dtim1_in = init_mem_in;
    dclint_in = init_mem_in;
    duart_in = init_mem_in;
    drom_in = init_mem_in;

    dbase_addr = 0;

    if (dmem0_in.mem_valid == 1) begin
      if (dmem0_in.mem_addr >= ram_base_addr && dmem0_in.mem_addr < ram_top_addr) begin
        dram_in = dmem0_in;
        dbase_addr = ram_base_addr;
      end else if (dmem0_in.mem_addr >= tim1_base_addr && dmem0_in.mem_addr < tim1_top_addr) begin
        dtim1_in   = dmem0_in;
        dbase_addr = tim1_base_addr;
      end else if (dmem0_in.mem_addr >= tim0_base_addr && dmem0_in.mem_addr < tim0_top_addr) begin
        dtim0_in   = dmem0_in;
        dbase_addr = tim0_base_addr;
      end else if (dmem0_in.mem_addr >= clint_base_addr && dmem0_in.mem_addr < clint_top_addr) begin
        dclint_in  = dmem0_in;
        dbase_addr = clint_base_addr;
      end else if (dmem0_in.mem_addr >= uart_base_addr && dmem0_in.mem_addr < uart_top_addr) begin
        duart_in   = dmem0_in;
        dbase_addr = uart_base_addr;
      end else if (dmem0_in.mem_addr >= rom_base_addr && dmem0_in.mem_addr < rom_top_addr) begin
        drom_in = dmem0_in;
        dbase_addr = rom_base_addr;
      end
    end

    dmem_addr = dmem0_in.mem_addr - dbase_addr;

    drom_in.mem_addr = dmem_addr;
    duart_in.mem_addr = dmem_addr;
    dclint_in.mem_addr = dmem_addr;
    dtim0_in.mem_addr = dmem_addr;
    dtim1_in.mem_addr = dmem_addr;
    dram_in.mem_addr = dmem_addr;

    dmem0_out = init_mem_out;

    if (drom_out.mem_ready == 1) begin
      dmem0_out = drom_out;
    end else if (duart_out.mem_ready == 1) begin
      dmem0_out = duart_out;
    end else if (dclint_out.mem_ready == 1) begin
      dmem0_out = dclint_out;
    end else if (dtim0_out.mem_ready == 1) begin
      dmem0_out = dtim0_out;
    end else if (dtim1_out.mem_ready == 1) begin
      dmem0_out = dtim1_out;
    end else if (dram_out.mem_ready == 1) begin
      dmem0_out = dram_out;
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

  arbiter arbiter_rom_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(irom_in),
      .imem_out(irom_out),
      .dmem_in(drom_in),
      .dmem_out(drom_out),
      .mem_in(rom_in),
      .mem_out(rom_out)
  );

  rom rom_comp (
      .reset  (reset),
      .clock  (clock),
      .rom_in (rom_in),
      .rom_out(rom_out)
  );

  arbiter arbiter_clint_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iclint_in),
      .imem_out(iclint_out),
      .dmem_in(dclint_in),
      .dmem_out(dclint_out),
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

  arbiter arbiter_ram_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iram_in),
      .imem_out(iram_out),
      .dmem_in(dram_in),
      .dmem_out(dram_out),
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

  arbiter arbiter_uart_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(iuart_in),
      .imem_out(iuart_out),
      .dmem_in(duart_in),
      .dmem_out(duart_out),
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
