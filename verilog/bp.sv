package bp_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr;
    logic [62-btb_depth : 0] wdata;
  } btb_in_type;

  typedef struct packed{
    logic [62-btb_depth : 0] rdata;
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

  typedef struct packed{
    logic [0 : 0] wen;
    logic [ras_depth-1 : 0] waddr;
    logic [ras_depth-1 : 0] raddr;
    logic [31 : 0] wdata;
  } ras_in_type;

  typedef struct packed{
    logic [31 : 0] rdata;
  } ras_out_type;

endpackage

import configure::*;
import wires::*;
import bp_wires::*;

module btb
(
  input logic clock,
  input btb_in_type btb_in,
  output btb_out_type btb_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [62-btb_depth:0] btb_array[0:2**btb_depth-1] = '{default:'0};

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

  logic [1:0] bht_array[0:2**bht_depth-1] = '{default:'0};

  assign bht_out.rdata1 = bht_array[bht_in.raddr1];
  assign bht_out.rdata2 = bht_array[bht_in.raddr2];

  always_ff @(posedge clock) begin
    if (bht_in.wen == 1) begin
      bht_array[bht_in.waddr] <= bht_in.wdata;
    end
  end

endmodule

module ras
(
  input logic clock,
  input ras_in_type ras_in,
  output ras_out_type ras_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] ras_array[0:2**ras_depth-1] = '{default:'0};

  assign ras_out.rdata = ras_array[ras_in.raddr];

  always_ff @(posedge clock) begin
    if (ras_in.wen == 1) begin
      ras_array[ras_in.waddr] <= ras_in.wdata;
    end
  end

endmodule

module bp_ctrl
(
  input logic reset,
  input logic clock,
  input bp_in_type bp_in,
  output bp_out_type bp_out,
  input btb_out_type btb_out,
  output btb_in_type btb_in,
  input bht_out_type bht_out,
  output bht_in_type bht_in,
  input ras_out_type ras_out,
  output ras_in_type ras_in
);
  timeunit 1ns;
  timeprecision 1ps;

  typedef struct packed{
    logic [btb_depth-1 : 0] wid;
    logic [btb_depth-1 : 0] rid;
    logic [31 : 0] wpc;
    logic [31 : 0] rpc;
    logic [31 : 0] waddr; 
    logic [0  : 0] update; 
  } btb_reg_type;

  parameter btb_reg_type init_btb_reg = '{
    wid : 0,
    rid : 0,
    wpc : 0,
    rpc : 0,
    waddr : 0,
    update : 0
  };

  typedef struct packed{
    logic [bht_depth-1 : 0] history;
    logic [bht_depth-1 : 0] get_ind;
    logic [bht_depth-1 : 0] upd_ind;
    logic [1 : 0] get_sat;
    logic [1 : 0] upd_sat;
    logic [0 : 0] update;
  } bht_reg_type;

  parameter bht_reg_type init_bht_reg = '{
    history : 0,
    get_ind : 0,
    upd_ind : 0,
    get_sat : 0,
    upd_sat : 0,
    update : 0
  };

  typedef struct packed{
    logic [ras_depth-1 : 0] wid;
    logic [ras_depth-1 : 0] rid;
    logic [ras_depth : 0] count;
    logic [31 : 0] waddr;
    logic [0  : 0] update;
  } ras_reg_type;

  parameter ras_reg_type init_ras_reg = '{
    wid : 0,
    rid : 0,
    count : 0,
    waddr : 0,
    update : 0
  };

  btb_reg_type r_btb, rin_btb, v_btb;
  bht_reg_type r_bht, rin_bht, v_bht;
  ras_reg_type r_ras, rin_ras, v_ras;

  always_comb begin : branch_target_buffer

    v_btb = r_btb;

    if (bp_in.clear == 0) begin
      v_btb.rpc = bp_in.get_pc;
      v_btb.rid = v_btb.rpc[btb_depth:1];
    end

    if (bp_in.clear == 0) begin
      v_btb.wpc = bp_in.upd_pc;
      v_btb.waddr = bp_in.upd_addr;
      v_btb.wid = v_btb.wpc[btb_depth:1];
    end

    btb_in.raddr = v_btb.rid;

    if (bp_in.upd_jump == 0 && bp_in.stall == 0 && bp_in.clear == 0 &&
          |(btb_out.rdata[62-btb_depth:32] ^ v_btb.rpc[31:(btb_depth+1)]) == 0) begin
        bp_out.pred_baddr = btb_out.rdata[31:0];
        bp_out.pred_branch = bp_in.get_branch;
        bp_out.pred_uncond = bp_in.get_uncond;
    end else begin
        bp_out.pred_baddr = 0;
        bp_out.pred_branch = 0;
        bp_out.pred_uncond = 0;
    end

    v_btb.update = (bp_in.upd_branch & bp_in.upd_jump) | bp_in.upd_uncond;

    btb_in.wen = v_btb.update;
    btb_in.waddr = v_btb.wid;
    btb_in.wdata = {v_btb.wpc[31:(btb_depth+1)],v_btb.waddr};

    rin_btb = v_btb;
    
  end

  always_comb begin : branch_history_table

    v_bht = r_bht;

    if (bp_in.clear == 0) begin
      v_bht.upd_ind = v_bht.history ^ bp_in.upd_pc[bht_depth:1];
    end

    bht_in.raddr1 = v_bht.upd_ind;
    v_bht.upd_sat = bht_out.rdata1;

    if (bp_in.clear == 0) begin
      v_bht.get_ind = v_bht.history ^ bp_in.get_pc[bht_depth:1];
    end

    bht_in.raddr2 = v_bht.get_ind;
    v_bht.get_sat = bht_out.rdata2;

    if (bp_in.upd_branch == 1) begin 
      v_bht.history = {v_bht.history[bht_depth-2:0],1'b0};
      if (bp_in.upd_jump == 1) begin
        v_bht.history[0] = 1;
        if (v_bht.upd_sat < 3) begin
          v_bht.upd_sat = v_bht.upd_sat + 1;
        end
      end else if (bp_in.upd_jump == 0) begin
        if (v_bht.upd_sat > 0) begin
          v_bht.upd_sat = v_bht.upd_sat - 1;
        end
      end
    end

    if (bp_in.get_branch == 1 && bp_in.upd_jump == 0 && bp_in.stall == 0 && bp_in.clear == 0) begin
      bp_out.pred_jump = v_bht.get_sat[1];
    end else begin 
      bp_out.pred_jump = 0;
    end

    v_bht.update = bp_in.upd_branch;

    bht_in.wen = v_bht.update;
    bht_in.waddr = v_bht.upd_ind;
    bht_in.wdata = v_bht.upd_sat;

    rin_bht = v_bht;
    
  end

  always_comb begin : return_address_stack

    v_ras = r_ras;

    v_ras.waddr = bp_in.upd_npc;

    if (bp_in.upd_return == 1) begin
      if (v_ras.count < 2**ras_depth) begin
        v_ras.count = v_ras.count + 1;
      end
      v_ras.rid = v_ras.wid;
      if (v_ras.wid < 2**ras_depth-1) begin
        v_ras.wid = v_ras.wid + 1;
      end else begin
        v_ras.wid = 0;
      end
    end

    ras_in.raddr = v_ras.rid;

    if (bp_in.get_return == 1 && bp_in.upd_jump == 0 && bp_in.stall == 0 && bp_in.clear == 0 &&
          v_ras.count > 0) begin
      bp_out.pred_raddr = ras_out.rdata;
      bp_out.pred_return = 1;
      v_ras.count = v_ras.count - 1;
      v_ras.wid = v_ras.rid;
      if (v_ras.rid > 0) begin
        v_ras.rid = v_ras.rid - 1;
      end else begin
        v_ras.rid = 2**ras_depth-1;
      end
    end else begin
      bp_out.pred_raddr = 0;
      bp_out.pred_return = 0;
    end

    v_ras.update = bp_in.upd_return;

    ras_in.wen = v_ras.update;
    ras_in.waddr = r_ras.wid;
    ras_in.wdata = v_ras.waddr;

    rin_ras = v_ras;
    
  end

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      r_btb <= init_btb_reg;
      r_bht <= init_bht_reg;
      r_ras <= init_ras_reg;
    end else begin
      r_btb <= rin_btb;
      r_bht <= rin_bht;
      r_ras <= rin_ras;
    end
  end

endmodule

module bp
(
  input logic reset,
  input logic clock,
  input bp_in_type bp_in,
  output bp_out_type bp_out
);
  timeunit 1ns;
  timeprecision 1ps;

  generate

    if (bp_enable == 1) begin

      btb_in_type btb_in;
      btb_out_type btb_out;
      bht_in_type bht_in;
      bht_out_type bht_out;
      ras_in_type ras_in;
      ras_out_type ras_out;

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

      ras ras_comp
      (
        .clock (clock),
        .ras_in (ras_in),
        .ras_out (ras_out)
      );

      bp_ctrl bp_ctrl_comp
      (
        .reset (reset),
        .clock (clock),
        .bp_in (bp_in),
        .bp_out (bp_out),
        .btb_in (btb_in),
        .btb_out (btb_out),
        .bht_in (bht_in),
        .bht_out (bht_out),
        .ras_in (ras_in),
        .ras_out (ras_out)
      );

    end else begin

      assign bp_out.pred_baddr = 0;
      assign bp_out.pred_branch = 0;
      assign bp_out.pred_jump = 0;
      assign bp_out.pred_raddr = 0;
      assign bp_out.pred_return = 0;
      assign bp_out.pred_uncond = 0;

    end

  endgenerate

endmodule