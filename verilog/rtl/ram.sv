import configure::*;

module ram
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] ram_valid,
  input logic [0   : 0] ram_instr,
  input logic [31  : 0] ram_addr,
  input logic [63  : 0] ram_wdata,
  input logic [7   : 0] ram_wstrb,
  output logic [63 : 0] ram_rdata,
  output logic [0  : 0] ram_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(ram_depth-1);

  generate

    if (ram_type == 0) begin

      logic [63 : 0] ram_block[0:ram_depth-1];

      initial begin
        $readmemh("ram.dat", ram_block);
      end

      always_ff @(posedge clock) begin

        if (ram_valid == 1) begin

          if (ram_wstrb[0] == 1)
            ram_block[ram_addr[(depth+2):3]][7:0] <= ram_wdata[7:0];
          if (ram_wstrb[1] == 1)
            ram_block[ram_addr[(depth+2):3]][15:8] <= ram_wdata[15:8];
          if (ram_wstrb[2] == 1)
            ram_block[ram_addr[(depth+2):3]][23:16] <= ram_wdata[23:16];
          if (ram_wstrb[3] == 1)
            ram_block[ram_addr[(depth+2):3]][31:24] <= ram_wdata[31:24];
          if (ram_wstrb[4] == 1)
            ram_block[ram_addr[(depth+2):3]][39:32] <= ram_wdata[39:32];
          if (ram_wstrb[5] == 1)
            ram_block[ram_addr[(depth+2):3]][47:40] <= ram_wdata[47:40];
          if (ram_wstrb[6] == 1)
            ram_block[ram_addr[(depth+2):3]][55:48] <= ram_wdata[55:48];
          if (ram_wstrb[7] == 1)
            ram_block[ram_addr[(depth+2):3]][63:56] <= ram_wdata[63:56];

          ram_rdata <= ram_block[ram_addr[(depth+2):3]];
          ram_ready <= 1;

        end else begin

          ram_rdata <= 0;
          ram_ready <= 0;

        end

      end

    end

    if (ram_type == 1) begin

      logic [7 : 0][7 : 0] ram_block[0:ram_depth-1];

      initial begin
        $readmemh("ram.dat", ram_block);
      end

      always_ff @(posedge clock) begin

          if (ram_wstrb[0] == 1)
            ram_block[ram_addr[(depth+2):3]][0] <= ram_wdata[7:0];
          if (ram_wstrb[1] == 1)
            ram_block[ram_addr[(depth+2):3]][1] <= ram_wdata[15:8];
          if (ram_wstrb[2] == 1)
            ram_block[ram_addr[(depth+2):3]][2] <= ram_wdata[23:16];
          if (ram_wstrb[3] == 1)
            ram_block[ram_addr[(depth+2):3]][3] <= ram_wdata[31:24];
          if (ram_wstrb[4] == 1)
            ram_block[ram_addr[(depth+2):3]][4] <= ram_wdata[39:32];
          if (ram_wstrb[5] == 1)
            ram_block[ram_addr[(depth+2):3]][5] <= ram_wdata[47:40];
          if (ram_wstrb[6] == 1)
            ram_block[ram_addr[(depth+2):3]][6] <= ram_wdata[55:48];
          if (ram_wstrb[7] == 1)
            ram_block[ram_addr[(depth+2):3]][7] <= ram_wdata[63:56];

          ram_rdata <= ram_block[ram_addr[(depth+2):3]];

      end

      always_ff @(posedge clock) begin

        if (ram_valid == 1) begin

          ram_ready <= 1;

        end else begin

          ram_ready <= 0;

        end

      end

    end

  endgenerate

endmodule
