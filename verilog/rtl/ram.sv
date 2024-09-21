import configure::*;

module ram (
    input logic reset,
    input logic clock,
    input mem_in_type ram_in,
    output mem_out_type ram_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(ram_depth);

  generate

    if (ram_type == 0) begin

      logic [63 : 0] ram_block[0:ram_depth-1];

      initial begin
        $readmemh("ram.dat", ram_block);
      end

      always_ff @(posedge clock) begin

        if (ram_in.mem_valid == 1) begin

          if (ram_in.mem_wstrb[0] == 1)
            ram_block[ram_in.mem_addr[(depth+2):3]][7:0] <= ram_in.mem_wdata[7:0];
          if (ram_in.mem_wstrb[1] == 1)
            ram_block[ram_in.mem_addr[(depth+2):3]][15:8] <= ram_in.mem_wdata[15:8];
          if (ram_in.mem_wstrb[2] == 1)
            ram_block[ram_in.mem_addr[(depth+2):3]][23:16] <= ram_in.mem_wdata[23:16];
          if (ram_in.mem_wstrb[3] == 1)
            ram_block[ram_in.mem_addr[(depth+2):3]][31:24] <= ram_in.mem_wdata[31:24];
          if (ram_in.mem_wstrb[4] == 1)
            ram_block[ram_in.mem_addr[(depth+2):3]][39:32] <= ram_in.mem_wdata[39:32];
          if (ram_in.mem_wstrb[5] == 1)
            ram_block[ram_in.mem_addr[(depth+2):3]][47:40] <= ram_in.mem_wdata[47:40];
          if (ram_in.mem_wstrb[6] == 1)
            ram_block[ram_in.mem_addr[(depth+2):3]][55:48] <= ram_in.mem_wdata[55:48];
          if (ram_in.mem_wstrb[7] == 1)
            ram_block[ram_in.mem_addr[(depth+2):3]][63:56] <= ram_in.mem_wdata[63:56];

          ram_out.mem_rdata <= ram_block[ram_in.mem_addr[(depth+2):3]];
          ram_out.mem_ready <= 1;

        end else begin

          ram_out.mem_rdata <= 0;
          ram_out.mem_ready <= 0;

        end

      end

    end

    if (ram_type == 1) begin

      logic [7 : 0][7 : 0] ram_block[0:ram_depth-1];

      initial begin
        $readmemh("ram.dat", ram_block);
      end

      always_ff @(posedge clock) begin

        if (ram_in.mem_wstrb[0] == 1)
          ram_block[ram_in.mem_addr[(depth+2):3]][0] <= ram_in.mem_wdata[7:0];
        if (ram_in.mem_wstrb[1] == 1)
          ram_block[ram_in.mem_addr[(depth+2):3]][1] <= ram_in.mem_wdata[15:8];
        if (ram_in.mem_wstrb[2] == 1)
          ram_block[ram_in.mem_addr[(depth+2):3]][2] <= ram_in.mem_wdata[23:16];
        if (ram_in.mem_wstrb[3] == 1)
          ram_block[ram_in.mem_addr[(depth+2):3]][3] <= ram_in.mem_wdata[31:24];
        if (ram_in.mem_wstrb[4] == 1)
          ram_block[ram_in.mem_addr[(depth+2):3]][4] <= ram_in.mem_wdata[39:32];
        if (ram_in.mem_wstrb[5] == 1)
          ram_block[ram_in.mem_addr[(depth+2):3]][5] <= ram_in.mem_wdata[47:40];
        if (ram_in.mem_wstrb[6] == 1)
          ram_block[ram_in.mem_addr[(depth+2):3]][6] <= ram_in.mem_wdata[55:48];
        if (ram_in.mem_wstrb[7] == 1)
          ram_block[ram_in.mem_addr[(depth+2):3]][7] <= ram_in.mem_wdata[63:56];

        ram_out.mem_rdata <= ram_block[ram_in.mem_addr[(depth+2):3]];

      end

      always_ff @(posedge clock) begin

        if (ram_in.mem_valid == 1) begin

          ram_out.mem_ready <= 1;

        end else begin

          ram_out.mem_ready <= 0;

        end

      end

    end

  endgenerate

endmodule
