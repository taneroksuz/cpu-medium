import configure::*;
import wires::*;

module clint
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] clint_valid,
  input logic [0   : 0] clint_instr,
  input logic [31  : 0] clint_addr,
  input logic [31  : 0] clint_wdata,
  input logic [3   : 0] clint_wstrb,
  output logic [31 : 0] clint_rdata,
  output logic [0  : 0] clint_ready,
  output logic [63 : 0] clint_mtime,
  output logic clint_msip,
  output logic clint_mtip
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam  clint_msip_start     = 0;
  localparam  clint_msip_end       = clint_msip_start + 4;
  localparam  clint_mtimecmp_start = 16384;
  localparam  clint_mtimecmp_end   = clint_mtimecmp_start + 8;
  localparam  clint_mtime_start    = 49144;
  localparam  clint_mtime_end      = clint_mtime_start + 8;

  logic [63 : 0] mtimecmp = 0;
  logic [63 : 0] mtime = 0;

  logic [31 : 0] rdata = 0;
  logic [0  : 0] ready = 0;

  logic [0  : 0] mtip = 0;
  logic [0  : 0] msip = 0;

  logic [31 : 0] count = 0;
  logic [0  : 0] state = 0;
  logic [0  : 0] incr  = 0;

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      mtimecmp <= '{default:0};
      mtime <= 0;
      rdata <= 0;
      ready <= 0;
      msip <= 0;
    end else begin
      if (incr == 1) begin
        mtime <= mtime + 64'h1;
      end
      rdata <= 0;
      ready <= 0;
      if (clint_valid == 1) begin
        if (clint_addr < clint_msip_end) begin
          if (|clint_wstrb == 0) begin
            rdata[0] <= msip;
            ready <= 1;
          end else begin
            msip <= clint_wdata[0];
            ready <= 1;
          end
        end else if (clint_addr >= clint_mtimecmp_start && clint_addr < clint_mtimecmp_end) begin
          if (|clint_wstrb == 0) begin
            if (clint_addr[2] == 0) begin
              rdata <= mtimecmp[31:0];
            end else begin
              rdata <= mtimecmp[63:32];
            end
            ready <= 1;
          end else begin
            if (clint_addr[2] == 0) begin
              mtimecmp[31:0] <= clint_wdata;
            end else begin
              mtimecmp[63:32] <= clint_wdata;
            end
            ready <= 1;
          end
        end else if (clint_addr >= clint_mtime_start && clint_addr < clint_mtime_end) begin
          if (|clint_wstrb == 0) begin
            if (clint_addr[2] == 0) begin
              rdata <= mtime[31:0];
            end else begin
              rdata <= mtime[63:32];
            end
            ready <= 1;
          end else begin
            if (clint_addr[2] == 0) begin
              mtime[31:0] <= clint_wdata;
            end else begin
              mtime[63:32] <= clint_wdata;
            end
            ready <= 1;
          end
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      mtip <= 0;
    end else begin
      if (mtime >= mtimecmp) begin
        mtip <= 1;
      end else begin
        mtip <= 0;
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      count <= 0;
      state <= 0;
      incr <= 0;
    end else begin
      if (state == 0 && count == clk_divider_rtc) begin
        count <= 0;
        state <= 1;
        incr <= 1;
      end else if (state == 1 && count == clk_divider_rtc) begin
        count <= 0;
        state <= 0;
        incr <= 0;
      end else begin
        count <= count + 1;
        incr <= 0;
      end
    end
  end

  assign clint_rdata = rdata;
  assign clint_ready = ready;

  assign clint_msip = msip;
  assign clint_mtip = mtip;
  assign clint_mtime = mtime;

endmodule
