import configure::*;

module bram
(
  input logic rst,
  input logic clk,
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

  logic [31 : 0] bram_block[0:2**bram_depth-1];

  logic [31 : 0] sig_b[0:0] = '{default:'0};
  logic [31 : 0] sig_e[0:0] = '{default:'0};

  logic [31 : 0] host[0:0] = '{default:'0};

  int sig_beg;
  int sig_end;
  int sig;

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  task check;
    input logic [31 : 0] addr;
    input logic [31 : 0] wdata;
    input logic [3  : 0] wstrb;
    integer i;
    logic ok;
    begin
      ok = 0;
      if (addr[31:2] == host[0][31:2] && |wstrb == 1) begin
        ok = 1;
      end
      if (ok == 1) begin
        for (i=sig_b[0]; i<sig_e[0]; i=i+4) begin
          $fwrite(sig,"%H\n",bram_block[i/4]);
        end
        if (wdata == 32'h1) begin
          $write("%c[1;32m",8'h1B);
          $display("TEST SUCCEEDED");
          $write("%c[0m",8'h1B);
          $finish;
        end else begin
          $write("%c[1;31m",8'h1B);
          $display("TEST STOPPED");
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

  initial begin
    sig_beg = $fopen("begin_signature.dat","r");
    sig_end = $fopen("end_signature.dat","r");
    sig = $fopen("signature.dat","w");
    if (sig_beg != 0) begin
      $readmemh("begin_signature.dat", sig_b);
    end
    if (sig_end != 0) begin
      $readmemh("end_signature.dat", sig_e);
    end
  end

  always_ff @(posedge clk) begin

    if (bram_valid == 1) begin

      check(bram_addr,bram_wdata,bram_wstrb);

      if (bram_wstrb[0] == 1)
        bram_block[bram_addr[(bram_depth+1):2]][7:0] <= bram_wdata[7:0];
      if (bram_wstrb[1] == 1)
        bram_block[bram_addr[(bram_depth+1):2]][15:8] <= bram_wdata[15:8];
      if (bram_wstrb[2] == 1)
        bram_block[bram_addr[(bram_depth+1):2]][23:16] <= bram_wdata[23:16];
      if (bram_wstrb[3] == 1)
        bram_block[bram_addr[(bram_depth+1):2]][31:24] <= bram_wdata[31:24];

      rdata <= bram_block[bram_addr[(bram_depth+1):2]];
      ready <= 1;

    end else begin

      ready <= 0;

    end

  end

  assign bram_rdata = rdata;
  assign bram_ready = ready;


endmodule
