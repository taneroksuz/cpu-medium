import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic reset,
  input logic clock,
  input csr_out_type csr_out,
  input bp_out_type bp_out,
  output bp_in_type bp_in,
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
  localparam [1:0] jump = 2;
  localparam [1:0] inv = 3;

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.valid = 0;
    v.stall = a.b.stall;

    v.fence = 0;
    v.spec = 0;
    
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
      jump : begin
        v.stall = 1;
      end
      inv : begin
        v.stall = 1;
      end
      default : begin
      end
    endcase

    bp_in.get_pc = d.d.instr0.pc;
    bp_in.get_npc = d.d.instr0.npc;
    bp_in.get_branch = d.d.instr0.op.branch;
    bp_in.get_return = d.d.instr0.op.return_pop;
    bp_in.get_uncond = d.d.instr0.op.jump_uncond;
    bp_in.upd_pc = d.e.instr0.pc;
    bp_in.upd_npc = d.e.instr0.npc;
    bp_in.upd_addr = d.e.instr0.address;
    bp_in.upd_branch = d.e.instr0.op.branch;
    bp_in.upd_return = d.e.instr0.op.return_push;
    bp_in.upd_uncond = d.e.instr0.op.jump_uncond;
    bp_in.upd_jump = d.e.instr0.op.jump;
    bp_in.stall = v.stall;
    bp_in.clear = d.w.clear;

    if (csr_out.trap == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = csr_out.mepc;
    end else if (bp_out.pred_branch == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = bp_out.pred_baddr;
    end else if (bp_out.pred_return == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = bp_out.pred_raddr;
    end else if (bp_out.pred_miss == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = bp_out.pred_maddr;
    end else if (d.e.instr0.op.jump == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = d.e.instr0.address;
    end else if (d.m.instr0.op.fence == 1) begin
      v.fence = 1;
      v.spec = 1;
      v.pc = d.m.instr0.npc;
    end else if (v.stall == 0) begin
      v.fence = 0;
      v.spec = 0;
      v.pc = v.pc + 8;
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
          v.state = jump;
          v.valid = 0;
        end else if (v.fence == 1) begin
          v.state = inv;
          v.valid = 0;
        end else begin
          v.state = busy;
          v.valid = 0;
        end
      end
      jump : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else begin
          v.state = jump;
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

    rin = v;

    y.pc = v.pc;
    y.rdata = v.rdata;
    y.ready = v.ready;

    q.pc = r.pc;
    q.rdata = r.rdata;
    q.ready = r.ready;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
