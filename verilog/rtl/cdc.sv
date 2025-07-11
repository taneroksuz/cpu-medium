import wires::*;
import constants::*;

module cdc #(
    parameter DEPTH = 4,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input  logic        src_clk,
    input  logic        src_rstn,
    input  mem_in_type  src_mem_in,
    output mem_out_type src_mem_out,

    input  logic        dst_clk,
    input  logic        dst_rstn,
    output mem_in_type  dst_mem_in,
    input  mem_out_type dst_mem_out
);
  timeunit 1ns; timeprecision 1ps;

  mem_in_type fifo_mem_in[0:DEPTH-1];
  logic [ADDR_WIDTH:0] wr_ptr, rd_ptr;
  logic full, empty;

  always_ff @(posedge src_clk) begin
    if (src_rstn == 0) begin
      wr_ptr <= 0;
    end else begin
      if (src_mem_in.mem_valid && !full) begin
        fifo_mem_in[wr_ptr[ADDR_WIDTH-1:0]] <= src_mem_in;
        wr_ptr <= wr_ptr + 1;
      end
    end
  end

  always_ff @(posedge dst_clk) begin
    if (dst_rstn == 0) begin
      rd_ptr <= 0;
    end else begin
      if (!empty && dst_mem_out.mem_ready) begin
        rd_ptr <= rd_ptr + 1;
      end
    end
  end

  assign full  = ( (wr_ptr[ADDR_WIDTH]    != rd_ptr[ADDR_WIDTH]) &&
                     (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) );

  assign empty = (wr_ptr == rd_ptr);

  assign dst_mem_in = fifo_mem_in[rd_ptr[ADDR_WIDTH-1:0]];

  logic mem_ready_sync_0, mem_ready_sync_1;
  always_ff @(posedge src_clk) begin
    if (src_rstn == 0) begin
      mem_ready_sync_0 <= 0;
      mem_ready_sync_1 <= 0;
    end else begin
      mem_ready_sync_0 <= dst_mem_out.mem_ready;
      mem_ready_sync_1 <= mem_ready_sync_0;
    end
  end

  assign src_mem_out.mem_ready = mem_ready_sync_1;
  assign src_mem_out.mem_error = dst_mem_out.mem_error;
  assign src_mem_out.mem_rdata = dst_mem_out.mem_rdata;

endmodule
