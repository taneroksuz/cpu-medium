import configure::*;

module rom
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] rom_valid,
  input logic [0   : 0] rom_instr,
  input logic [31  : 0] rom_addr,
  output logic [31 : 0] rom_rdata,
  output logic [0  : 0] rom_ready
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [4  : 0] raddr;

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  assign raddr = rom_addr[6:2];

  always_ff @(posedge clock) begin

    case(raddr)
      5'b00000 : rdata <= 32'h41014081;
      5'b00001 : rdata <= 32'h42014181;
      5'b00010 : rdata <= 32'h43014281;
      5'b00011 : rdata <= 32'h44014381;
      5'b00100 : rdata <= 32'h45014481;
      5'b00101 : rdata <= 32'h46014581;
      5'b00110 : rdata <= 32'h47014681;
      5'b00111 : rdata <= 32'h48014781;
      5'b01000 : rdata <= 32'h49014881;
      5'b01001 : rdata <= 32'h4A014981;
      5'b01010 : rdata <= 32'h4B014A81;
      5'b01011 : rdata <= 32'h4C014B81;
      5'b01100 : rdata <= 32'h4D014C81;
      5'b01101 : rdata <= 32'h4E014D81;
      5'b01110 : rdata <= 32'h4F014E81;
      5'b01111 : rdata <= 32'h02B74F81;
      5'b10000 : rdata <= 32'h80678000;
      5'b10001 : rdata <= 32'h00000002;
      5'b10010 : rdata <= 32'h00000000;
      5'b10011 : rdata <= 32'h00000000;
      5'b10100 : rdata <= 32'h00000000;
      5'b10101 : rdata <= 32'h00000000;
      5'b10110 : rdata <= 32'h00000000;
      5'b10111 : rdata <= 32'h00000000;
      5'b11000 : rdata <= 32'h00000000;
      5'b11001 : rdata <= 32'h00000000;
      5'b11010 : rdata <= 32'h00000000;
      5'b11011 : rdata <= 32'h00000000;
      5'b11100 : rdata <= 32'h00000000;
      5'b11101 : rdata <= 32'h00000000;
      5'b11110 : rdata <= 32'h00000000;
      5'b11111 : rdata <= 32'h00000000;
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
