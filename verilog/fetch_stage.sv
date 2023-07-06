import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic reset,
  input logic clock,
  input csr_out_type csr_out,
  input btac_out_type btac_out,
  output btac_in_type btac_in,
  input itim_out_type imem_out,
  output itim_in_type imem_in,
  input fetch_in_type a,
  input fetch_in_type d,
  output fetch_out_type y,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [1:0] idle = 0;
  localparam [1:0] busy = 1;
  localparam [1:0] ctrl = 2;
  localparam [1:0] inv = 3;

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.valid = 0;
    v.stall = a.i.halt;

    v.fence = 0;
    v.spec = 0;
    v.taken = 0;
    
    v.rdata = imem_out.mem_rdata;
    v.ready = imem_out.mem_ready;

    case(v.state)
      idle : begin
        v.stall = 1;
      end
      busy : begin
        if (v.ready == 0) begin
          v.stall = 1;
        end
      end
      ctrl : begin
        v.stall = 1;
      end
      inv : begin
        v.stall = 1;
      end
      default : begin
      end
    endcase

    if (csr_out.trap == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.taken = 0;
      v.pc = csr_out.mtvec;
      v.taddr = 0;
      v.tpc = 0;
      v.tnpc = 0;
    end else if (csr_out.mret == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.taken = 0;
      v.pc = csr_out.mepc;
      v.taddr = 0;
      v.tpc = 0;
      v.tnpc = 0;
    end else if (btac_out.pred_miss == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.taken = 0;
      v.pc = btac_out.pred_maddr;
      v.taddr = 0;
      v.tpc = 0;
      v.tnpc = 0;
    end else if (d.m.calc0.op.fence == 1) begin
      v.fence = 1;
      v.spec = 1;
      v.taken = 0;
      v.pc = d.m.calc0.npc;
      v.taddr = 0;
      v.tpc = 0;
      v.tnpc = 0;
    end else if (btac_out.pred_branch == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.taken = 1;
      v.pc = btac_out.pred_baddr;
      v.taddr = btac_out.pred_baddr;
      v.tpc = btac_out.pred_pc;
      v.tnpc = btac_out.pred_npc;
    end else if (v.stall == 0) begin
      v.fence = 0;
      v.spec = 0;
      v.taken = 0;
      v.pc = v.pc + 8;
      v.taddr = 0;
      v.tpc = 0;
      v.tnpc = 0;
    end

    case(v.state)
      idle : begin
        if (d.w.clear == 0) begin
          v.state = busy;
          v.valid = 1;
        end
      end
      busy : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else if (v.spec == 1) begin
          v.state = ctrl;
          v.valid = 0;
        end else if (v.fence == 1) begin
          v.state = inv;
          v.valid = 0;
        end else begin
          v.state = busy;
          v.valid = 0;
        end
      end
      ctrl : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else begin
          v.state = ctrl;
          v.valid = 0;
        end
        v.ready = 0;
      end
      inv : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else begin
          v.state = inv;
          v.valid = 0;
        end
        v.ready = 0;
      end
      default : begin
      end
    endcase

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = v.fence;
    imem_in.mem_spec = v.spec;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.pc;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    btac_in.get_pc0 = a.i.calc0.pc;
    btac_in.get_pc1 = a.i.calc1.pc;
    btac_in.upd_pc0 = d.e.calc0.pc;
    btac_in.upd_pc1 = d.e.calc1.pc;
    btac_in.upd_npc0 = d.e.calc0.npc;
    btac_in.upd_npc1 = d.e.calc1.npc;
    btac_in.upd_addr0 = d.e.calc0.address;
    btac_in.upd_addr1 = d.e.calc1.address;
    btac_in.upd_jal0 = d.e.calc0.op.jal;
    btac_in.upd_jal1 = d.e.calc1.op.jal;
    btac_in.upd_jalr0 = d.e.calc0.op.jalr;
    btac_in.upd_jalr1 = d.e.calc1.op.jalr;
    btac_in.upd_branch0 = d.e.calc0.op.branch;
    btac_in.upd_branch1 = d.e.calc1.op.branch;
    btac_in.upd_jump0 = d.e.calc0.op.jump;
    btac_in.upd_jump1 = d.e.calc1.op.jump;
    btac_in.taken = v.taken;
    btac_in.taddr = v.taddr;
    btac_in.tpc = v.tpc;
    btac_in.tnpc = v.tnpc;
    btac_in.stall = v.stall;
    btac_in.clear = d.w.clear;

    rin = v;

    y.pc = v.pc;
    y.rdata = v.rdata;
    y.ready = v.ready;
    y.taken = v.taken;
    y.taddr = v.taddr;
    y.tpc = v.tpc;
    y.tnpc = v.tnpc;

    q.pc = r.pc;
    q.rdata = r.rdata;
    q.ready = r.ready;
    q.taken = r.taken;
    q.taddr = r.taddr;
    q.tpc = r.tpc;
    q.tnpc = r.tnpc;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
