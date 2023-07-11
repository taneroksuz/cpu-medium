package btac_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  localparam btb_depth = $clog2(branchtarget_depth-1);

  typedef struct packed{
    logic [0 : 0] wen;
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr0;
    logic [btb_depth-1 : 0] raddr1;
    logic [63-btb_depth : 0] wdata;
  } btb_in_type;

  typedef struct packed{
    logic [63-btb_depth : 0] rdata0;
    logic [63-btb_depth : 0] rdata1;
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

  logic [63-btb_depth:0] btb_array[0:branchtarget_depth-1] = '{default:'0};

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

  task saturation;
    output logic [1:0] sat_o;
    input logic [1:0] sat_i;
    input logic [0:0] jump;
    begin
      if (jump == 0 && |sat_i == 1)
        sat_o = sat_i - 1;
      else if (jump == 1 && &sat_i == 0)
        sat_o = sat_i + 1;
      else
        sat_o = sat_i;
    end
  endtask

  typedef struct packed{
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr0;
    logic [btb_depth-1 : 0] raddr1;
    logic [63-btb_depth : 0] wdata;
    logic [0  : 0] wen;
    logic [0  : 0] branch0;
    logic [0  : 0] branch1;
    logic [1  : 0] sat0;
    logic [1  : 0] sat1;
    logic [31 : 0] pc0;
    logic [31 : 0] pc1;
    logic [31 : 0] maddr;
    logic [0  : 0] miss0;
    logic [0  : 0] miss1;
  } reg_type;

  parameter reg_type init_reg = '{
    waddr : 0,
    raddr0 : 0,
    raddr1 : 0,
    wdata : 0,
    wen : 0,
    branch0 : 0,
    branch1 : 0,
    sat0 : 0,
    sat1 : 0,
    pc0 : 0,
    pc1 : 0,
    maddr : 0,
    miss0 : 0,
    miss1 : 0
  };

  reg_type r, rin, v;

  always_comb begin

    v = r;

    if (btac_in.clear == 0) begin
      v.pc0 = btac_in.get_pc0;
      v.pc1 = btac_in.get_pc1;
      v.raddr0 = btac_in.get_pc0[btb_depth+1:2];
      v.raddr1 = btac_in.get_pc1[btb_depth+1:2];
    end

    btb_in.raddr0 = v.raddr0;
    btb_in.raddr1 = v.raddr1;

    if (btac_in.clear == 0) begin
      saturation(v.sat0,btac_in.upd_pred0.tsat,btac_in.upd_jump0);
      saturation(v.sat1,btac_in.upd_pred1.tsat,btac_in.upd_jump1);
      v.wen = ((btac_in.upd_jal0 | btac_in.upd_branch0) & btac_in.upd_jump0) | ((btac_in.upd_jal1 | btac_in.upd_branch1) & btac_in.upd_jump1);
      v.waddr = btac_in.upd_jump0 ? btac_in.upd_pc0[btb_depth+1:2] : btac_in.upd_pc1[btb_depth+1:2];
      v.wdata = btac_in.upd_jump0 ? {btac_in.upd_pc0[31:btb_depth+2],btac_in.upd_addr0,v.sat0} : {btac_in.upd_pc1[31:btb_depth+2],btac_in.upd_addr1,v.sat1};
    end else begin
      v.wen = 0;
      v.waddr = 0;
      v.wdata = 0;
    end

    if (btac_in.stall == 0 && btac_in.clear == 0) begin
      v.branch0 = btb_out.rdata0[1] & (~(|(btb_out.rdata0[63-btb_depth:34] ^ r.pc0[31:btb_depth+2])));
      v.branch1 = btb_out.rdata1[1] & (~(|(btb_out.rdata1[63-btb_depth:34] ^ r.pc1[31:btb_depth+2])));
      btac_out.pred_branch0 = v.branch0;
      btac_out.pred_branch1 = v.branch0 ? 0 : v.branch1;
      btac_out.pred_bsat = v.branch0 ? btb_out.rdata0[1:0] : btb_out.rdata1[1:0];
      btac_out.pred_baddr = v.branch0 ? btb_out.rdata0[33:2] : btb_out.rdata1[33:2];
    end else begin
      btac_out.pred_branch0 = 0;
      btac_out.pred_branch1 = 0;
      btac_out.pred_bsat = 0;
      btac_out.pred_baddr = 0;
    end

    if (btac_in.clear == 0) begin
      if (btac_in.upd_pred0.taken == 1) begin
        if (btac_in.upd_jump0 == 1) begin
          v.maddr = btac_in.upd_addr0;
          v.miss0 = |(btac_in.upd_addr0 ^ btac_in.upd_pred0.taddr);
          v.miss1 = 0;
        end else if (btac_in.upd_jump0 == 0 && btac_in.upd_branch0 == 1) begin
          v.maddr = btac_in.upd_npc0;
          v.miss0 = 1;
          v.miss1 = 0;
        end else begin
          v.maddr = 0;
          v.miss0 = 0;
          v.miss1 = 0;
        end
      end else if (btac_in.upd_pred1.taken == 1) begin
        if (btac_in.upd_jump1 == 1) begin
          v.maddr = btac_in.upd_addr1;
          v.miss0 = 0;
          v.miss1 = |(btac_in.upd_addr1 ^ btac_in.upd_pred1.taddr);
        end else if (btac_in.upd_jump1 == 0 && btac_in.upd_branch1 == 1) begin
          v.maddr = btac_in.upd_npc1;
          v.miss0 = 0;
          v.miss1 = 1;
        end else begin
          v.maddr = 0;
          v.miss0 = 0;
          v.miss1 = 0;
        end
      end else begin
        if (btac_in.upd_jump0 == 1) begin
          v.maddr = btac_in.upd_addr0;
          v.miss0 = 1;
          v.miss1 = 0;
        end else if (btac_in.upd_jump1 == 1) begin
          v.maddr = btac_in.upd_addr1;
          v.miss0 = 0;
          v.miss1 = 1;
        end else begin
          v.maddr = 0;
          v.miss0 = 0;
          v.miss1 = 0;
        end
      end
    end else begin
      v.maddr = 0;
      v.miss0 = 0;
      v.miss1 = 0;
    end

    btb_in.wen = v.wen;
    btb_in.waddr = v.waddr;
    btb_in.wdata = v.wdata;

    rin = v;

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

        btac_out.pred_baddr = 0;
        btac_out.pred_branch0 = 0;
        btac_out.pred_branch1 = 0;
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