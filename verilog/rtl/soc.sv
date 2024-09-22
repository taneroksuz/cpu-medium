import configure::*;
import wires::*;

module soc (
    input  reset,
    input  clock,
    input  clock_per,
    output sclk,
    output mosi,
    input  miso,
    output ss,
    input  rx,
    output tx
);

  timeunit 1ns; timeprecision 1ps;

  mem_in_type imem0_in;
  mem_in_type imem1_in;
  mem_in_type dmem0_in;
  mem_in_type dmem1_in;

  mem_out_type imem0_out;
  mem_out_type imem1_out;
  mem_out_type dmem0_out;
  mem_out_type dmem1_out;

  mem_in_type itim0_in;
  mem_in_type itim1_in;
  mem_in_type dtim0_in;
  mem_in_type dtim1_in;

  mem_out_type itim0_out;
  mem_out_type itim1_out;
  mem_out_type dtim0_out;
  mem_out_type dtim1_out;

  mem_in_type iper0_in;
  mem_in_type iper1_in;
  mem_in_type dper0_in;
  mem_in_type dper1_in;

  mem_out_type iper0_out;
  mem_out_type iper1_out;
  mem_out_type dper0_out;
  mem_out_type dper1_out;

  mem_in_type per_in;
  mem_in_type rom_in;
  mem_in_type ram_in;
  mem_in_type spi_in;
  mem_in_type clint_in;
  mem_in_type error_in;
  mem_in_type uart_rx_in;
  mem_in_type uart_tx_in;

  mem_out_type per_out;
  mem_out_type rom_out;
  mem_out_type ram_out;
  mem_out_type spi_out;
  mem_out_type clint_out;
  mem_out_type error_out;
  mem_out_type uart_rx_out;
  mem_out_type uart_tx_out;

  mem_in_type ram_per_in;

  mem_out_type ram_per_out;

  logic [0 : 0] meip;
  logic [0 : 0] msip;
  logic [0 : 0] mtip;
  logic [0 : 0] irpt;

  logic [63 : 0] mtime;

  logic [0 : 0] itim0_rev;
  logic [0 : 0] itim1_rev;
  logic [0 : 0] dtim0_rev;
  logic [0 : 0] dtim1_rev;

  logic [0 : 0] itim0_rev_reg;
  logic [0 : 0] itim1_rev_reg;
  logic [0 : 0] dtim0_rev_reg;
  logic [0 : 0] dtim1_rev_reg;

  logic [31 : 0] mem_addr;
  logic [31 : 0] base_addr;

  always_comb begin

    itim0_in  = init_mem_in;
    itim1_in  = init_mem_in;
    dtim0_in  = init_mem_in;
    dtim1_in  = init_mem_in;

    iper0_in  = init_mem_in;
    iper1_in  = init_mem_in;
    dper0_in  = init_mem_in;
    dper1_in  = init_mem_in;

    itim0_rev = itim0_rev_reg;
    itim1_rev = itim1_rev_reg;
    dtim0_rev = dtim0_rev_reg;
    dtim1_rev = dtim1_rev_reg;

    if (imem0_in.mem_valid & ~|(itim_base_addr ^ (imem0_in.mem_addr & ~itim_mask_addr))) begin
      itim0_in = imem0_in;
      itim0_in.mem_addr = imem0_in.mem_addr - itim_base_addr;
      itim0_rev = 0;
    end else if (dmem0_in.mem_valid & ~|(itim_base_addr ^ (dmem0_in.mem_addr & ~itim_mask_addr))) begin
      itim0_in = dmem0_in;
      itim0_in.mem_addr = dmem0_in.mem_addr - itim_base_addr;
      itim0_rev = 1;
    end

    if (imem1_in.mem_valid & ~|(itim_base_addr ^ (imem1_in.mem_addr & ~itim_mask_addr))) begin
      itim1_in = imem1_in;
      itim1_in.mem_addr = imem1_in.mem_addr - itim_base_addr;
      itim1_rev = 0;
    end else if (dmem1_in.mem_valid & ~|(itim_base_addr ^ (dmem1_in.mem_addr & ~itim_mask_addr))) begin
      itim1_in = dmem1_in;
      itim1_in.mem_addr = dmem1_in.mem_addr - itim_base_addr;
      itim1_rev = 1;
    end

    if (imem0_in.mem_valid & ~|(dtim_base_addr ^ (imem0_in.mem_addr & ~dtim_mask_addr))) begin
      dtim0_in = imem0_in;
      dtim0_in.mem_addr = imem0_in.mem_addr - dtim_base_addr;
      dtim0_rev = 1;
    end else if (dmem0_in.mem_valid & ~|(dtim_base_addr ^ (dmem0_in.mem_addr & ~dtim_mask_addr))) begin
      dtim0_in = dmem0_in;
      dtim0_in.mem_addr = dmem0_in.mem_addr - dtim_base_addr;
      dtim0_rev = 0;
    end

    if (imem1_in.mem_valid & ~|(dtim_base_addr ^ (imem1_in.mem_addr & ~dtim_mask_addr))) begin
      dtim1_in = imem1_in;
      dtim1_in.mem_addr = imem1_in.mem_addr - dtim_base_addr;
      dtim1_rev = 1;
    end else if (dmem1_in.mem_valid & ~|(dtim_base_addr ^ (dmem1_in.mem_addr & ~dtim_mask_addr))) begin
      dtim1_in = dmem1_in;
      dtim1_in.mem_addr = dmem1_in.mem_addr - dtim_base_addr;
      dtim1_rev = 0;
    end

    if (imem0_in.mem_valid & |(itim_base_addr ^ (imem0_in.mem_addr & ~itim_mask_addr)) & |(dtim_base_addr ^ (imem0_in.mem_addr & ~dtim_mask_addr))) begin
      iper0_in = imem0_in;
    end
    if (imem1_in.mem_valid & |(itim_base_addr ^ (imem1_in.mem_addr & ~itim_mask_addr)) & |(dtim_base_addr ^ (imem1_in.mem_addr & ~dtim_mask_addr))) begin
      iper1_in = imem1_in;
    end
    if (dmem0_in.mem_valid & |(itim_base_addr ^ (dmem0_in.mem_addr & ~itim_mask_addr)) & |(dtim_base_addr ^ (dmem0_in.mem_addr & ~dtim_mask_addr))) begin
      dper0_in = dmem0_in;
    end
    if (dmem1_in.mem_valid & |(itim_base_addr ^ (dmem1_in.mem_addr & ~itim_mask_addr)) & |(dtim_base_addr ^ (dmem1_in.mem_addr & ~dtim_mask_addr))) begin
      dper1_in = dmem1_in;
    end

    imem0_out = init_mem_out;
    imem1_out = init_mem_out;
    dmem0_out = init_mem_out;
    dmem1_out = init_mem_out;

    if (itim0_out.mem_ready == 1 && itim0_rev_reg == 0) begin
      imem0_out = itim0_out;
    end
    if (itim0_out.mem_ready == 1 && itim0_rev_reg == 1) begin
      dmem0_out = itim0_out;
    end
    if (itim1_out.mem_ready == 1 && itim1_rev_reg == 0) begin
      imem1_out = itim1_out;
    end
    if (itim1_out.mem_ready == 1 && itim1_rev_reg == 1) begin
      dmem1_out = itim1_out;
    end

    if (dtim0_out.mem_ready == 1 && dtim0_rev_reg == 1) begin
      imem0_out = dtim0_out;
    end
    if (dtim0_out.mem_ready == 1 && dtim0_rev_reg == 0) begin
      dmem0_out = dtim0_out;
    end
    if (dtim1_out.mem_ready == 1 && dtim1_rev_reg == 1) begin
      imem1_out = dtim1_out;
    end
    if (dtim1_out.mem_ready == 1 && dtim1_rev_reg == 0) begin
      dmem1_out = dtim1_out;
    end

    if (iper0_out.mem_ready == 1) begin
      imem0_out = iper0_out;
    end
    if (iper1_out.mem_ready == 1) begin
      imem1_out = iper1_out;
    end
    if (dper0_out.mem_ready == 1) begin
      dmem0_out = dper0_out;
    end
    if (dper1_out.mem_ready == 1) begin
      dmem1_out = dper1_out;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      itim0_rev_reg <= 0;
      itim1_rev_reg <= 0;
      dtim0_rev_reg <= 0;
      dtim1_rev_reg <= 0;
    end else begin
      itim0_rev_reg <= itim0_rev;
      itim1_rev_reg <= itim1_rev;
      dtim0_rev_reg <= dtim0_rev;
      dtim1_rev_reg <= dtim1_rev;
    end
  end

  always_comb begin

    rom_in = init_mem_in;
    ram_in = init_mem_in;
    spi_in = init_mem_in;
    clint_in = init_mem_in;
    error_in = init_mem_in;
    uart_rx_in = init_mem_in;
    uart_tx_in = init_mem_in;

    base_addr = 0;

    error_in.mem_valid = per_in.mem_valid;

    if (per_in.mem_valid & ~|(rom_base_addr ^ (per_in.mem_addr & ~rom_mask_addr))) begin
      rom_in = per_in;
      base_addr = rom_base_addr;
      error_in.mem_valid = 0;
    end
    if (per_in.mem_valid & ~|(ram_base_addr ^ (per_in.mem_addr & ~ram_mask_addr))) begin
      ram_in = per_in;
      base_addr = ram_base_addr;
      error_in.mem_valid = 0;
    end
    if (per_in.mem_valid & ~|(spi_base_addr ^ (per_in.mem_addr & ~spi_mask_addr))) begin
      spi_in = per_in;
      base_addr = spi_base_addr;
      error_in.mem_valid = 0;
    end
    if (per_in.mem_valid & ~|(clint_base_addr ^ (per_in.mem_addr & ~clint_mask_addr))) begin
      clint_in = per_in;
      base_addr = clint_base_addr;
      error_in.mem_valid = 0;
    end
    if (per_in.mem_valid & ~|(uart_rx_base_addr ^ (per_in.mem_addr & ~uart_rx_mask_addr))) begin
      uart_rx_in = per_in;
      base_addr = uart_rx_base_addr;
      error_in.mem_valid = 0;
    end
    if (per_in.mem_valid & ~|(uart_tx_base_addr ^ (per_in.mem_addr & ~uart_tx_mask_addr))) begin
      uart_tx_in = per_in;
      base_addr = uart_tx_base_addr;
      error_in.mem_valid = 0;
    end

    mem_addr = per_in.mem_addr - base_addr;

    rom_in.mem_addr = mem_addr;
    ram_in.mem_addr = mem_addr;
    spi_in.mem_addr = mem_addr;
    clint_in.mem_addr = mem_addr;
    uart_rx_in.mem_addr = mem_addr;
    uart_tx_in.mem_addr = mem_addr;

    per_out = init_mem_out;

    if (rom_out.mem_ready == 1) begin
      per_out = rom_out;
    end
    if (ram_out.mem_ready == 1) begin
      per_out = ram_out;
    end
    if (spi_out.mem_ready == 1) begin
      per_out = spi_out;
    end
    if (clint_out.mem_ready == 1) begin
      per_out = clint_out;
    end
    if (error_out.mem_ready == 1) begin
      per_out = error_out;
    end
    if (uart_rx_out.mem_ready == 1) begin
      per_out = uart_rx_out;
    end
    if (uart_tx_out.mem_ready == 1) begin
      per_out = uart_tx_out;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      error_out <= init_mem_out;
    end else begin
      if (error_in.mem_valid == 1) begin
        error_out.mem_rdata <= 0;
        error_out.mem_error <= 1;
        error_out.mem_ready <= 1;
      end else begin
        error_out <= init_mem_out;
      end
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
      .irpt(irpt),
      .mtime(mtime)
  );

  tim itim_comp (
      .reset(reset),
      .clock(clock),
      .tim0_in(itim0_in),
      .tim1_in(itim1_in),
      .tim0_out(itim0_out),
      .tim1_out(itim1_out)
  );

  tim dtim_comp (
      .reset(reset),
      .clock(clock),
      .tim0_in(dtim0_in),
      .tim1_in(dtim1_in),
      .tim0_out(dtim0_out),
      .tim1_out(dtim1_out)
  );

  arbiter arbiter_comp (
      .reset(reset),
      .clock(clock),
      .imem0_in(iper0_in),
      .imem0_out(iper0_out),
      .imem1_in(iper1_in),
      .imem1_out(iper1_out),
      .dmem0_in(dper0_in),
      .dmem0_out(dper0_out),
      .dmem1_in(dper1_in),
      .dmem1_out(dper1_out),
      .mem_in(per_in),
      .mem_out(per_out)
  );

  rom rom_comp (
      .reset  (reset),
      .clock  (clock),
      .rom_in (rom_in),
      .rom_out(rom_out)
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

  ccd #(
      .clock_rate(clk_divider_per)
  ) ccd_ram_comp (
      .reset(reset),
      .clock(clock),
      .clock_per(clock_per),
      .mem_in(ram_in),
      .mem_out(ram_out),
      .mem_per_in(ram_per_in),
      .mem_per_out(ram_per_out)
  );

  ram ram_comp (
      .reset  (reset),
      .clock  (clock_per),
      .ram_in (ram_per_in),
      .ram_out(ram_per_out)
  );

  spi #(
      .clock_rate(clk_divider_per)
  ) spi_comp (
      .reset(reset),
      .clock(clock),
      .spi_in(spi_in),
      .spi_out(spi_out),
      .sclk(sclk),
      .mosi(mosi),
      .miso(miso),
      .ss(ss)
  );

  uart_rx #(
      .clock_rate(clk_divider_bit)
  ) uart_rx_comp (
      .reset(reset),
      .clock(clock),
      .uart_in(uart_rx_in),
      .uart_out(uart_rx_out),
      .uart_irpt(irpt),
      .rx(rx)
  );

  uart_tx #(
      .clock_rate(clk_divider_bit)
  ) uart_tx_comp (
      .reset(reset),
      .clock(clock),
      .uart_in(uart_tx_in),
      .uart_out(uart_tx_out),
      .tx(tx)
  );

endmodule
