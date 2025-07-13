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

  typedef enum logic {
    IDLE,
    WAIT
  } state;

  mem_in_type  mem_in_reg = '0;

  logic        req_in_valid = 0;
  logic        ack_in_valid = 0;
  logic        req_in_valid_sync = 0;
  logic        ack_in_valid_sync = 0;
  logic        req_in_valid_meta = 0;
  logic        ack_in_valid_meta = 0;

  state        current_in_state = IDLE;
  state        next_in_state = IDLE;

  mem_out_type mem_out_reg = '0;

  logic        req_out_ready = 0;
  logic        ack_out_ready = 0;
  logic        req_out_ready_sync = 0;
  logic        ack_out_ready_sync = 0;
  logic        req_out_ready_meta = 0;
  logic        ack_out_ready_meta = 0;

  state        current_out_state = IDLE;
  state        next_out_state = IDLE;

  // SRC -> DST

  always_ff @(posedge src_clk) begin
    if (!src_rstn) begin
      current_in_state <= IDLE;
    end else begin
      current_in_state <= next_in_state;
    end
  end

  always_comb begin
    case (current_in_state)
      IDLE: begin
        if (src_mem_in.mem_valid) begin
          next_in_state = WAIT;
        end else begin
          next_in_state = IDLE;
        end
      end
      WAIT: begin
        if (!(req_in_valid ^ ack_in_valid_sync)) begin
          next_in_state = IDLE;
        end else begin
          next_in_state = WAIT;
        end
      end
      default: next_in_state = IDLE;
    endcase
  end

  always_ff @(posedge src_clk) begin
    if (!src_rstn) begin
      req_in_valid <= 1'b0;
      mem_in_reg   <= '0;
    end else if (current_in_state == IDLE && src_mem_in.mem_valid) begin
      req_in_valid <= ~req_in_valid;
      mem_in_reg   <= src_mem_in;
    end
  end

  always_ff @(posedge dst_clk) begin
    if (!dst_rstn) begin
      req_in_valid_meta <= 1'b0;
      req_in_valid_sync <= 1'b0;
    end else begin
      req_in_valid_meta <= req_in_valid;
      req_in_valid_sync <= req_in_valid_meta;
    end
  end

  always_ff @(posedge src_clk) begin
    if (!src_rstn) begin
      ack_in_valid_meta <= 1'b0;
      ack_in_valid_sync <= 1'b0;
    end else begin
      ack_in_valid_meta <= ack_in_valid;
      ack_in_valid_sync <= ack_in_valid_meta;
    end
  end

  always_ff @(posedge dst_clk) begin
    if (!dst_rstn) begin
      ack_in_valid <= 1'b0;
      dst_mem_in   <= '0;
    end else if (req_in_valid_sync ^ ack_in_valid) begin
      ack_in_valid <= ~ack_in_valid;
      dst_mem_in   <= mem_in_reg;
    end else begin
      dst_mem_in <= '0;
    end
  end

  // DST -> SRC

  always_ff @(posedge dst_clk) begin
    if (!dst_rstn) begin
      current_out_state <= IDLE;
    end else begin
      current_out_state <= next_out_state;
    end
  end

  always_comb begin
    case (current_out_state)
      IDLE: begin
        if (dst_mem_out.mem_ready) begin
          next_out_state = WAIT;
        end else begin
          next_out_state = IDLE;
        end
      end
      WAIT: begin
        if (!(req_out_ready ^ ack_out_ready_sync)) begin
          next_out_state = IDLE;
        end else begin
          next_out_state = WAIT;
        end
      end
      default: next_out_state = IDLE;
    endcase
  end

  always_ff @(posedge dst_clk) begin
    if (!dst_rstn) begin
      req_out_ready <= 1'b0;
      mem_out_reg   <= '0;
    end else if (current_out_state == IDLE && dst_mem_out.mem_ready) begin
      req_out_ready <= ~req_out_ready;
      mem_out_reg   <= dst_mem_out;
    end
  end

  always_ff @(posedge src_clk) begin
    if (!src_rstn) begin
      req_out_ready_meta <= 1'b0;
      req_out_ready_sync <= 1'b0;
    end else begin
      req_out_ready_meta <= req_out_ready;
      req_out_ready_sync <= req_out_ready_meta;
    end
  end

  always_ff @(posedge dst_clk) begin
    if (!dst_rstn) begin
      ack_out_ready_meta <= 1'b0;
      ack_out_ready_sync <= 1'b0;
    end else begin
      ack_out_ready_meta <= ack_out_ready;
      ack_out_ready_sync <= ack_out_ready_meta;
    end
  end

  always_ff @(posedge src_clk) begin
    if (!src_rstn) begin
      ack_out_ready <= 1'b0;
      src_mem_out   <= '0;
    end else if (req_out_ready_sync ^ ack_out_ready) begin
      ack_out_ready <= ~ack_out_ready;
      src_mem_out   <= mem_out_reg;
    end else begin
      src_mem_out <= '0;
    end
  end

endmodule
