import configure::*;

module soc
(
  input logic rst,
  input logic clk,
  input logic rx,
  output logic tx
);
  timeunit 1ns;
  timeprecision 1ps;

  logic rtc = 0;
  logic [31 : 0] count = 0;

  logic clk_pll = 0;
  logic [31 : 0] count_pll = 0;

  logic [0  : 0] imemory_valid;
  logic [0  : 0] imemory_instr;
  logic [31 : 0] imemory_addr;
  logic [31 : 0] imemory_wdata;
  logic [3  : 0] imemory_wstrb;
  logic [31 : 0] imemory_rdata;
  logic [0  : 0] imemory_ready;

  logic [0  : 0] dmemory_valid;
  logic [0  : 0] dmemory_instr;
  logic [31 : 0] dmemory_addr;
  logic [31 : 0] dmemory_wdata;
  logic [3  : 0] dmemory_wstrb;
  logic [31 : 0] dmemory_rdata;
  logic [0  : 0] dmemory_ready;

  logic [0  : 0] bram_valid;
  logic [0  : 0] bram_wen;
  logic [0  : 0] bram_instr;
  logic [31 : 0] bram_addr;
  logic [31 : 0] bram_wdata;
  logic [3  : 0] bram_wstrb;
  logic [31 : 0] bram_rdata;
  logic [0  : 0] bram_ready;

  logic [0  : 0] uart_valid;
  logic [0  : 0] uart_instr;
  logic [31 : 0] uart_addr;
  logic [31 : 0] uart_wdata;
  logic [3  : 0] uart_wstrb;
  logic [31 : 0] uart_rdata;
  logic [0  : 0] uart_ready;

  logic [0  : 0] clint_valid;
  logic [0  : 0] clint_instr;
  logic [31 : 0] clint_addr;
  logic [31 : 0] clint_wdata;
  logic [3  : 0] clint_wstrb;
  logic [31 : 0] clint_rdata;
  logic [0  : 0] clint_ready;

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] imem_addr;
  logic [31 : 0] dmem_addr;

  logic [31 : 0] ibase_addr;
  logic [31 : 0] dbase_addr;

  typedef struct packed{
    logic [0  : 0] bram_i;
    logic [0  : 0] bram_d;
    logic [0  : 0] uart_i;
    logic [0  : 0] uart_d;
    logic [0  : 0] clint_i;
    logic [0  : 0] clint_d;
  } reg_type;

  parameter reg_type init_reg = '{
    bram_i : 0,
    bram_d : 0,
    uart_i : 0,
    uart_d : 0,
    clint_i : 0,
    clint_d : 0
  };

  reg_type r,rin;
  reg_type v;

  always_ff @(posedge clk) begin
    if (count == clk_divider_rtc) begin
      rtc <= ~rtc;
      count <= 0;
    end else begin
      count <= count + 1;
    end
    if (count_pll == clk_divider_pll) begin
      clk_pll <= ~clk_pll;
      count_pll <= 0;
    end else begin
      count_pll <= count_pll + 1;
    end
  end

  always_comb begin

    v = r;

    dbase_addr = 0;

    if (bram_ready == 1) begin
      v.bram_i = 0;
      v.bram_d = 0;
    end
    if (uart_ready == 1) begin
      v.uart_i = 0;
      v.uart_d = 0;
    end
    if (clint_ready == 1) begin
      v.clint_i = 0;
      v.clint_d = 0;
    end

    if (dmemory_valid == 1) begin
      if (dmemory_addr >= clint_base_addr &&
        dmemory_addr < clint_top_addr) begin
          v.clint_d = dmemory_valid;
          v.uart_d = 0;
          v.bram_d = 0;
          dbase_addr = clint_base_addr;
      end else if (dmemory_addr >= uart_base_addr &&
        dmemory_addr < uart_top_addr) begin
          v.clint_d = 0;
          v.uart_d = dmemory_valid;
          v.bram_d = 0;
          dbase_addr = uart_base_addr;
      end else if (dmemory_addr >= bram_base_addr &&
        dmemory_addr < bram_top_addr) begin
          v.clint_d = 0;
          v.uart_d = 0;
          v.bram_d = dmemory_valid;
          dbase_addr = bram_base_addr;
      end else begin
        v.clint_d = 0;
        v.uart_d = 0;
        v.bram_d = 0;
        dbase_addr = 0;
      end
    end

    dmem_addr = dmemory_addr - dbase_addr;

    ibase_addr = 0;

    if (imemory_valid == 1) begin
      if (imemory_addr >= clint_base_addr &&
        imemory_addr < clint_top_addr) begin
          v.clint_i = imemory_valid;
          v.uart_i = 0;
          v.bram_i = 0;
          ibase_addr = clint_base_addr;
      end else if (imemory_addr >= uart_base_addr &&
        imemory_addr < uart_top_addr) begin
          v.clint_i = 0;
          v.uart_i = imemory_valid;
          v.bram_i = 0;
          ibase_addr = uart_base_addr;
      end else if (imemory_addr >= bram_base_addr &&
        imemory_addr < bram_top_addr) begin
          v.clint_i = 0;
          v.uart_i = 0;
          v.bram_i = imemory_valid;
          ibase_addr = bram_base_addr;
      end else begin
        v.clint_i = 0;
        v.uart_i = 0;
        v.bram_i = 0;
        ibase_addr = 0;
      end
    end

    if (v.bram_i == 1 && v.bram_d == 1) begin
      v.bram_i = 0;
    end
    if (v.uart_i == 1 && v.uart_d == 1) begin
      v.uart_i = 0;
    end
    if (v.clint_i == 1 && v.clint_d == 1) begin
      v.clint_i = 0;
    end

    imem_addr = imemory_addr - ibase_addr;

    bram_valid = v.bram_d ? dmemory_valid : imemory_valid;
    bram_instr = v.bram_d ? dmemory_instr : imemory_instr;
    bram_addr = v.bram_d ? dmem_addr : imem_addr;
    bram_wdata = v.bram_d ? dmemory_wdata : imemory_wdata;
    bram_wstrb = v.bram_d ? dmemory_wstrb : imemory_wstrb;

    uart_valid = v.uart_d ? dmemory_valid : imemory_valid;
    uart_instr = v.uart_d ? dmemory_instr : imemory_instr;
    uart_addr = v.uart_d ? dmem_addr : imem_addr;
    uart_wdata = v.uart_d ? dmemory_wdata : imemory_wdata;
    uart_wstrb = v.uart_d ? dmemory_wstrb : imemory_wstrb;

    clint_valid = v.clint_d ? dmemory_valid : imemory_valid;
    clint_instr = v.clint_d ? dmemory_instr : imemory_instr;
    clint_addr = v.clint_d ? dmem_addr : imem_addr;
    clint_wdata = v.clint_d ? dmemory_wdata : imemory_wdata;
    clint_wstrb = v.clint_d ? dmemory_wstrb : imemory_wstrb;

    rin = v;

    if (r.bram_i == 1 && bram_ready == 1) begin
      imemory_rdata = bram_rdata;
      imemory_ready = bram_ready;
    end else if (r.uart_i == 1 && uart_ready == 1) begin
      imemory_rdata = uart_rdata;
      imemory_ready = uart_ready;
    end else if (r.clint_i == 1 && clint_ready == 1) begin
      imemory_rdata = clint_rdata;
      imemory_ready = clint_ready;
    end else begin
      imemory_rdata = 0;
      imemory_ready = 0;
    end

    if (r.bram_d == 1 && bram_ready == 1) begin
      dmemory_rdata = bram_rdata;
      dmemory_ready = bram_ready;
    end else if (r.uart_d == 1 && uart_ready == 1) begin
      dmemory_rdata = uart_rdata;
      dmemory_ready = uart_ready;
    end else if (r.clint_d == 1 && clint_ready == 1) begin
      dmemory_rdata = clint_rdata;
      dmemory_ready = clint_ready;
    end else begin
      dmemory_rdata = 0;
      dmemory_ready = 0;
    end

  end

  always_ff @(posedge clk_pll) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

  cpu cpu_comp
  (
    .rst (rst),
    .clk (clk_pll),
    .imemory_valid (imemory_valid),
    .imemory_instr (imemory_instr),
    .imemory_addr (imemory_addr),
    .imemory_wdata (imemory_wdata),
    .imemory_wstrb (imemory_wstrb),
    .imemory_rdata (imemory_rdata),
    .imemory_ready (imemory_ready),
    .dmemory_valid (dmemory_valid),
    .dmemory_instr (dmemory_instr),
    .dmemory_addr (dmemory_addr),
    .dmemory_wdata (dmemory_wdata),
    .dmemory_wstrb (dmemory_wstrb),
    .dmemory_rdata (dmemory_rdata),
    .dmemory_ready (dmemory_ready),
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  bram bram_comp
  (
    .clk (clk_pll),
    .bram_wen (bram_wen),
    .bram_waddr (bram_addr[bram_depth+1:2]),
    .bram_raddr (bram_addr[bram_depth+1:2]),
    .bram_wdata (bram_wdata),
    .bram_wstrb (bram_wstrb),
    .bram_rdata (bram_rdata)
  );

  uart uart_comp
  (
    .rst (rst),
    .clk (clk_pll),
    .uart_valid (uart_valid),
    .uart_instr (uart_instr),
    .uart_addr (uart_addr),
    .uart_wdata (uart_wdata),
    .uart_wstrb (uart_wstrb),
    .uart_rdata (uart_rdata),
    .uart_ready (uart_ready),
    .uart_rx (rx),
    .uart_tx (tx)
  );

  clint clint_comp
  (
    .rst (rst),
    .clk (clk_pll),
    .rtc (rtc),
    .clint_valid (clint_valid),
    .clint_instr (clint_instr),
    .clint_addr (clint_addr),
    .clint_wdata (clint_wdata),
    .clint_wstrb (clint_wstrb),
    .clint_rdata (clint_rdata),
    .clint_ready (clint_ready),
    .clint_msip (msip),
    .clint_mtip (mtip),
    .clint_mtime (mtime)
  );

endmodule
