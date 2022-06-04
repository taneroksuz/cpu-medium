package dtim_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [29-(dtim_depth+dtim_width) : 0] wdata;
  } dtim_tag_in_type;

  typedef struct packed{
    logic [29-(dtim_depth+dtim_width) : 0] rdata;
  } dtim_tag_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [2**dtim_width*32-1 : 0] wdata;
  } dtim_data_in_type;

  typedef struct packed{
    logic [2**dtim_width*32-1 : 0] rdata;
  } dtim_data_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } dtim_valid_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } dtim_valid_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } dtim_lock_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } dtim_lock_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } dtim_dirty_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } dtim_dirty_out_type;

  typedef struct packed{
    dtim_tag_out_type tag_out;
    dtim_data_out_type data_out;
    dtim_valid_out_type valid_out;
    dtim_lock_out_type lock_out;
    dtim_dirty_out_type dirty_out;
  } dtim_ctrl_in_type;

  typedef struct packed{
    dtim_tag_in_type tag_in;
    dtim_data_in_type data_in;
    dtim_valid_in_type valid_in;
    dtim_lock_in_type lock_in;
    dtim_dirty_in_type dirty_in;
  } dtim_ctrl_out_type;

endpackage

import configure::*;
import dtim_wires::*;

module dtim_tag
(
  input logic clk,
  input dtim_tag_in_type dtim_tag_in,
  output dtim_tag_out_type dtim_tag_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [29-(dtim_depth+dtim_width):0] tag_array[0:2**dtim_depth-1] = '{default:'0};
  logic [29-(dtim_depth+dtim_width):0] tag_rdata = 0;

  assign dtim_tag_out.rdata = tag_rdata;

  always_ff @(posedge clk) begin
    if (dtim_tag_in.wen == 1) begin
      tag_array[dtim_tag_in.waddr] <= dtim_tag_in.wdata;
    end
    tag_rdata <= tag_array[dtim_tag_in.raddr];
  end

endmodule

module dtim_data
(
  input logic clk,
  input dtim_data_in_type dtim_data_in,
  output dtim_data_out_type dtim_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [2**dtim_width*32-1 : 0] data_array[0:2**dtim_depth-1] = '{default:'0};
  logic [2**dtim_width*32-1 : 0] data_rdata = 0;

  assign dtim_data_out.rdata = data_rdata;

  always_ff @(posedge clk) begin
    if (dtim_data_in.wen == 1) begin
      data_array[dtim_data_in.waddr] <= dtim_data_in.wdata;
    end
    data_rdata <= data_array[dtim_data_in.raddr];
  end

endmodule

module dtim_valid
(
  input logic clk,
  input dtim_valid_in_type dtim_valid_in,
  output dtim_valid_out_type dtim_valid_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] valid_array[0:2**dtim_depth-1] = '{default:'0};
  logic [0 : 0] valid_rdata = 0;

  assign dtim_valid_out.rdata = valid_rdata;

  always_ff @(posedge clk) begin
    if (dtim_valid_in.wen == 1) begin
      valid_array[dtim_valid_in.waddr] <= dtim_valid_in.wdata;
    end
    valid_rdata <= valid_array[dtim_valid_in.raddr];
  end

endmodule

module dtim_lock
(
  input logic clk,
  input dtim_lock_in_type dtim_lock_in,
  output dtim_lock_out_type dtim_lock_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] lock_array[0:2**dtim_depth-1] = '{default:'0};
  logic [0 : 0] lock_rdata = 0;

  assign dtim_lock_out.rdata = lock_rdata;

  always_ff @(posedge clk) begin
    if (dtim_lock_in.wen == 1) begin
      lock_array[dtim_lock_in.waddr] <= dtim_lock_in.wdata;
    end
    lock_rdata <= lock_array[dtim_lock_in.raddr];
  end

endmodule

module dtim_dirty
(
  input logic clk,
  input dtim_dirty_in_type dtim_dirty_in,
  output dtim_dirty_out_type dtim_dirty_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] dirty_array[0:2**dtim_depth-1] = '{default:'0};
  logic [0 : 0] dirty_rdata = 0;

  assign dtim_dirty_out.rdata = dirty_rdata;

  always_ff @(posedge clk) begin
    if (dtim_dirty_in.wen == 1) begin
      dirty_array[dtim_dirty_in.waddr] <= dtim_dirty_in.wdata;
    end
    dirty_rdata <= dirty_array[dtim_dirty_in.raddr];
  end

endmodule

module dtim_ctrl
(
  input logic rst,
  input logic clk,
  input dtim_ctrl_in_type dctrl_in,
  output dtim_ctrl_out_type dctrl_out,
  input mem_in_type dtim_in,
  output mem_out_type dtim_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  parameter [2:0] hit = 0;
  parameter [2:0] miss = 1;
  parameter [2:0] ldst = 2;
  parameter [2:0] update = 3;
  parameter [2:0] fence = 4;
  parameter [2:0] reset = 5;
  parameter [2:0] writeback = 6;

  typedef struct packed{
    logic [29-(dtim_depth+dtim_width):0] tag;
    logic [dtim_width-1:0] wid;
    logic [dtim_depth-1:0] did;
    logic [31:0] addr;
    logic [31:0] data;
    logic [3:0] strb;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] fence;
  } front_type;

  parameter front_type init_front = '{
    tag : 0,
    wid : 0,
    did : 0,
    addr : 0,
    data : 0,
    strb : 0,
    wren : 0,
    rden : 0,
    fence : 0
  };

  typedef struct packed{
    logic [29-(dtim_depth+dtim_width):0] tag;
    logic [2**dtim_width*32-1:0] data;
    logic [dtim_depth-1:0] did;
    logic [dtim_width-1:0] wid;
    logic [dtim_width-1:0] cnt;
    logic [31:0] addr;
    logic [3:0] strb;
    logic [3:0] wstrb;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [31:0] sdata;
    logic [0:0] ready;
    logic [0:0] fence;
    logic [0:0] valid;
    logic [0:0] lock;
    logic [0:0] dirty;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] store;
    logic [0:0] inv;
    logic [0:0] wen;
    logic [0:0] hit;
    logic [0:0] miss;
    logic [0:0] ldst;
    logic [2:0] state;
  } back_type;

  parameter back_type init_back = '{
    tag : 0,
    data : 0,
    did : 0,
    wid : 0,
    cnt : 0,
    addr : 0,
    strb : 0,
    wdata : 0,
    sdata : 0,
    wstrb : 0,
    rdata : 0,
    ready : 0,
    fence : 0,
    valid : 0,
    lock : 0,
    dirty : 0,
    wren : 0,
    rden : 0,
    store : 0,
    inv : 0,
    wen : 0,
    hit : 0,
    miss : 0,
    ldst : 0,
    state : 0
  };

  integer i;

  front_type r_f,rin_f = init_front;
  front_type v_f = init_front;

  back_type r_b,rin_b = init_back;
  back_type v_b = init_back;

  always_comb begin

    v_f = r_f;

    v_f.fence = 0;
    v_f.wren = 0;
    v_f.rden = 0;

    if (dtim_in.mem_valid == 1) begin
      if (dtim_in.mem_fence == 1) begin
        v_f.fence = dtim_in.mem_fence;
        v_f.did = 0;
      end else begin
        v_f.wren = |dtim_in.mem_wstrb;
        v_f.rden = ~(|dtim_in.mem_wstrb);
        v_f.data = dtim_in.mem_wdata;
        v_f.strb = dtim_in.mem_wstrb;
        v_f.addr = dtim_in.mem_addr;
        v_f.tag = dtim_in.mem_addr[31:(dtim_depth+dtim_width+2)];
        v_f.did = dtim_in.mem_addr[(dtim_depth+dtim_width+1):(dtim_width+2)];
        v_f.wid = dtim_in.mem_addr[(dtim_width+1):2];
      end
    end

    if (rin_b.fence == 1) begin
      v_f.did = rin_b.did;
    end

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.fence = 0;
    v_b.rden = 0;
    v_b.wren = 0;
    v_b.inv = 0;
    v_b.hit = 0;
    v_b.miss = 0;
    v_b.ldst = 0;
    v_b.wstrb = 0;

    if (r_b.state == hit) begin
      v_b.wren = r_f.wren;
      v_b.rden = r_f.rden;
      v_b.store = r_f.wren;
      v_b.fence = r_f.fence;
      v_b.wdata = r_f.data;
      v_b.addr = r_f.addr;
      v_b.strb = r_f.strb;
      v_b.tag = r_f.tag;
      v_b.did = r_f.did;
      v_b.wid = r_f.wid;
    end

    case(r_b.state)
      hit :
        begin

          v_b.wen = 0;
          v_b.lock = dctrl_in.lock_out.rdata;
          v_b.dirty = dctrl_in.dirty_out.rdata;

          if (v_b.fence == 1) begin
            v_b.inv = v_b.fence;
          end else if (v_b.addr < dtim_base_addr || v_b.addr >= dtim_top_addr) begin
            v_b.ldst = v_b.wren | v_b.rden;
          end else if (v_b.lock == 0) begin
            v_b.miss = v_b.wren | v_b.rden;
          end else if (|(dctrl_in.tag_out.rdata ^ v_b.tag) == 1) begin
            v_b.ldst = v_b.wren | v_b.rden;
          end else begin
            v_b.hit = v_b.rden;
          end

          if (v_b.inv == 1) begin
            v_b.state = fence;
            v_b.valid = 0;
          end else if (v_b.miss == 1) begin
            v_b.state = miss;
            v_b.addr[dtim_width+1:0] = 0;
            v_b.cnt = 0;
            v_b.valid = 1;
          end else if (v_b.ldst == 1) begin
            v_b.state = ldst;
            v_b.wstrb = v_b.strb;
            v_b.valid = 1;
          end else begin
            v_b.state = v_b.wren == 1 ? update : hit;
            v_b.data = dctrl_in.data_out.rdata;
            v_b.wen = v_b.wren;
            v_b.lock = v_b.wren;
            v_b.dirty = v_b.wren;
            v_b.valid = 0;
          end

        end
      miss :
        begin

          v_b.wen = 0;
          v_b.lock = 0;
          v_b.dirty = 0;

          if (dmem_out.mem_ready == 1) begin
            v_b.data[32*v_b.cnt +: 32] = dmem_out.mem_rdata;
            if (v_b.cnt == 2*dtim_width-1) begin
              v_b.wen = 1;
              v_b.lock = 1;
              v_b.valid = 0;
              v_b.state = update;
            end else begin
              v_b.addr = v_b.addr + 4;
              v_b.cnt = v_b.cnt + 1;
            end
          end

        end
      ldst :
        begin

          v_b.wen = 0;
          v_b.lock = 0;
          v_b.dirty = 0;

          if (dmem_out.mem_ready == 1) begin
            v_b.valid = 0;
            v_b.state = hit;
          end

        end
      update :
        begin

          v_b.wen = 0;
          v_b.lock = 0;
          v_b.dirty = 0;
          v_b.valid = 0;
          v_b.state = hit;

        end
      fence :
        begin

          v_b.wen = 0;
          v_b.lock = 0;
          v_b.dirty = 0;
          v_b.valid = 0;
          v_b.fence = 1;

          v_b.tag = dctrl_in.tag_out.rdata;
          v_b.lock = dctrl_in.lock_out.rdata;
          v_b.data = dctrl_in.data_out.rdata;

          if (v_b.lock == 1) begin
            v_b.addr[31:(dtim_width+2)] = {v_b.tag,v_b.did};
            v_b.addr[(dtim_width+1):0] = 0;
            v_b.state = writeback;
            v_b.valid = 1;
          end

          v_b.cnt = 0;

        end
      writeback :
        begin

          v_b.wen = 1;
          v_b.lock = 0;
          v_b.dirty = 0;
          v_b.fence = 1;

          if (dmem_out.mem_ready == 1) begin
            if (v_b.cnt == 2*dtim_width-1) begin
              v_b.wen = 1;
              v_b.lock = 0;
              v_b.valid = 0;
              v_b.state = fence;
            end else begin
              v_b.addr = v_b.addr + 4;
              v_b.cnt = v_b.cnt + 1;
            end
          end

        end
      default :
        begin

        end
    endcase

    if (v_b.state == writeback) begin
      v_b.wdata = v_b.data[32*v_b.cnt +: 32];
      v_b.wstrb = 4'hF;
    end

    if (v_b.store == 1) begin
      v_b.sdata = v_b.data[32*v_b.wid +: 32];
      for (i=0; i<4; i=i+1) begin
        if (v_b.strb[i] == 1) begin
          v_b.sdata[8*i +: 8] = v_b.wdata[8*i +: 8];
        end
      end
      v_b.data[32*v_b.wid +: 32] = v_b.sdata;
    end

    dctrl_out.tag_in.raddr = rin_f.did;
    dctrl_out.data_in.raddr = rin_f.did;
    dctrl_out.lock_in.raddr = rin_f.did;
    dctrl_out.dirty_in.raddr = rin_f.did;
    // dctrl_out.valid_in.raddr = rin_f.did;

    dctrl_out.tag_in.waddr = v_b.did;
    dctrl_out.tag_in.wen = v_b.wen;
    dctrl_out.tag_in.wdata = v_b.tag;

    dctrl_out.data_in.waddr = v_b.did;
    dctrl_out.data_in.wen = v_b.wen;
    dctrl_out.data_in.wdata = v_b.data;

    dctrl_out.lock_in.waddr = v_b.did;
    dctrl_out.lock_in.wen = v_b.wen | v_b.fence;
    dctrl_out.lock_in.wdata = v_b.lock;

    dctrl_out.dirty_in.waddr = v_b.did;
    dctrl_out.dirty_in.wen = v_b.wen;
    dctrl_out.dirty_in.wdata = v_b.dirty;

    // dctrl_out.valid_in.waddr = v_b.did;
    // dctrl_out.valid_in.wen = v_b.wen or v_b.fence;
    // dctrl_out.valid_in.wdata = v_b.valid;

    if (v_b.state == fence) begin
      if (v_b.did == 2**dtim_depth-1) begin
        v_b.state = hit;
      end else begin
        v_b.did = v_b.did + 1;
      end
    end

    case(r_b.state)
      hit :
        begin
          v_b.rdata = v_b.data[32*v_b.wid +: 32];
          v_b.ready = (v_b.wren | v_b.rden) & v_b.hit;
        end
      ldst :
        begin
          v_b.rdata = dmem_out.mem_rdata;
          v_b.ready = dmem_out.mem_ready;
        end
      update :
        begin
          v_b.rdata = v_b.data[32*v_b.wid +: 32];
          v_b.ready = 1;
        end
      fence :
        begin
          if (v_b.state == hit) begin
            v_b.rdata = 0;
            v_b.ready = 1;
          end else begin
            v_b.rdata = 0;
            v_b.ready = 0;
          end
        end
      default :
        begin
          v_b.rdata = 0;
          v_b.ready = 0;
        end
    endcase

    dmem_in.mem_valid = v_b.valid;
    dmem_in.mem_fence = 0;
    dmem_in.mem_instr = 1;
    dmem_in.mem_addr = v_b.addr;
    dmem_in.mem_wdata = v_b.wdata;
    dmem_in.mem_wstrb = v_b.wstrb;

    dtim_out.mem_rdata = v_b.rdata;
    dtim_out.mem_ready = v_b.ready;

    rin_b = v_b;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r_f <= init_front;
      r_b <= init_back;
    end else begin
      r_f <= rin_f;
      r_b <= rin_b;
    end
  end

endmodule

module dtim
#(
  parameter dtim_enable = 1
)
(
  input logic rst,
  input logic clk,
  input mem_in_type dtim_in,
  output mem_out_type dtim_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  generate

    if (dtim_enable == 1) begin

      dtim_ctrl_in_type dctrl_in;
      dtim_ctrl_out_type dctrl_out;

      dtim_tag dtim_tag_comp
      (
        .clk (clk),
        .dtim_tag_in (dctrl_out.tag_in),
        .dtim_tag_out (dctrl_in.tag_out)
      );

      dtim_data dtim_data_comp
      (
        .clk (clk),
        .dtim_data_in (dctrl_out.data_in),
        .dtim_data_out (dctrl_in.data_out)
      );

      dtim_valid dtim_valid_comp
      (
        .clk (clk),
        .dtim_valid_in (dctrl_out.valid_in),
        .dtim_valid_out (dctrl_in.valid_out)
      );

      dtim_dirty dtim_dirty_comp
      (
        .clk (clk),
        .dtim_dirty_in (dctrl_out.dirty_in),
        .dtim_dirty_out (dctrl_in.dirty_out)
      );

      dtim_lock dtim_lock_comp
      (
        .clk (clk),
        .dtim_lock_in (dctrl_out.lock_in),
        .dtim_lock_out (dctrl_in.lock_out)
      );

      dtim_ctrl dtim_ctrl_comp
      (
        .rst (rst),
        .clk (clk),
        .dctrl_in (dctrl_in),
        .dctrl_out (dctrl_out),
        .dtim_in (dtim_in),
        .dtim_out (dtim_out),
        .dmem_out (dmem_out),
        .dmem_in (dmem_in)
      );

    end else begin

      assign dmem_in = dtim_in;
      assign dtim_out = dmem_out;

    end

  endgenerate

endmodule
