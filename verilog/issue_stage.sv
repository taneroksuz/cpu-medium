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

    v.instr0 = d.d.instr0;
    v.instr1 = d.d.instr1;

    v.instr0.pred.taken = btac_out.pred0.taken;
    v.instr1.pred.taken = btac_out.pred1.taken;
    v.instr0.pred.taddr = btac_out.pred0.taddr;
    v.instr1.pred.taddr = btac_out.pred1.taddr;
    v.instr0.pred.tsat = btac_out.pred0.tsat;
    v.instr1.pred.tsat = btac_out.pred1.tsat;

    hazard_in.instr0 = v.instr0;
    hazard_in.instr1 = v.instr1;
    hazard_in.clear = a.m.calc0.op.fence | csr_out.trap | csr_out.mret | btac_out.pred_miss | d.w.clear;
    hazard_in.stall = d.i.stall | d.e.stall | d.m.stall;

    v.calc0 = hazard_out.calc0;
    v.calc1 = hazard_out.calc1;

    if ((d.i.stall | d.e.stall | d.m.stall) == 1) begin
      v = r;
      v.calc0.op = r.calc0.op_b;
      v.calc1.op = r.calc1.op_b;
    end

    v.halt = hazard_out.stall;
    v.stall = 0;

    v.clear = a.m.calc0.op.fence | csr_out.trap | csr_out.mret | btac_out.pred_miss | d.w.clear;

    if (csr_out.fs == 2'b00) begin
      v.calc0.fmt = 0;
      v.calc0.rm = 0;
      v.calc0.op.fwren = 0;
      v.calc0.op.frden1 = 0;
      v.calc0.op.frden2 = 0;
      v.calc0.op.frden3 = 0;
      v.calc0.op.fload = 0;
      v.calc0.op.fstore = 0;
      v.calc0.op.fpunit = 0;
      v.calc0.op.fpuc = 0;
      v.calc0.op.fpuf = 0;
    end

    if (csr_out.fs == 2'b00) begin
      v.calc1.fmt = 0;
      v.calc1.rm = 0;
      v.calc1.op.fwren = 0;
      v.calc1.op.frden1 = 0;
      v.calc1.op.frden2 = 0;
      v.calc1.op.frden3 = 0;
      v.calc1.op.fload = 0;
      v.calc1.op.fstore = 0;
      v.calc1.op.fpunit = 0;
      v.calc1.op.fpuc = 0;
      v.calc1.op.fpuf = 0;
    end

    if (v.calc0.rm == 3'b111) begin
      v.calc0.rm = fp_csr_out.frm;
    end

    if (v.calc1.rm == 3'b111) begin
      v.calc1.rm = fp_csr_out.frm;
    end

    register0_rin.rden1 = v.calc0.op.rden1;
    register0_rin.rden2 = v.calc0.op.rden2;
    register0_rin.raddr1 = v.calc0.raddr1;
    register0_rin.raddr2 = v.calc0.raddr2;

    register1_rin.rden1 = v.calc1.op.rden1;
    register1_rin.rden2 = v.calc1.op.rden2;
    register1_rin.raddr1 = v.calc1.raddr1;
    register1_rin.raddr2 = v.calc1.raddr2;

    fp_register_rin.rden1 = v.calc0.op.frden1 | v.calc1.op.frden1;
    fp_register_rin.rden2 = v.calc0.op.frden2 | v.calc1.op.frden2;
    fp_register_rin.rden3 = v.calc0.op.frden3 | v.calc1.op.frden3;
    fp_register_rin.raddr1 = v.calc0.op.frden1 ? v.calc0.raddr1 : v.calc1.raddr1;
    fp_register_rin.raddr2 = v.calc0.op.frden2 ? v.calc0.raddr2 : v.calc1.raddr2;
    fp_register_rin.raddr3 = v.calc0.op.frden3 ? v.calc0.raddr3 : v.calc1.raddr3;

    csr_rin.crden = v.calc0.op.crden | v.calc1.op.crden;
    csr_rin.craddr = v.calc0.op.crden ? v.calc0.caddr : v.calc1.caddr;

    fp_csr_rin.crden = v.calc0.op.crden | v.calc1.op.crden;
    fp_csr_rin.craddr = v.calc0.op.crden ? v.calc0.caddr : v.calc1.caddr;

    v.calc0.cdata = (fp_csr_out.ready == 1) ? fp_csr_out.cdata : csr_out.cdata;
    v.calc1.cdata = (fp_csr_out.ready == 1) ? fp_csr_out.cdata : csr_out.cdata;

    if (a.e.calc0.op.cwren == 1 || a.m.calc0.op.cwren == 1 || a.e.calc1.op.cwren == 1 || a.m.calc1.op.cwren == 1) begin
      v.stall = 1;
    end else if (v.calc0.op.crden == 1 && (v.calc0.caddr == csr_fflags || v.calc0.caddr == csr_fcsr) && (a.e.calc0.op.fpuf == 1 || a.m.calc0.op.fpuf == 1 || a.e.calc1.op.fpuf == 1 || a.m.calc1.op.fpuf == 1)) begin
      v.stall = 1;
    end else if (v.calc1.op.crden == 1 && (v.calc1.caddr == csr_fflags || v.calc1.caddr == csr_fcsr) && (a.e.calc0.op.fpuf == 1 || a.m.calc0.op.fpuf == 1 || a.e.calc1.op.fpuf == 1 || a.m.calc1.op.fpuf == 1)) begin
      v.stall = 1;
    end else if (a.e.calc0.op.load == 1 && ((v.calc0.op.rden1 == 1 && a.e.calc0.waddr == v.calc0.raddr1) || (v.calc0.op.rden2 == 1 && a.e.calc0.waddr == v.calc0.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.calc1.op.load == 1 && ((v.calc0.op.rden1 == 1 && a.e.calc1.waddr == v.calc0.raddr1) || (v.calc0.op.rden2 == 1 && a.e.calc1.waddr == v.calc0.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.calc0.op.load == 1 && ((v.calc1.op.rden1 == 1 && a.e.calc0.waddr == v.calc1.raddr1) || (v.calc1.op.rden2 == 1 && a.e.calc0.waddr == v.calc1.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.calc1.op.load == 1 && ((v.calc1.op.rden1 == 1 && a.e.calc1.waddr == v.calc1.raddr1) || (v.calc1.op.rden2 == 1 && a.e.calc1.waddr == v.calc1.raddr2))) begin 
      v.stall = 1;
    end else if (a.e.calc0.op.fload == 1 && ((v.calc0.op.frden1 == 1 && a.e.calc0.waddr == v.calc0.raddr1) || (v.calc0.op.frden2 == 1 && a.e.calc0.waddr == v.calc0.raddr2) || (v.calc0.op.frden3 == 1 && a.e.calc0.waddr == v.calc0.raddr3))) begin 
      v.stall = 1;
    end else if (a.e.calc1.op.fload == 1 && ((v.calc0.op.frden1 == 1 && a.e.calc1.waddr == v.calc0.raddr1) || (v.calc0.op.frden2 == 1 && a.e.calc1.waddr == v.calc0.raddr2) || (v.calc0.op.frden3 == 1 && a.e.calc1.waddr == v.calc0.raddr3))) begin 
      v.stall = 1;
    end else if (a.e.calc0.op.fload == 1 && ((v.calc1.op.frden1 == 1 && a.e.calc0.waddr == v.calc1.raddr1) || (v.calc1.op.frden2 == 1 && a.e.calc0.waddr == v.calc1.raddr2) || (v.calc1.op.frden3 == 1 && a.e.calc0.waddr == v.calc1.raddr3))) begin 
      v.stall = 1;
    end else if (a.e.calc1.op.fload == 1 && ((v.calc1.op.frden1 == 1 && a.e.calc1.waddr == v.calc1.raddr1) || (v.calc1.op.frden2 == 1 && a.e.calc1.waddr == v.calc1.raddr2) || (v.calc1.op.frden3 == 1 && a.e.calc1.waddr == v.calc1.raddr3))) begin 
      v.stall = 1;
    end

    v.calc0.op_b = v.calc0.op;
    v.calc1.op_b = v.calc1.op;

    if ((v.stall | a.e.stall | a.m.stall) == 1) begin
      v.calc0.op = init_operation;
      v.calc1.op = init_operation;
    end

    if (a.e.calc1.op.jump == 1 && (a.e.calc1.npc == v.calc0.pc)) begin
      v.calc0 = init_calculation;
    end
    if (a.e.calc0.op.jump == 1 && (a.e.calc0.npc == v.calc0.pc)) begin
      v.calc0 = init_calculation;
    end

    if (v.clear == 1) begin
      v.calc0 = init_calculation;
      v.calc1 = init_calculation;
    end

    if (v.clear == 1) begin
      v.halt = 0;
      v.stall = 0;
    end

    rin = v;

    y.calc0 = v.calc0;
    y.calc1 = v.calc1;
    y.halt = v.halt;
    y.stall = v.stall;

    q.calc0 = r.calc0;
    q.calc1 = r.calc1;
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
