import constants::*;
import wires::*;
import functions::*;
import fp_wire::*;

module buffer_stage
(
  input logic reset,
  input logic clock,
  input hazard_out_type hazard_out,
  output hazard_in_type hazard_in,
  input mem_out_type imem_out,
  input buffer_in_type a,
  input buffer_in_type d,
  output buffer_out_type y,
  output buffer_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  buffer_reg_type r,rin;
  buffer_reg_type v;

  always_comb begin

    v = r;

    v.pc = d.f.pc;

    v.stall = 0;

    hazard_in.rdata = {nop_instr,imem_out.mem_rdata};
    hazard_in.ready = imem_out.mem_ready;

    v.instr0 = hazard_out.instr0;
    v.instr1 = hazard_out.instr1;

    if (imem_out.mem_ready == 1) begin
      v.npc = v.pc + ((v.instr0[1:0] == 2'b11) ? 4 : 2);
    end

    if ((d.e.jump | d.e.fence | d.e.mret | d.e.exception) == 1) begin
      v.clear = ~imem_out.mem_ready;
    end

    if ((v.stall | a.d.stall | a.e.stall | a.m.stall | a.e.jump | a.e.fence | a.e.mret | a.e.exception | v.clear) == 1) begin
      v.instr0 = nop_instr;
      v.instr1 = nop_instr;
      v.clear = ~imem_out.mem_ready;
    end

    rin = v;

    y.pc = v.pc;
    y.npc = v.npc;
    y.instr = v.instr0;

    q.pc = r.pc;
    q.npc = r.npc;
    q.instr = r.instr0;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_buffer_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
