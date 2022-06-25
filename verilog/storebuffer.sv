package store_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [storebuffer_depth-1 : 0] waddr;
    logic [storebuffer_depth-1 : 0] raddr;
    logic [67 : 0] wdata;
  } storebuffer_data_in_type;

  typedef struct packed{
    logic [67 : 0] rdata;
  } storebuffer_data_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import store_wires::*;

module storebuffer_data
(
  input logic clk,
  input storebuffer_data_in_type storebuffer_data_in,
  output storebuffer_data_out_type storebuffer_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [67 : 0] storebuffer_data_array[0:2**storebuffer_depth-1] = '{default:'0};

  assign storebuffer_data_out.rdata = storebuffer_data_array[storebuffer_data_in.raddr];

  always_ff @(posedge clk) begin
    if (storebuffer_data_in.wen == 1) begin
      storebuffer_data_array[storebuffer_data_in.waddr] <= storebuffer_data_in.wdata;
    end
  end

endmodule

module storebuffer_ctrl
(
  input logic rst,
  input logic clk,
  input storebuffer_data_out_type storebuffer_data_out,
  output storebuffer_data_in_type storebuffer_data_in,
  input mem_in_type storebuffer_in,
  output mem_out_type storebuffer_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  typedef struct packed{
    logic [storebuffer_depth-1:0] waddr;
    logic [storebuffer_depth-1:0] raddr;
    logic [31:0] addr;
    logic [31:0] baddr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [31:0] bwdata;
    logic [67:0] brdata;
    logic [3:0] wstrb;
    logic [3:0] bwstrb;
    logic [0:0] bstore;
    logic [0:0] bload;
    logic [0:0] bfence;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] load;
    logic [0:0] overflow;
    logic [0:0] bypass;
    logic [0:0] empty;
    logic [0:0] full;
    logic [0:0] fence;
    logic [0:0] valid;
    logic [0:0] ready;
    logic [0:0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    waddr : 0,
    raddr : 0,
    addr : 0,
    baddr : 0,
    wdata : 0,
    rdata : 0,
    bwdata : 0,
    brdata : 0,
    wstrb : 0,
    bwstrb : 0,
    bstore : 0,
    bload : 0,
    bfence : 0,
    wren : 0,
    rden : 0,
    load : 0,
    overflow : 0,
    bypass : 0,
    empty : 0,
    full : 0,
    fence : 0,
    valid : 0,
    ready : 0,
    stall : 0
  };

  reg_type r,rin = init_reg;
  reg_type v = init_reg;

  always_comb begin

    v = r;

    if (r.wren == 1) begin
      v.rdata = 0;
      v.ready = 1;
    end else if (r.bypass == 1) begin
      v.rdata = 0;
      v.ready = 1;
    end else if (r.fence == 1) begin
      v.rdata = 0;
      v.ready = dmem_out.mem_ready;
    end else if (r.load == 1) begin
      v.rdata = dmem_out.mem_rdata;
      v.ready = dmem_out.mem_ready;
    end else begin
      v.rdata = 0;
      v.ready = 0;
    end

    if (v.ready == 1) begin
      if (v.fence == 1) begin
        v.fence = 0;
      end else if (v.load == 1) begin
        v.load = 0;
      end
    end

    if (dmem_out.mem_ready == 1) begin
      v.empty = 0;
    end

    storebuffer_out.mem_rdata = v.rdata;
    storebuffer_out.mem_ready = v.ready;

    v.bstore = 0;

    if (storebuffer_in.mem_valid == 1) begin
      v.bfence = storebuffer_in.mem_fence;
      v.bstore = |storebuffer_in.mem_wstrb;
      v.bload = ~(|storebuffer_in.mem_wstrb);
      v.baddr = storebuffer_in.mem_addr;
      v.bwstrb = storebuffer_in.mem_wstrb;
      v.bwdata = storebuffer_in.mem_wdata;
    end

    if (r.full == 1 && r.bstore == 1) begin
      v.bstore = 1;
    end

    v.wren = 0;
    v.full = 0;
    if (v.bstore == 1) begin
      if (v.overflow == 1 && v.waddr<v.raddr) begin
        v.wren = 1;
      end else if (v.overflow == 0) begin
        v.wren = 1;
      end else begin
        v.full = 1;
      end
    end

    if (dmem_out.mem_ready == 1) begin
      if (v.rden == 1) begin
        if (v.raddr == 2**storebuffer_depth-1) begin
          v.overflow = 0;
          v.raddr = 0;
        end else begin
          v.raddr = v.raddr + 1;
        end
      end
    end

    v.rden = 0;
    if (v.overflow == 0 && v.raddr<v.waddr) begin
      v.rden = 1;
    end else if (v.overflow == 1) begin
      v.rden = 1;
    end

    v.bypass = 0;
    if (v.wren == 1 && v.rden == 0) begin
      if (v.empty == 0) begin
        v.wren = 0;
        v.empty = 1;
        v.bypass = 1;
      end
    end else if (v.rden == 1) begin
      if (v.empty == 1) begin
        v.rden = 0;
      end
    end

    storebuffer_data_in.wen = v.wren;
    storebuffer_data_in.waddr = v.waddr;
    storebuffer_data_in.wdata = {v.bwstrb,v.baddr,v.bwdata};

    storebuffer_data_in.raddr = v.raddr;

    v.brdata = storebuffer_data_out.rdata;

    if (v.wren == 1) begin
      if (v.waddr == 2**storebuffer_depth-1) begin
        v.overflow = 1;
        v.waddr = 0;
      end else begin
        v.waddr = v.waddr + 1;
      end
    end

    if ((v.rden | v.wren) == 0) begin
      if (v.empty == 0) begin
        if (v.bfence == 1) begin
          v.fence = 1;
        end else if (v.bload == 1) begin
          v.load = 1;
        end
        v.bfence = 0;
        v.bload = 0;
      end
    end

    if (v.rden == 1) begin
      v.wstrb = v.brdata[67:64];
      v.addr = v.brdata[63:32];
      v.wdata = v.brdata[31:0];
    end else if (v.load == 1) begin
      v.wstrb = v.bwstrb;
      v.addr = v.baddr;
      v.wdata = v.bwdata;
    end else if (v.bypass == 1) begin
      v.wstrb = v.bwstrb;
      v.addr = v.baddr;
      v.wdata = v.bwdata;
    end else begin
      v.wstrb = 0;
      v.addr = 0;
      v.wdata = 0;
    end

    v.valid = v.rden | v.load | v.fence | v.bypass;
    if ((r.rden | r.load | r.fence | r.bypass) == 1) begin
      if (dmem_out.mem_ready == 0) begin
        v.valid = 0;
      end
    end

    dmem_in.mem_valid = v.valid;
    dmem_in.mem_fence = v.fence;
    dmem_in.mem_instr = 0;
    dmem_in.mem_addr = v.addr;
    dmem_in.mem_wdata = v.wdata;
    dmem_in.mem_wstrb = v.wstrb;

    rin = v;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module storebuffer
(
  input logic rst,
  input logic clk,
  input mem_in_type storebuffer_in,
  output mem_out_type storebuffer_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  storebuffer_data_in_type storebuffer_data_in;
  storebuffer_data_out_type storebuffer_data_out;

  storebuffer_data storebuffer_data_comp
  (
    .clk (clk),
    .storebuffer_data_in (storebuffer_data_in),
    .storebuffer_data_out (storebuffer_data_out)
  );

  storebuffer_ctrl storebuffer_ctrl_comp
  (
    .rst (rst),
    .clk (clk),
    .storebuffer_data_out (storebuffer_data_out),
    .storebuffer_data_in (storebuffer_data_in),
    .storebuffer_in (storebuffer_in),
    .storebuffer_out (storebuffer_out),
    .dmem_out (dmem_out),
    .dmem_in (dmem_in)
  );

endmodule
