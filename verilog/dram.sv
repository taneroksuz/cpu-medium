import configure::*;

module dram1
#(
  parameter DATA = 1,
  parameter ADDR = 1
)
(
  input  clk,
  input  wr,
  input  [ADDR-1 : 0] wr_addr,
  input  [DATA-1 : 0] wr_data,
  input  [ADDR-1 : 0] rd_addr,
  output [DATA-1 : 0] rd_data
);
  timeunit 1ns;
  timeprecision 1ps;

  reg [DATA-1 : 0] mem[0:2**ADDR-1] = '{default:'0};

  always_ff @(posedge clk) begin
    if (wr == 1) begin
      mem[wr_addr] <= wr_data;
    end
  end
  
  assign rd_data = mem[rd_addr];

endmodule

module dram2
#(
  parameter DATA = 1,
  parameter ADDR = 1
)
(
  input  clk,
  input  wr,
  input  [ADDR-1 : 0] wr_addr,
  input  [DATA-1 : 0] wr_data,
  input  [ADDR-1 : 0] rd0_addr,
  output [DATA-1 : 0] rd0_data,
  input  [ADDR-1 : 0] rd1_addr,
  output [DATA-1 : 0] rd1_data
);
  timeunit 1ns;
  timeprecision 1ps;

  reg [DATA-1 : 0] mem[0:2**ADDR-1] = '{default:'0};

  always_ff @(posedge clk) begin
    if (wr == 1) begin
      mem[wr_addr] <= wr_data;
    end
  end
  
  assign rd0_data = mem[rd0_addr];
  assign rd1_data = mem[rd1_addr];

endmodule
