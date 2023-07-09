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
    logic [95 : 0] wdata;
  } btb_in_type;

  typedef struct packed{
    logic [95 : 0] rdata0;
    logic [95 : 0] rdata1;
  } btb_out_type;

  typedef struct packed{
    logic [0  : 0] wen;
    logic [2  : 0] waddr;
    logic [2  : 0] raddr;
    logic [95 : 0] wdata;
  } btac_pred_in_type;

  typedef struct packed{
    logic [95 : 0] rdata;
  } btac_pred_out_type;

  typedef struct packed{
    logic [0  : 0] rden;
    logic [0  : 0] wren;
    logic [95 : 0] wdata;
    logic [0  : 0] clear;
  } btac_fifo_in_type;

  typedef struct packed{
    logic [95 : 0] rdata;
    logic [0  : 0] ready;
  } btac_fifo_out_type;

endpackage

import configure::*;
import wires::*;
import btac_wires::*;

module btac_pred
(
  input logic clock,
  input btac_pred_in_type btac_pred_in,
  output btac_pred_out_type btac_pred_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [95 : 0] btac_pred_array[0:7] = '{default:'0};

  assign btac_pred_out.rdata = btac_pred_array[btac_pred_in.raddr];

  always_ff @(posedge clock) begin
    if (btac_pred_in.wen == 1) begin
      btac_pred_array[btac_pred_in.waddr] <= btac_pred_in.wdata;
    end
  end

endmodule

module btac_fifo
(
  input logic reset,
  input logic clock,
  output btac_pred_in_type btac_pred_in,
  input btac_pred_out_type btac_pred_out,
  input btac_fifo_in_type btac_fifo_in,
  output btac_fifo_out_type btac_fifo_out
);
  timeunit 1ns;
  timeprecision 1ps;

  typedef struct packed{
    logic [2:0] waddr;
    logic [2:0] raddr;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] oflow;
  } reg_type;

  parameter reg_type init_reg = '{
    waddr : 0,
    raddr : 0,
    wren : 0,
    rden : 0,
    oflow : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin
    v = r;

    v.wren = 0;
    if (btac_fifo_in.wren == 1) begin
      if (v.oflow == 1 && v.waddr < v.raddr) begin
        v.wren = 1;
      end else if (v.oflow == 0) begin
        v.wren = 1;
      end
    end

    v.rden = 0;
    if (btac_fifo_in.rden == 1) begin
      if (v.oflow == 0 && v.raddr < v.waddr) begin
        v.rden = 1;
      end else if (v.oflow == 1) begin
        v.rden = 1;
      end
    end

    if (v.wren == 1) begin
      if (&(v.waddr) == 1) begin
        v.oflow = 1;
        v.waddr = 0;
      end else begin
        v.waddr = v.waddr + 1;
      end
    end

    if (v.rden == 1) begin
      if (&(v.raddr) == 1) begin
        v.oflow = 0;
        v.raddr = 0;
      end else begin
        v.raddr = v.raddr + 1;
      end
    end

    if (btac_fifo_in.clear == 1) begin
      v.waddr = 0;
      v.raddr = 0;
      v.wren = 0;
      v.rden = 0;
      v.oflow = 0;
    end

    btac_pred_in.wen = v.wren;
    btac_pred_in.waddr = v.waddr;
    btac_pred_in.wdata = btac_fifo_in.wdata;

    btac_pred_in.raddr = v.raddr;

    btac_fifo_out.rdata = btac_pred_out.rdata;
    btac_fifo_out.ready = v.rden;

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
  output btb_in_type btb_in,
  input btac_fifo_out_type btac_fifo_out,
  output btac_fifo_in_type btac_fifo_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam btb_depth = $clog2(branchtarget_depth-1);

  typedef struct packed{
    logic [btb_depth-1 : 0] waddr;
    logic [btb_depth-1 : 0] raddr0;
    logic [btb_depth-1 : 0] raddr1;
    logic [95 : 0] wdata;
    logic [0  : 0] wen;
    logic [0  : 0] branch0;
    logic [0  : 0] branch1;
    logic [31 : 0] pc0;
    logic [31 : 0] pc1;
    logic [0  : 0] taken;
    logic [31 : 0] taddr;
    logic [31 : 0] tpc;
    logic [31 : 0] tnpc;
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
    pc0 : 0,
    pc1 : 0,
    taken : 0,
    taddr : 0,
    tpc : 0,
    tnpc : 0,
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
      v.wen = ((btac_in.upd_jal0 | btac_in.upd_branch0) & btac_in.upd_jump0) | ((btac_in.upd_jal1 | btac_in.upd_branch1) & btac_in.upd_jump1);
      v.waddr = btac_in.upd_jump0 ? btac_in.upd_pc0[btb_depth+1:2] : btac_in.upd_pc1[btb_depth+1:2];
      v.wdata = btac_in.upd_jump0 ? {btac_in.upd_addr0,btac_in.upd_pc0,btac_in.upd_npc0} : {btac_in.upd_addr1,btac_in.upd_pc1,btac_in.upd_npc1};
    end else begin
      v.wen = 0;
      v.waddr = 0;
      v.wdata = 0;
    end

    btac_fifo_in.wren = v.wen;
    btac_fifo_in.wdata = v.wdata;

    btac_fifo_in.rden = btac_in.upd_jal0 | btac_in.upd_branch0 | btac_in.upd_jal1 | btac_in.upd_branch1;

    if (btac_fifo_out.ready == 1) begin
      v.taken = 1;
      v.taddr = btac_fifo_out.rdata[95:64];
      v.tpc = btac_fifo_out.rdata[63:32];
      v.tnpc = btac_fifo_out.rdata[31:0];
    end

    if (btac_in.stall == 0 && btac_in.clear == 0) begin
      v.branch0 = (|btb_out.rdata0) & (~(|(btb_out.rdata0[63:32] ^ r.pc0)));
      v.branch1 = (|btb_out.rdata1) & (~(|(btb_out.rdata1[63:32] ^ r.pc1)));
      btac_out.pred_branch = v.branch0 | v.branch1;
      btac_out.pred_baddr = v.branch0 ? btb_out.rdata0[95:64] : btb_out.rdata1[95:64];
      btac_out.pred_pc = v.branch0 ? btb_out.rdata0[63:32] : btb_out.rdata1[63:32];
      btac_out.pred_npc = v.branch0 ? btb_out.rdata0[31:0] : btb_out.rdata1[31:0];
    end else begin
      btac_out.pred_branch = 0;
      btac_out.pred_baddr = 0;
      btac_out.pred_pc = 0;
      btac_out.pred_npc = 0;
    end

    if (btac_in.clear == 0) begin
      if (v.taken == 1 && btac_in.upd_pc0 == v.tpc) begin
        if (btac_in.upd_jump0 == 1) begin
          v.maddr = btac_in.upd_addr0;
          v.miss0 = |(btac_in.upd_addr0 ^ v.taddr);
          v.miss1 = 0;
          v.taken = 0;
        end else if (btac_in.upd_jump0 == 0 && btac_in.upd_branch0 == 1) begin
          v.maddr = v.tnpc;
          v.miss0 = 1;
          v.miss1 = 0;
          v.taken = 0;
        end else begin
          v.maddr = 0;
          v.miss0 = 0;
          v.miss1 = 0;
        end
      end else if (v.taken == 1 && btac_in.upd_pc1 == v.tpc) begin
        if (btac_in.upd_jump1 == 1) begin
          v.maddr = btac_in.upd_addr1;
          v.miss0 = 0;
          v.miss1 = |(btac_in.upd_addr1 ^ v.taddr);
          v.taken = 0;
        end else if (btac_in.upd_jump1 == 0 && btac_in.upd_branch1 == 1) begin
          v.maddr = v.tnpc;
          v.miss0 = 0;
          v.miss1 = 1;
          v.taken = 0;
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

    btac_fifo_in.clear = 0;

    rin = v;

    btac_out.pred_maddr = r.maddr;
    btac_out.pred_miss = r.miss0 | r.miss1;
    btac_out.pred_hazard = v.miss0;

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

      btac_pred_in_type btac_pred_in;
      btac_pred_out_type btac_pred_out;
      btac_fifo_in_type btac_fifo_in;
      btac_fifo_out_type btac_fifo_out;

      btb btb_comp
      (
        .clock (clock),
        .btb_in (btb_in),
        .btb_out (btb_out)
      );

      btac_pred btac_pred_comp
      (
        .clock (clock),
        .btac_pred_in (btac_pred_in),
        .btac_pred_out (btac_pred_out)
      );

      btac_fifo btac_fifo_comp
      (
        .reset (reset),
        .clock (clock),
        .btac_pred_in (btac_pred_in),
        .btac_pred_out (btac_pred_out),
        .btac_fifo_in (btac_fifo_in),
        .btac_fifo_out (btac_fifo_out)
      );

      btac_ctrl btac_ctrl_comp
      (
        .reset (reset),
        .clock (clock),
        .btac_in (btac_in),
        .btac_out (btac_out),
        .btb_in (btb_in),
        .btb_out (btb_out),
        .btac_fifo_in (btac_fifo_in),
        .btac_fifo_out (btac_fifo_out)
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
        btac_out.pred_branch = 0;
        btac_out.pred_pc = 0;
        btac_out.pred_npc = 0;
        btac_out.pred_maddr = r.maddr;
        btac_out.pred_miss = r.miss0 | r.miss1;
        btac_out.pred_hazard = v.miss0;

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