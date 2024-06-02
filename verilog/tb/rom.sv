import configure::*;

module rom
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] rom_valid,
  input logic [0   : 0] rom_instr,
  input logic [31  : 0] rom_addr,
  output logic [63 : 0] rom_rdata,
  output logic [0  : 0] rom_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [3  : 0] raddr;

  logic [63 : 0] rdata;
  logic [0  : 0] ready;

  assign raddr = rom_addr[6:3];

  always_ff @(posedge clock) begin

    case(raddr)
      4'b0000 : rdata <= 64'h4201418141014081;
      4'b0001 : rdata <= 64'h4401438143014281;
      4'b0010 : rdata <= 64'h4601458145014481;
      4'b0011 : rdata <= 64'h4801478147014681;
      4'b0100 : rdata <= 64'h4A01498149014881;
      4'b0101 : rdata <= 64'h4C014B814B014A81;
      4'b0110 : rdata <= 64'h4E014D814D014C81;
      4'b0111 : rdata <= 64'h02B74F814F014E81;
      4'b1000 : rdata <= 64'h0000000280678000;
      4'b1001 : rdata <= 64'h0000000000000000;
      4'b1010 : rdata <= 64'h0000000000000000;
      4'b1011 : rdata <= 64'h0000000000000000;
      4'b1100 : rdata <= 64'h0000000000000000;
      4'b1101 : rdata <= 64'h0000000000000000;
      4'b1110 : rdata <= 64'h0000000000000000;
      4'b1111 : rdata <= 64'h0000000000000000;
    endcase

  end

  always_ff @(posedge clock) begin

    if (rom_valid == 1) begin
      ready <= 1;
    end else begin
      ready <= 0;
    end

  end

  assign rom_rdata = rdata;
  assign rom_ready = ready;


endmodule
