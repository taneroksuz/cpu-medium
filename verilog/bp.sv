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

  typedef struct packed{
    logic [31 : 0] get_pc;
    logic [0  : 0] get_branch;
    logic [0  : 0] get_return;
    logic [0  : 0] get_uncond;
    logic [31 : 0] upd_pc;
    logic [31 : 0] upd_npc;
    logic [31 : 0] upd_addr;
    logic [0  : 0] upd_branch;
    logic [0  : 0] upd_return;
    logic [0  : 0] upd_uncond;
    logic [0  : 0] upd_jump;
    logic [0  : 0] stall;
    logic [0  : 0] clear;
  } bp_in_type;

  typedef struct packed{
    logic [31 : 0] pred_baddr;
    logic [0  : 0] pred_branch;
    logic [0  : 0] pred_jump;
    logic [31 : 0] pred_raddr;
    logic [0  : 0] pred_return;
    logic [0  : 0] pred_uncond;
  } bp_out_type;

endpackage

import configure::*;
import bp_wires::*;

module btb
(
  input logic clk,
  input btb_in_type btb_in,
  output btb_out_type btb_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [62-btb_depth:0] btb_array[0:2**btb_depth-1] = '{default:'0};

  assign btb_out.rdata = btb_array[btb_in.raddr];

  always_ff @(posedge clk) begin
    if (btb_in.wen == 1) begin
      tag_array[btb_in.waddr] <= btb_in.wdata;
    end
  end

endmodule

module bht
(
  input logic clk,
  input bht_in_type bht_in,
  output bht_out_type bht_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [1:0] bht_array[0:2**bht_depth-1] = '{default:'0};

  assign bht_out.rdata = bht_array[bht_in.raddr];

  always_ff @(posedge clk) begin
    if (bht_in.wen == 1) begin
      tag_array[bht_in.waddr] <= bht_in.wdata;
    end
  end

endmodule

module ras
(
  input logic clk,
  input ras_in_type ras_in,
  output ras_out_type ras_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] ras_array[0:2**ras_depth-1] = '{default:'0};

  assign ras_out.rdata1 = ras_array[ras_in.raddr1];
  assign ras_out.rdata2 = ras_array[ras_in.raddr2];

  always_ff @(posedge clk) begin
    if (ras_in.wen == 1) begin
      tag_array[ras_in.waddr] <= ras_in.wdata;
    end
  end

endmodule

module bp
(
  input logic rst,
  input logic clk,
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
    logic [1  : 0] update;
  } ras_reg_type;

  parameter ras_reg_type init_ras_reg = '{
    wid : 0,
    rid : 0,
    count : 0,
    waddr : 0,
    update : 0
  };

  btb_reg_type r_btb, rin_btb, v_btb = init_btb_reg;
  btb_reg_type r_bht, rin_bht, v_bht = init_bht_reg;
  btb_reg_type r_ras, rin_ras, v_ras = init_ras_reg;

  generate

    if (bp_enable == 1) begin

      always_comb begin : branch_target_buffer

        v_btb = r_btb;

        rin_btb = v_btb;
        
      end

      always_comb begin : branch_history_table

        v_bht = r_bht;

        rin_bht = v_bht;
        
      end

      always_comb begin : return_address_stack

        v_ras = r_ras;

        rin_ras = v_ras;
        
      end

      always_ff @(posedge clk) begin
        if (rst == 0) begin
          r_btb <= init_btb_reg;
          r_bht <= init_bht_reg;
          r_ras <= init_ras_reg;
        end else begin
          r_btb <= rin_btb;
          r_bht <= rin_bht;
          r_ras <= rin_ras;
        end
      end

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