import constants::*;
import wires::*;
import functions::*;
import fp_wire::*;

module issue_stage
(
  input logic reset,
  input logic clock,
  input hazard_out_type hazard_out,
  output hazard_in_type hazard_in,
  output register_read_in_type register0_rin,
  output register_read_in_type register1_rin,
  output fp_register_read_in_type fp_register_rin,
  input csr_out_type csr_out,
  output csr_read_in_type csr_rin,
  input fp_csr_out_type fp_csr_out,
  output fp_csr_read_in_type fp_csr_rin,
  input btac_out_type btac_out,
  input issue_in_type a,
  input issue_in_type d,
  output issue_out_type y,
  output issue_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  issue_reg_type r,rin;
  issue_reg_type v;

  always_comb begin

    v = r;

    hazard_in.instr0 = d.d.instr0;
    hazard_in.instr1 = d.d.instr1;
    hazard_in.clear = a.d.taken | a.e.instr0.op.fence | a.e.instr0.op.jump | a.e.instr1.op.jump | csr_out.trap | csr_out.mret | btac_out.pred_miss | d.w.clear;
    hazard_in.stall = d.i.stall | d.e.stall | d.m.stall;

    v.instr0 = hazard_out.instr0;
    v.instr1 = hazard_out.instr1;
    v.swap = hazard_out.swap;

    if ((d.i.stall | d.e.stall | d.m.stall) == 1) begin
      v = r;
      v.instr0.op = r.instr0.op_b;
      v.instr1.op = r.instr1.op_b;
    end

    v.halt = hazard_out.stall;
    v.stall = 0;

    v.clear = a.e.instr0.op.fence | a.e.instr0.op.jump | a.e.instr1.op.jump | csr_out.trap | csr_out.mret | btac_out.pred_miss | d.w.clear;

    if (csr_out.fs == 2'b00) begin
      v.instr0.fmt = 0;
      v.instr0.rm = 0;
      v.instr0.op.fwren = 0;
      v.instr0.op.frden1 = 0;
      v.instr0.op.frden2 = 0;
      v.instr0.op.frden3 = 0;
      v.instr0.op.fload = 0;
      v.instr0.op.fstore = 0;
      v.instr0.op.fpu = 0;
      v.instr0.op.fpuc = 0;
      v.instr0.op.fpuf = 0;
    end

    if (v.instr0.rm == 3'b111) begin
      v.instr0.rm = fp_csr_out.frm;
    end

    register0_rin.rden1 = v.instr0.op.rden1;
    register0_rin.rden2 = v.instr0.op.rden2;
    register0_rin.raddr1 = v.instr0.raddr1;
    register0_rin.raddr2 = v.instr0.raddr2;

    register1_rin.rden1 = v.instr1.op.rden1;
    register1_rin.rden2 = v.instr1.op.rden2;
    register1_rin.raddr1 = v.instr1.raddr1;
    register1_rin.raddr2 = v.instr1.raddr2;

    fp_register_rin.rden1 = v.instr0.op.frden1;
    fp_register_rin.rden2 = v.instr0.op.frden2;
    fp_register_rin.rden3 = v.instr0.op.frden3;
    fp_register_rin.raddr1 = v.instr0.raddr1;
    fp_register_rin.raddr2 = v.instr0.raddr2;
    fp_register_rin.raddr3 = v.instr0.raddr3;

    v.instr0.cdata = (fp_csr_out.ready == 1) ? fp_csr_out.cdata : csr_out.cdata;

    csr_rin.crden = v.instr0.op.crden;
    csr_rin.craddr = v.instr0.caddr;

    fp_csr_rin.crden = v.instr0.op.crden;
    fp_csr_rin.craddr = v.instr0.caddr;

    if (a.e.instr0.op.cwren == 1 || a.m.instr0.op.cwren == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.op.division == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.op.bitc == 1) begin
      v.stall = 1;
    end else if (a.e.instr0.op.fpuc == 1) begin
      v.stall = 1;
    end else if (v.instr0.op.crden == 1 && (v.instr0.caddr == csr_fflags || v.instr0.caddr == csr_fcsr) && (a.e.instr0.op.fpuf == 1 || a.m.instr0.op.fpuf == 1)) begin
      v.stall = 1;
    end else if (a.e.instr0.op.load == 1 && ((v.instr0.op.rden1 == 1 && a.e.instr0.waddr == v.instr0.raddr1) || (v.instr0.op.rden2 == 1 && a.e.instr0.waddr == v.instr0.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.instr1.op.load == 1 && ((v.instr0.op.rden1 == 1 && a.e.instr1.waddr == v.instr0.raddr1) || (v.instr0.op.rden2 == 1 && a.e.instr1.waddr == v.instr0.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.instr0.op.load == 1 && ((v.instr1.op.rden1 == 1 && a.e.instr0.waddr == v.instr1.raddr1) || (v.instr1.op.rden2 == 1 && a.e.instr0.waddr == v.instr1.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.instr1.op.load == 1 && ((v.instr1.op.rden1 == 1 && a.e.instr1.waddr == v.instr1.raddr1) || (v.instr1.op.rden2 == 1 && a.e.instr1.waddr == v.instr1.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.instr0.op.fload == 1 && ((v.instr0.op.frden1 == 1 && a.e.instr0.waddr == v.instr0.raddr1) || (v.instr0.op.frden2 == 1 && a.e.instr0.waddr == v.instr0.raddr2) || (v.instr0.op.frden3 == 1 && a.e.instr0.waddr == v.instr0.raddr3))) begin 
      v.stall = 1;
    end

    v.instr0.op_b = v.instr0.op;
    v.instr1.op_b = v.instr1.op;

    if ((v.stall | a.e.stall | a.m.stall) == 1) begin
      v.instr0.op = init_operation;
      v.instr1.op = init_operation;
    end

    if ((a.f.taken & v.instr0.op.branch) == 1) begin
      v.instr1 = init_instruction;
    end

    if (v.clear == 1) begin
      v.instr0 = init_instruction;
      v.instr1 = init_instruction;
    end

    if (v.clear == 1) begin
      v.halt = 0;
      v.stall = 0;
    end

    rin = v;

    y.instr0 = v.instr0;
    y.instr1 = v.instr1;
    y.swap = v.swap;
    y.halt = v.halt;
    y.stall = v.stall;

    q.instr0 = r.instr0;
    q.instr1 = r.instr1;
    q.swap = r.swap;
    q.halt = r.halt;
    q.stall = r.stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_issue_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
