import configure::*;

module ram (
    input logic reset,
    input logic clock,
    input mem_in_type ram_in,
    output mem_out_type ram_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam r_depth = $clog2(ram_depth);

  generate

    if (ram_type == 0) begin

      logic [63 : 0] ram_block[0:ram_depth-1];

      initial begin
        $readmemh("ram.dat", ram_block);
      end

      always_ff @(posedge clock) begin

        if (ram_in.mem_valid == 1) begin

          if (ram_in.mem_store == 1) ram_block[ram_in.mem_addr[(r_depth+2):3]] <= ram_in.mem_wdata;

          ram_out.mem_rdata <= ram_block[ram_in.mem_addr[(r_depth+2):3]];
          ram_out.mem_ready <= 1;

        end else begin

          ram_out.mem_rdata <= 0;
          ram_out.mem_ready <= 0;

        end

      end

    end

    if (ram_type == 1) begin

      logic [63 : 0] ram_block[0:ram_depth-1];

      initial begin
        $readmemh("ram.dat", ram_block);
      end

      always_ff @(posedge clock) begin

        if (ram_in.mem_store == 1) ram_block[ram_in.mem_addr[(r_depth+2):3]] <= ram_in.mem_wdata;

        ram_out.mem_rdata <= ram_block[ram_in.mem_addr[(r_depth+2):3]];

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
