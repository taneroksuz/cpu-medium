package tim_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(tim_depth-1);
  localparam width = $clog2(tim_width-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [depth-1 : 0] waddr;
    logic [depth-1 : 0] raddr;
    logic [31 : 0] wdata;
  } tim_ram_in_type;

  typedef struct packed{
    logic [31 : 0] rdata;
  } tim_ram_out_type;

  typedef tim_ram_in_type tim_vec_in_type [tim_width];
  typedef tim_ram_out_type tim_vec_out_type [tim_width];

endpackage

import configure::*;
import wires::*;
import tim_wires::*;

module tim_ram
(
  input logic clock,
  input tim_ram_in_type tim_ram_in,
  output tim_ram_out_type tim_ram_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(tim_depth-1);
  localparam width = $clog2(tim_width-1);

  logic [31 : 0] tim_ram[0:tim_depth-1] = '{default:'0};

  logic [depth-1 : 0] raddr = 0;

  always_ff @(posedge clock) begin
    raddr <= tim_ram_in.raddr;
    if (tim_ram_in.wen == 1) begin
      tim_ram[tim_ram_in.waddr] <= tim_ram_in.wdata;
    end
  end

  assign tim_ram_out.rdata = tim_ram[raddr];

endmodule

module tim_ctrl
(
  input logic reset,
  input logic clock,
  input tim_vec_out_type dvec_out,
  output tim_vec_in_type dvec_in,
  input mem_in_type tim_in,
  output mem_out_type tim_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(tim_depth-1);
  localparam width = $clog2(tim_width-1);

  typedef struct packed{
    logic [width-1:0] wid;
    logic [depth-1:0] did;
    logic [31:0] data;
    logic [3:0] strb;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] enable;
  } front_type;

  parameter front_type init_front = '{
    wid : 0,
    did : 0,
    data : 0,
    strb : 0,
    wren : 0,
    rden : 0,
    enable : 0
  };

  typedef struct packed{
    logic [depth-1:0] did;
    logic [width-1:0] wid;
    logic [3:0] strb;
    logic [31:0] data;
    logic [31:0] rdata;
    logic [0:0] enable;
    logic [0:0] wren;
    logic [0:0] rden;
  } back_type;

  parameter back_type init_back = '{
    did : 0,
    wid : 0,
    strb : 0,
    data : 0,
    rdata : 0,
    enable : 0,
    wren : 0,
    rden : 0
  };

  integer i;

  front_type r_f,rin_f;
  front_type v_f;

  back_type r_b,rin_b;
  back_type v_b;

  always_comb begin

    v_f = r_f;

    v_f.enable = 0;
    v_f.rden = 0;
    v_f.wren = 0;

    if (tim_in.mem_valid == 1) begin
      v_f.enable = tim_in.mem_valid;
      v_f.wren = |tim_in.mem_wstrb;
      v_f.rden = ~(|tim_in.mem_wstrb);
      v_f.data = tim_in.mem_wdata;
      v_f.strb = tim_in.mem_wstrb;
      v_f.did = tim_in.mem_addr[(depth+width+1):(width+2)];
      v_f.wid = tim_in.mem_addr[(width+1):2];
    end

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.enable = r_f.enable;
    v_b.wren = r_f.wren;
    v_b.rden = r_f.rden;
    v_b.data = r_f.data;
    v_b.strb = r_f.strb;
    v_b.did = r_f.did;
    v_b.wid = r_f.wid;

    v_b.rdata = 0;

    if (v_b.enable == 1) begin
      v_b.rdata = dvec_out[v_b.wid].rdata[31:0];
      if (v_b.strb[0] == 0) begin
        v_b.data[7:0] = v_b.rdata[7:0];
      end
      if (v_b.strb[1] == 0) begin
        v_b.data[15:8] = v_b.rdata[15:8];
      end
      if (v_b.strb[2] == 0) begin
        v_b.data[23:16] = v_b.rdata[23:16];
      end
      if (v_b.strb[3] == 0) begin
        v_b.data[31:24] = v_b.rdata[31:24];
      end
    end

    // Read data

    for (int i=0; i<tim_width; i=i+1) begin
      dvec_in[i].raddr = 0;
    end

    dvec_in[rin_f.wid].raddr = rin_f.did;

    // Write data

    for (int i=0; i<tim_width; i=i+1) begin
      dvec_in[i].wen = 0;
      dvec_in[i].waddr = 0;
      dvec_in[i].wdata = 0;
    end

    dvec_in[v_b.wid].wen = v_b.wren;
    dvec_in[v_b.wid].waddr = v_b.did;
    dvec_in[v_b.wid].wdata = v_b.data;

    // Output

    tim_out.mem_rdata = v_b.rden ? v_b.rdata : 0;
    tim_out.mem_ready = v_b.rden | v_b.wren;

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

module tim
(
  input  logic reset,
  input  logic clock,
  input  logic [0  : 0] tim_valid,
  input  logic [0  : 0] tim_instr,
  input  logic [31 : 0] tim_addr,
  input  logic [31 : 0] tim_wdata,
  input  logic [3  : 0] tim_wstrb,
  output logic [31 : 0] tim_rdata,
  output logic [0  : 0] tim_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  tim_vec_in_type dvec_in;
  tim_vec_out_type dvec_out;
  mem_in_type tim_in;
  mem_out_type tim_out;

  generate

    genvar i;

    for (i=0; i<tim_width; i=i+1) begin : tim_ram
      tim_ram tim_ram_comp
      (
        .clock (clock),
        .tim_ram_in (dvec_in[i]),
        .tim_ram_out (dvec_out[i])
      );
    end

  endgenerate

  tim_ctrl tim_ctrl_comp
  (
    .reset (reset),
    .clock (clock),
    .dvec_out (dvec_out),
    .dvec_in (dvec_in),
    .tim_in (tim_in),
    .tim_out (tim_out)
  );

  assign tim_in.mem_valid = tim_valid;
  assign tim_in.mem_instr = tim_instr;
  assign tim_in.mem_addr  = tim_addr;
  assign tim_in.mem_wdata = tim_wdata;
  assign tim_in.mem_wstrb = tim_wstrb;

  assign tim_rdata = tim_out.mem_rdata;
  assign tim_ready = tim_out.mem_ready;

endmodule
