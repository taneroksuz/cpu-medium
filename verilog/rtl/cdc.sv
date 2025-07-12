import wires::*;
import constants::*;

module cdc (
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

  mem_in_type  mem_in_reg;

  logic        req_valid_src;
  logic        req_valid_meta;
  logic        req_valid_sync;

  mem_out_type mem_out_reg;

  logic        ack_ready_dst;
  logic        ack_ready_meta;
  logic        ack_ready_sync;

  always_ff @(posedge src_clk) begin
    if (!src_rstn) begin
      mem_in_reg      <= '0;
      req_valid_src   <= 1'b0;
    end else begin
      if (src_mem_in.mem_valid && !req_valid_src && ack_ready_sync) begin
        mem_in_reg    <= src_mem_in;
        req_valid_src <= 1'b1;
      end else if (req_valid_src && ack_ready_sync) begin
        mem_in_reg    <= '0;
        req_valid_src <= 1'b0;
      end
    end
  end

  always_ff @(posedge dst_clk) begin
    if (!dst_rstn) begin
      req_valid_meta <= 1'b0;
      req_valid_sync <= 1'b0;
    end else begin
      req_valid_meta <= req_valid_src;
      req_valid_sync <= req_valid_meta;
    end
  end

  always_ff @(posedge dst_clk) begin
    if (!dst_rstn) begin
      mem_out_reg     <= '0;
      ack_ready_dst   <= 1'b0;
    end else begin
      if (dst_mem_out.mem_ready && !ack_ready_dst && req_valid_sync) begin
        mem_out_reg   <= dst_mem_out;
        ack_ready_dst <= 1'b1;
      end else if (ack_ready_dst && req_valid_sync) begin
        mem_out_reg   <= '0;
        ack_ready_dst <= 1'b0;
      end
    end
  end

  always_ff @(posedge src_clk) begin
    if (!src_rstn) begin
      ack_ready_meta <= 1'b0;
      ack_ready_sync <= 1'b0;
    end else begin
      ack_ready_meta <= ack_ready_dst;
      ack_ready_sync <= ack_ready_meta;
    end
  end

  assign dst_mem_in = mem_in_reg;
  assign src_mem_out = mem_out_reg;

endmodule
