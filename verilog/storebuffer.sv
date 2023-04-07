package store_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(storebuffer_depth-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [depth-1 : 0] waddr;
    logic [depth-1 : 0] raddr;
    logic [67 : 0] wdata;
  } storebuffer_data_in_type;

  typedef struct packed{
    logic [67 : 0] rdata;
  } storebuffer_data_out_type;

  typedef struct packed{
    logic [0 : 0] rden;
    logic [0 : 0] wren;
    logic [67 : 0] wdata;
  } storebuffer_fifo_in_type;

  typedef struct packed{
    logic [67 : 0] rdata;
    logic [0 : 0] wready;
    logic [0 : 0] rready;
    logic [0 : 0] full;
    logic [0 : 0] pass;
  } storebuffer_fifo_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import store_wires::*;

module storebuffer_data
(
  input logic clock,
  input storebuffer_data_in_type storebuffer_data_in,
  output storebuffer_data_out_type storebuffer_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [67 : 0] storebuffer_data_array[0:storebuffer_depth-1] = '{default:'0};

  assign storebuffer_data_out.rdata = storebuffer_data_array[storebuffer_data_in.raddr];

  always_ff @(posedge clock) begin
    if (storebuffer_data_in.wen == 1) begin
      storebuffer_data_array[storebuffer_data_in.waddr] <= storebuffer_data_in.wdata;
    end
  end

endmodule

module storebuffer_fifo
(
  input logic reset,
  input logic clock,
  output storebuffer_data_in_type storebuffer_data_in,
  input storebuffer_data_out_type storebuffer_data_out,
  input storebuffer_fifo_in_type storebuffer_fifo_in,
  output storebuffer_fifo_out_type storebuffer_fifo_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(storebuffer_depth-1);

  typedef struct packed{
    logic [depth-1:0] waddr;
    logic [depth-1:0] raddr;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] full;
    logic [0:0] pass;
    logic [0:0] oflow;
  } reg_type;

  parameter reg_type init_reg = '{
    waddr : 0,
    raddr : 0,
    wren : 0,
    rden : 0,
    full : 0,
    pass : 0,
    oflow : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin
    v = r;

    v.wren = 0;
    v.full = 0;
    if (storebuffer_fifo_in.wren == 1) begin
      if (v.oflow == 1 && v.waddr < v.raddr) begin
        v.wren = 1;
      end else if (v.oflow == 0) begin
        v.wren = 1;
      end else begin
        v.full = 1;
      end
    end

    v.rden = 0;
    v.pass = 0;
    if (storebuffer_fifo_in.rden == 1) begin
      if (v.oflow == 0 && v.raddr < v.waddr) begin
        v.rden = 1;
      end else if (v.oflow == 1) begin
        v.rden = 1;
      end else begin
        v.pass = v.wren;
      end
    end

    if (v.wren == 1) begin
      if (&(v.waddr) == 1) begin
        v.oflow = 1;
        v.waddr = 0;
      end else begin
        v.waddr = v.waddr + 1;
      end
    end

    if (v.rden == 1 | v.pass == 1) begin
      if (&(v.raddr) == 1) begin
        v.oflow = 0;
        v.raddr = 0;
      end else begin
        v.raddr = v.raddr + 1;
      end
    end

    storebuffer_data_in.wen = v.wren;
    storebuffer_data_in.waddr = v.waddr;
    storebuffer_data_in.wdata = storebuffer_fifo_in.wdata;

    storebuffer_data_in.raddr = v.raddr;

    storebuffer_fifo_out.rdata = storebuffer_data_out.rdata;
    storebuffer_fifo_out.wready = v.wren;
    storebuffer_fifo_out.rready = v.rden;
    storebuffer_fifo_out.full = v.full;
    storebuffer_fifo_out.pass = v.pass;

    rin = v;
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module storebuffer_ctrl
(
  input logic reset,
  input logic clock,
  input storebuffer_fifo_out_type storebuffer_fifo_out,
  output storebuffer_fifo_in_type storebuffer_fifo_in,
  input mem_in_type storebuffer_in,
  output mem_out_type storebuffer_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(storebuffer_depth-1);

  localparam [1:0] idle = 0;
  localparam [1:0] active = 1;
  localparam [1:0] load = 2;
  localparam [1:0] fence = 3;

  typedef struct packed{
    logic [1:0] state;
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
    logic [0:0] bwren;
    logic [0:0] brden;
    logic [0:0] bwready;
    logic [0:0] brready;
    logic [0:0] bfull;
    logic [0:0] bpass;
    logic [0:0] fence;
    logic [0:0] valid;
    logic [0:0] ready;
    logic [0:0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    state : 0,
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
    bwren : 0,
    brden : 0,
    bwready : 0,
    brready : 0,
    bfull : 0,
    bpass : 0,
    fence : 0,
    valid : 0,
    ready : 0,
    stall : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    v.rdata = 0;
    v.ready = 0;

    if (r.bwready == 1) begin
      v.bstore = 0;
      v.rdata = 0;
      v.ready = 1;
    end

    case(r.state)
      load : begin
        v.bload = 0;
        v.rdata = dmem_out.mem_rdata;
        v.ready = dmem_out.mem_ready;
        if (dmem_out.mem_ready == 1) begin
          v.state = idle;
        end
      end
      fence : begin
        v.bfence = 0;
        v.rdata = 0;
        v.ready = dmem_out.mem_ready;
        if (dmem_out.mem_ready == 1) begin
          v.state = idle;
        end
      end
      default : begin
      end
    endcase

    storebuffer_out.mem_rdata = v.rdata;
    storebuffer_out.mem_ready = v.ready;

    if (storebuffer_in.mem_valid == 1) begin
      v.bfence = storebuffer_in.mem_fence;
      v.bstore = |storebuffer_in.mem_wstrb;
      v.bload = ~v.bstore & ~v.bfence;
      v.baddr = storebuffer_in.mem_addr;
      v.bwstrb = storebuffer_in.mem_wstrb;
      v.bwdata = storebuffer_in.mem_wdata;
    end

    if (v.bstore == 1) begin
      v.bwren = 1;
    end else begin
      v.bwren = 0;
    end

    case(v.state)
      idle : begin
        if (v.bstore == 1) begin
          v.state = active;
          v.brden = 1;
        end else if (v.bload == 1) begin
          v.state = load;
          v.brden = 0;
        end else if (v.bfence == 1) begin
          v.state = fence;
          v.brden = 0;
        end else begin
          v.brden = 0;
        end
      end
      active : begin
        if (dmem_out.mem_ready == 1) begin
          v.state = active;
          v.brden = 1;
        end else begin
          v.brden = 0;
        end
      end
      default : begin
        v.brden = 0;
      end
    endcase

    storebuffer_fifo_in.wren = v.bwren;
    storebuffer_fifo_in.wdata = {v.baddr,v.bwdata,v.bwstrb};

    storebuffer_fifo_in.rden = v.brden;

    v.brdata = storebuffer_fifo_out.rdata;
    v.bwready = storebuffer_fifo_out.wready;
    v.brready = storebuffer_fifo_out.rready;
    v.bfull = storebuffer_fifo_out.full;
    v.bpass = storebuffer_fifo_out.pass;

    case(v.state)
      active : begin
        if (v.brden == 1) begin
          if (v.brready == 1) begin
            v.valid = 1;
            v.fence = 0;
            v.addr = v.brdata[67:36];
            v.wdata = v.brdata[35:4];
            v.wstrb = v.brdata[3:0];
          end else if (v.bpass == 1) begin
            v.valid = 1;
            v.fence = 0;
            v.addr = v.baddr;
            v.wdata = v.bwdata;
            v.wstrb = v.bwstrb;
          end else begin
            v.valid = 0;
            v.fence = 0;
            v.addr = 0;
            v.wdata = 0;
            v.wstrb = 0;
            v.state = idle;
          end
        end
      end
      load : begin
        v.valid = 1;
        v.fence = 0;
        v.addr = v.baddr;
        v.wdata = 0;
        v.wstrb = 0;
      end
      fence : begin
        v.valid = 1;
        v.fence = 1;
        v.addr = 0;
        v.wdata = 0;
        v.wstrb = 0;
      end
      default : begin
        v.valid = 0;
        v.fence = 0;
        v.addr = 0;
        v.wdata = 0;
        v.wstrb = 0;
      end
    endcase

    dmem_in.mem_valid = v.valid;
    dmem_in.mem_fence = v.fence;
    dmem_in.mem_spec = 0;
    dmem_in.mem_instr = 0;
    dmem_in.mem_addr = v.addr;
    dmem_in.mem_wdata = v.wdata;
    dmem_in.mem_wstrb = v.wstrb;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module storebuffer
(
  input logic reset,
  input logic clock,
  input mem_in_type storebuffer_in,
  output mem_out_type storebuffer_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  storebuffer_data_in_type storebuffer_data_in;
  storebuffer_data_out_type storebuffer_data_out;
  storebuffer_fifo_in_type storebuffer_fifo_in;
  storebuffer_fifo_out_type storebuffer_fifo_out;

  storebuffer_data storebuffer_data_comp
  (
    .clock (clock),
    .storebuffer_data_in (storebuffer_data_in),
    .storebuffer_data_out (storebuffer_data_out)
  );

  storebuffer_fifo storebuffer_fifo_comp
  (
    .reset (reset),
    .clock (clock),
    .storebuffer_data_out (storebuffer_data_out),
    .storebuffer_data_in (storebuffer_data_in),
    .storebuffer_fifo_in (storebuffer_fifo_in),
    .storebuffer_fifo_out (storebuffer_fifo_out)
  );

  storebuffer_ctrl storebuffer_ctrl_comp
  (
    .reset (reset),
    .clock (clock),
    .storebuffer_fifo_out (storebuffer_fifo_out),
    .storebuffer_fifo_in (storebuffer_fifo_in),
    .storebuffer_in (storebuffer_in),
    .storebuffer_out (storebuffer_out),
    .dmem_out (dmem_out),
    .dmem_in (dmem_in)
  );

endmodule
