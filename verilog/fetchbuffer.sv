package fetch_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [fetchbuffer_depth-1 : 0] waddr;
    logic [fetchbuffer_depth-1 : 0] raddr1;
    logic [fetchbuffer_depth-1 : 0] raddr2;
    logic [62 : 0] wdata;
  } fetchbuffer_data_in_type;

  typedef struct packed{
    logic [62 : 0] rdata1;
    logic [62 : 0] rdata2;
  } fetchbuffer_data_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import fetch_wires::*;

module fetchbuffer_data
(
  input logic clk,
  input fetchbuffer_data_in_type fetchbuffer_data_in,
  output fetchbuffer_data_out_type fetchbuffer_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [62 : 0] fetchbuffer_data_array[0:2**fetchbuffer_depth-1] = '{default:'0};

  assign fetchbuffer_data_out.rdata1 = fetchbuffer_data_array[fetchbuffer_data_in.raddr1];
  assign fetchbuffer_data_out.rdata2 = fetchbuffer_data_array[fetchbuffer_data_in.raddr2];

  always_ff @(posedge clk) begin
    if (fetchbuffer_data_in.wen == 1) begin
      fetchbuffer_data_array[fetchbuffer_data_in.waddr] <= fetchbuffer_data_in.wdata;
    end
  end

endmodule

module fetchbuffer_ctrl
(
  input logic rst,
  input logic clk,
  input fetchbuffer_data_out_type fetchbuffer_data_out,
  output fetchbuffer_data_in_type fetchbuffer_data_in,
  input mem_in_type fetchbuffer_in,
  output mem_out_type fetchbuffer_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  typedef struct packed{
    logic [2*fetchbuffer_depth-1:0] incr;
    logic [2*fetchbuffer_depth-1:0] step;
    logic [fetchbuffer_depth-1:0] wid;
    logic [fetchbuffer_depth-1:0] rid1;
    logic [fetchbuffer_depth-1:0] rid2;
    logic [62:0] wdata;
    logic [62:0] rdata1;
    logic [62:0] rdata2;
    logic [0:0] wren;
    logic [0:0] rden1;
    logic [0:0] rden2;
    logic [0:0] wrden1;
    logic [0:0] wrden2;
    logic [31:0] paddr;
    logic [31:0] addr;
    logic [0:0] pfence;
    logic [0:0] fence;
    logic [0:0] pvalid;
    logic [0:0] valid;
    logic [0:0] comp;
    logic [31:0] rdata;
    logic [0:0] ready;
    logic [0:0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    incr : 0,
    step : 0,
    wid : 0,
    rid1 : 0,
    rid2 : 0,
    wdata : 0,
    rdata1 : 0,
    rdata2 : 0,
    wren : 0,
    rden1 : 0,
    rden2 : 0,
    wrden1 : 0,
    wrden2 : 0,
    paddr : 0,
    addr : 0,
    pfence : 0,
    fence : 0,
    pvalid : 0,
    valid : 0,
    comp : 0,
    rdata : 0,
    ready : 0,
    stall : 0
  };

  reg_type r,rin = init_reg;
  reg_type v = init_reg;

  always_comb begin

    v = r;

    v.pvalid = 0;

    v.pfence = 0;

    v.valid = 1;

    v.ready = 0;
    v.rdata = 0;

    v.rden1 = 0;
    v.rden2 = 0;

    v.rdata1 = 0;
    v.rdata2 = 0;

    v.wren = 0;

    v.wrden1 = 0;
    v.wrden2 = 0;

    v.comp = 0;

    if (v.fence == 1) begin
      if (v.wid == 2**fetchbuffer_depth-1) begin
        v.wren = 0;
        v.wdata = 0;
        if (imem_out.mem_ready == 1) begin
          v.wid = 0;
          v.fence = 0;
        end
      end else begin 
        v.wren = 1;
        v.wid = v.wid + 1;
        v.wdata = 0;
        v.fence = 1;
      end
    end else if (imem_out.mem_ready == 1) begin
      v.wren = 1;
      v.wid = v.addr[(fetchbuffer_depth+1):2];
      v.wdata = {v.wren,v.addr[31:2],imem_out.mem_rdata};
    end

    if (v.wren == 1) begin
      if (v.incr < 2**fetchbuffer_depth-1) begin
        v.incr = v.incr + 2;
        v.addr = v.addr + 4;
      end else begin
        v.valid = 0;
      end
    end

    if (fetchbuffer_in.mem_valid == 1) begin
      v.pvalid = fetchbuffer_in.mem_valid;
      v.pfence = fetchbuffer_in.mem_fence;
      v.paddr = fetchbuffer_in.mem_addr;
    end

    v.rid1 = v.paddr[fetchbuffer_depth+1:2];

    if (v.rid1 == 2**fetchbuffer_depth-1) begin
      v.rid2 = 0;
    end else begin
      v.rid2 = v.paddr[fetchbuffer_depth+1:2]+1;
    end

    if (v.pfence == 1) begin
      v.wren = 1;
      v.wid = 0;
      v.wdata = 0;
      v.fence = 1;
    end

    fetchbuffer_data_in.wen = v.wren;
    fetchbuffer_data_in.waddr = v.wid;
    fetchbuffer_data_in.wdata = v.wdata;

    fetchbuffer_data_in.raddr1 = v.rid1;
    fetchbuffer_data_in.raddr2 = v.rid2;

    v.rdata1 = fetchbuffer_data_out.rdata1;
    v.rdata2 = fetchbuffer_data_out.rdata2;

    if (v.rdata1[62] == 1 && |(v.rdata1[61:32] ^ v.paddr[31:2]) == 0) begin
      v.rden1 = 1;
    end
    if (v.rdata2[62] == 1 && |(v.rdata2[61:32] ^ (v.paddr[31:2]+1)) == 0) begin
      v.rden2 = 1;
    end

    if (v.wren == 1) begin
      if (|(v.wdata[61:32] ^ v.paddr[31:2]) == 0) begin
        v.wrden1 = 1;
      end
      if (|(v.wdata[61:32] ^ (v.paddr[31:2]+1)) == 0) begin
        v.wrden2 = 1;
      end
    end

    if (v.paddr[1:1] == 0) begin
      if (v.wrden1 == 1) begin
        v.rdata = v.wdata[31:0];
        v.ready = 1;
      end else if (v.rden1 == 1) begin
        v.rdata = v.rdata1[31:0];
        v.ready = 1;
      end
    end else if (v.paddr[1:1] == 1) begin
      if (v.wrden1 == 1) begin
        v.rdata[15:0] = v.wdata[31:16];
        if (&(v.rdata[1:0]) == 0) begin
          v.ready = 1;
        end
        v.comp = 1;
      end else if (v.rden1 == 1) begin
        v.rdata[15:0] = v.rdata1[31:16];
        if (&(v.rdata[1:0]) == 0) begin
          v.ready = 1;
        end
        v.comp = 1;
      end
      if (v.comp == 1) begin
        if (v.wrden2 == 1) begin
          v.rdata[31:16] = v.wdata[15:0];
          v.ready = 1;
        end else if (v.rden2 == 1) begin
          v.rdata[31:16] = v.rdata2[15:0];
          v.ready = 1;
        end
      end
    end

    if (v.pvalid == 1) begin
      if (v.ready == 0 && v.wren == 1) begin
        if (v.rden1 == 0) begin
          v.addr = {v.paddr[31:2],2'b0};
          v.incr = 0;
        end else if (v.rden2 == 0) begin
          v.addr = {(v.paddr[31:2]+30'b1),2'b0};
          v.incr = 0;
        end
      end
    end

    if (v.ready == 0) begin
      v.step = 0;
    end else if (v.rdata[1:0] < 3) begin
      v.step = 1;
    end else begin
      v.step = 2;
    end

    if (v.pvalid == 1) begin
      if (v.step <= v.incr) begin
        v.incr = v.incr - v.step;
      end
    end

    if (v.fence == 1) begin
      v.ready = 0;
    end

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = v.fence;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.addr;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    fetchbuffer_out.mem_rdata = v.rdata;
    fetchbuffer_out.mem_ready = v.ready;

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

module fetchbuffer
(
  input logic rst,
  input logic clk,
  input mem_in_type fetchbuffer_in,
  output mem_out_type fetchbuffer_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  fetchbuffer_data_in_type fetchbuffer_data_in;
  fetchbuffer_data_out_type fetchbuffer_data_out;

  fetchbuffer_data fetchbuffer_data_comp
  (
    .clk (clk),
    .fetchbuffer_data_in (fetchbuffer_data_in),
    .fetchbuffer_data_out (fetchbuffer_data_out)
  );

  fetchbuffer_ctrl fetchbuffer_ctrl_comp
  (
    .rst (rst),
    .clk (clk),
    .fetchbuffer_data_out (fetchbuffer_data_out),
    .fetchbuffer_data_in (fetchbuffer_data_in),
    .fetchbuffer_in (fetchbuffer_in),
    .fetchbuffer_out (fetchbuffer_out),
    .imem_out (imem_out),
    .imem_in (imem_in)
  );

endmodule
