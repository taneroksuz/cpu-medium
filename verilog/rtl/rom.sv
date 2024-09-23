import configure::*;

module rom (
    input logic reset,
    input logic clock,
    input mem_in_type rom_in,
    output mem_out_type rom_out
);
  timeunit 1ns; timeprecision 1ps;

  logic [63 : 0] rdata;
  logic [ 0 : 0] ready;

  logic [ 5 : 0] raddr;

  assign raddr = rom_in.mem_addr[8:3];

  always_ff @(posedge clock) begin

    case (raddr)
      6'b000000: rdata <= 64'h4201418141014081;
      6'b000001: rdata <= 64'h4401438143014281;
      6'b000010: rdata <= 64'h4601458145014481;
      6'b000011: rdata <= 64'h4801478147014681;
      6'b000100: rdata <= 64'h4A01498149014881;
      6'b000101: rdata <= 64'h4C014B814B014A81;
      6'b000110: rdata <= 64'h4E014D814D014C81;
      6'b000111: rdata <= 64'h62F94F814F014E81;
      6'b001000: rdata <= 64'h3002A07360828293;
      6'b001001: rdata <= 64'h02973042A07342BD;
      6'b001010: rdata <= 64'h9073090282930000;
      6'b001011: rdata <= 64'h0053003010733052;
      6'b001100: rdata <= 64'h0153F00000D3F000;
      6'b001101: rdata <= 64'h0253F00001D3F000;
      6'b001110: rdata <= 64'h0353F00002D3F000;
      6'b001111: rdata <= 64'h0453F00003D3F000;
      6'b010000: rdata <= 64'h0553F00004D3F000;
      6'b010001: rdata <= 64'h0653F00005D3F000;
      6'b010010: rdata <= 64'h0753F00006D3F000;
      6'b010011: rdata <= 64'h0853F00007D3F000;
      6'b010100: rdata <= 64'h0953F00008D3F000;
      6'b010101: rdata <= 64'h0A53F00009D3F000;
      6'b010110: rdata <= 64'h0B53F0000AD3F000;
      6'b010111: rdata <= 64'h0C53F0000BD3F000;
      6'b011000: rdata <= 64'h0D53F0000CD3F000;
      6'b011001: rdata <= 64'h0E53F0000DD3F000;
      6'b011010: rdata <= 64'h0F53F0000ED3F000;
      6'b011011: rdata <= 64'h0297F0000FD3F000;
      6'b011100: rdata <= 64'h907301C282930000;
      6'b011101: rdata <= 64'h0337010002B73052;
      6'b011110: rdata <= 64'h00080E3743818000;
      6'b011111: rdata <= 64'h3420237342E1A001;
      6'b100000: rdata <= 64'h0002AE83FE629CE3;
      6'b100001: rdata <= 64'h0391031101D32023;
      6'b100010: rdata <= 64'h3020007301C3D463;
      6'b100011: rdata <= 64'h00008067800000B7;
      6'b100100: rdata <= 64'h0000000000000000;
      6'b100101: rdata <= 64'h0000000000000000;
      6'b100110: rdata <= 64'h0000000000000000;
      6'b100111: rdata <= 64'h0000000000000000;
      6'b101000: rdata <= 64'h0000000000000000;
      6'b101001: rdata <= 64'h0000000000000000;
      6'b101010: rdata <= 64'h0000000000000000;
      6'b101011: rdata <= 64'h0000000000000000;
      6'b101100: rdata <= 64'h0000000000000000;
      6'b101101: rdata <= 64'h0000000000000000;
      6'b101110: rdata <= 64'h0000000000000000;
      6'b101111: rdata <= 64'h0000000000000000;
      6'b110000: rdata <= 64'h0000000000000000;
      6'b110001: rdata <= 64'h0000000000000000;
      6'b110010: rdata <= 64'h0000000000000000;
      6'b110011: rdata <= 64'h0000000000000000;
      6'b110100: rdata <= 64'h0000000000000000;
      6'b110101: rdata <= 64'h0000000000000000;
      6'b110110: rdata <= 64'h0000000000000000;
      6'b110111: rdata <= 64'h0000000000000000;
      6'b111000: rdata <= 64'h0000000000000000;
      6'b111001: rdata <= 64'h0000000000000000;
      6'b111010: rdata <= 64'h0000000000000000;
      6'b111011: rdata <= 64'h0000000000000000;
      6'b111100: rdata <= 64'h0000000000000000;
      6'b111101: rdata <= 64'h0000000000000000;
      6'b111110: rdata <= 64'h0000000000000000;
      6'b111111: rdata <= 64'h0000000000000000;
    endcase

  end

  always_ff @(posedge clock) begin

    if (rom_in.mem_valid == 1) begin
      ready <= 1;
    end else begin
      ready <= 0;
    end

  end

  assign rom_out.mem_rdata = rdata;
  assign rom_out.mem_error = 0;
  assign rom_out.mem_ready = ready;


endmodule
