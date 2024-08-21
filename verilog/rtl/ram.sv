import configure::*;

module ram (
    input logic reset,
    input logic clock,
    input logic [0 : 0] ram_valid,
    input logic [0 : 0] ram_instr,
    input logic [0 : 0] ram_store,
    input logic [31 : 0] ram_addr,
    input logic [63 : 0] ram_wdata,
    output logic [63 : 0] ram_rdata,
    output logic [0 : 0] ram_ready
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(ram_depth - 1);

  logic [63 : 0] ram_block[0:ram_depth-1];

  initial begin
    $readmemh("ram.dat", ram_block);
  end

  always_ff @(posedge clock) begin

    if (ram_store == 1) ram_block[ram_addr[(depth+2):3]] <= ram_wdata;

    ram_rdata <= ram_block[ram_addr[(depth+2):3]];

  end

  always_ff @(posedge clock) begin

    if (ram_valid == 1) begin

      ram_ready <= 1;

    end else begin

      ram_ready <= 0;

    end

  end

endmodule
