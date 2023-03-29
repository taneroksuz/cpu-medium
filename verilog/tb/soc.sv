import configure::*;

module soc;

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

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] imem_addr;
  logic [31 : 0] dmem_addr;

  logic [31 : 0] ibase_addr;
  logic [31 : 0] dbase_addr;

  logic [31 : 0] host[0:0] = '{default:'0};

  typedef struct packed{
    logic [0  : 0] bram_i;
    logic [0  : 0] bram_d;
    logic [0  : 0] print_i;
    logic [0  : 0] print_d;
    logic [0  : 0] clint_i;
    logic [0  : 0] clint_d;
  } reg_type;

  parameter reg_type init_reg = '{
    bram_i : 0,
    bram_d : 0,
    print_i : 0,
    print_d : 0,
    clint_i : 0,
    clint_d : 0
  };

  reg_type r,rin;
  reg_type v;

	logic reset = 0;
	logic clock = 0;

	initial begin
		$timeformat(-9,0,"ns",0);
		#10ns reset = 1;
	end

	always begin
		#1ns clock=~clock;
	end

  initial begin
    $readmemh("host.dat", host);
  end

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

    if (dmemory_valid == 1) begin
      if (dmemory_addr >= clint_base_addr &&
        dmemory_addr < clint_top_addr) begin
          v.clint_d = dmemory_valid;
          v.print_d = 0;
          v.bram_d = 0;
          dbase_addr = clint_base_addr;
      end else if (dmemory_addr >= print_base_addr &&
        dmemory_addr < print_top_addr) begin
          v.clint_d = 0;
          v.print_d = dmemory_valid;
          v.bram_d = 0;
          dbase_addr = print_base_addr;
      end else if (dmemory_addr >= bram_base_addr &&
        dmemory_addr < bram_top_addr) begin
          v.clint_d = 0;
          v.print_d = 0;
          v.bram_d = dmemory_valid;
          dbase_addr = bram_base_addr;
      end else if (dmemory_addr == host[0]) begin
          v.clint_d = 0;
          v.print_d = 0;
          v.bram_d = dmemory_valid;
          dbase_addr = bram_base_addr;
      end else begin
        v.clint_d = 0;
        v.print_d = 0;
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
          v.print_i = 0;
          v.bram_i = 0;
          ibase_addr = clint_base_addr;
      end else if (imemory_addr >= print_base_addr &&
        imemory_addr < print_top_addr) begin
          v.clint_i = 0;
          v.print_i = imemory_valid;
          v.bram_i = 0;
          ibase_addr = print_base_addr;
      end else if (imemory_addr >= bram_base_addr &&
        imemory_addr < bram_top_addr) begin
          v.clint_i = 0;
          v.print_i = 0;
          v.bram_i = imemory_valid;
          ibase_addr = bram_base_addr;
      end else if (imemory_addr == host[0]) begin
          v.clint_i = 0;
          v.print_i = 0;
          v.bram_i = imemory_valid;
          ibase_addr = bram_base_addr;
      end else begin
        v.clint_i = 0;
        v.print_i = 0;
        v.bram_i = 0;
        ibase_addr = 0;
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

    imem_addr = imemory_addr - ibase_addr;

    if (v.bram_d == 1) begin
      bram_valid = dmemory_valid;
      bram_instr = dmemory_instr;
      bram_addr = dmem_addr;
      bram_wdata = dmemory_wdata;
      bram_wstrb = dmemory_wstrb;
    end else if (v.bram_i == 1) begin
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

    if (v.print_d == 1) begin
      print_valid = dmemory_valid;
      print_instr = dmemory_instr;
      print_addr = dmem_addr;
      print_wdata = dmemory_wdata;
      print_wstrb = dmemory_wstrb;
    end else if (v.print_i == 1) begin
      print_valid = imemory_valid;
      print_instr = imemory_instr;
      print_addr = imem_addr;
      print_wdata = imemory_wdata;
      print_wstrb = imemory_wstrb;
    end else begin
      print_valid = 0;
      print_instr = 0;
      print_addr = 0;
      print_wdata = 0;
      print_wstrb = 0;
    end

    if (v.clint_d == 1) begin
      clint_valid = dmemory_valid;
      clint_instr = dmemory_instr;
      clint_addr = dmem_addr;
      clint_wdata = dmemory_wdata;
      clint_wstrb = dmemory_wstrb;
    end else if (v.clint_i == 1) begin
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
    end else begin
      dmemory_rdata = 0;
      dmemory_ready = 0;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
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

  print print_comp
  (
    .reset (reset),
    .clock (clock),
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

endmodule
