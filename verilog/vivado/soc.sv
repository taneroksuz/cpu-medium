import configure::*;

module soc
(
  input  logic rst,
  input  logic clk,
  input  logic rx,
  output logic tx,
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

  logic [0  : 0] bram_valid;
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

  logic [31 : 0] imem_addr;
  logic [31 : 0] dmem_addr;

  logic [31 : 0] ibase_addr;
  logic [31 : 0] dbase_addr;

  logic [0  : 0] bram_i;
  logic [0  : 0] bram_d;
  logic [0  : 0] uart_i;
  logic [0  : 0] uart_d;
  logic [0  : 0] clint_i;
  logic [0  : 0] clint_d;
  logic [0  : 0] axi_i;
  logic [0  : 0] axi_d;

  logic [0  : 0] bram_i_r;
  logic [0  : 0] bram_d_r;
  logic [0  : 0] uart_i_r;
  logic [0  : 0] uart_d_r;
  logic [0  : 0] clint_i_r;
  logic [0  : 0] clint_d_r;
  logic [0  : 0] axi_i_r;
  logic [0  : 0] axi_d_r;

  logic [0  : 0] bram_i_rin;
  logic [0  : 0] bram_d_rin;
  logic [0  : 0] uart_i_rin;
  logic [0  : 0] uart_d_rin;
  logic [0  : 0] clint_i_rin;
  logic [0  : 0] clint_d_rin;
  logic [0  : 0] axi_i_rin;
  logic [0  : 0] axi_d_rin;

  always_comb begin

    bram_i = bram_i_r;
    bram_d = bram_d_r;
    uart_i = uart_i_r;
    uart_d = uart_d_r;
    clint_i = clint_i_r;
    clint_d = clint_d_r;
    axi_i = axi_i_r;
    axi_d = axi_d_r;

    dbase_addr = 0;

    if (bram_ready == 1) begin
      bram_i = 0;
      bram_d = 0;
    end
    if (uart_ready == 1) begin
      uart_i = 0;
      uart_d = 0;
    end
    if (clint_ready == 1) begin
      clint_i = 0;
      clint_d = 0;
    end
    if (axi_ready == 1) begin
      axi_i = 0;
      axi_d = 0;
    end

    if (dmemory_valid == 1) begin
      if (dmemory_addr >= axi_base_addr &&
        dmemory_addr < axi_top_addr) begin
          axi_d = dmemory_valid;
          clint_d = 0;
          uart_d = 0;
          bram_d = 0;
          dbase_addr = axi_base_addr;
        end else if (dmemory_addr >= clint_base_addr &&
        dmemory_addr < clint_top_addr) begin
          axi_d = 0;
          clint_d = dmemory_valid;
          uart_d = 0;
          bram_d = 0;
          dbase_addr = clint_base_addr;
      end else if (dmemory_addr >= uart_base_addr &&
        dmemory_addr < uart_top_addr) begin
          axi_d = 0;
          clint_d = 0;
          uart_d = dmemory_valid;
          bram_d = 0;
          dbase_addr = uart_base_addr;
      end else if (dmemory_addr >= bram_base_addr &&
        dmemory_addr < bram_top_addr) begin
          axi_d = 0;
          clint_d = 0;
          uart_d = 0;
          bram_d = dmemory_valid;
          dbase_addr = bram_base_addr;
      end else begin
        axi_d = 0;
        clint_d = 0;
        uart_d = 0;
        bram_d = 0;
        dbase_addr = 0;
      end
    end

    dmem_addr = dmemory_addr - dbase_addr;

    ibase_addr = 0;

    if (imemory_valid == 1) begin
      if (imemory_addr >= axi_base_addr &&
        imemory_addr < axi_top_addr) begin
          axi_i = imemory_valid;
          clint_i = 0;
          uart_i = 0;
          bram_i = 0;
          ibase_addr = axi_base_addr;
      end else if (imemory_addr >= clint_base_addr &&
        imemory_addr < clint_top_addr) begin
          axi_i = 0;
          clint_i = imemory_valid;
          uart_i = 0;
          bram_i = 0;
          ibase_addr = clint_base_addr;
      end else if (imemory_addr >= uart_base_addr &&
        imemory_addr < uart_top_addr) begin
          axi_i = 0;
          clint_i = 0;
          uart_i = imemory_valid;
          bram_i = 0;
          ibase_addr = uart_base_addr;
      end else if (imemory_addr >= bram_base_addr &&
        imemory_addr < bram_top_addr) begin
          axi_i = 0;
          clint_i = 0;
          uart_i = 0;
          bram_i = imemory_valid;
          ibase_addr = bram_base_addr;
      end else begin
        axi_i = 0;
        clint_i = 0;
        uart_i = 0;
        bram_i = 0;
        ibase_addr = 0;
      end
    end

    if (bram_i == 1 && bram_d == 1) begin
      bram_i = 0;
    end
    if (uart_i == 1 && uart_d == 1) begin
      uart_i = 0;
    end
    if (clint_i == 1 && clint_d == 1) begin
      clint_i = 0;
    end
    if (axi_i == 1 && axi_d == 1) begin
      axi_i = 0;
    end

    imem_addr = imemory_addr - ibase_addr;

    if (bram_d == 1) begin
      bram_valid = dmemory_valid;
      bram_instr = dmemory_instr;
      bram_addr = dmem_addr;
      bram_wdata = dmemory_wdata;
      bram_wstrb = dmemory_wstrb;
    end else if (bram_i == 1) begin
      bram_valid = imemory_valid;
      bram_instr = imemory_instr;
      bram_addr = imem_addr;
      bram_wdata = imemory_wdata;
      bram_wstrb = imemory_wstrb;
    end else begin
      bram_valid = 0;
      bram_instr = 0;
      bram_addr = 0;
      bram_wdata = 0;
      bram_wstrb = 0;
    end

    if (uart_d == 1) begin
      uart_valid = dmemory_valid;
      uart_instr = dmemory_instr;
      uart_addr = dmem_addr;
      uart_wdata = dmemory_wdata;
      uart_wstrb = dmemory_wstrb;
    end else if (uart_i == 1) begin
      uart_valid = imemory_valid;
      uart_instr = imemory_instr;
      uart_addr = imem_addr;
      uart_wdata = imemory_wdata;
      uart_wstrb = imemory_wstrb;
    end else begin
      uart_valid = 0;
      uart_instr = 0;
      uart_addr = 0;
      uart_wdata = 0;
      uart_wstrb = 0;
    end

    if (clint_d == 1) begin
      clint_valid = dmemory_valid;
      clint_instr = dmemory_instr;
      clint_addr = dmem_addr;
      clint_wdata = dmemory_wdata;
      clint_wstrb = dmemory_wstrb;
    end else if (clint_i == 1) begin
      clint_valid = imemory_valid;
      clint_instr = imemory_instr;
      clint_addr = imem_addr;
      clint_wdata = imemory_wdata;
      clint_wstrb = imemory_wstrb;
    end else begin
      clint_valid = 0;
      clint_instr = 0;
      clint_addr = 0;
      clint_wdata = 0;
      clint_wstrb = 0;
    end

    if (axi_d == 1) begin
      axi_valid = dmemory_valid;
      axi_instr = dmemory_instr;
      axi_addr = dmem_addr;
      axi_wdata = dmemory_wdata;
      axi_wstrb = dmemory_wstrb;
    end else if (axi_i == 1) begin
      axi_valid = imemory_valid;
      axi_instr = imemory_instr;
      axi_addr = imem_addr;
      axi_wdata = imemory_wdata;
      axi_wstrb = imemory_wstrb;
    end else begin
      axi_valid = 0;
      axi_instr = 0;
      axi_addr = 0;
      axi_wdata = 0;
      axi_wstrb = 0;
    end

    bram_i_rin = bram_i;
    bram_d_rin = bram_d;
    uart_i_rin = uart_i;
    uart_d_rin = uart_d;
    clint_i_rin = clint_i;
    clint_d_rin = clint_d;
    axi_i_rin = axi_i;
    axi_d_rin = axi_d;

    if (bram_i_r == 1 && bram_ready == 1) begin
      imemory_rdata = bram_rdata;
      imemory_ready = bram_ready;
    end else if (uart_i_r == 1 && uart_ready == 1) begin
      imemory_rdata = uart_rdata;
      imemory_ready = uart_ready;
    end else if (clint_i_r == 1 && clint_ready == 1) begin
      imemory_rdata = clint_rdata;
      imemory_ready = clint_ready;
    end else if (axi_i_r == 1 && axi_ready == 1) begin
      imemory_rdata = axi_rdata;
      imemory_ready = axi_ready;
    end else begin
      imemory_rdata = 0;
      imemory_ready = 0;
    end

    if (bram_d_r == 1 && bram_ready == 1) begin
      dmemory_rdata = bram_rdata;
      dmemory_ready = bram_ready;
    end else if (uart_d_r == 1 && uart_ready == 1) begin
      dmemory_rdata = uart_rdata;
      dmemory_ready = uart_ready;
    end else if (clint_d_r == 1 && clint_ready == 1) begin
      dmemory_rdata = clint_rdata;
      dmemory_ready = clint_ready;
    end else if (axi_d_r == 1 && axi_ready == 1) begin
      dmemory_rdata = axi_rdata;
      dmemory_ready = axi_ready;
    end else begin
      dmemory_rdata = 0;
      dmemory_ready = 0;
    end

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      bram_i_r <= 0;
      bram_d_r <= 0;
      uart_i_r <= 0;
      uart_d_r <= 0;
      clint_i_r <= 0;
      clint_d_r <= 0;
      axi_i_r <= 0;
      axi_d_r <= 0;
    end else begin
      bram_i_r <= bram_i_rin;
      bram_d_r <= bram_d_rin;
      uart_i_r <= uart_i_rin;
      uart_d_r <= uart_d_rin;
      clint_i_r <= clint_i_rin;
      clint_d_r <= clint_d_rin;
      axi_i_r <= axi_i_rin;
      axi_d_r <= axi_d_rin;
    end
  end

  cpu cpu_comp
  (
    .rst (rst),
    .clk (clk),
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
    .rst (rst),
    .clk (clk),
    .bram_valid (bram_valid),
    .bram_instr (bram_instr),
    .bram_addr (bram_addr),
    .bram_wdata (bram_wdata),
    .bram_wstrb (bram_wstrb),
    .bram_rdata (bram_rdata),
    .bram_ready (bram_ready)
  );

  uart uart_comp
  (
    .rst (rst),
    .clk (clk),
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
    .clk (clk),
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
    .rst (rst),
    .clk (clk),
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
