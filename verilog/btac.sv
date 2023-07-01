package btac_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam btb_depth = $clog2(branchtarget_depth-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr;
    logic [95 : 0] wdata;
  } btb_in_type;

  typedef struct packed{
    logic [95 : 0] rdata;
  } btb_out_type;

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

module btac_ctrl
(
  input logic reset,
  input logic clock,
  input btac_in_type btac_in,
  output btac_out_type btac_out,
  input btb_out_type btb_out,
  output btb_in_type btb_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam btb_depth = $clog2(branchtarget_depth-1);

  typedef struct packed{
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr;
    logic [95 : 0] wdata;
    logic [0  : 0] wen;
    logic [0  : 0] taken;
    logic [31 : 0] taddr;
    logic [31 : 0] tpc;
  } btb_reg_type;

  parameter btb_reg_type init_reg = '{
    waddr : 0,
    raddr : 0,
    wdata : 0,
    wen : 0,
    taken : 0,
    taddr : 0,
    tpc : 0
  };

  btb_reg_type r, rin, v;

  always_comb begin : branch_target_buffer

    v = r;

    if (btac_in.clear == 0) begin
      v.raddr = btac_in.get_pc[btb_depth:1];
    end

    btb_in.raddr = v.raddr;

    if (btac_in.clear == 0) begin
      v.wen = btac_in.upd_jump0 | btac_in.upd_jump1;
      v.waddr = btac_in.upd_jump0 ? btac_in.upd_pc0[btb_depth:1] : btac_in.upd_pc1[btb_depth:1];
      v.wdata = btac_in.upd_jump0 ? {btac_in.upd_pc0,btac_in.upd_addr0,btac_in.upd_npc0} : {btac_in.upd_pc1,btac_in.upd_addr1,btac_in.upd_npc1};
    end else begin
      v.wen = 0;
      v.waddr = 0;
      v.wdata = 0;
    end

    if (btac_in.clear == 0) begin
      btac_out.pred_branch = (|btb_out.rdata) & (~(|(btb_out.rdata[95:64] ^ btac_in.get_pc)));
      btac_out.pred_baddr = btb_out.rdata[63:32];
      btac_out.pred_pc = btb_out.rdata[31:0];
    end else begin
      btac_out.pred_branch = 0;
      btac_out.pred_baddr = 0;
      btac_out.pred_pc = 0;
    end

    if (btac_in.clear == 0 && btac_in.taken == 1) begin
      v.taken = btac_in.taken;
      v.taddr = btac_in.taddr;
      v.tpc = btac_in.tpc;
    end else if (btac_in.clear == 0 && btac_in.taken == 0) begin
      v.taken = r.taken;
      v.taddr = r.taddr;
      v.tpc = r.tpc;
    end else begin
      v.taken = 0;
      v.taddr = 0;
      v.tpc = 0;
    end

    if (btac_in.clear == 0) begin
      if (v.taken == 0) begin
        if (btac_in.upd_jump0 == 1) begin
          btac_out.pred_maddr = btac_in.upd_addr0;
          btac_out.pred_miss = 1;
        end else if (btac_in.upd_jump1 == 1) begin
          btac_out.pred_maddr = btac_in.upd_addr1;
          btac_out.pred_miss = 1;
        end else begin
          btac_out.pred_maddr = 0;
          btac_out.pred_miss = 0;
        end
      end else begin
        if (btac_in.upd_jump0 == 1) begin
          btac_out.pred_maddr = btac_in.upd_addr0;
          btac_out.pred_miss = |(btac_in.upd_addr0 ^ v.taddr);
          v.taken = 0;
        end else if (btac_in.upd_jump0 == 0 && btac_in.upd_branch0 == 1) begin
          btac_out.pred_maddr = v.tpc;
          btac_out.pred_miss = 1;
          v.taken = 0;
        end else if (btac_in.upd_jump1 == 1) begin
          btac_out.pred_maddr = btac_in.upd_addr1;
          btac_out.pred_miss = |(btac_in.upd_addr1 ^ v.taddr);
          v.taken = 0;
        end else if (btac_in.upd_jump1 == 0 && btac_in.upd_branch1 == 1) begin
          btac_out.pred_maddr = v.tpc;
          btac_out.pred_miss = 1;
          v.taken = 0;
        end else begin
          btac_out.pred_maddr = 0;
          btac_out.pred_miss = 0;
        end
      end
    end else begin
      btac_out.pred_maddr = 0;
      btac_out.pred_miss = 0;
    end

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

      btb btb_comp
      (
        .clock (clock),
        .btb_in (btb_in),
        .btb_out (btb_out)
      );

      btac_ctrl btac_ctrl_comp
      (
        .reset (reset),
        .clock (clock),
        .btac_in (btac_in),
        .btac_out (btac_out),
        .btb_in (btb_in),
        .btb_out (btb_out)
      );

    end else begin

      assign btac_out.pred_baddr = 0;
      assign btac_out.pred_branch = 0;
      assign btac_out.pred_maddr = 0;
      assign btac_out.pred_miss = 0;
      assign btac_out.pred_pc = 0;

    end

  endgenerate

endmodule