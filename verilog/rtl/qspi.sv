import configure::*;
import wires::*;

module qspi #(
    parameter clock_rate
) (
    input logic reset,
    input logic clock,
    input mem_in_type qspi_in,
    output mem_out_type qspi_out,
    output logic sclk,
    output logic cs,
    inout logic d0,
    inout logic d1,
    inout logic d2,
    inout logic d3
);
  timeunit 1ns; timeprecision 1ps;

  localparam half = (clock_rate / 2 - 1);

  typedef struct packed {
    logic [31 : 0] counter;
    logic [7 : 0]  data;
    logic [1 : 0]  state;
    logic [0 : 0]  write;
    logic [0 : 0]  read;
    logic [5 : 0]  incr;
    logic [0 : 0]  sclk;
    logic [0 : 0]  cs;
    logic [2 : 0]  dim;
    logic [0 : 0]  ready;
  } register_type;

  register_type init_register = 0;

  register_type r, rin, v;

  always_comb begin

    v = r;

    v.counter = v.counter + 1;
    v.ready = 0;
    v.cs = 1;

    if (v.counter > half) begin
      v.counter = 0;
      v.sclk = ~v.sclk;
    end

    if (v.sclk == 0 && (v.write == 1 || v.read == 1)) begin
      if (v.state == 1) begin
        v.ready = 1;
        v.write = 0;
        v.read  = 0;
      end else begin
        v.data  = {v.data[3:0], 4'b0};
        v.state = v.state + 1;
      end
    end

    if (qspi_in.mem_valid == 1 && |qspi_in.mem_wstrb == 1 && qspi_in.mem_addr == 0) begin
      v.data  = qspi_in.mem_wdata[7:0];
      v.write = 1;
      v.state = 0;
    end

    if (qspi_in.mem_valid == 1 && |qspi_in.mem_wstrb == 0 && qspi_in.mem_addr == 0) begin
      v.read  = 1;
      v.state = 0;
    end

    if (v.write == 1) begin
      v.cs = 0;
      d0   = v.data[4];
      d1   = v.data[5];
      d2   = v.data[6];
      d3   = v.data[7];
    end else if (v.read == 1) begin
      v.cs = 0;
      v.data[0] = d0;
      v.data[1] = d1;
      v.data[2] = d2;
      v.data[3] = d3;
    end

    sclk = v.sclk;
    cs   = v.cs;

    rin  = v;

  end

  assign qspi_out.mem_rdata = {56'h0, r.data};
  assign qspi_out.mem_ready = r.ready;

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
