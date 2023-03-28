import configure::*;

module soc
(
  input  logic reset,
  input  logic clock,
  input  logic rx,
  output logic tx,
  output logic [31 : 0] m_avl_address,
  output logic [3  : 0] m_avl_byteenable,
  output logic [0  : 0] m_avl_lock,
  output logic [0  : 0] m_avl_read,
  output logic [31 : 0] m_avl_writedata,
  output logic [0  : 0] m_avl_write,
  output logic [2  : 0] m_avl_burstcount,
  input  logic [31 : 0] m_avl_readdata,
  input  logic [1  : 0] m_avl_response,
  input  logic [0  : 0] m_avl_waitrequest,
  input  logic [0  : 0] m_avl_readdatavalid,
  input  logic [0  : 0] m_avl_writeresponsevalid
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

  logic [0  : 0] avl_valid;
  logic [0  : 0] avl_instr;
  logic [31 : 0] avl_addr;
  logic [31 : 0] avl_wdata;
  logic [3  : 0] avl_wstrb;
  logic [31 : 0] avl_rdata;
  logic [0  : 0] avl_ready;

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
  logic [0  : 0] avl_i;
  logic [0  : 0] avl_d;

  logic [0  : 0] bram_i_r;
  logic [0  : 0] bram_d_r;
  logic [0  : 0] uart_i_r;
  logic [0  : 0] uart_d_r;
  logic [0  : 0] clint_i_r;
  logic [0  : 0] clint_d_r;
  logic [0  : 0] avl_i_r;
  logic [0  : 0] avl_d_r;

  logic [0  : 0] bram_i_rin;
  logic [0  : 0] bram_d_rin;
  logic [0  : 0] uart_i_rin;
  logic [0  : 0] uart_d_rin;
  logic [0  : 0] clint_i_rin;
  logic [0  : 0] clint_d_rin;
  logic [0  : 0] avl_i_rin;
  logic [0  : 0] avl_d_rin;

  always_comb begin

    bram_i = bram_i_r;
    bram_d = bram_d_r;
    uart_i = uart_i_r;
    uart_d = uart_d_r;
    clint_i = clint_i_r;
    clint_d = clint_d_r;
    avl_i = avl_i_r;
    avl_d = avl_d_r;

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
    if (avl_ready == 1) begin
      avl_i = 0;
      avl_d = 0;
    end

    if (dmemory_valid == 1) begin
      if (dmemory_addr >= avl_base_addr &&
        dmemory_addr < avl_top_addr) begin
          avl_d = dmemory_valid;
          clint_d = 0;
          uart_d = 0;
          bram_d = 0;
          dbase_addr = avl_base_addr;
        end else if (dmemory_addr >= clint_base_addr &&
        dmemory_addr < clint_top_addr) begin
          avl_d = 0;
          clint_d = dmemory_valid;
          uart_d = 0;
          bram_d = 0;
          dbase_addr = clint_base_addr;
      end else if (dmemory_addr >= uart_base_addr &&
        dmemory_addr < uart_top_addr) begin
          avl_d = 0;
          clint_d = 0;
          uart_d = dmemory_valid;
          bram_d = 0;
          dbase_addr = uart_base_addr;
      end else if (dmemory_addr >= bram_base_addr &&
        dmemory_addr < bram_top_addr) begin
          avl_d = 0;
          clint_d = 0;
          uart_d = 0;
          bram_d = dmemory_valid;
          dbase_addr = bram_base_addr;
      end else begin
        avl_d = 0;
        clint_d = 0;
        uart_d = 0;
        bram_d = 0;
        dbase_addr = 0;
      end
    end

    dmem_addr = dmemory_addr - dbase_addr;

    ibase_addr = 0;

    if (imemory_valid == 1) begin
      if (imemory_addr >= avl_base_addr &&
        imemory_addr < avl_top_addr) begin
          avl_i = imemory_valid;
          clint_i = 0;
          uart_i = 0;
          bram_i = 0;
          ibase_addr = avl_base_addr;
      end else if (imemory_addr >= clint_base_addr &&
        imemory_addr < clint_top_addr) begin
          avl_i = 0;
          clint_i = imemory_valid;
          uart_i = 0;
          bram_i = 0;
          ibase_addr = clint_base_addr;
      end else if (imemory_addr >= uart_base_addr &&
        imemory_addr < uart_top_addr) begin
          avl_i = 0;
          clint_i = 0;
          uart_i = imemory_valid;
          bram_i = 0;
          ibase_addr = uart_base_addr;
      end else if (imemory_addr >= bram_base_addr &&
        imemory_addr < bram_top_addr) begin
          avl_i = 0;
          clint_i = 0;
          uart_i = 0;
          bram_i = imemory_valid;
          ibase_addr = bram_base_addr;
      end else begin
        avl_i = 0;
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
    if (avl_i == 1 && avl_d == 1) begin
      avl_i = 0;
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

    if (avl_d == 1) begin
      avl_valid = dmemory_valid;
      avl_instr = dmemory_instr;
      avl_addr = dmem_addr;
      avl_wdata = dmemory_wdata;
      avl_wstrb = dmemory_wstrb;
    end else if (avl_i == 1) begin
      avl_valid = imemory_valid;
      avl_instr = imemory_instr;
      avl_addr = imem_addr;
      avl_wdata = imemory_wdata;
      avl_wstrb = imemory_wstrb;
    end else begin
      avl_valid = 0;
      avl_instr = 0;
      avl_addr = 0;
      avl_wdata = 0;
      avl_wstrb = 0;
    end

    bram_i_rin = bram_i;
    bram_d_rin = bram_d;
    uart_i_rin = uart_i;
    uart_d_rin = uart_d;
    clint_i_rin = clint_i;
    clint_d_rin = clint_d;
    avl_i_rin = avl_i;
    avl_d_rin = avl_d;

    if (bram_i_r == 1 && bram_ready == 1) begin
      imemory_rdata = bram_rdata;
      imemory_ready = bram_ready;
    end else if (uart_i_r == 1 && uart_ready == 1) begin
      imemory_rdata = uart_rdata;
      imemory_ready = uart_ready;
    end else if (clint_i_r == 1 && clint_ready == 1) begin
      imemory_rdata = clint_rdata;
      imemory_ready = clint_ready;
    end else if (avl_i_r == 1 && avl_ready == 1) begin
      imemory_rdata = avl_rdata;
      imemory_ready = avl_ready;
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
    end else if (avl_d_r == 1 && avl_ready == 1) begin
      dmemory_rdata = avl_rdata;
      dmemory_ready = avl_ready;
    end else begin
      dmemory_rdata = 0;
      dmemory_ready = 0;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      bram_i_r <= 0;
      bram_d_r <= 0;
      uart_i_r <= 0;
      uart_d_r <= 0;
      clint_i_r <= 0;
      clint_d_r <= 0;
      avl_i_r <= 0;
      avl_d_r <= 0;
    end else begin
      bram_i_r <= bram_i_rin;
      bram_d_r <= bram_d_rin;
      uart_i_r <= uart_i_rin;
      uart_d_r <= uart_d_rin;
      clint_i_r <= clint_i_rin;
      clint_d_r <= clint_d_rin;
      avl_i_r <= avl_i_rin;
      avl_d_r <= avl_d_rin;
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

  bram bram_comp
  (
    .reset (reset),
    .clock (clock),
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
    .reset (reset),
    .clock (clock),
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

  avl avl_comp
  (
    .reset (reset),
    .clock (clock),
    .avl_valid (avl_valid),
    .avl_instr (avl_instr),
    .avl_addr (avl_addr),
    .avl_wdata (avl_wdata),
    .avl_wstrb (avl_wstrb),
    .avl_rdata (avl_rdata),
    .avl_ready (avl_ready),
    .m_avl_address (m_avl_address),
    .m_avl_byteenable (m_avl_byteenable),
    .m_avl_lock (m_avl_lock),
    .m_avl_read (m_avl_read),
    .m_avl_writedata (m_avl_writedata),
    .m_avl_write (m_avl_write),
    .m_avl_burstcount (m_avl_burstcount),
    .m_avl_readdata (m_avl_readdata),
    .m_avl_response (m_avl_response),
    .m_avl_waitrequest (m_avl_waitrequest),
    .m_avl_readdatavalid (m_avl_readdatavalid),
    .m_avl_writeresponsevalid (m_avl_writeresponsevalid)
  );

endmodule
