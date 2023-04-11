package itim_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(itim_depth-1);
  localparam width = $clog2(itim_width-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [depth-1 : 0] waddr;
    logic [depth-1 : 0] raddr;
    logic [62-(depth+width) : 0] wdata;
  } itim_ram_in_type;

  typedef struct packed{
    logic [62-(depth+width) : 0] rdata;
  } itim_ram_out_type;

  typedef itim_ram_in_type itim_vec_in_type [itim_width];
  typedef itim_ram_out_type itim_vec_out_type [itim_width];

endpackage

import configure::*;
import wires::*;
import itim_wires::*;

module itim_ram
(
  input logic clock,
  input itim_ram_in_type itim_ram_in,
  output itim_ram_out_type itim_ram_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(itim_depth-1);
  localparam width = $clog2(itim_width-1);

  logic [62-(depth+width) : 0] ram_array[0:itim_depth-1] = '{default:'0};

  logic [depth-1 : 0] raddr = 0;

  always_ff @(posedge clock) begin
    raddr <= itim_ram_in.raddr;
    if (itim_ram_in.wen == 1) begin
      ram_array[itim_ram_in.waddr] <= itim_ram_in.wdata;
    end
  end

  assign itim_ram_out.rdata = ram_array[raddr];

endmodule

module itim_ctrl
(
  input logic reset,
  input logic clock,
  input itim_vec_out_type ivec_out,
  output itim_vec_in_type ivec_in,
  input mem_in_type itim_in,
  output mem_out_type itim_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(itim_depth-1);
  localparam width = $clog2(itim_width-1);

  localparam [2:0] hit = 0;
  localparam [2:0] miss = 1;
  localparam [2:0] load = 2;
  localparam [2:0] fence = 3;

  typedef struct packed{
    logic [29-(depth+width):0] tag;
    logic [width-1:0] wid;
    logic [depth-1:0] did;
    logic [31:0] addr;
    logic [0:0] fence;
    logic [0:0] enable;
  } front_type;

  parameter front_type init_front = '{
    tag : 0,
    wid : 0,
    did : 0,
    addr : 0,
    fence : 0,
    enable : 0
  };

  typedef struct packed{
    logic [29-(depth+width):0] itag;
    logic [29-(depth+width):0] tag;
    logic [depth-1:0] did;
    logic [width-1:0] wid;
    logic [31:0] addr;
    logic [31:0] idata;
    logic [31:0] data;
    logic [31:0] rdata;
    logic [0:0] ready;
    logic [0:0] valid;
    logic [0:0] ilock;
    logic [0:0] lock;
    logic [0:0] enable;
    logic [0:0] fence;
    logic [0:0] wen;
    logic [0:0] inv;
    logic [0:0] clear;
    logic [0:0] hit;
    logic [0:0] miss;
    logic [0:0] load;
    logic [2:0] state;
  } back_type;

  parameter back_type init_back = '{
    itag : 0,
    tag : 0,
    did : 0,
    wid : 0,
    addr : 0,
    idata : 0,
    data : 0,
    rdata : 0,
    ready : 0,
    valid : 0,
    ilock : 0,
    lock : 0,
    enable : 0,
    fence : 0,
    wen : 0,
    inv : 0,
    clear : 0,
    hit : 0,
    miss : 0,
    load : 0,
    state : 0
  };

  front_type r_f,rin_f;
  front_type v_f;

  back_type r_b,rin_b;
  back_type v_b;

  always_comb begin

    v_f = r_f;

    v_f.enable = 0;

    if (itim_in.mem_valid == 1) begin
      v_f.enable = itim_in.mem_valid;
      v_f.fence = itim_in.mem_fence;
      v_f.addr = itim_in.mem_addr;
      v_f.tag = itim_in.mem_addr[31:(depth+width+2)];
      v_f.did = itim_in.mem_addr[(depth+width+1):(width+2)];
      v_f.wid = itim_in.mem_addr[(width+1):2];
    end

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.enable = 0;
    v_b.fence = 0;
    v_b.lock = 0;
    v_b.wen = 0;
    v_b.clear = 0;
    v_b.hit = 0;
    v_b.miss = 0;
    v_b.load = 0;

    v_b.rdata = 0;
    v_b.ready = 0;

    if (r_b.state == hit) begin
      v_b.enable = r_f.enable;
      v_b.fence = r_f.fence;
      v_b.addr = r_f.addr;
      v_b.tag = r_f.tag;
      v_b.did = r_f.did;
      v_b.wid = r_f.wid;
    end

    case(r_b.state)
      hit :
        begin
          v_b.itag = ivec_out[v_b.wid].rdata[61-(depth+width):32];
          v_b.ilock = ivec_out[v_b.wid].rdata[62-(depth+width)];
          v_b.idata = ivec_out[v_b.wid].rdata[31:0];
          if (v_b.fence == 1) begin
            v_b.clear = v_b.enable;
          end else if (v_b.addr < itim_base_addr || v_b.addr >= itim_top_addr) begin
            v_b.load = v_b.enable;
          end else if (v_b.ilock == 0) begin
            v_b.miss = v_b.enable;
          end else if (|(v_b.itag ^ v_b.tag) == 1) begin
            v_b.load = v_b.enable;
          end else begin
            v_b.hit = v_b.enable;
          end
          if (v_b.clear == 1) begin
            v_b.state = fence;
            v_b.inv = 1;
            v_b.did = 0;
            v_b.valid = 0;
          end if (v_b.miss == 1) begin
            v_b.state = miss;
            v_b.valid = 1;
          end else if (v_b.load == 1) begin
            v_b.state = load;
            v_b.valid = 1;
          end else if (v_b.hit == 1) begin
            v_b.valid = 0;
            v_b.rdata = v_b.idata;
            v_b.ready = 1;
          end
        end
      miss :
        begin
          if (imem_out.mem_ready == 1) begin
            v_b.wen = 1;
            v_b.lock = 1;
            v_b.data = imem_out.mem_rdata;
            v_b.valid = 0;
            v_b.state = hit;
            v_b.rdata = imem_out.mem_rdata;
            v_b.ready = 1;
          end
        end
      load :
        begin
          if (imem_out.mem_ready == 1) begin
            v_b.valid = 0;
            v_b.state = hit;
            v_b.rdata = imem_out.mem_rdata;
            v_b.ready = 1;
          end
        end
      fence :
        begin
          if (&(v_b.did) == 1) begin
            v_b.inv = 0;
            v_b.state = hit;
            v_b.ready = 1;
          end else begin
            v_b.did = v_b.did + 1;
          end
        end
      default :
        begin
        end
    endcase

    ivec_in[rin_f.wid].raddr = rin_f.did;

    ivec_in[v_b.wid].wen = v_b.wen;
    ivec_in[v_b.wid].waddr = v_b.did;
    ivec_in[v_b.wid].wdata = {v_b.lock,v_b.tag,v_b.data};

    if (v_b.inv == 1) begin
      for (int i=0; i<itim_width; i=i+1) begin
        ivec_in[i].wen = v_b.inv;
        ivec_in[i].waddr = v_b.did;
        ivec_in[i].wdata = 0;
      end
    end

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

  always_ff @(posedge clock) begin
    if (reset == 0) begin
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
  input logic reset,
  input logic clock,
  input mem_in_type itim_in,
  output mem_out_type itim_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  generate

    genvar i;

    if (itim_enable == 1) begin

      itim_vec_in_type ivec_in;
      itim_vec_out_type ivec_out;

      for (i=0; i<itim_width; i=i+1) begin
        itim_ram itim_ram_comp
        (
          .clock (clock),
          .itim_ram_in (ivec_in[i]),
          .itim_ram_out (ivec_out[i])
        );
      end

      itim_ctrl itim_ctrl_comp
      (
        .reset (reset),
        .clock (clock),
        .ivec_out (ivec_out),
        .ivec_in (ivec_in),
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
