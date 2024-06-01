import configure::*;

module ram
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] ram_valid,
  input logic [0   : 0] ram_instr,
  input logic [31  : 0] ram_addr,
  input logic [31  : 0] ram_wdata,
  input logic [3   : 0] ram_wstrb,
  output logic [31 : 0] ram_rdata,
  output logic [0  : 0] ram_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(ram_depth-1);

  logic [31 : 0] ram_block[0:ram_depth-1];

  logic [31 : 0] count = 0;

  initial begin
    $readmemh("ram.dat", ram_block);
  end

  always_ff @(posedge clock) begin

    ram_rdata <= 0;
    ram_ready <= 0;

    if (ram_valid == 1) begin

      if (count == ram_cycle) begin

        if (ram_wstrb[0] == 1)
          ram_block[ram_addr[(depth+1):2]][7:0] <= ram_wdata[7:0];
        if (ram_wstrb[1] == 1)
          ram_block[ram_addr[(depth+1):2]][15:8] <= ram_wdata[15:8];
        if (ram_wstrb[2] == 1)
          ram_block[ram_addr[(depth+1):2]][23:16] <= ram_wdata[23:16];
        if (ram_wstrb[3] == 1)
          ram_block[ram_addr[(depth+1):2]][31:24] <= ram_wdata[31:24];

        ram_rdata <= ram_block[ram_addr[(depth+1):2]];
        ram_ready <= 1;

        count <= 0;

      end else begin

        count <= count + 1;

      end

    end

  end

endmodule
