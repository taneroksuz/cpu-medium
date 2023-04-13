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
  localparam [2:0] miss1 = 1;
  localparam [2:0] miss2 = 2;
  localparam [2:0] load1 = 3;
  localparam [2:0] load2 = 4;
  localparam [2:0] fence = 5;

  typedef struct packed{
    logic [29-(depth+width):0] tag1;
    logic [29-(depth+width):0] tag2;
    logic [depth-1:0] did1;
    logic [depth-1:0] did2;
    logic [width-1:0] wid1;
    logic [width-1:0] wid2;
    logic [31:0] addr1;
    logic [31:0] addr2;
    logic [0:0] align;
    logic [0:0] fence;
    logic [0:0] enable;
  } front_type;

  parameter front_type init_front = '{
    tag1 : 0,
    tag2 : 0,
    did1 : 0,
    did2 : 0,
    wid1 : 0,
    wid2 : 0,
    addr1 : 0,
    addr2 : 0,
    align : 0,
    fence : 0,
    enable : 0
  };

  typedef struct packed{
    logic [29-(depth+width):0] itag1;
    logic [29-(depth+width):0] itag2;
    logic [29-(depth+width):0] tag;
    logic [29-(depth+width):0] tag1;
    logic [29-(depth+width):0] tag2;
    logic [depth-1:0] did;
    logic [depth-1:0] did1;
    logic [depth-1:0] did2;
    logic [width-1:0] wid;
    logic [width-1:0] wid1;
    logic [width-1:0] wid2;
    logic [31:0] addr;
    logic [31:0] addr1;
    logic [31:0] addr2;
    logic [31:0] idata1;
    logic [31:0] idata2;
    logic [31:0] data;
    logic [31:0] rdata;
    logic [0:0] ready;
    logic [0:0] valid;
    logic [0:0] ilock1;
    logic [0:0] ilock2;
    logic [0:0] lock;
    logic [0:0] enable;
    logic [0:0] fence;
    logic [0:0] align;
    logic [0:0] wen;
    logic [0:0] en;
    logic [0:0] inv;
    logic [0:0] clear;
    logic [0:0] hit;
    logic [0:0] miss1;
    logic [0:0] miss2;
    logic [0:0] load1;
    logic [0:0] load2;
    logic [2:0] state;
  } back_type;

  parameter back_type init_back = '{
    itag1 : 0,
    itag2 : 0,
    tag : 0,
    tag1 : 0,
    tag2 : 0,
    did : 0,
    did1 : 0,
    did2 : 0,
    wid : 0,
    wid1 : 0,
    wid2 : 0,
    addr : 0,
    addr1 : 0,
    addr2 : 0,
    idata1 : 0,
    idata2 : 0,
    data : 0,
    rdata : 0,
    ready : 0,
    valid : 0,
    ilock1 : 0,
    ilock2 : 0,
    lock : 0,
    enable : 0,
    fence : 0,
    align : 0,
    wen : 0,
    en : 0,
    inv : 0,
    clear : 0,
    hit : 0,
    miss1 : 0,
    miss2 : 0,
    load1 : 0,
    load2 : 0,
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
      v_f.addr1 = itim_in.mem_addr;
      v_f.align = v_f.addr1[1];
      v_f.tag1 = v_f.addr1[31:(depth+width+2)];
      v_f.did1 = v_f.addr1[(depth+width+1):(width+2)];
      v_f.wid1 = v_f.addr1[(width+1):2];
      v_f.addr2 = v_f.addr1 + 4;
      v_f.tag2 = v_f.addr2[31:(depth+width+2)];
      v_f.did2 = v_f.addr2[(depth+width+1):(width+2)];
      v_f.wid2 = v_f.addr2[(width+1):2];
    end

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.enable = 0;
    v_b.fence = 0;
    v_b.lock = 0;
    v_b.wen = 0;
    v_b.en = 0;
    v_b.inv = 0;
    v_b.clear = 0;
    v_b.hit = 0;
    v_b.miss1 = 0;
    v_b.miss2 = 0;
    v_b.load1 = 0;
    v_b.load2 = 0;

    if (r_b.state == hit) begin
      v_b.enable = r_f.enable;
      v_b.fence = r_f.fence;
      v_b.addr1 = r_f.addr1;
      v_b.addr2 = r_f.addr2;
      v_b.align = r_f.align;
      v_b.tag1 = r_f.tag1;
      v_b.tag2 = r_f.tag2;
      v_b.did1 = r_f.did1;
      v_b.did2 = r_f.did2;
      v_b.wid1 = r_f.wid1;
      v_b.wid2 = r_f.wid2;
    end

    case(r_b.state)
      hit :
        begin
          v_b.rdata = 0;
          v_b.ready = 0;
          v_b.itag1 = ivec_out[v_b.wid1].rdata[61-(depth+width):32];
          v_b.itag2 = ivec_out[v_b.wid2].rdata[61-(depth+width):32];
          v_b.ilock1 = ivec_out[v_b.wid1].rdata[62-(depth+width)];
          v_b.ilock2 = ivec_out[v_b.wid2].rdata[62-(depth+width)];
          v_b.idata1 = ivec_out[v_b.wid1].rdata[31:0];
          v_b.idata2 = ivec_out[v_b.wid2].rdata[31:0];
          if (v_b.fence == 1) begin
            v_b.clear = v_b.enable;
          end else if ((v_b.addr1 < itim_base_addr || v_b.addr1 >= itim_top_addr)) begin
            v_b.load1 = v_b.enable;
          end else if (v_b.align == 1 && (v_b.addr2 < itim_base_addr || v_b.addr2 >= itim_top_addr)) begin
            v_b.load2 = v_b.enable;
          end else if (v_b.ilock1 == 0) begin
            v_b.miss1 = v_b.enable;
          end else if (v_b.align == 1 && v_b.ilock2 == 0) begin
            v_b.miss2 = v_b.enable;
          end else if (|(v_b.itag1 ^ v_b.tag1) == 1) begin
            v_b.load1 = v_b.enable;
          end else if (v_b.align == 1 && |(v_b.itag2 ^ v_b.tag2) == 1) begin
            v_b.load2 = v_b.enable;
          end else begin
            v_b.hit = v_b.enable;
          end
          if (v_b.clear == 1) begin
            v_b.state = fence;
            v_b.inv = 1;
            v_b.did = 0;
            v_b.valid = 0;
          end if (v_b.miss1 == 1) begin
            v_b.state = miss1;
            v_b.valid = 1;
            v_b.addr = v_b.addr1;
          end if (v_b.miss2 == 1) begin
            v_b.state = miss2;
            v_b.valid = 1;
            v_b.addr = v_b.addr2;
            v_b.rdata[15:0] = v_b.idata1[31:16];
            v_b.ready = ~(&(v_b.rdata[1:0]));
          end else if (v_b.load1 == 1) begin
            v_b.state = load1;
            v_b.valid = 1;
            v_b.addr = v_b.addr1;
          end else if (v_b.load2 == 1) begin
            v_b.state = load2;
            v_b.valid = 1;
            v_b.addr = v_b.addr2;
            v_b.rdata[15:0] = v_b.idata1[31:16];
            v_b.ready = ~(&(v_b.rdata[1:0]));
          end else if (v_b.hit == 1) begin
            v_b.valid = 0;
            v_b.rdata = v_b.align ? {v_b.idata2[15:0],v_b.idata1[31:16]} : v_b.idata1;
            v_b.ready = 1;
          end
          if (v_b.miss2 == 1 || v_b.load2 == 1) begin
            if (v_b.ready == 1) begin
              v_b.state = hit;
              v_b.valid = 0;
            end
          end
        end
      miss1 :
        begin
          if (imem_out.mem_ready == 1) begin
            v_b.wen = 1;
            v_b.lock = 1;
            v_b.tag = v_b.tag1;
            v_b.did = v_b.did1;
            v_b.wid = v_b.wid1;
            v_b.data = imem_out.mem_rdata;
            if (imem_out.mem_ready == 1) begin
              if (v_b.align == 1) begin
                if (&(v_b.rdata[1:0]) == 1) begin
                  v_b.valid = 1;
                  v_b.state = miss2;
                end else begin
                  v_b.valid = 0;
                  v_b.state = hit;
                end
                v_b.rdata[15:0] = imem_out.mem_rdata[31:16];
                v_b.ready = ~(&(v_b.rdata[1:0]));
              end else begin
                v_b.valid = 0;
                v_b.state = hit;
                v_b.rdata = imem_out.mem_rdata;
                v_b.ready = 1;
              end
            end
          end
        end
      miss2 :
        begin
          v_b.ready = 0;
          if (imem_out.mem_ready == 1) begin
            v_b.wen = 1;
            v_b.lock = 1;
            v_b.tag = v_b.tag2;
            v_b.did = v_b.did2;
            v_b.wid = v_b.wid2;
            v_b.data = imem_out.mem_rdata;
            v_b.valid = 0;
            v_b.state = hit;
            v_b.rdata[31:16] = imem_out.mem_rdata[15:0];
            v_b.ready = 1;
          end
        end
      load1 :
        begin
          if (imem_out.mem_ready == 1) begin
            if (v_b.align == 1) begin
              if (&(v_b.rdata[1:0]) == 1) begin
                v_b.valid = 1;
                v_b.state = load2;
              end else begin
                v_b.valid = 0;
                v_b.state = hit;
              end
              v_b.rdata[15:0] = imem_out.mem_rdata[31:16];
              v_b.ready = ~(&(v_b.rdata[1:0]));
            end else begin
              v_b.valid = 0;
              v_b.state = hit;
              v_b.rdata = imem_out.mem_rdata;
              v_b.ready = 1;
            end
          end
        end
      load2 :
        begin
          v_b.ready = 0;
          if (imem_out.mem_ready == 1) begin
            v_b.valid = 0;
            v_b.state = hit;
            v_b.rdata[31:16] = imem_out.mem_rdata[15:0];
            v_b.ready = 1;
          end
        end
      fence :
        begin
          if (&(v_b.did) == 1) begin
            v_b.state = hit;
            v_b.inv = 1;
            v_b.en = 0;
            v_b.did = 0;
          end else begin
            v_b.inv = 1;
            v_b.en = 1;
            v_b.did = v_b.did + 1;
          end
        end
      default :
        begin
          v_b.rdata = 0;
          v_b.ready = 0;
        end
    endcase

    ivec_in[rin_f.wid1].raddr = rin_f.did1;
    ivec_in[rin_f.wid2].raddr = rin_f.did2;

    ivec_in[v_b.wid].wen = v_b.wen;
    ivec_in[v_b.wid].waddr = v_b.did;
    ivec_in[v_b.wid].wdata = {v_b.lock,v_b.tag,v_b.data};

    if (v_b.inv == 1) begin
      for (int i=0; i<itim_width; i=i+1) begin
        ivec_in[i].wen = v_b.en;
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
