import configure::*;
import constants::*;
import wires::*;

module writebuffer
(
  input logic rst,
  input logic clk,
  input mem_in_type writebuffer_in,
  output mem_out_type writebuffer_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [67 : 0] writebuffer_buffer[0:2**writebuffer_depth-1] = '{default:'0};

  typedef struct packed{
    logic [writebuffer_depth-1:0] wbwaddr;
    logic [writebuffer_depth-1:0] wbraddr;
    logic [writebuffer_depth-1:0] waddr;
    logic [writebuffer_depth-1:0] raddr;
    logic [31:0] addr;
    logic [31:0] baddr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [67:0] wbwdata;
    logic [67:0] wbrdata;
    logic [31:0] bwdata;
    logic [3:0] wstrb;
    logic [3:0] bwstrb;
    logic [0:0] wbwren;
    logic [0:0] wbrden;
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

  reg_type init_reg = '{
    wbwaddr : 0,
    wbraddr : 0,
    waddr : 0,
    raddr : 0,
    addr : 0,
    baddr : 0,
    wdata : 0,
    rdata : 0,
    wbwdata : 0,
    wbrdata : 0,
    bwdata : 0,
    wstrb : 0,
    bwstrb : 0,
    wbwren : 0,
    wbrden : 0,
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

    writebuffer_out.mem_rdata = v.rdata;
    writebuffer_out.mem_ready = v.ready;

    v.bstore = 0;

    if (writebuffer_in.mem_valid == 1) begin
      v.bfence = writebuffer_in.mem_fence;
      v.bstore = |writebuffer_in.mem_wstrb;
      v.bload = ~(|writebuffer_in.mem_wstrb);
      v.baddr = writebuffer_in.mem_addr;
      v.bwstrb = writebuffer_in.mem_wstrb;
      v.bwdata = writebuffer_in.mem_wdata;
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
        if (v.raddr == 2**writebuffer_depth-1) begin
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

    v.wbwren = v.wren;
    v.wbwaddr = v.waddr;
    v.wbwdata = {v.bwstrb,v.baddr,v.bwdata};

    v.wbrdata = writebuffer_buffer[v.raddr];

    if (v.wren == 1) begin
      if (v.waddr == 2**writebuffer_depth-1) begin
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
      v.wstrb = v.wbrdata[67:64];
      v.addr = v.wbrdata[63:32];
      v.wdata = v.wbrdata[31:0];
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

  always_ff @(posedge clk) begin
    if (rin.wbwren == 1) begin
      writebuffer_buffer[rin.wbwaddr] <= rin.wbwdata;
    end
  end

endmodule
