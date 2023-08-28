package btac_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam btb_depth = $clog2(branchtarget_depth-1);
  localparam bht_depth = $clog2(branchhistory_depth-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr0;
    logic [btb_depth-1 : 0] raddr1;
    logic [62-btb_depth : 0] wdata;
  } btb_in_type;

  typedef struct packed{
    logic [62-btb_depth : 0] rdata0;
    logic [62-btb_depth : 0] rdata1;
  } btb_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [bht_depth-1 : 0] waddr;
    logic [bht_depth-1 : 0] raddr0;
    logic [bht_depth-1 : 0] raddr1;
    logic [1 : 0] wdata;
  } bht_in_type;

  typedef struct packed{
    logic [1 : 0] rdata0;
    logic [1 : 0] rdata1;
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

  logic [62-btb_depth:0] btb_array[0:branchtarget_depth-1] = '{default:'0};

  logic [btb_depth-1 : 0] raddr0 = 0;
  logic [btb_depth-1 : 0] raddr1 = 0;

  always_ff @(posedge clock) begin
    raddr0 <= btb_in.raddr0;
    raddr1 <= btb_in.raddr1;
    if (btb_in.wen == 1) begin
      btb_array[btb_in.waddr] <= btb_in.wdata;
    end
  end

  assign btb_out.rdata0 = btb_array[raddr0];
  assign btb_out.rdata1 = btb_array[raddr1];

endmodule

import configure::*;
import wires::*;
import btac_wires::*;

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

  logic [bht_depth-1 : 0] raddr0 = 0;
  logic [bht_depth-1 : 0] raddr1 = 0;

  always_ff @(posedge clock) begin
    raddr0 <= bht_in.raddr0;
    raddr1 <= bht_in.raddr1;
    if (bht_in.wen == 1) begin
      bht_array[bht_in.waddr] <= bht_in.wdata;
    end
  end

  assign bht_out.rdata0 = bht_array[raddr0];
  assign bht_out.rdata1 = bht_array[raddr1];

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

  function [1:0] saturation;
    input logic [1:0] sat;
    input logic [0:0] jal;
    input logic [0:0] jump;
    begin
      if (jal == 0) begin
        if (jump == 0 && |sat == 1)
          saturation = sat - 1;
        else if (jump == 1 && &sat == 0)
          saturation = sat + 1;
        else
          saturation = sat;
      end else begin
        saturation = 3;
      end
    end
  endfunction

  typedef struct packed{
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr0;
    logic [btb_depth-1 : 0] raddr1;
    logic [62-btb_depth : 0] wdata;
    logic [0  : 0] wen;
    logic [31 : 0] pc0;
    logic [31 : 0] pc1;
    logic [31 : 0] maddr0;
    logic [31 : 0] maddr1;
    logic [0  : 0] miss0;
    logic [0  : 0] miss1;
  } btb_reg_type;

  parameter btb_reg_type init_btb_reg = '{
    waddr : 0,
    raddr0 : 0,
    raddr1 : 0,
    wdata : 0,
    wen : 0,
    pc0 : 0,
    pc1 : 0,
    maddr0 : 0,
    maddr1 : 0,
    miss0 : 0,
    miss1 : 0
  };

  typedef struct packed{
    logic [bht_depth-1 : 0] waddr;
    logic [bht_depth-1 : 0] raddr0;
    logic [bht_depth-1 : 0] raddr1;
    logic [1  : 0] wdata;
    logic [0  : 0] wen;
    logic [1  : 0] sat0;
    logic [1  : 0] sat1;
  } bht_reg_type;

  parameter bht_reg_type init_bht_reg = '{
    waddr : 0,
    raddr0 : 0,
    raddr1 : 0,
    wdata : 0,
    wen : 0,
    sat0 : 0,
    sat1 : 0
  };

  btb_reg_type r_btb, rin_btb, v_btb;
  bht_reg_type r_bht, rin_bht, v_bht;

  always_comb begin

    v_btb = r_btb;
    v_bht = r_bht;

    if (btac_in.clear == 0) begin
      v_btb.pc0 = btac_in.get_pc0;
      v_btb.pc1 = btac_in.get_pc1;
      v_btb.raddr0 = btac_in.get_pc0[btb_depth:1];
      v_btb.raddr1 = btac_in.get_pc1[btb_depth:1];
    end
    if (btac_in.clear == 0) begin
      v_bht.raddr0 = btac_in.get_pc0[bht_depth:1];
      v_bht.raddr1 = btac_in.get_pc1[bht_depth:1];
    end

    btb_in.raddr0 = v_btb.raddr0;
    btb_in.raddr1 = v_btb.raddr1;
    bht_in.raddr0 = v_bht.raddr0;
    bht_in.raddr1 = v_bht.raddr1;

    if (btac_in.clear == 0) begin
      v_btb.wen = (btac_in.upd_jal0 | btac_in.upd_branch0) | (btac_in.upd_jal1 | btac_in.upd_branch1);
      v_btb.waddr = (btac_in.upd_jal0 | btac_in.upd_branch0) ? btac_in.upd_pc0[btb_depth:1] : btac_in.upd_pc1[btb_depth:1];
      v_btb.wdata = (btac_in.upd_jal0 | btac_in.upd_branch0) ? {btac_in.upd_pc0[31:btb_depth+1],btac_in.upd_addr0} : {btac_in.upd_pc1[31:btb_depth+1],btac_in.upd_addr1};
    end else begin
      v_btb.wen = 0;
      v_btb.waddr = 0;
      v_btb.wdata = 0;
    end
    if (btac_in.clear == 0) begin
      v_bht.wen = (btac_in.upd_jal0 | btac_in.upd_branch0) | (btac_in.upd_jal1 | btac_in.upd_branch1);
      v_bht.waddr = (btac_in.upd_jal0 | btac_in.upd_branch0) ? btac_in.upd_pc0[bht_depth:1] : btac_in.upd_pc1[bht_depth:1];
      v_bht.wdata = (btac_in.upd_jal0 | btac_in.upd_branch0) ? saturation(btac_in.upd_pred0.tsat,btac_in.upd_jal0,btac_in.upd_jump0) : saturation(btac_in.upd_pred1.tsat,btac_in.upd_jal1,btac_in.upd_jump1);
    end else begin
      v_bht.wen = 0;
      v_bht.waddr = 0;
      v_bht.wdata = 0;
    end

    if (btac_in.stall == 0 && btac_in.clear == 0) begin
      btac_out.pred0.taddr = btb_out.rdata0[31:0];
      btac_out.pred1.taddr = btb_out.rdata1[31:0];
    end else begin
      btac_out.pred0.taddr = 0;
      btac_out.pred1.taddr = 0;
    end
    if (btac_in.stall == 0 && btac_in.clear == 0) begin
      btac_out.pred0.taken = bht_out.rdata0[1] & (~(|(btb_out.rdata0[62-btb_depth:32] ^ r_btb.pc0[31:btb_depth+1])));
      btac_out.pred1.taken = bht_out.rdata1[1] & (~(|(btb_out.rdata1[62-btb_depth:32] ^ r_btb.pc1[31:btb_depth+1])));
      btac_out.pred0.tsat = bht_out.rdata0;
      btac_out.pred1.tsat = bht_out.rdata1;
    end else begin
      btac_out.pred0.taken = 0;
      btac_out.pred1.taken = 0;
      btac_out.pred0.tsat = 0;
      btac_out.pred1.tsat = 0;
    end

    v_btb.maddr0 = 0;
    v_btb.maddr1 = 0;
    v_btb.miss0 = 0;
    v_btb.miss1 = 0;

    if (btac_in.clear == 0) begin
      if (btac_in.upd_pred0.taken == 1) begin
        if (btac_in.upd_jump0 == 1) begin
          v_btb.maddr0 = btac_in.upd_addr0;
          v_btb.miss0 = |(btac_in.upd_addr0 ^ btac_in.upd_pred0.taddr);
        end else if (btac_in.upd_jump0 == 0 && btac_in.upd_branch0 == 1) begin
          v_btb.maddr0 = btac_in.upd_npc0;
          v_btb.miss0 = 1;
        end
      end else if (btac_in.upd_jump0 == 1) begin
        v_btb.maddr0 = btac_in.upd_addr0;
        v_btb.miss0 = 1;
      end
      if (btac_in.upd_pred1.taken == 1) begin
        if (btac_in.upd_jump1 == 1) begin
          v_btb.maddr1 = btac_in.upd_addr1;
          v_btb.miss1 = |(btac_in.upd_addr1 ^ btac_in.upd_pred1.taddr);
        end else if (btac_in.upd_jump1 == 0 && btac_in.upd_branch1 == 1) begin
          v_btb.maddr1 = btac_in.upd_npc1;
          v_btb.miss1 = 1;
        end
      end else if (btac_in.upd_jump1 == 1) begin
        v_btb.maddr1 = btac_in.upd_addr1;
        v_btb.miss1 = 1;
      end
    end

    btb_in.wen = v_btb.wen;
    btb_in.waddr = v_btb.waddr;
    btb_in.wdata = v_btb.wdata;

    bht_in.wen = v_bht.wen;
    bht_in.waddr = v_bht.waddr;
    bht_in.wdata = v_bht.wdata;

    rin_btb = v_btb;
    rin_bht = v_bht;

    btac_out.pred_maddr = r_btb.miss0 ? r_btb.maddr0 : r_btb.maddr1;
    btac_out.pred_miss = r_btb.miss0 | r_btb.miss1;
    btac_out.pred_hazard0 = v_btb.miss0;
    btac_out.pred_hazard1 = v_btb.miss1;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r_btb <= init_btb_reg;
      r_bht <= init_bht_reg;
    end else begin
      r_btb <= rin_btb;
      r_bht <= rin_bht;
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

      typedef struct packed{
        logic [31 : 0] maddr;
        logic [0  : 0] miss0;
        logic [0  : 0] miss1;
      } reg_type;

      parameter reg_type init_reg = '{
        maddr : 0,
        miss0 : 0,
        miss1 : 0
      };

      reg_type r, rin, v;

      always_comb begin

        v = r;

        v.maddr = btac_in.upd_jump0 ? btac_in.upd_addr0 : btac_in.upd_addr1;
        v.miss0 = btac_in.upd_jump0;
        v.miss1 = btac_in.upd_jump1;

        rin = v;

        btac_out.pred0.taken = 0;
        btac_out.pred1.taken = 0;
        btac_out.pred0.taddr = 0;
        btac_out.pred1.taddr = 0;
        btac_out.pred0.tsat = 0;
        btac_out.pred1.tsat = 0;
        btac_out.pred_maddr = r.maddr;
        btac_out.pred_miss = r.miss0 | r.miss1;
        btac_out.pred_hazard0 = v.miss0;
        btac_out.pred_hazard1 = v.miss1;

      end

      always_ff @(posedge clock) begin
        if (reset == 0) begin
          r <= init_reg;
        end else begin
          r <= rin;
        end
      end

    end

  endgenerate

endmodule