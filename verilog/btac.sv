package btac_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam btb_depth = $clog2(branchtarget_depth-1);
  localparam bht_depth = $clog2(branchhistory_depth-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr;
    logic [95 : 0] wdata;
  } btb_in_type;

  typedef struct packed{
    logic [95 : 0] rdata;
  } btb_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [bht_depth-1 : 0] waddr;
    logic [bht_depth-1 : 0] raddr1;
    logic [bht_depth-1 : 0] raddr2;
    logic [1 : 0] wdata;
  } bht_in_type;

  typedef struct packed{
    logic [1 : 0] rdata1;
    logic [1 : 0] rdata2;
  } bht_out_type;

endpackage

import configure::*;
import wires::*;
import btac_wires::*;

module btb
(
  input logic clock,
  input btb_in_type btb_in,
  output btb_out_type btb_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam btb_depth = $clog2(branchtarget_depth-1);

  logic [95:0] btb_array[0:branchtarget_depth-1] = '{default:'0};

  assign btb_out.rdata = btb_array[btb_in.raddr];

  always_ff @(posedge clock) begin
    if (btb_in.wen == 1) begin
      btb_array[btb_in.waddr] <= btb_in.wdata;
    end
  end

endmodule

module bht
(
  input logic clock,
  input bht_in_type bht_in,
  output bht_out_type bht_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam bht_depth = $clog2(branchhistory_depth-1);

  logic [1:0] bht_array[0:branchhistory_depth-1] = '{default:'0};

  assign bht_out.rdata1 = bht_array[bht_in.raddr1];
  assign bht_out.rdata2 = bht_array[bht_in.raddr2];

  always_ff @(posedge clock) begin
    if (bht_in.wen == 1) begin
      bht_array[bht_in.waddr] <= bht_in.wdata;
    end
  end

endmodule

module btac_ctrl
(
  input logic reset,
  input logic clock,
  input btac_in_type btac_in,
  output btac_out_type btac_out,
  input btb_out_type btb_out,
  output btb_in_type btb_in,
  input bht_out_type bht_out,
  output bht_in_type bht_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam btb_depth = $clog2(branchtarget_depth-1);
  localparam bht_depth = $clog2(branchhistory_depth-1);

  typedef struct packed{
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr;
    logic [95 : 0] wdata;
    logic [0  : 0] wen;
    logic [0  : 0] miss;
  } btb_reg_type;

  parameter btb_reg_type init_reg = '{
    waddr : 0,
    raddr : 0,
    wdata : 0,
    wen : 0,
    miss : 0
  };

  btb_reg_type r, rin, v;

  always_comb begin : branch_target_buffer

    v = r;

    if (btac_in.clear == 0) begin
      v.raddr = btac_in.get_pc[btb_depth:1];
    end

    btb_in.raddr = v.raddr;

    if (btac_in.clear == 0) begin
      v.waddr = btac_in.upd_pc[btb_depth:1];
      v.wdata = {btac_in.upd_pc,btac_in.upd_addr,btac_in.upd_npc};
    end

    if (btac_in.clear == 0) begin
      btac_out.pred_branch = (|btb_out.rdata) & (~(|(btb_out.rdata[95:64] ^ btac_in.get_pc)));
      btac_out.pred_baddr = btb_out.rdata[63:32];
      btac_out.pred_taddr = btb_out.rdata[31:0];
    end else begin
      btac_out.pred_branch = 0;
      btac_out.pred_baddr = 0;
    end

    if (btac_in.clear == 0) begin
      btac_out.pred_maddr = (btac_in.upd_jump & btac_in.upd_branch) == 1 ? btac_in.upd_addr : btac_in.tpc;
      btac_out.pred_miss = btac_in.taken ^ (btac_in.upd_jump & btac_in.upd_branch);
    end else begin
      btac_out.pred_maddr = 0;
      btac_out.pred_miss = 0;
    end

    v.wen = btac_in.upd_branch & btac_in.upd_jump;

    btb_in.wen = v.wen;
    btb_in.waddr = v.waddr;
    btb_in.wdata = v.wdata;

    rin = v;
    
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module btac
(
  input logic reset,
  input logic clock,
  input btac_in_type btac_in,
  output btac_out_type btac_out
);
  timeunit 1ns;
  timeprecision 1ps;

  generate

    if (btac_enable == 1) begin

      btb_in_type btb_in;
      btb_out_type btb_out;
      bht_in_type bht_in;
      bht_out_type bht_out;

      btb btb_comp
      (
        .clock (clock),
        .btb_in (btb_in),
        .btb_out (btb_out)
      );

      bht bht_comp
      (
        .clock (clock),
        .bht_in (bht_in),
        .bht_out (bht_out)
      );

      btac_ctrl btac_ctrl_comp
      (
        .reset (reset),
        .clock (clock),
        .btac_in (btac_in),
        .btac_out (btac_out),
        .btb_in (btb_in),
        .btb_out (btb_out),
        .bht_in (bht_in),
        .bht_out (bht_out)
      );

    end else begin

      assign btac_out.pred_baddr = 0;
      assign btac_out.pred_branch = 0;
      assign btac_out.pred_maddr = 0;
      assign btac_out.pred_miss = 0;

    end

  endgenerate

endmodule