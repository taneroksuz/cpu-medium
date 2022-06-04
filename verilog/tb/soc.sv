module soc
(
  input logic rst,
  input logic clk,
  input logic rtc
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

  logic [0  : 0] print_valid;
  logic [0  : 0] print_instr;
  logic [31 : 0] print_addr;
  logic [31 : 0] print_wdata;
  logic [3  : 0] print_wstrb;
  logic [31 : 0] print_rdata;
  logic [0  : 0] print_ready;

  logic [0  : 0] clint_valid;
  logic [0  : 0] clint_instr;
  logic [31 : 0] clint_addr;
  logic [31 : 0] clint_wdata;
  logic [3  : 0] clint_wstrb;
  logic [31 : 0] clint_rdata;
  logic [0  : 0] clint_ready;

  logic [0  : 0] debug_valid;
  logic [0  : 0] debug_instr;
  logic [31 : 0] debug_addr;
  logic [31 : 0] debug_wdata;
  logic [3  : 0] debug_wstrb;
  logic [31 : 0] debug_rdata;
  logic [0  : 0] debug_ready;

  logic [11 : 0] meid;
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
    logic [0  : 0] print_i;
    logic [0  : 0] print_d;
    logic [0  : 0] clint_i;
    logic [0  : 0] clint_d;
    logic [0  : 0] debug_i;
    logic [0  : 0] debug_d;
  } reg_type;

  parameter reg_type init_reg = '{
    bram_i : 0,
    bram_d : 0,
    print_i : 0,
    print_d : 0,
    clint_i : 0,
    clint_d : 0,
    debug_i : 0,
    debug_d : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    dbase_addr = 0;

    if (bram_ready == 1) begin
      v.bram_i = 0;
      v.bram_d = 0;
    end
    if (print_ready == 1) begin
      v.print_i = 0;
      v.print_d = 0;
    end
    if (clint_ready == 1) begin
      v.clint_i = 0;
      v.clint_d = 0;
    end
    if (debug_ready == 1) begin
      v.debug_i = 0;
      v.debug_d = 0;
    end

    if (dmemory_valid == 1) begin
      if (dmemory_addr >= debug_base_addr &&
        dmemory_addr < debug_top_addr) begin
          v.debug_d = dmemory_valid;
          v.print_d = 0;
          v.bram_d = 0;
          dbase_addr = debug_base_addr;
      end else if (dmemory_addr >= clint_base_addr &&
        dmemory_addr < clint_top_addr) begin
          v.debug_d = 0;
          v.clint_d = dmemory_valid;
          v.print_d = 0;
          v.bram_d = 0;
          dbase_addr = clint_base_addr;
      end else if (dmemory_addr >= print_base_addr &&
        dmemory_addr < print_top_addr) begin
          v.debug_d = 0;
          v.clint_d = 0;
          v.print_d = dmemory_valid;
          v.bram_d = 0;
          dbase_addr = print_base_addr;
      end else if (dmemory_addr >= bram_base_addr &&
        dmemory_addr < bram_top_addr) begin
          v.debug_d = 0;
          v.clint_d = 0;
          v.print_d = 0;
          v.bram_d = dmemory_valid;
          dbase_addr = bram_base_addr;
      end else begin
        v.debug_d = 0;
        v.clint_d = 0;
        v.print_d = 0;
        v.bram_d = dmemory_valid;
        dbase_addr = bram_base_addr;
      end
    end

    dmem_addr = dmemory_addr - dbase_addr;

    ibase_addr = 0;

    if (imemory_valid == 1) begin
      if (imemory_addr >= debug_base_addr &&
        imemory_addr < debug_top_addr) begin
          v.debug_i = dmemory_valid;
          v.print_i = 0;
          v.bram_i = 0;
          ibase_addr = debug_base_addr;
      end else if (imemory_addr >= clint_base_addr &&
        imemory_addr < clint_top_addr) begin
          v.debug_i = 0;
          v.clint_i = imemory_valid;
          v.print_i = 0;
          v.bram_i = 0;
          ibase_addr = clint_base_addr;
      end else if (imemory_addr >= print_base_addr &&
        imemory_addr < print_top_addr) begin
          v.debug_i = 0;
          v.clint_i = 0;
          v.print_i = imemory_valid;
          v.bram_i = 0;
          ibase_addr = print_base_addr;
      end else if (imemory_addr >= bram_base_addr &&
        imemory_addr < bram_top_addr) begin
          v.debug_i = 0;
          v.clint_i = 0;
          v.print_i = 0;
          v.bram_i = imemory_valid;
          ibase_addr = bram_base_addr;
      end else begin
        v.debug_i = 0;
        v.clint_i = 0;
        v.print_i = 0;
        v.bram_i = imemory_valid;
        ibase_addr = bram_base_addr;
      end
    end

    if (v.bram_i == 1 && v.bram_d == 1) begin
      v.bram_i = 0;
    end
    if (v.print_i == 1 && v.print_d == 1) begin
      v.print_i = 0;
    end
    if (v.clint_i == 1 && v.clint_d == 1) begin
      v.clint_i = 0;
    end
    if (v.debug_i == 1 && v.debug_d == 1) begin
      v.debug_i = 0;
    end

    imem_addr = imemory_addr - ibase_addr;

    bram_valid = v.bram_d ? dmemory_valid : imemory_valid;
    bram_instr = v.bram_d ? dmemory_instr : imemory_instr;
    bram_addr = v.bram_d ? dmem_addr : imem_addr;
    bram_wdata = v.bram_d ? dmemory_wdata : imemory_wdata;
    bram_wstrb = v.bram_d ? dmemory_wstrb : imemory_wstrb;

    print_valid = v.print_d ? dmemory_valid : imemory_valid;
    print_instr = v.print_d ? dmemory_instr : imemory_instr;
    print_addr = v.print_d ? dmem_addr : imem_addr;
    print_wdata = v.print_d ? dmemory_wdata : imemory_wdata;
    print_wstrb = v.print_d ? dmemory_wstrb : imemory_wstrb;

    clint_valid = v.clint_d ? dmemory_valid : imemory_valid;
    clint_instr = v.clint_d ? dmemory_instr : imemory_instr;
    clint_addr = v.clint_d ? dmem_addr : imem_addr;
    clint_wdata = v.clint_d ? dmemory_wdata : imemory_wdata;
    clint_wstrb = v.clint_d ? dmemory_wstrb : imemory_wstrb;

    debug_valid = v.debug_d ? dmemory_valid : imemory_valid;
    debug_instr = v.debug_d ? dmemory_instr : imemory_instr;
    debug_addr = v.debug_d ? dmem_addr : imem_addr;
    debug_wdata = v.debug_d ? dmemory_wdata : imemory_wdata;
    debug_wstrb = v.debug_d ? dmemory_wstrb : imemory_wstrb;

    rin = v;

    if (r.bram_i == 1 && bram_ready == 1) begin
      imemory_rdata = bram_rdata;
      imemory_ready = bram_ready;
    end else if (r.print_i == 1 && print_ready == 1) begin
      imemory_rdata = print_rdata;
      imemory_ready = print_ready;
    end else if (r.clint_i == 1 && clint_ready == 1) begin
      imemory_rdata = clint_rdata;
      imemory_ready = clint_ready;
    end else if (r.debug_i == 1 && debug_ready == 1) begin
      imemory_rdata = debug_rdata;
      imemory_ready = debug_ready;
    end else begin
      imemory_rdata = 0;
      imemory_ready = 0;
    end

    if (r.bram_d == 1 && bram_ready == 1) begin
      dmemory_rdata = bram_rdata;
      dmemory_ready = bram_ready;
    end else if (r.print_d == 1 && print_ready == 1) begin
      dmemory_rdata = print_rdata;
      dmemory_ready = print_ready;
    end else if (r.clint_d == 1 && clint_ready == 1) begin
      dmemory_rdata = clint_rdata;
      dmemory_ready = clint_ready;
    end else if (r.debug_d == 1 && debug_ready == 1) begin
      dmemory_rdata = debug_rdata;
      dmemory_ready = debug_ready;
    end else begin
      dmemory_rdata = 0;
      dmemory_ready = 0;
    end

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
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

  print print_comp
  (
    .rst (rst),
    .clk (clk),
    .print_valid (print_valid),
    .print_instr (print_instr),
    .print_addr (print_addr),
    .print_wdata (print_wdata),
    .print_wstrb (print_wstrb),
    .print_rdata (print_rdata),
    .print_ready (print_ready)
  );

  clint clint_comp
  (
    .rst (rst),
    .clk (clk),
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

  debug debug_comp
  (
    .rst (rst),
    .clk (clk),
    .rtc (rtc),
    .debug_valid (debug_valid),
    .debug_instr (debug_instr),
    .debug_addr (debug_addr),
    .debug_wdata (debug_wdata),
    .debug_wstrb (debug_wstrb),
    .debug_rdata (debug_rdata),
    .debug_ready (debug_ready)
  );

endmodule
