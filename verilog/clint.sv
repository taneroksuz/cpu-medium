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

  logic [0  : 0] mtip = 0;
  logic [0  : 0] msip = 0;

  logic [31 : 0] count = 0;
  logic [0  : 0] enable = 0;

  logic [31 : 0] rdata_ms = 0;
  logic [31 : 0] rdata_mt = 0;
  logic [31 : 0] rdata_mtc = 0;

  logic [0  : 0] ready_ms = 0;
  logic [0  : 0] ready_mt = 0;
  logic [0  : 0] ready_mtc = 0;

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      rdata_ms <= 0;
      ready_ms <= 0;
      msip <= 0;
    end else begin
      rdata_ms <= 0;
      ready_ms <= 0;
      if (clint_valid == 1) begin
        if (clint_addr < clint_msip_end) begin
          if (|clint_wstrb == 0) begin
            rdata_ms[0] <= msip;
            ready_ms <= 1;
          end else begin
            msip <= clint_wdata[0];
            ready_ms <= 1;
          end
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      rdata_mt <= 0;
      ready_mt <= 0;
      mtime <= 0;
    end else begin
      rdata_mt <= 0;
      ready_mt <= 0;
      if (enable == 1) begin
        mtime <= mtime + 64'h1;
      end
      if (clint_valid == 1) begin
        if (clint_addr >= clint_mtime_start && clint_addr < clint_mtime_end) begin
          if (|clint_wstrb == 0) begin
            if (clint_addr[2] == 0) begin
              rdata_mt <= mtime[31:0];
            end else begin
              rdata_mt <= mtime[63:32];
            end
            ready_mt <= 1;
          end else begin
            if (clint_addr[2] == 0) begin
              mtime[31:0] <= clint_wdata;
            end else begin
              mtime[63:32] <= clint_wdata;
            end
            ready_mt <= 1;
          end
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      rdata_mtc <= 0;
      ready_mtc <= 0;
      mtimecmp <= 0;
    end else begin
      rdata_mtc <= 0;
      ready_mtc <= 0;
      if (clint_valid == 1) begin
        if (clint_addr >= clint_mtimecmp_start && clint_addr < clint_mtimecmp_end) begin
          if (|clint_wstrb == 0) begin
            if (clint_addr[2] == 0) begin
              rdata_mtc <= mtimecmp[31:0];
            end else begin
              rdata_mtc <= mtimecmp[63:32];
            end
            ready_mtc <= 1;
          end else begin
            if (clint_addr[2] == 0) begin
              mtimecmp[31:0] <= clint_wdata;
            end else begin
              mtimecmp[63:32] <= clint_wdata;
            end
            ready_mtc <= 1;
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
      enable <= 0;
    end else begin
      if (count == clk_divider_rtc) begin
        count <= 0;
        enable <= 1;
      end else begin
        count <= count + 1;
        enable <= 0;
      end
    end
  end

  assign clint_rdata = (ready_ms == 1) ? rdata_ms :
                       (ready_mt == 1) ? rdata_mt :
                       (ready_mtc == 1) ? rdata_mtc : 0;
  assign clint_ready = ready_ms | ready_mt | ready_mtc;

  assign clint_msip = msip;
  assign clint_mtip = mtip;
  assign clint_mtime = mtime;

endmodule
