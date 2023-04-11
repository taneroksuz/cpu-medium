import configure::*;

module soc
(
  input  logic reset,
  input  logic clock,
  input  logic uart_rx,
  output logic uart_tx,
  output logic [31 : 0] m_axi_awaddr,
  output logic [7  : 0] m_axi_awlen,
  output logic [2  : 0] m_axi_awsize,
  output logic [1  : 0] m_axi_awburst,
  output logic [0  : 0] m_axi_awlock,
  output logic [3  : 0] m_axi_awcache,
  output logic [2  : 0] m_axi_awprot,
  output logic [3  : 0] m_axi_awqos,
  output logic [0  : 0] m_axi_awvalid,
  input  logic [0  : 0] m_axi_awready,
  output logic [31 : 0] m_axi_wdata,
  output logic [3  : 0] m_axi_wstrb,
  output logic [0  : 0] m_axi_wlast,
  output logic [0  : 0] m_axi_wvalid,
  input  logic [0  : 0] m_axi_wready,
  input  logic [1  : 0] m_axi_bresp,
  input  logic [0  : 0] m_axi_bvalid,
  output logic [0  : 0] m_axi_bready,
  output logic [31 : 0] m_axi_araddr,
  output logic [7  : 0] m_axi_arlen,
  output logic [2  : 0] m_axi_arsize,
  output logic [1  : 0] m_axi_arburst,
  output logic [0  : 0] m_axi_arlock,
  output logic [3  : 0] m_axi_arcache,
  output logic [2  : 0] m_axi_arprot,
  output logic [3  : 0] m_axi_arqos,
  output logic [0  : 0] m_axi_arvalid,
  input  logic [0  : 0] m_axi_arready,
  input  logic [31 : 0] m_axi_rdata,
  input  logic [1  : 0] m_axi_rresp,
  input  logic [0  : 0] m_axi_rlast,
  input  logic [0  : 0] m_axi_rvalid,
  output logic [0  : 0] m_axi_rready
);
  timeunit 1ns;
  timeprecision 1ps;

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

  logic [0  : 0] memory_valid;
  logic [0  : 0] memory_instr;
  logic [31 : 0] memory_addr;
  logic [31 : 0] memory_wdata;
  logic [3  : 0] memory_wstrb;
  logic [31 : 0] memory_rdata;
  logic [0  : 0] memory_ready;

  logic [0  : 0] rom_valid;
  logic [0  : 0] rom_instr;
  logic [31 : 0] rom_addr;
  logic [31 : 0] rom_rdata;
  logic [0  : 0] rom_ready;

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

  logic [0  : 0] axi_valid;
  logic [0  : 0] axi_instr;
  logic [31 : 0] axi_addr;
  logic [31 : 0] axi_wdata;
  logic [3  : 0] axi_wstrb;
  logic [31 : 0] axi_rdata;
  logic [0  : 0] axi_ready;

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] mem_addr;

  logic [31 : 0] base_addr;

  always_comb begin

    rom_valid = 0;
    uart_valid = 0;
    clint_valid = 0;
    axi_valid = 0;

    base_addr = 0;

    if (memory_valid == 1) begin
      if (memory_addr >= axi_base_addr &&
        memory_addr < axi_top_addr) begin
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          axi_valid = memory_valid;
          base_addr = axi_base_addr;
      end else if (memory_addr >= clint_base_addr &&
        memory_addr < clint_top_addr) begin
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = memory_valid;
          axi_valid = 0;
          base_addr = clint_base_addr;
      end else if (memory_addr >= uart_base_addr &&
        memory_addr < uart_top_addr) begin
          rom_valid = 0;
          uart_valid = memory_valid;
          clint_valid = 0;
          axi_valid = 0;
          base_addr = uart_base_addr;
      end else if (memory_addr >= rom_base_addr &&
        memory_addr < rom_top_addr) begin
          rom_valid = memory_valid;
          uart_valid = 0;
          clint_valid = 0;
          axi_valid = 0;
          base_addr = rom_base_addr;
      end else begin
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          axi_valid = 0;
          base_addr = 0;
      end
    end

    mem_addr = memory_addr - base_addr;

    rom_instr = memory_instr;
    rom_addr = mem_addr;

    uart_instr = memory_instr;
    uart_addr = mem_addr;
    uart_wdata = memory_wdata;
    uart_wstrb = memory_wstrb;

    clint_instr = memory_instr;
    clint_addr = mem_addr;
    clint_wdata = memory_wdata;
    clint_wstrb = memory_wstrb;

    axi_instr = memory_instr;
    axi_addr = mem_addr;
    axi_wdata = memory_wdata;
    axi_wstrb = memory_wstrb;

    if (rom_ready == 1) begin
      memory_rdata = rom_rdata;
      memory_ready = rom_ready;
    end else if  (uart_ready == 1) begin
      memory_rdata = uart_rdata;
      memory_ready = uart_ready;
    end else if  (clint_ready == 1) begin
      memory_rdata = clint_rdata;
      memory_ready = clint_ready;
    end else if  (axi_ready == 1) begin
      memory_rdata = axi_rdata;
      memory_ready = axi_ready;
    end else begin
      memory_rdata = 0;
      memory_ready = 0;
    end

  end

  cpu cpu_comp
  (
    .reset (reset),
    .clock (clock),
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

  arbiter arbiter_comp
  (
    .reset (reset),
    .clock (clock),
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
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready)
  );

  rom rom_comp
  (
    .reset (reset),
    .clock (clock),
    .rom_valid (rom_valid),
    .rom_instr (rom_instr),
    .rom_addr (rom_addr),
    .rom_rdata (rom_rdata),
    .rom_ready (rom_ready)
  );

  uart uart_comp
  (
    .reset (reset),
    .clock (clock),
    .uart_valid (uart_valid),
    .uart_instr (uart_instr),
    .uart_addr (uart_addr),
    .uart_wdata (uart_wdata),
    .uart_wstrb (uart_wstrb),
    .uart_rdata (uart_rdata),
    .uart_ready (uart_ready),
    .uart_rx (uart_rx),
    .uart_tx (uart_tx)
  );

  clint clint_comp
  (
    .reset (reset),
    .clock (clock),
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

  axi axi_comp
  (
    .reset (reset),
    .clock (clock),
    .axi_valid (axi_valid),
    .axi_instr (axi_instr),
    .axi_addr (axi_addr),
    .axi_wdata (axi_wdata),
    .axi_wstrb (axi_wstrb),
    .axi_rdata (axi_rdata),
    .axi_ready (axi_ready),
    .m_axi_awaddr (m_axi_awaddr),
    .m_axi_awlen (m_axi_awlen),
    .m_axi_awsize (m_axi_awsize),
    .m_axi_awburst (m_axi_awburst),
    .m_axi_awlock (m_axi_awlock),
    .m_axi_awcache (m_axi_awcache),
    .m_axi_awprot (m_axi_awprot),
    .m_axi_awqos (m_axi_awqos),
    .m_axi_awvalid (m_axi_awvalid),
    .m_axi_awready (m_axi_awready),
    .m_axi_wdata (m_axi_wdata),
    .m_axi_wstrb (m_axi_wstrb),
    .m_axi_wlast (m_axi_wlast),
    .m_axi_wvalid (m_axi_wvalid),
    .m_axi_wready (m_axi_wready),
    .m_axi_bresp (m_axi_bresp),
    .m_axi_bvalid (m_axi_bvalid),
    .m_axi_bready (m_axi_bready),
    .m_axi_araddr (m_axi_araddr),
    .m_axi_arlen (m_axi_arlen),
    .m_axi_arsize (m_axi_arsize),
    .m_axi_arburst (m_axi_arburst),
    .m_axi_arlock (m_axi_arlock),
    .m_axi_arcache (m_axi_arcache),
    .m_axi_arprot (m_axi_arprot),
    .m_axi_arqos (m_axi_arqos),
    .m_axi_arvalid (m_axi_arvalid),
    .m_axi_arready (m_axi_arready),
    .m_axi_rdata (m_axi_rdata),
    .m_axi_rresp (m_axi_rresp),
    .m_axi_rlast (m_axi_rlast),
    .m_axi_rvalid (m_axi_rvalid),
    .m_axi_rready (m_axi_rready)
  );

endmodule
