package itim_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [itim_depth-1 : 0] waddr;
    logic [itim_depth-1 : 0] raddr;
    logic [29-(itim_depth+itim_width) : 0] wdata;
  } itim_tag_in_type;

  typedef struct packed{
    logic [29-(itim_depth+itim_width) : 0] rdata;
  } itim_tag_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [itim_depth-1 : 0] waddr;
    logic [itim_depth-1 : 0] raddr;
    logic [2**itim_width*32-1 : 0] wdata;
  } itim_data_in_type;

  typedef struct packed{
    logic [2**itim_width*32-1 : 0] rdata;
  } itim_data_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [itim_depth-1 : 0] waddr;
    logic [itim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } itim_valid_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } itim_valid_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [itim_depth-1 : 0] waddr;
    logic [itim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } itim_lock_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } itim_lock_out_type;

  typedef struct packed{
    itim_tag_out_type tag_out;
    itim_data_out_type data_out;
    itim_valid_out_type valid_out;
    itim_lock_out_type lock_out;
  } itim_ctrl_in_type;

  typedef struct packed{
    itim_tag_in_type tag_in;
    itim_data_in_type data_in;
    itim_valid_in_type valid_in;
    itim_lock_in_type lock_in;
  } itim_ctrl_out_type;

endpackage

import configure::*;
import wires::*;
import itim_wires::*;

module itim_tag
(
  input logic clk,
  input itim_tag_in_type itim_tag_in,
  output itim_tag_out_type itim_tag_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [29-(itim_depth+itim_width):0] tag_array[0:2**itim_depth-1] = '{default:'0};

  logic [itim_depth-1 : 0] raddr = 0;

  always_ff @(posedge clk) begin
    raddr <= itim_tag_in.raddr;
    if (itim_tag_in.wen == 1) begin
      tag_array[itim_tag_in.waddr] <= itim_tag_in.wdata;
    end
  end

  assign itim_tag_out.rdata = tag_array[raddr];

endmodule

module itim_data
(
  input logic clk,
  input itim_data_in_type itim_data_in,
  output itim_data_out_type itim_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [2**itim_width*32-1 : 0] data_array[0:2**itim_depth-1] = '{default:'0};

  logic [itim_depth-1 : 0] raddr = 0;

  always_ff @(posedge clk) begin
    raddr <= itim_data_in.raddr;
    if (itim_data_in.wen == 1) begin
      data_array[itim_data_in.waddr] <= itim_data_in.wdata;
    end
  end

  assign itim_data_out.rdata = data_array[raddr];

endmodule

module itim_valid
(
  input logic clk,
  input itim_valid_in_type itim_valid_in,
  output itim_valid_out_type itim_valid_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] valid_array[0:2**itim_depth-1] = '{default:'0};

  logic [itim_depth-1 : 0] raddr = 0;

  always_ff @(posedge clk) begin
    raddr <= itim_valid_in.raddr;
    if (itim_valid_in.wen == 1) begin
      valid_array[itim_valid_in.waddr] <= itim_valid_in.wdata;
    end
  end

  assign itim_valid_out.rdata = valid_array[raddr];

endmodule

module itim_lock
(
  input logic clk,
  input itim_lock_in_type itim_lock_in,
  output itim_lock_out_type itim_lock_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] lock_array[0:2**itim_depth-1] = '{default:'0};

  logic [itim_depth-1 : 0] raddr = 0;

  always_ff @(posedge clk) begin
    raddr <= itim_lock_in.raddr;
    if (itim_lock_in.wen == 1) begin
      lock_array[itim_lock_in.waddr] <= itim_lock_in.wdata;
    end
  end

  assign itim_lock_out.rdata = lock_array[raddr];

endmodule

module itim_ctrl
(
  input logic rst,
  input logic clk,
  input itim_ctrl_in_type ictrl_in,
  output itim_ctrl_out_type ictrl_out,
  input mem_in_type itim_in,
  output mem_out_type itim_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  parameter [2:0] hit = 0;
  parameter [2:0] miss = 1;
  parameter [2:0] load = 2;
  parameter [2:0] update = 3;
  parameter [2:0] fence = 4;
  parameter [2:0] reset = 5;

  typedef struct packed{
    logic [29-(itim_depth+itim_width):0] tag;
    logic [itim_width-1:0] wid;
    logic [itim_depth-1:0] did;
    logic [31:0] addr;
    logic [0:0] fence;
    logic [0:0] en;
  } front_type;

  parameter front_type init_front = '{
    tag : 0,
    wid : 0,
    did : 0,
    addr : 0,
    fence : 0,
    en : 0
  };

  typedef struct packed{
    logic [29-(itim_depth+itim_width):0] tag;
    logic [2**itim_width*32-1:0] data;
    logic [itim_depth-1:0] did;
    logic [itim_width-1:0] wid;
    logic [itim_width-1:0] cnt;
    logic [31:0] addr;
    logic [31:0] rdata;
    logic [0:0] ready;
    logic [0:0] fence;
    logic [0:0] valid;
    logic [0:0] lock;
    logic [0:0] en;
    logic [0:0] wen;
    logic [0:0] inv;
    logic [0:0] hit;
    logic [0:0] miss;
    logic [0:0] load;
    logic [2:0] state;
  } back_type;

  parameter back_type init_back = '{
    tag : 0,
    data : 0,
    did : 0,
    wid : 0,
    cnt : 0,
    addr : 0,
    rdata : 0,
    ready : 0,
    fence : 0,
    valid : 0,
    lock : 0,
    en : 0,
    wen : 0,
    inv : 0,
    hit : 0,
    miss : 0,
    load : 0,
    state : 0
  };

  front_type r_f,rin_f = init_front;
  front_type v_f = init_front;

  back_type r_b,rin_b = init_back;
  back_type v_b = init_back;

  always_comb begin

    v_f = r_f;

    v_f.fence = 0;
    v_f.en = 0;

    if (itim_in.mem_valid == 1) begin
      if (itim_in.mem_fence == 1) begin
        v_f.fence = itim_in.mem_fence;
      end else begin
        v_f.en = itim_in.mem_valid;
        v_f.addr = itim_in.mem_addr;
        v_f.tag = itim_in.mem_addr[31:(itim_depth+itim_width+2)];
        v_f.did = itim_in.mem_addr[(itim_depth+itim_width+1):(itim_width+2)];
        v_f.wid = itim_in.mem_addr[(itim_width+1):2];
      end
    end

    if (v_f.fence == 1) begin
      v_f.did = 0;
    end else if (rin_b.fence == 1) begin
      v_f.did = rin_b.did;
    end

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.fence = 0;
    v_b.en = 0;
    v_b.inv = 0;
    v_b.hit = 0;
    v_b.miss = 0;
    v_b.load = 0;

    if (r_b.state == hit) begin
      v_b.fence = r_f.fence;
      v_b.en = r_f.en;
      v_b.addr = r_f.addr;
      v_b.tag = r_f.tag;
      v_b.did = r_f.did;
      v_b.wid = r_f.wid;
    end

    case(r_b.state)
      hit :
        begin

          v_b.wen = 0;
          v_b.lock = ictrl_in.lock_out.rdata;

          if (v_b.fence == 1) begin
            v_b.inv = v_b.fence;
          end else if (v_b.addr < itim_base_addr || v_b.addr >= itim_top_addr) begin
            v_b.load = v_b.en;
          end else if (v_b.lock == 0) begin
            v_b.miss = v_b.en;
          end else if (|(ictrl_in.tag_out.rdata ^ v_b.tag) == 1) begin
            v_b.load = v_b.en;
          end else begin
            v_b.hit = v_b.en;
          end

          if (v_b.inv == 1) begin
            v_b.state = fence;
            v_b.valid = 0;
          end if (v_b.miss == 1) begin
            v_b.state = miss;
            v_b.addr[itim_width+1:0] = 0;
            v_b.cnt = 0;
            v_b.valid = 1;
          end else if (v_b.load == 1) begin
            v_b.state = load;
            v_b.valid = 1;
          end else begin
            v_b.data = ictrl_in.data_out.rdata;
            v_b.valid = 0;
          end

        end
      miss :
        begin

          v_b.wen = 0;
          v_b.lock = 0;

          if (imem_out.mem_ready == 1) begin
            v_b.data[32*v_b.cnt +: 32] = imem_out.mem_rdata;
            if (v_b.cnt == 2**itim_width-1) begin
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
      load :
        begin

          v_b.wen = 0;
          v_b.lock = 0;

          if (imem_out.mem_ready == 1) begin
            v_b.state = hit;
            v_b.valid = 0;
          end

        end
      update :
        begin

          v_b.wen = 0;
          v_b.lock = 0;
          v_b.valid = 0;
          v_b.state = hit;

        end
      fence :
        begin

          v_b.wen = 1;
          v_b.lock = 0;
          v_b.valid = 0;
          v_b.fence = 1;

        end
      default :
        begin

        end
    endcase

    ictrl_out.tag_in.raddr = rin_f.did;
    ictrl_out.data_in.raddr = rin_f.did;
    ictrl_out.lock_in.raddr = rin_f.did;
    // ictrl_out.valid_in.raddr = rin_f.did;

    ictrl_out.tag_in.waddr = v_b.did;
    ictrl_out.tag_in.wen = v_b.wen;
    ictrl_out.tag_in.wdata = v_b.tag;

    ictrl_out.data_in.waddr = v_b.did;
    ictrl_out.data_in.wen = v_b.wen;
    ictrl_out.data_in.wdata = v_b.data;

    ictrl_out.lock_in.waddr = v_b.did;
    ictrl_out.lock_in.wen = v_b.wen | v_b.fence;
    ictrl_out.lock_in.wdata = v_b.lock;

    // ictrl_out.valid_in.waddr = v_b.did;
    // ictrl_out.valid_in.wen = v_b.wen or v_b.fence;
    // ictrl_out.valid_in.wdata = v_b.valid;

    if (v_b.state == fence) begin
      if (v_b.did == 2**itim_depth-1) begin
        v_b.state = update;
      end else begin
        v_b.did = v_b.did + 1;
      end
    end

    case(r_b.state)
      hit :
        begin
          v_b.rdata = v_b.data[32*v_b.wid +: 32];
          v_b.ready = v_b.en & v_b.hit;
        end
      load :
        begin
          v_b.rdata = imem_out.mem_rdata;
          v_b.ready = imem_out.mem_ready;
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

    imem_in.mem_valid = v_b.valid;
    imem_in.mem_fence = 0;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v_b.addr;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    itim_out.mem_rdata = v_b.rdata;
    itim_out.mem_ready = v_b.ready;

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

module itim
#(
  parameter itim_enable = 1
)
(
  input logic rst,
  input logic clk,
  input mem_in_type itim_in,
  output mem_out_type itim_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  generate

    if (itim_enable == 1) begin

      itim_ctrl_in_type ictrl_in;
      itim_ctrl_out_type ictrl_out;

      itim_tag itim_tag_comp
      (
        .clk (clk),
        .itim_tag_in (ictrl_out.tag_in),
        .itim_tag_out (ictrl_in.tag_out)
      );

      itim_data itim_data_comp
      (
        .clk (clk),
        .itim_data_in (ictrl_out.data_in),
        .itim_data_out (ictrl_in.data_out)
      );

      itim_valid itim_valid_comp
      (
        .clk (clk),
        .itim_valid_in (ictrl_out.valid_in),
        .itim_valid_out (ictrl_in.valid_out)
      );

      itim_lock itim_lock_comp
      (
        .clk (clk),
        .itim_lock_in (ictrl_out.lock_in),
        .itim_lock_out (ictrl_in.lock_out)
      );

      itim_ctrl itim_ctrl_comp
      (
        .rst (rst),
        .clk (clk),
        .ictrl_in (ictrl_in),
        .ictrl_out (ictrl_out),
        .itim_in (itim_in),
        .itim_out (itim_out),
        .imem_out (imem_out),
        .imem_in (imem_in)
      );

    end else begin

      assign imem_in = itim_in;
      assign itim_out = imem_out;

    end

  endgenerate

endmodule
