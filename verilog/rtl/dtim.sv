package dtim_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(dtim_depth-1);
  localparam width = $clog2(dtim_width-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [depth-1 : 0] waddr;
    logic [depth-1 : 0] raddr;
    logic [63-(depth+width) : 0] wdata;
  } dtim_ram_in_type;

  typedef struct packed{
    logic [63-(depth+width) : 0] rdata;
  } dtim_ram_out_type;

  typedef dtim_ram_in_type dtim_vec_in_type [dtim_width];
  typedef dtim_ram_out_type dtim_vec_out_type [dtim_width];

endpackage

import configure::*;
import wires::*;
import dtim_wires::*;

module dtim_ram
(
  input logic clock,
  input dtim_ram_in_type dtim_ram_in,
  output dtim_ram_out_type dtim_ram_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(dtim_depth-1);
  localparam width = $clog2(dtim_width-1);

  logic [63-(depth+width) : 0] dtim_ram[0:dtim_depth-1] = '{default:'0};

  logic [depth-1 : 0] raddr = 0;

  always_ff @(posedge clock) begin
    raddr <= dtim_ram_in.raddr;
    if (dtim_ram_in.wen == 1) begin
      dtim_ram[dtim_ram_in.waddr] <= dtim_ram_in.wdata;
    end
  end

  assign dtim_ram_out.rdata = dtim_ram[raddr];

endmodule

module dtim_ctrl
(
  input logic reset,
  input logic clock,
  input dtim_vec_out_type dvec_out,
  output dtim_vec_in_type dvec_in,
  input mem_in_type dtim_in,
  output mem_out_type dtim_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(dtim_depth-1);
  localparam width = $clog2(dtim_width-1);

  localparam [2:0] hit = 0;
  localparam [2:0] miss = 1;
  localparam [2:0] ldst = 2;
  localparam [2:0] fence = 3;

  typedef struct packed{
    logic [29-(depth+width):0] tag;
    logic [width-1:0] wid;
    logic [depth-1:0] did;
    logic [31:0] addr;
    logic [31:0] data;
    logic [3:0] strb;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] fence;
    logic [0:0] enable;
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
    fence : 0,
    enable : 0
  };

  typedef struct packed{
    logic [29-(depth+width):0] dtag;
    logic [29-(depth+width):0] tag;
    logic [depth-1:0] did;
    logic [depth-1:0] id;
    logic [width-1:0] wid;
    logic [31:0] addr;
    logic [3:0] strb;
    logic [3:0] sstrb;
    logic [3:0] wstrb;
    logic [31:0] ddata;
    logic [31:0] data;
    logic [31:0] sdata;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [0:0] ready;
    logic [0:0] valid;
    logic [0:0] dlock;
    logic [0:0] lock;
    logic [0:0] ddirty;
    logic [0:0] dirty;
    logic [0:0] enable;
    logic [0:0] fence;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] store;
    logic [0:0] inv;
    logic [0:0] pass;
    logic [0:0] clear;
    logic [0:0] wen;
    logic [0:0] en;
    logic [0:0] hit;
    logic [0:0] miss;
    logic [0:0] ldst;
    logic [2:0] state;
  } back_type;

  parameter back_type init_back = '{
    dtag : 0,
    tag : 0,
    did : 0,
    id : 0,
    wid : 0,
    addr : 0,
    strb : 0,
    sstrb : 0,
    wstrb : 0,
    ddata : 0,
    data : 0,
    sdata : 0,
    wdata : 0,
    rdata : 0,
    ready : 0,
    valid : 0,
    dlock : 0,
    lock : 0,
    ddirty : 0,
    dirty : 0,
    enable : 0,
    fence : 0,
    wren : 0,
    rden : 0,
    store : 0,
    inv : 0,
    pass : 0,
    clear : 0,
    wen : 0,
    en : 0,
    hit : 0,
    miss : 0,
    ldst : 0,
    state : 0
  };

  integer i;

  front_type r_f,rin_f;
  front_type v_f;

  back_type r_b,rin_b;
  back_type v_b;

  always_comb begin

    v_f = r_f;

    v_f.enable = 0;

    if (dtim_in.mem_valid == 1) begin
        v_f.enable = dtim_in.mem_valid;
        v_f.fence = dtim_in.mem_fence;
        v_f.wren = |dtim_in.mem_wstrb;
        v_f.rden = ~(|dtim_in.mem_wstrb);
        v_f.data = dtim_in.mem_wdata;
        v_f.strb = dtim_in.mem_wstrb;
        v_f.addr = {dtim_in.mem_addr[31:2],2'b00};
        v_f.tag = dtim_in.mem_addr[31:(depth+width+2)];
        v_f.did = dtim_in.mem_addr[(depth+width+1):(width+2)];
        v_f.wid = dtim_in.mem_addr[(width+1):2];
    end

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.enable = 0;
    v_b.fence = 0;
    v_b.rden = 0;
    v_b.wren = 0;
    v_b.lock = 0;
    v_b.dirty = 0;
    v_b.wen = 0;
    v_b.en = 0;
    v_b.inv = 0;
    v_b.clear = 0;
    v_b.hit = 0;
    v_b.miss = 0;
    v_b.ldst = 0;

    v_b.valid = 0;
    v_b.addr = 0;
    v_b.wdata = 0;
    v_b.wstrb = 0;

    v_b.rdata = 0;
    v_b.ready = 0;

    if (r_b.state == hit) begin
      v_b.enable = r_f.enable;
      v_b.fence = r_f.fence;
      v_b.wren = r_f.wren;
      v_b.rden = r_f.rden;
      v_b.data = r_f.data;
      v_b.strb = r_f.strb;
      v_b.addr = r_f.addr;
      v_b.tag = r_f.tag;
      v_b.did = r_f.did;
      v_b.wid = r_f.wid;
    end

    case(r_b.state)
      hit :
        begin
          v_b.dtag = dvec_out[v_b.wid].rdata[61-(depth+width):32];
          v_b.dlock = dvec_out[v_b.wid].rdata[63-(depth+width)];
          v_b.ddirty = dvec_out[v_b.wid].rdata[62-(depth+width)];
          v_b.ddata = dvec_out[v_b.wid].rdata[31:0];
          if (v_b.fence == 1) begin
            v_b.clear = v_b.enable;
          end else if (v_b.addr < dtim_base_addr || v_b.addr >= dtim_top_addr) begin
            v_b.ldst = v_b.enable;
          end else if (v_b.dlock == 0) begin
            v_b.miss = v_b.enable;
          end else if (|(v_b.dtag ^ v_b.tag) == 1) begin
            v_b.ldst = v_b.enable;
          end else begin
            v_b.hit = v_b.enable;
          end
          if (v_b.clear == 1) begin
            v_b.state = fence;
            v_b.did = 0;
            v_b.wid = 0;
            v_b.inv = 1;
            v_b.pass = 1;
            v_b.valid = 0;
          end else if (v_b.miss == 1) begin
            v_b.state = miss;
            v_b.valid = 1;
            v_b.store = v_b.wren;
            v_b.sstrb = v_b.wren ? v_b.strb : 0;
            v_b.sdata = v_b.wren ? v_b.data : 0;
          end else if (v_b.ldst == 1) begin
            v_b.state = ldst;
            v_b.valid = 1;
            v_b.wstrb = v_b.wren ? v_b.strb : 0;
            v_b.wdata = v_b.wren ? v_b.data : 0;
          end else if (v_b.hit == 1) begin
            v_b.wen = v_b.wren;
            v_b.lock = v_b.wren;
            v_b.dirty = v_b.wren;
            if (~v_b.strb[0])
              v_b.data[7:0] = v_b.ddata[7:0];
            if (~v_b.strb[1])
              v_b.data[15:8] = v_b.ddata[15:8];
            if (~v_b.strb[2])
              v_b.data[23:16] = v_b.ddata[23:16];
            if (~v_b.strb[3])
              v_b.data[31:24] = v_b.ddata[31:24];
            v_b.valid = 0;
            v_b.rdata = v_b.rden ? v_b.ddata : 0;
            v_b.ready = 1;
          end
        end
      miss :
        begin
          if (dmem_out.mem_ready == 1) begin
            v_b.wen = 1;
            v_b.lock = 1;
            v_b.dirty = v_b.store;
            v_b.data = dmem_out.mem_rdata;
            if (v_b.sstrb[0])
              v_b.data[7:0] = v_b.sdata[7:0];
            if (v_b.sstrb[1])
              v_b.data[15:8] = v_b.sdata[15:8];
            if (v_b.sstrb[2])
              v_b.data[23:16] = v_b.sdata[23:16];
            if (v_b.sstrb[3])
              v_b.data[31:24] = v_b.sdata[31:24];
            v_b.valid = 0;
            v_b.store = 0;
            v_b.sstrb = 0;
            v_b.sdata = 0;
            v_b.state = hit;
            v_b.rdata = dmem_out.mem_rdata;
            v_b.ready = 1;
          end
        end
      ldst :
        begin
          if (dmem_out.mem_ready == 1) begin
            v_b.valid = 0;
            v_b.state = hit;
            v_b.rdata = dmem_out.mem_rdata;
            v_b.ready = 1;
          end
        end
      fence :
        begin
          if (dmem_out.mem_ready == 1 || v_b.valid == 0) begin
            v_b.inv = 1;
            v_b.en = 1;
            if (&(v_b.wid) == 1) begin
              if (&(v_b.did) == 1) begin
                v_b.state = hit;
                v_b.en = 0;
                v_b.pass = 0;
                v_b.did = 0;
                v_b.ready = 1;
              end else begin
                v_b.did = v_b.did + 1;
              end
              v_b.wid = 0;
            end else begin
              v_b.wid = v_b.wid + 1;
            end
          end
          v_b.tag = dvec_out[v_b.wid].rdata[61-(depth+width):32];
          v_b.lock = dvec_out[v_b.wid].rdata[63-(depth+width)];
          v_b.dirty = dvec_out[v_b.wid].rdata[62-(depth+width)];
          v_b.data = dvec_out[v_b.wid].rdata[31:0];
          if (v_b.lock == 1 && v_b.dirty == 1) begin
            v_b.valid = 1;
            v_b.addr = {v_b.tag,v_b.did,v_b.wid,2'b0};
            v_b.wdata = v_b.data;
            v_b.wstrb = 4'hF;
          end
        end
      default :
        begin
        end
    endcase
    
    for (int i=0; i<dtim_width; i=i+1) begin
      dvec_in[i].raddr = 0;
    end

    dvec_in[rin_f.wid].raddr = rin_f.did;

    if (v_b.pass == 1) begin
      for (int i=0; i<dtim_width; i=i+1) begin
        dvec_in[i].raddr = v_b.did;
      end
    end
    
    for (int i=0; i<dtim_width; i=i+1) begin
      dvec_in[i].wen = 0;
      dvec_in[i].waddr = 0;
      dvec_in[i].wdata = 0;
    end

    dvec_in[v_b.wid].wen = v_b.wen;
    dvec_in[v_b.wid].waddr = v_b.did;
    dvec_in[v_b.wid].wdata = {v_b.lock,v_b.dirty,v_b.tag,v_b.data};

    if (v_b.inv == 1) begin
      for (int i=0; i<dtim_width; i=i+1) begin
        if (i[width-1:0] == v_b.wid) begin
          dvec_in[i].wen = v_b.en;
          dvec_in[i].waddr = v_b.did;
          dvec_in[i].wdata = 0;
        end else begin
          dvec_in[i].wen = 0;
          dvec_in[i].waddr = v_b.did;
          dvec_in[i].wdata = 0;
        end
      end
    end

    dmem_in.mem_valid = v_b.valid;
    dmem_in.mem_fence = 0;
    dmem_in.mem_spec = 0;
    dmem_in.mem_instr = 0;
    dmem_in.mem_addr = v_b.addr;
    dmem_in.mem_wdata = v_b.wdata;
    dmem_in.mem_wstrb = v_b.wstrb;

    dtim_out.mem_rdata = v_b.rdata;
    dtim_out.mem_ready = v_b.ready;

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

module dtim
(
  input logic reset,
  input logic clock,
  input mem_in_type dtim_in,
  output mem_out_type dtim_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  dtim_vec_in_type dvec_in;
  dtim_vec_out_type dvec_out;

  generate

    genvar i;

    for (i=0; i<dtim_width; i=i+1) begin : dtim_ram
      dtim_ram dtim_ram_comp
      (
        .clock (clock),
        .dtim_ram_in (dvec_in[i]),
        .dtim_ram_out (dvec_out[i])
      );
    end

  endgenerate

  dtim_ctrl dtim_ctrl_comp
  (
    .reset (reset),
    .clock (clock),
    .dvec_out (dvec_out),
    .dvec_in (dvec_in),
    .dtim_in (dtim_in),
    .dtim_out (dtim_out),
    .dmem_out (dmem_out),
    .dmem_in (dmem_in)
  );

endmodule
