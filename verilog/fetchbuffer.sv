package fetch_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(fetchbuffer_depth-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [depth-1 : 0] waddr;
    logic [depth-1 : 0] raddr1;
    logic [depth-1 : 0] raddr2;
    logic [61 : 0] wdata;
  } fetchbuffer_data_in_type;

  typedef struct packed{
    logic [61 : 0] rdata1;
    logic [61 : 0] rdata2;
  } fetchbuffer_data_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import fetch_wires::*;

module fetchbuffer_data
(
  input logic clock,
  input fetchbuffer_data_in_type fetchbuffer_data_in,
  output fetchbuffer_data_out_type fetchbuffer_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [61 : 0] fetchbuffer_data_array[0:fetchbuffer_depth-1] = '{default:'0};

  assign fetchbuffer_data_out.rdata1 = fetchbuffer_data_array[fetchbuffer_data_in.raddr1];
  assign fetchbuffer_data_out.rdata2 = fetchbuffer_data_array[fetchbuffer_data_in.raddr2];

  always_ff @(posedge clock) begin
    if (fetchbuffer_data_in.wen == 1) begin
      fetchbuffer_data_array[fetchbuffer_data_in.waddr] <= fetchbuffer_data_in.wdata;
    end
  end

endmodule

module fetchbuffer_ctrl
(
  input logic reset,
  input logic clock,
  input fetchbuffer_data_out_type fetchbuffer_data_out,
  output fetchbuffer_data_in_type fetchbuffer_data_in,
  input mem_in_type fetchbuffer_in,
  output mem_out_type fetchbuffer_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(fetchbuffer_depth-1);
  localparam limit = 2*fetchbuffer_depth-2;

  localparam [1:0] idle = 0;
  localparam [1:0] active = 1;
  localparam [1:0] control = 2;

  typedef struct packed{
    logic [fetchbuffer_depth-1:0] enable;
    logic [depth+1:0] count;
    logic [depth+1:0] step;
    logic [depth-1:0] wid;
    logic [depth-1:0] rid1;
    logic [depth-1:0] rid2;
    logic [1:0] state;
    logic [61:0] wdata;
    logic [61:0] rdata1;
    logic [61:0] rdata2;
    logic [0:0] wren;
    logic [0:0] rden1;
    logic [0:0] rden2;
    logic [0:0] wrden1;
    logic [0:0] wrden2;
    logic [31:0] paddr1;
    logic [31:0] paddr2;
    logic [31:0] addr;
    logic [0:0] pfence;
    logic [0:0] fence;
    logic [0:0] pspec;
    logic [0:0] pvalid;
    logic [0:0] valid;
    logic [0:0] halt;
    logic [0:0] full;
    logic [0:0] comp;
    logic [31:0] rdata;
    logic [0:0] ready;
    logic [0:0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    enable : 0,
    count : 0,
    step : 0,
    wid : 0,
    rid1 : 0,
    rid2 : 0,
    state : 0,
    wdata : 0,
    rdata1 : 0,
    rdata2 : 0,
    wren : 0,
    rden1 : 0,
    rden2 : 0,
    wrden1 : 0,
    wrden2 : 0,
    paddr1 : 0,
    paddr2 : 0,
    addr : 0,
    pfence : 0,
    fence : 0,
    pspec : 0,
    pvalid : 0,
    valid : 0,
    halt : 0,
    full : 0,
    comp : 0,
    rdata : 0,
    ready : 0,
    stall : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    v.fence = 0;

    v.halt = 0;

    v.pvalid = 0;

    v.rdata = 0;
    v.ready = 0;

    v.rden1 = 0;
    v.rden2 = 0;

    v.rdata1 = 0;
    v.rdata2 = 0;

    v.wren = 0;

    v.wrden1 = 0;
    v.wrden2 = 0;

    v.comp = 0;
    v.step = 0;

    case(r.state)
      idle : begin
        v.state = active;
      end
      active : begin
        if (fetchbuffer_in.mem_valid == 1) begin
          v.pvalid = fetchbuffer_in.mem_valid;
          v.pfence = fetchbuffer_in.mem_fence;
          v.pspec = fetchbuffer_in.mem_spec;
          v.paddr1 = fetchbuffer_in.mem_addr;
          v.paddr2 = v.paddr1 + 4;
        end
        if (v.pfence == 1) begin
          v.state = control;
          v.enable = 0;
          v.count = 0;
        end else if (v.pspec == 1) begin
          v.state = control;
          v.enable = 0;
          v.count = 0;
        end else if (v.pvalid == 1) begin
          v.state = active;
        end
      end
      control : begin
        if (fetchbuffer_in.mem_spec == 1) begin
          v.paddr1 = fetchbuffer_in.mem_addr;
          v.paddr2 = v.paddr1 + 4;
        end
        v.halt = 1;
      end
      default : begin

      end
    endcase

    if (imem_out.mem_ready == 1) begin
      if (v.state == active) begin
        v.wren = 1;
        v.wid = v.addr[(depth+1):2];
        v.enable[v.wid] = 1;
        v.wdata = {v.addr[31:2],imem_out.mem_rdata};
        v.addr = v.addr + 4;
        v.count = v.count + 2;
      end
    end

    if (v.full == 1 || imem_out.mem_ready == 1) begin
      if (v.state == control) begin
        if (v.pfence == 1) begin
          v.state = active;
          v.pfence = 0;
          v.fence = 1;
          v.halt = 0;
          v.addr = {v.paddr1[31:2],2'b0};
        end else if (v.pspec == 1) begin
          v.state = active;
          v.pspec = 0;
          v.halt = 0;
          v.addr = {v.paddr1[31:2],2'b0};
        end
      end
    end

    v.rid1 = v.paddr1[depth+1:2];
    v.rid2 = v.paddr2[depth+1:2];

    fetchbuffer_data_in.wen = v.wren;
    fetchbuffer_data_in.waddr = v.wid;
    fetchbuffer_data_in.wdata = v.wdata;

    fetchbuffer_data_in.raddr1 = v.rid1;
    fetchbuffer_data_in.raddr2 = v.rid2;

    v.rdata1 = fetchbuffer_data_out.rdata1;
    v.rdata2 = fetchbuffer_data_out.rdata2;

    if (v.enable[v.rid1] == 1 && |(v.rdata1[61:32] ^ v.paddr1[31:2]) == 0) begin
      v.rden1 = 1;
    end
    if (v.enable[v.rid2] == 1 && |(v.rdata2[61:32] ^ v.paddr2[31:2]) == 0) begin
      v.rden2 = 1;
    end

    if (|(v.wdata[61:32] ^ v.paddr1[31:2]) == 0) begin
      v.wrden1 = v.wren;
    end
    if (|(v.wdata[61:32] ^ v.paddr2[31:2]) == 0) begin
      v.wrden2 = v.wren;
    end

    if (v.pvalid == 1) begin
      if (v.paddr1[1:1] == 0) begin
        if (v.wrden1 == 1) begin
          v.rdata = v.wdata[31:0];
          v.ready = 1;
        end else if (v.rden1 == 1) begin
          v.rdata = v.rdata1[31:0];
          v.ready = 1;
        end
      end else if (v.paddr1[1:1] == 1) begin
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
      if (v.ready == 1) begin
        if (&(v.rdata[1:0]) == 0) begin
          v.rdata[31:16] = 0;
          v.step = 1;
        end else if (&(v.rdata[1:0]) == 1) begin
          v.step = 2;
        end
        if (v.step <= v.count) begin
          v.count = v.count - v.step;
        end
      end
    end

    if (v.count < limit) begin
      v.full = 0;
      v.valid = 1;
    end else begin
      v.full = 1;
      v.valid = 0;
    end

    if (v.halt == 1) begin
      v.valid = 0;
      v.ready = 0;
    end

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = v.fence;
    imem_in.mem_spec = 0;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.addr;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    fetchbuffer_out.mem_rdata = v.rdata;
    fetchbuffer_out.mem_ready = v.ready;

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

module fetchbuffer
(
  input logic reset,
  input logic clock,
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
    .clock (clock),
    .fetchbuffer_data_in (fetchbuffer_data_in),
    .fetchbuffer_data_out (fetchbuffer_data_out)
  );

  fetchbuffer_ctrl fetchbuffer_ctrl_comp
  (
    .reset (reset),
    .clock (clock),
    .fetchbuffer_data_out (fetchbuffer_data_out),
    .fetchbuffer_data_in (fetchbuffer_data_in),
    .fetchbuffer_in (fetchbuffer_in),
    .fetchbuffer_out (fetchbuffer_out),
    .imem_out (imem_out),
    .imem_in (imem_in)
  );

endmodule
