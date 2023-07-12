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

  logic [63-(depth+width) : 0] ram_array[0:dtim_depth-1] = '{default:'0};

  logic [depth-1 : 0] raddr = 0;

  always_ff @(posedge clock) begin
    raddr <= dtim_ram_in.raddr;
    if (dtim_ram_in.wen == 1) begin
      ram_array[dtim_ram_in.waddr] <= dtim_ram_in.wdata;
    end
  end

  assign dtim_ram_out.rdata = ram_array[raddr];

endmodule

module dtim_ctrl
(
  input logic reset,
  input logic clock,
  input dtim_vec_out_type dvec_out,
  output dtim_vec_in_type dvec_in,
  input dtim_in_type dtim0_in,
  output dtim_out_type dtim0_out,
  input dtim_in_type dtim1_in,
  output dtim_out_type dtim1_out,
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

  task enable_data;
    output logic [31:0] data_o;
    input logic [31:0] data_i;
    input logic [31:0] data_s;
    input logic [3:0] strb;
    input logic [0:0] set;
    begin
      data_o = data_i;
      if (strb[0] == set)
        data_o[7:0] = data_s[7:0];
      if (strb[1] == set)
        data_o[15:8] = data_s[15:8];
      if (strb[2] == set)
        data_o[23:16] = data_s[23:16];
      if (strb[3] == set)
        data_o[31:24] = data_s[31:24];
    end
  endtask

  typedef struct packed{
    logic [29-(depth+width):0] tag0;
    logic [29-(depth+width):0] tag1;
    logic [depth-1:0] did0;
    logic [depth-1:0] did1;
    logic [width-1:0] wid0;
    logic [width-1:0] wid1;
    logic [31:0] addr0;
    logic [31:0] addr1;
    logic [31:0] data0;
    logic [31:0] data1;
    logic [3:0] strb0;
    logic [3:0] strb1;
    logic [0:0] wren0;
    logic [0:0] wren1;
    logic [0:0] rden0;
    logic [0:0] rden1;
    logic [0:0] fence;
    logic [0:0] enable0;
    logic [0:0] enable1;
  } front_type;

  parameter front_type init_front = '{
    tag0 : 0,
    tag1 : 0,
    did0 : 0,
    did1 : 0,
    wid0 : 0,
    wid1 : 0,
    addr0 : 0,
    addr1 : 0,
    data0 : 0,
    data1 : 0,
    strb0 : 0,
    strb1 : 0,
    wren0 : 0,
    wren1 : 0,
    rden0 : 0,
    rden1 : 0,
    fence : 0,
    enable0 : 0,
    enable1 : 0
  };

  typedef struct packed{
    logic [29-(depth+width):0] dtag0;
    logic [29-(depth+width):0] dtag1;
    logic [29-(depth+width):0] tag0;
    logic [29-(depth+width):0] tag1;
    logic [29-(depth+width):0] tag;
    logic [depth-1:0] did0;
    logic [depth-1:0] did1;
    logic [depth-1:0] did;
    logic [width-1:0] wid0;
    logic [width-1:0] wid1;
    logic [width-1:0] wid;
    logic [31:0] addr0;
    logic [31:0] addr1;
    logic [31:0] ddata0;
    logic [31:0] ddata1;
    logic [31:0] data0;
    logic [31:0] data1;
    logic [31:0] data;
    logic [3:0] strb0;
    logic [3:0] strb1;
    logic [0:0] dlock0;
    logic [0:0] dlock1;
    logic [0:0] ddirty0;
    logic [0:0] ddirty1;
    logic [0:0] wren0;
    logic [0:0] wren1;
    logic [0:0] wren;
    logic [0:0] rden0;
    logic [0:0] rden1;
    logic [0:0] rden;
    logic [0:0] fence;
    logic [0:0] equal;
    logic [0:0] enable0;
    logic [0:0] enable1;
    logic [31:0] sdata0;
    logic [31:0] sdata1;
    logic [3:0] sstrb0;
    logic [3:0] sstrb1;
    logic [0:0] store0;
    logic [0:0] store1;
    logic [0:0] clear;
    logic [0:0] ldst0;
    logic [0:0] ldst1;
    logic [0:0] miss0;
    logic [0:0] miss1;
    logic [0:0] hit0;
    logic [0:0] hit1;
    logic [0:0] lock0;
    logic [0:0] lock1;
    logic [0:0] lock;
    logic [0:0] dirty0;
    logic [0:0] dirty1;
    logic [0:0] dirty;
    logic [0:0] wen0;
    logic [0:0] wen1;
    logic [0:0] valid0;
    logic [0:0] valid1;
    logic [31:0] wdata0;
    logic [31:0] wdata1;
    logic [3:0] wstrb0;
    logic [3:0] wstrb1;
    logic [31:0] rdata0;
    logic [31:0] rdata1;
    logic [0:0] ready0;
    logic [0:0] ready1;
    logic [2:0] state;
  } back_type;

  parameter back_type init_back = '{
    dtag0 : 0,
    dtag1 : 0,
    tag0 : 0,
    tag1 : 0,
    tag : 0,
    did0 : 0,
    did1 : 0,
    did : 0,
    wid0 : 0,
    wid1 : 0,
    wid : 0,
    addr0 : 0,
    addr1 : 0,
    ddata0 : 0,
    ddata1 : 0,
    data0 : 0,
    data1 : 0,
    data : 0,
    strb0 : 0,
    strb1 : 0,
    dlock0 : 0,
    dlock1 : 0,
    ddirty0 : 0,
    ddirty1 : 0,
    wren0 : 0,
    wren1 : 0,
    wren : 0,
    rden0 : 0,
    rden1 : 0,
    rden : 0,
    fence : 0,
    equal : 0,
    enable0 : 0,
    enable1 : 0,
    sdata0 : 0,
    sdata1 : 0,
    sstrb0 : 0,
    sstrb1 : 0,
    store0 : 0,
    store1 : 0,
    clear : 0,
    ldst0 : 0,
    ldst1 : 0,
    miss0 : 0,
    miss1 : 0,
    hit0 : 0,
    hit1 : 0,
    lock0 : 0,
    lock1 : 0,
    lock : 0,
    dirty0 : 0,
    dirty1 : 0,
    dirty : 0,
    wen0 : 0,
    wen1 : 0,
    valid0 : 0,
    valid1 : 0,
    wdata0 : 0,
    wdata1 : 0,
    wstrb0 : 0,
    wstrb1 : 0,
    rdata0 : 0,
    rdata1 : 0,
    ready0 : 0,
    ready1 : 0,
    state : 0
  };

  integer i;

  front_type r_f,rin_f;
  front_type v_f;

  back_type r_b,rin_b;
  back_type v_b;

  always_comb begin

    v_f = r_f;

    v_f.enable0 = 0;
    v_f.enable1 = 0;

    v_f.fence = 0;

    v_f.wren0 = 0;
    v_f.wren1 = 0;
    v_f.rden0 = 0;
    v_f.rden1 = 0;

    if (dtim0_in.mem_valid == 1) begin
      v_f.enable0 = dtim0_in.mem_valid;
      v_f.fence = dtim0_in.mem_fence;
      v_f.wren0 = |dtim0_in.mem_wstrb;
      v_f.rden0 = ~(|dtim0_in.mem_wstrb);
      v_f.data0 = dtim0_in.mem_wdata;
      v_f.strb0 = dtim0_in.mem_wstrb;
      v_f.addr0 = {dtim0_in.mem_addr[31:2],2'b00};
      v_f.tag0 = dtim0_in.mem_addr[31:(depth+width+2)];
      v_f.did0 = dtim0_in.mem_addr[(depth+width+1):(width+2)];
      v_f.wid0 = dtim0_in.mem_addr[(width+1):2];
    end

    if (dtim1_in.mem_valid == 1) begin
      v_f.enable1 = dtim1_in.mem_valid;
      v_f.wren1 = |dtim1_in.mem_wstrb;
      v_f.rden1 = ~(|dtim1_in.mem_wstrb);
      v_f.data1 = dtim1_in.mem_wdata;
      v_f.strb1 = dtim1_in.mem_wstrb;
      v_f.addr1 = {dtim1_in.mem_addr[31:2],2'b00};
      v_f.tag1 = dtim1_in.mem_addr[31:(depth+width+2)];
      v_f.did1 = dtim1_in.mem_addr[(depth+width+1):(width+2)];
      v_f.wid1 = dtim1_in.mem_addr[(width+1):2];
    end

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.wen0 = 0;
    v_b.wen1 = 0;

    v_b.wren = 0;
    v_b.rden = 0;

    v_b.valid0 = 0;
    v_b.valid1 = 0;
    v_b.wdata0 = 0;
    v_b.wdata1 = 0;
    v_b.wstrb0 = 0;
    v_b.wstrb1 = 0;

    case(r_b.state)
      hit :
        begin
          v_b.ready0 = 0;
          v_b.ready1 = 0;
          v_b.enable0 = r_f.enable0;
          v_b.enable1 = r_f.enable1;
          v_b.fence = r_f.fence;
          v_b.wren0 = r_f.wren0;
          v_b.wren1 = r_f.wren1;
          v_b.rden0 = r_f.rden0;
          v_b.rden1 = r_f.rden1;
          v_b.data0 = r_f.data0;
          v_b.data1 = r_f.data1;
          v_b.strb0 = r_f.strb0;
          v_b.strb1 = r_f.strb1;
          v_b.addr0 = r_f.addr0;
          v_b.addr1 = r_f.addr1;
          v_b.tag0 = r_f.tag0;
          v_b.tag1 = r_f.tag1;
          v_b.did0 = r_f.did0;
          v_b.did1 = r_f.did1;
          v_b.wid0 = r_f.wid0;
          v_b.wid1 = r_f.wid1;
          ///////////////////////////////////////////////////////////////////////////////////
          v_b.dtag0 = dvec_out[v_b.wid0].rdata[61-(depth+width):32];
          v_b.dtag1 = dvec_out[v_b.wid1].rdata[61-(depth+width):32];
          v_b.dlock0 = dvec_out[v_b.wid0].rdata[63-(depth+width)];
          v_b.dlock1 = dvec_out[v_b.wid1].rdata[63-(depth+width)];
          v_b.ddirty0 = dvec_out[v_b.wid0].rdata[62-(depth+width)];
          v_b.ddirty1 = dvec_out[v_b.wid1].rdata[62-(depth+width)];
          v_b.ddata0 = dvec_out[v_b.wid0].rdata[31:0];
          v_b.ddata1 = dvec_out[v_b.wid1].rdata[31:0];
          ///////////////////////////////////////////////////////////////////////////////////
          v_b.equal = 0;
          v_b.clear = 0;
          v_b.ldst0 = 0;
          v_b.ldst1 = 0;
          v_b.miss0 = 0;
          v_b.miss1 = 0;
          v_b.hit0 = 0;
          v_b.hit1 = 0;
          ///////////////////////////////////////////////////////////////////////////////////
          if (v_b.addr0[31:2] == v_b.addr1[31:2]) begin
            v_b.equal = v_b.enable0 & v_b.enable1;
          end
          ///////////////////////////////////////////////////////////////////////////////////
          if (v_b.fence == 1) begin
            v_b.clear = v_b.enable0;
          end else if (v_b.addr0 < dtim_base_addr || v_b.addr0 >= dtim_top_addr) begin
            v_b.ldst0 = v_b.enable0;
          end else if (v_b.dlock0 == 0) begin
            v_b.miss0 = v_b.enable0;
          end else if (|(v_b.dtag0 ^ v_b.tag0) == 1) begin
            v_b.ldst0 = v_b.enable0;
          end else begin
            v_b.hit0 = v_b.enable0;
          end
          ///////////////////////////////////////////////////////////////////////////////////
          if (v_b.addr1 < dtim_base_addr || v_b.addr1 >= dtim_top_addr) begin
            v_b.ldst1 = v_b.enable1;
          end else if (v_b.dlock1 == 0) begin
            v_b.miss1 = v_b.enable1;
          end else if (|(v_b.dtag1 ^ v_b.tag1) == 1) begin
            v_b.ldst1 = v_b.enable1;
          end else begin
            v_b.hit1 = v_b.enable1;
          end
          ///////////////////////////////////////////////////////////////////////////////////
          if (v_b.clear == 1) begin
            v_b.did0 = 0;
            v_b.wid0 = 0;
            v_b.wren = 0;
            v_b.rden = 1;
          end else begin
            if (v_b.miss0 == 1) begin
              v_b.store0 = v_b.wren0;
              v_b.sstrb0 = v_b.wren0 ? v_b.strb0 : 0;
              v_b.sdata0 = v_b.wren0 ? v_b.data0 : 0;
            end else if (v_b.ldst0 == 1) begin
              v_b.wstrb0 = v_b.wren0 ? v_b.strb0 : 0;
              v_b.wdata0 = v_b.wren0 ? v_b.data0 : 0;
            end else if (v_b.hit0 == 1) begin
              v_b.wen0 = v_b.wren0;
              v_b.lock0 = v_b.wren0;
              v_b.dirty0 = v_b.wren0;
              enable_data(v_b.data0,v_b.data0,v_b.ddata0,v_b.strb0,0);
              v_b.rdata0 = v_b.ddata0;
              v_b.ready0 = 1;
            end
            if (v_b.miss1 == 1) begin
              v_b.store1 = v_b.wren1;
              v_b.sstrb1 = v_b.wren1 ? v_b.strb1 : 0;
              v_b.sdata1 = v_b.wren1 ? v_b.data1 : 0;
            end else if (v_b.ldst1 == 1) begin
              v_b.wstrb1 = v_b.wren1 ? v_b.strb1 : 0;
              v_b.wdata1 = v_b.wren1 ? v_b.data1 : 0;
            end else if (v_b.hit1 == 1) begin
              v_b.wen1 = v_b.wren1;
              v_b.lock1 = v_b.wren1;
              v_b.dirty1 = v_b.wren1;
              if (v_b.equal == 1) begin
                enable_data(v_b.data1,v_b.data0,v_b.ddata0,v_b.strb1,0);
                v_b.rdata1 = v_b.data0;
              end else begin
                enable_data(v_b.data1,v_b.data1,v_b.ddata1,v_b.strb1,0);
                v_b.rdata1 = v_b.ddata1;
              end
              v_b.ready1 = 1;
            end
          end
          ///////////////////////////////////////////////////////////////////////////////////
          if (v_b.clear == 1) begin
            v_b.state = fence;
          end else if ((v_b.miss0 | v_b.miss1) == 1) begin
            if (v_b.miss0 == 1) begin
              v_b.valid0 = 1;
            end else if (v_b.miss1 == 1) begin
              v_b.valid1 = 1;
            end
            v_b.state = miss;
          end else if ((v_b.ldst0 | v_b.ldst1) == 1) begin
            if (v_b.ldst0 == 1) begin
              v_b.valid0 = 1;
            end else if (v_b.ldst1 == 1) begin
              v_b.valid1 = 1;
            end
            v_b.state = ldst;
          end
        end
      miss :
        begin
          if (dmem_out.mem_ready == 1) begin
            if (v_b.miss0 == 1) begin
              v_b.wen0 = 1;
              v_b.lock0 = 1;
              v_b.dirty0 = v_b.store0;
              v_b.data0 = dmem_out.mem_rdata;
              enable_data(v_b.data0,v_b.data0,v_b.sdata0,v_b.sstrb0,1);
              v_b.rdata0 = dmem_out.mem_rdata;
              v_b.ready0 = 1;
              v_b.store0 = 0;
              v_b.sstrb0 = 0;
              v_b.sdata0 = 0;
              v_b.miss0 = 0;
              if (v_b.equal == 1) begin
                v_b.wen1 = 1;
                v_b.lock1 = 1;
                v_b.dirty1 = v_b.store1;
                enable_data(v_b.data1,v_b.data0,v_b.sdata1,v_b.sstrb1,1);
                v_b.rdata1 = v_b.data0;
                v_b.ready1 = 1;
                v_b.state = hit;
              end else if (v_b.miss1 == 1) begin
                v_b.valid1 = 1;
                v_b.state = miss;
              end else if (v_b.ldst1 == 1) begin
                v_b.valid1 = 1;
                v_b.state = ldst;
              end else begin
                v_b.state = hit;
              end
            end else if (v_b.miss1 == 1) begin
              v_b.wen1 = 1;
              v_b.lock1 = 1;
              v_b.dirty1 = v_b.store1;
              v_b.data1 = dmem_out.mem_rdata;
              enable_data(v_b.data1,v_b.data1,v_b.sdata1,v_b.sstrb1,1);
              v_b.rdata1 = dmem_out.mem_rdata;
              v_b.ready1 = 1;
              v_b.store1 = 0;
              v_b.sstrb1 = 0;
              v_b.sdata1 = 0;
              v_b.miss1 = 0;
              if (v_b.ldst0 == 1) begin
                v_b.valid0 = 1;
                v_b.state = ldst;
              end else begin
                v_b.state = hit;
              end
            end
          end
        end
      ldst :
        begin
          if (dmem_out.mem_ready == 1) begin
            if (v_b.ldst0 == 1) begin
              v_b.rdata0 = dmem_out.mem_rdata;
              v_b.ready0 = 1;
              v_b.ldst0 = 0;
              if (v_b.equal == 1) begin
                v_b.rdata1 = dmem_out.mem_rdata;
                v_b.ready1 = 1;
                v_b.state = hit;
              end else if (v_b.ldst1 == 1) begin
                v_b.valid1 = 1;
                v_b.state = ldst;
              end else if (v_b.miss1 == 1) begin
                v_b.valid1 = 1;
                v_b.state = miss;
              end else begin
                v_b.state = hit;
              end
            end else if (v_b.ldst1 == 1) begin
              v_b.rdata1 = dmem_out.mem_rdata;
              v_b.ready1 = 1;
              v_b.ldst1 = 0;
              if (v_b.miss0 == 1) begin
                v_b.valid0 = 1;
                v_b.state = miss;
              end else begin
                v_b.state = hit;
              end
            end
          end
        end
      fence :
        begin
          if (dmem_out.mem_ready == 1 || v_b.valid0 == 0) begin
            v_b.wren = 1;
            v_b.did = v_b.did0;
            v_b.wid = v_b.wid0;
            if (&(v_b.wid0) == 1 && &(v_b.did0) == 1) begin
              v_b.rdata0 = 0;
              v_b.ready0 = 1;
              v_b.state = hit;
              v_b.rden = 0;
              v_b.did0 = 0;
              v_b.wid0 = 0;
            end else if (&(v_b.wid0) == 1 && &(v_b.did0) == 0) begin
              v_b.rden = 1;
              v_b.did0 = v_b.did0 + 1;
              v_b.wid0 = 0;
            end else begin
              v_b.rden = 1;
              v_b.wid0 = v_b.wid0 + 1;
            end
          end
          v_b.tag = dvec_out[v_b.wid].rdata[61-(depth+width):32];
          v_b.lock = dvec_out[v_b.wid].rdata[63-(depth+width)];
          v_b.dirty = dvec_out[v_b.wid].rdata[62-(depth+width)];
          v_b.data = dvec_out[v_b.wid].rdata[31:0];
          if (v_b.lock == 1 && v_b.dirty == 1) begin
            v_b.valid0 = 1;
            v_b.addr0 = {v_b.tag,v_b.did,v_b.wid,2'b0};
            v_b.wdata0 = v_b.data;
            v_b.wstrb0 = 4'hF;
          end else begin
            v_b.addr0 = 0;
          end
        end
      default :
        begin
        end
    endcase
    
    for (int i=0; i<dtim_width; i=i+1) begin
      dvec_in[i].raddr = 0;
    end

    if (rin_f.rden0 == 1 || rin_f.wren0 == 1) begin
      dvec_in[rin_f.wid0].raddr = rin_f.did0;
    end
    if (rin_f.rden1 == 1 || rin_f.wren1 == 1) begin
      dvec_in[rin_f.wid1].raddr = rin_f.did1;
    end

    if (v_b.rden == 1) begin
      dvec_in[v_b.wid0].raddr = v_b.did0;
    end

    for (int i=0; i<dtim_width; i=i+1) begin
      dvec_in[i].wen = 0;
      dvec_in[i].waddr = 0;
      dvec_in[i].wdata = 0;
    end

    if (v_b.wen0 == 1) begin
      dvec_in[v_b.wid0].wen = v_b.wen0;
      dvec_in[v_b.wid0].waddr = v_b.did0;
      dvec_in[v_b.wid0].wdata = {v_b.lock0,v_b.dirty0,v_b.tag0,v_b.data0};
    end
    if (v_b.wen1 == 1) begin
      dvec_in[v_b.wid1].wen = v_b.wen1;
      dvec_in[v_b.wid1].waddr = v_b.did1;
      dvec_in[v_b.wid1].wdata = {v_b.lock1,v_b.dirty1,v_b.tag1,v_b.data1};
    end

    if (v_b.wren == 1) begin
      dvec_in[v_b.wid].wen = v_b.wren;
      dvec_in[v_b.wid].waddr = v_b.did;
      dvec_in[v_b.wid].wdata = 0;
    end

    dmem_in.mem_valid = v_b.valid0 | v_b.valid1;
    dmem_in.mem_fence = 0;
    dmem_in.mem_instr = 0;
    dmem_in.mem_addr = v_b.valid0 ? v_b.addr0 : v_b.addr1;
    dmem_in.mem_wdata = v_b.valid0 ? v_b.wdata0 : v_b.wdata1;
    dmem_in.mem_wstrb = v_b.valid0 ? v_b.wstrb0 : v_b.wstrb1;

    dtim0_out.mem_rdata = v_b.rdata0;
    dtim0_out.mem_ready = v_b.ready0;

    dtim1_out.mem_rdata = v_b.rdata1;
    dtim1_out.mem_ready = v_b.ready1;

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
  input dtim_in_type dtim0_in,
  output dtim_out_type dtim0_out,
  input dtim_in_type dtim1_in,
  output dtim_out_type dtim1_out,
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
    .dtim0_in (dtim0_in),
    .dtim0_out (dtim0_out),
    .dtim1_in (dtim1_in),
    .dtim1_out (dtim1_out),
    .dmem_out (dmem_out),
    .dmem_in (dmem_in)
  );

endmodule
