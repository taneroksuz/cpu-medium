import configure::*;
import constants::*;
import wires::*;

module buffer
(
  input logic reset,
  input logic clock,
  input buffer_in_type buffer_in,
  output buffer_out_type buffer_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(buffer_depth-1);
  localparam total = 2**(depth-1);

  logic [47 : 0] buffer [0:buffer_depth-1];
  logic [47 : 0] buffer_reg [0:buffer_depth-1];

  typedef struct packed{
    logic [depth-1 : 0] wid;
    logic [depth-1 : 0] rid;
    logic [depth-1 : 0] diff;
    logic [depth : 0] count;
    logic [47 : 0] data0;
    logic [47 : 0] data1;
    logic [47 : 0] data2;
    logic [47 : 0] data3;
    logic [31 : 0] pc0;
    logic [31 : 0] pc1;
    logic [31 : 0] instr0;
    logic [31 : 0] instr1;
    logic [0 : 0] comp0;
    logic [0 : 0] comp1;
    logic [0 : 0] ready0;
    logic [0 : 0] ready1;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    wid : 0,
    rid : 0,
    diff : 0,
    count : 0,
    data0 : 0,
    data1 : 0,
    data2 : 0,
    data3 : 0,
    pc0 : 0,
    pc1 : 0,
    instr0 : 0,
    instr1 : 0,
    comp0 : 0,
    comp1 : 0,
    ready0 : 0,
    ready1 : 0,
    stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    buffer = buffer_reg;

    v = r;

    if (buffer_in.clear == 1) begin
      v.count = 0;
      v.wid = 0;
      v.rid = 0;
    end else if (r.stall == 0) begin
      if (buffer_in.ready == 1) begin
        buffer[v.wid] = {buffer_in.pc,buffer_in.rdata[15:0]};
        v.wid = v.wid + 1;
        buffer[v.wid] = {buffer_in.pc+2,buffer_in.rdata[31:16]};
        v.wid = v.wid + 1;
        buffer[v.wid] = {buffer_in.pc+4,buffer_in.rdata[47:32]};
        v.wid = v.wid + 1;
        buffer[v.wid] = {buffer_in.pc+6,buffer_in.rdata[63:48]};
        v.wid = v.wid + 1;
        v.count = v.count + 4;
      end
    end

    v.data0 = buffer[v.rid];
    v.data1 = buffer[v.rid+1];
    v.data2 = buffer[v.rid+2];
    v.data3 = buffer[v.rid+3];

    v.pc0 = 0;
    v.pc1 = 0;

    v.instr0 = 0;
    v.instr1 = 0;

    v.comp0 = 0;
    v.comp1 = 0;

    v.ready0 = 0;
    v.ready1 = 0;

    v.diff = 0;

    if (v.count > 0) begin
      v.pc0 = v.data0[47:16];
      v.instr0[15:0] = v.data0[15:0];
      v.comp0 = ~(&v.data0[1:0]);
      v.ready0 = v.comp0;
      v.diff = v.comp0 ? 1 : 0;
    end
    if (v.count > 1) begin
      if (v.comp0 == 0) begin
        v.instr0[31:16] = v.data1[15:0];
        v.ready0 = 1;
        v.diff = 2;
      end
      if (v.comp0 == 1) begin
        v.pc1 = v.data1[47:16];
        v.instr1[15:0] = v.data1[15:0];
        v.comp1 = ~(&v.data1[1:0]);
        v.ready1 = v.comp1;
        v.diff = v.comp1 ? 2 : 1;
      end
    end
    if (v.count > 2) begin
      if (v.comp0 == 1 && v.comp1 == 0) begin
        v.instr1[31:16] = v.data2[15:0];
        v.ready1 = 1;
        v.diff = 3;
      end
      if (v.comp0 == 0 && v.comp1 == 0) begin
        v.pc1 = v.data2[47:16];
        v.instr1[15:0] = v.data2[15:0];
        v.comp1 = ~(&v.data2[1:0]);
        v.ready1 = v.comp1;
        v.diff = v.comp1 ? 3 : 2;
      end
    end
    if (v.count > 3) begin
      if (v.comp0 == 0 && v.comp1 == 0) begin
        v.instr1[31:16] = v.data3[15:0];
        v.ready1 = 1;
        v.diff = 4;
      end
    end

    if (buffer_in.stall == 1) begin
      v.ready0 = 0;
      v.ready1 = 0;
      v.diff = 0;
    end

    v.count = v.count - v.diff;
    v.rid = v.rid + v.diff;

    v.stall = 0;

    if (v.count > total) begin
      v.stall = 1;
    end

    buffer_out.pc0 = v.ready0 ? v.pc0 : 32'hFFFFFFFF;
    buffer_out.pc1 = v.ready1 ? v.pc1 : 32'hFFFFFFFF;
    buffer_out.instr0 = v.ready0 ? v.instr0 : 0;
    buffer_out.instr1 = v.ready1 ? v.instr1 : 0;
    buffer_out.ready0 = v.ready0;
    buffer_out.ready1 = v.ready1;
    buffer_out.stall = v.stall;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      buffer_reg <= '{default:0};
      r <= init_reg;
    end else begin
      buffer_reg <= buffer;
      r <= rin;
    end
  end

endmodule
