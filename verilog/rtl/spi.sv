import configure::*;
import wires::*;

module spi #(
    parameter clock_rate
) (
    input logic reset,
    input logic clock,
    input mem_in_type spi_in,
    output mem_out_type spi_out,
    output sclk,
    output mosi,
    input miso,
    output ss
);
  timeunit 1ns; timeprecision 1ps;

  localparam half = (clock_rate / 2 - 1);

  typedef struct packed {
    logic [31 : 0] counter;
    logic [7 : 0]  data;
    logic [2 : 0]  state;
    logic [0 : 0]  write;
    logic [0 : 0]  read;
    logic [5 : 0]  incr;
    logic [0 : 0]  sclk;
    logic [0 : 0]  ss;
    logic [2 : 0]  dim;
    logic [0 : 0]  ready;
  } register_type;

  register_type init_register = 0;

  register_type r, rin, v;

  always_comb begin

    v = r;

    v.counter = v.counter + 1;
    v.ready = 0;
    v.ss = 1;

    if (v.counter > half) begin
      v.counter = 0;
      v.sclk = ~v.sclk;
    end

    if (v.sclk == 0 && (v.write == 1 || v.read == 1)) begin
      if (v.state == 7) begin
        v.ready = 1;
        v.write = 0;
        v.read  = 0;
      end else begin
        v.data  = {v.data[6:0], 1'b0};
        v.state = v.state + 1;
      end
    end

    if (spi_in.mem_valid == 1 && |spi_in.mem_wstrb == 1 && spi_in.mem_addr == 0) begin
      v.data  = spi_in.mem_wdata[7:0];
      v.write = 1;
      v.state = 0;
    end

    if (spi_in.mem_valid == 1 && |spi_in.mem_wstrb == 0 && spi_in.mem_addr == 0) begin
      v.read  = 1;
      v.state = 0;
    end

    if (v.write == 1) begin
      v.ss = 0;
    end else if (v.read == 1) begin
      v.ss = 0;
      v.data[0] = miso;
    end

    rin = v;

  end

  assign spi_out.mem_rdata = {56'h0, r.data};
  assign spi_out.mem_error = 0;
  assign spi_out.mem_ready = r.ready;

  assign sclk = r.sclk;
  assign ss = r.ss;
  assign mosi = r.write == 1 ? r.data[7] : 0;

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
