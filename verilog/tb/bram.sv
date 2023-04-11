import configure::*;

module bram
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] bram_valid,
  input logic [0   : 0] bram_instr,
  input logic [31  : 0] bram_addr,
  input logic [31  : 0] bram_wdata,
  input logic [3   : 0] bram_wstrb,
  output logic [31 : 0] bram_rdata,
  output logic [0  : 0] bram_ready
);
	timeunit 1ns;
	timeprecision 1ps;

  localparam depth = $clog2(bram_depth-1);

  logic [31 : 0] bram_block[0:bram_depth-1];

  logic [31 : 0] host[0:0] = '{default:'0};

  logic [31 : 0] raddr;
  logic [0  : 0] ready;

  logic [31 : 0] count = 0;
  logic [31 : 0] cycle = 0;

  task check;
    input logic [31 : 0] addr;
    input logic [31 : 0] wdata;
    input logic [3  : 0] wstrb;
    begin
      if (addr[31:2] == host[0][31:2] && |wstrb == 1) begin
        if (wdata == 32'h1) begin
          $write("%c[1;32m",8'h1B);
          $display("TEST SUCCEEDED");
          $write("%c[0m",8'h1B);
          $finish;
        end else begin
          $write("%c[1;31m",8'h1B);
          $display("TEST FAILED");
          $write("%c[0m",8'h1B);
          $finish;
        end
      end
    end
  endtask

  initial begin
    $readmemh("bram.dat", bram_block);
    $readmemh("host.dat", host);
  end

  always_ff @(posedge clock) begin

    raddr <= bram_addr;
    ready <= 0;

    if (bram_valid == 1) begin

      if (count == cycle) begin

        check(bram_addr,bram_wdata,bram_wstrb);

        if (bram_wstrb[0] == 1)
          bram_block[bram_addr[(depth+1):2]][7:0] <= bram_wdata[7:0];
        if (bram_wstrb[1] == 1)
          bram_block[bram_addr[(depth+1):2]][15:8] <= bram_wdata[15:8];
        if (bram_wstrb[2] == 1)
          bram_block[bram_addr[(depth+1):2]][23:16] <= bram_wdata[23:16];
        if (bram_wstrb[3] == 1)
          bram_block[bram_addr[(depth+1):2]][31:24] <= bram_wdata[31:24];

        ready <= 1;
        count <= 0;

      end else begin

        count <= count + 1;

      end

    end

  end

  assign bram_rdata = bram_block[raddr[(depth+1):2]];
  assign bram_ready = ready;


endmodule
