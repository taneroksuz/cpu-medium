import configure::*;
import wires::*;

module cpu
(
  input  logic reset,
  input  logic clock,
  output logic [0  : 0] imemory_valid,
  output logic [0  : 0] imemory_instr,
  output logic [31 : 0] imemory_addr,
  output logic [31 : 0] imemory_wdata,
  output logic [3  : 0] imemory_wstrb,
  input  logic [31 : 0] imemory_rdata,
  input  logic [0  : 0] imemory_ready,
  output logic [0  : 0] dmemory_valid,
  output logic [0  : 0] dmemory_instr,
  output logic [31 : 0] dmemory_addr,
  output logic [31 : 0] dmemory_wdata,
  output logic [3  : 0] dmemory_wstrb,
  input  logic [31 : 0] dmemory_rdata,
  input  logic [0  : 0] dmemory_ready,
  input  logic [0  : 0] meip,
  input  logic [0  : 0] msip,
  input  logic [0  : 0] mtip,
  input  logic [63 : 0] mtime
);
  timeunit 1ns;
  timeprecision 1ps;

  agu_in_type agu_in;
  agu_out_type agu_out;
  alu_in_type alu_in;
  alu_out_type alu_out;
  bcu_in_type bcu_in;
  bcu_out_type bcu_out;
  lsu_in_type lsu_in;
  lsu_out_type lsu_out;
  csr_alu_in_type csr_alu_in;
  csr_alu_out_type csr_alu_out;
  div_in_type div_in;
  div_out_type div_out;
  mul_in_type mul_in;
  mul_out_type mul_out;
  bit_alu_in_type bit_alu_in;
  bit_alu_out_type bit_alu_out;
  bit_clmul_in_type bit_clmul_in;
  bit_clmul_out_type bit_clmul_out;
  bp_in_type bp_in;
  bp_out_type bp_out;
  hazard_in_type hazard_in;
  hazard_out_type hazard_out;
  decoder_in_type decoder_in;
  decoder_out_type decoder_out;
  compress_in_type compress_in;
  compress_out_type compress_out;
  forwarding_register_in_type forwarding_rin;
  forwarding_memory_in_type forwarding_min;
  forwarding_writeback_in_type forwarding_win;
  forwarding_out_type forwarding_out;
  csr_read_in_type csr_rin;
  csr_write_in_type csr_win;
  csr_exception_in_type csr_ein;
  csr_out_type csr_out;
  register_read_in_type register_rin;
  register_write_in_type register_win;
  register_out_type register_out;
  fetch_in_type fetch_in_a;
  buffer_in_type buffer_in_a;
  decode_in_type decode_in_a;
  execute_in_type execute_in_a;
  memory_in_type memory_in_a;
  writeback_in_type writeback_in_a;
  fetch_out_type fetch_out_y;
  buffer_out_type buffer_out_y;
  decode_out_type decode_out_y;
  execute_out_type execute_out_y;
  memory_out_type memory_out_y;
  writeback_out_type writeback_out_y;
  fetch_in_type fetch_in_d;
  buffer_in_type buffer_in_d;
  decode_in_type decode_in_d;
  execute_in_type execute_in_d;
  memory_in_type memory_in_d;
  writeback_in_type writeback_in_d;
  fetch_out_type fetch_out_q;
  buffer_out_type buffer_out_q;
  decode_out_type decode_out_q;
  execute_out_type execute_out_q;
  memory_out_type memory_out_q;
  writeback_out_type writeback_out_q;
  fpu_in_type fpu_in;
  fpu_out_type fpu_out;
  fp_decode_in_type fp_decode_in;
  fp_execute_in_type fp_execute_in;
  fp_register_read_in_type fp_register_rin;
  fp_register_write_in_type fp_register_win;
  fp_csr_read_in_type fp_csr_rin;
  fp_csr_write_in_type fp_csr_win;
  fp_csr_exception_in_type fp_csr_ein;
  fp_forwarding_register_in_type fp_forwarding_rin;
  fp_forwarding_memory_in_type fp_forwarding_min;
  fp_forwarding_writeback_in_type fp_forwarding_win;
  fp_decode_out_type fp_decode_out;
  fp_execute_out_type fp_execute_out;
  fp_register_out_type fp_register_out;
  fp_csr_out_type fp_csr_out;
  fp_forwarding_out_type fp_forwarding_out;
  mem_in_type fetchbuffer_in;
  mem_out_type fetchbuffer_out;
  mem_in_type storebuffer_in;
  mem_out_type storebuffer_out;
  mem_in_type itim_in;
  mem_out_type itim_out;
  mem_in_type dtim_in;
  mem_out_type dtim_out;
  mem_in_type imem_in;
  mem_out_type imem_out;
  mem_in_type dmem_in;
  mem_out_type dmem_out;

  assign fpu_in.fp_decode_in = fp_decode_in;
  assign fpu_in.fp_execute_in = fp_execute_in;
  assign fpu_in.fp_register_rin = fp_register_rin;
  assign fpu_in.fp_register_win = fp_register_win;
  assign fpu_in.fp_csr_rin = fp_csr_rin;
  assign fpu_in.fp_csr_win = fp_csr_win;
  assign fpu_in.fp_csr_ein = fp_csr_ein;
  assign fpu_in.fp_forwarding_rin = fp_forwarding_rin;
  assign fpu_in.fp_forwarding_min = fp_forwarding_min;
  assign fpu_in.fp_forwarding_win = fp_forwarding_win;

  assign fp_decode_out = fpu_out.fp_decode_out;
  assign fp_execute_out = fpu_out.fp_execute_out;
  assign fp_register_out = fpu_out.fp_register_out;
  assign fp_csr_out = fpu_out.fp_csr_out;
  assign fp_forwarding_out = fpu_out.fp_forwarding_out;

  assign fetch_in_a.f = fetch_out_y;
  assign fetch_in_a.b = buffer_out_y;
  assign fetch_in_a.d = decode_out_y;
  assign fetch_in_a.e = execute_out_y;
  assign fetch_in_a.m = memory_out_y;
  assign fetch_in_a.w = writeback_out_y;
  assign buffer_in_a.f = fetch_out_y;
  assign buffer_in_a.b = buffer_out_y;
  assign buffer_in_a.d = decode_out_y;
  assign buffer_in_a.e = execute_out_y;
  assign buffer_in_a.m = memory_out_y;
  assign buffer_in_a.w = writeback_out_y;
  assign decode_in_a.f = fetch_out_y;
  assign decode_in_a.b = buffer_out_y;
  assign decode_in_a.d = decode_out_y;
  assign decode_in_a.e = execute_out_y;
  assign decode_in_a.m = memory_out_y;
  assign decode_in_a.w = writeback_out_y;
  assign execute_in_a.f = fetch_out_y;
  assign execute_in_a.b = buffer_out_y;
  assign execute_in_a.d = decode_out_y;
  assign execute_in_a.e = execute_out_y;
  assign execute_in_a.m = memory_out_y;
  assign execute_in_a.w = writeback_out_y;
  assign memory_in_a.f = fetch_out_y;
  assign memory_in_a.b = buffer_out_y;
  assign memory_in_a.d = decode_out_y;
  assign memory_in_a.e = execute_out_y;
  assign memory_in_a.m = memory_out_y;
  assign memory_in_a.w = writeback_out_y;
  assign writeback_in_a.f = fetch_out_y;
  assign writeback_in_a.b = buffer_out_y;
  assign writeback_in_a.d = decode_out_y;
  assign writeback_in_a.e = execute_out_y;
  assign writeback_in_a.m = memory_out_y;
  assign writeback_in_a.w = writeback_out_y;

  assign fetch_in_d.f = fetch_out_q;
  assign fetch_in_d.b = buffer_out_q;
  assign fetch_in_d.d = decode_out_q;
  assign fetch_in_d.e = execute_out_q;
  assign fetch_in_d.m = memory_out_q;
  assign fetch_in_d.w = writeback_out_q;
  assign buffer_in_d.f = fetch_out_q;
  assign buffer_in_d.b = buffer_out_q;
  assign buffer_in_d.d = decode_out_q;
  assign buffer_in_d.e = execute_out_q;
  assign buffer_in_d.m = memory_out_q;
  assign buffer_in_d.w = writeback_out_q;
  assign decode_in_d.f = fetch_out_q;
  assign decode_in_d.b = buffer_out_q;
  assign decode_in_d.d = decode_out_q;
  assign decode_in_d.e = execute_out_q;
  assign decode_in_d.m = memory_out_q;
  assign decode_in_d.w = writeback_out_q;
  assign execute_in_d.f = fetch_out_q;
  assign execute_in_d.b = buffer_out_q;
  assign execute_in_d.d = decode_out_q;
  assign execute_in_d.e = execute_out_q;
  assign execute_in_d.m = memory_out_q;
  assign execute_in_d.w = writeback_out_q;
  assign memory_in_d.f = fetch_out_q;
  assign memory_in_d.b = buffer_out_q;
  assign memory_in_d.d = decode_out_q;
  assign memory_in_d.e = execute_out_q;
  assign memory_in_d.m = memory_out_q;
  assign memory_in_d.w = writeback_out_q;
  assign writeback_in_d.f = fetch_out_q;
  assign writeback_in_d.b = buffer_out_q;
  assign writeback_in_d.d = decode_out_q;
  assign writeback_in_d.e = execute_out_q;
  assign writeback_in_d.m = memory_out_q;
  assign writeback_in_d.w = writeback_out_q;

  agu agu_comp
  (
    .agu_in (agu_in),
    .agu_out (agu_out)
  );

  alu alu_comp
  (
    .alu_in (alu_in),
    .alu_out (alu_out)
  );

  bcu bcu_comp
  (
    .bcu_in (bcu_in),
    .bcu_out (bcu_out)
  );

  lsu lsu_comp
  (
    .lsu_in (lsu_in),
    .lsu_out (lsu_out)
  );

  csr_alu csr_alu_comp
  (
    .csr_alu_in (csr_alu_in),
    .csr_alu_out (csr_alu_out)
  );

  div div_comp
  (
    .reset (reset),
    .clock (clock),
    .div_in (div_in),
    .div_out (div_out)
  );

  mul mul_comp
  (
    .reset (reset),
    .clock (clock),
    .mul_in (mul_in),
    .mul_out (mul_out)
  );

  bit_alu bit_alu_comp
  (
    .bit_alu_in (bit_alu_in),
    .bit_alu_out (bit_alu_out)
  );

  bit_clmul bit_clmul_comp
  (
    .reset (reset),
    .clock (clock),
    .bit_clmul_in (bit_clmul_in),
    .bit_clmul_out (bit_clmul_out)
  );

  forwarding forwarding_comp
  (
    .forwarding_rin (forwarding_rin),
    .forwarding_win (forwarding_win),
    .forwarding_min (forwarding_min),
    .forwarding_out (forwarding_out)
  );

  bp bp_comp
  (
    .reset (reset),
    .clock (clock),
    .bp_in (bp_in),
    .bp_out (bp_out)
  );

  hazard hazard_comp
  (
    .hazard_in (hazard_in),
    .hazard_out (hazard_out)
  );

  decoder decoder_comp
  (
    .decoder_in (decoder_in),
    .decoder_out (decoder_out)
  );

  compress compress_comp
  (
    .compress_in (compress_in),
    .compress_out (compress_out)
  );

  register register_comp
  (
    .reset (reset),
    .clock (clock),
    .register_rin (register_rin),
    .register_win (register_win),
    .register_out (register_out)
  );

  csr csr_comp
  (
    .reset (reset),
    .clock (clock),
    .csr_rin (csr_rin),
    .csr_win (csr_win),
    .csr_ein (csr_ein),
    .csr_out (csr_out),
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  fetch_stage fetch_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .csr_out (csr_out),
    .bp_out (bp_out),
    .bp_in (bp_in),
    .imem_in (itim_in),
    .a (fetch_in_a),
    .d (fetch_in_d),
    .y (fetch_out_y),
    .q (fetch_out_q)
  );

  buffer_stage buffer_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .hazard_out (hazard_out),
    .hazard_in (hazard_in),
    .imem_out (itim_out),
    .a (buffer_in_a),
    .d (buffer_in_d),
    .y (buffer_out_y),
    .q (buffer_out_q)
  );

  decode_stage decode_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .decoder_out (decoder_out),
    .decoder_in (decoder_in),
    .compress_out (compress_out),
    .compress_in (compress_in),
    .fp_decode_out (fp_decode_out),
    .fp_decode_in (fp_decode_in),
    .register_rin (register_rin),
    .fp_register_rin (fp_register_rin),
    .csr_out (csr_out),
    .csr_rin (csr_rin),
    .fp_csr_out (fp_csr_out),
    .fp_csr_rin (fp_csr_rin),
    .bp_out (bp_out),
    .a (decode_in_a),
    .d (decode_in_d),
    .y (decode_out_y),
    .q (decode_out_q)
  );

  execute_stage execute_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .alu_out (alu_out),
    .alu_in (alu_in),
    .agu_out (agu_out),
    .agu_in (agu_in),
    .bcu_out (bcu_out),
    .bcu_in (bcu_in),
    .csr_alu_out (csr_alu_out),
    .csr_alu_in (csr_alu_in),
    .div_out (div_out),
    .div_in (div_in),
    .mul_out (mul_out),
    .mul_in (mul_in),
    .bit_alu_out (bit_alu_out),
    .bit_alu_in (bit_alu_in),
    .bit_clmul_out (bit_clmul_out),
    .bit_clmul_in (bit_clmul_in),
    .fp_execute_out (fp_execute_out),
    .fp_execute_in (fp_execute_in),
    .register_out (register_out),
    .fp_register_out (fp_register_out),
    .forwarding_out (forwarding_out),
    .forwarding_rin (forwarding_rin),
    .fp_forwarding_out (fp_forwarding_out),
    .fp_forwarding_rin (fp_forwarding_rin),
    .csr_out (csr_out),
    .bp_out (bp_out),
    .a (execute_in_a),
    .d (execute_in_d),
    .y (execute_out_y),
    .q (execute_out_q)
  );

  memory_stage memory_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .lsu_out (lsu_out),
    .lsu_in (lsu_in),
    .dmem_out (dtim_out),
    .dmem_in (dtim_in),
    .forwarding_min (forwarding_min),
    .fp_forwarding_min (fp_forwarding_min),
    .csr_out (csr_out),
    .csr_win (csr_win),
    .csr_ein (csr_ein),
    .fp_csr_out (fp_csr_out),
    .fp_csr_win (fp_csr_win),
    .fp_csr_ein (fp_csr_ein),
    .a (memory_in_a),
    .d (memory_in_d),
    .y (memory_out_y),
    .q (memory_out_q)
  );

  writeback_stage writeback_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .register_win (register_win),
    .fp_register_win (fp_register_win),
    .forwarding_win (forwarding_win),
    .fp_forwarding_win (fp_forwarding_win),
    .a (writeback_in_a),
    .d (writeback_in_d),
    .y (writeback_out_y),
    .q (writeback_out_q)
  );

  itim#(
    .itim_enable (itim_enable)
  ) itim_comp
  (
    .reset (reset),
    .clock (clock),
    .itim_in (itim_in),
    .itim_out (itim_out),
    .imem_out (imem_out),
    .imem_in (imem_in)
  );

  dtim#(
    .dtim_enable (dtim_enable)
  ) dtim_comp
  (
    .reset (reset),
    .clock (clock),
    .dtim_in (dtim_in),
    .dtim_out (dtim_out),
    .dmem_out (dmem_out),
    .dmem_in (dmem_in)
  );

  fpu#(
    .fpu_enable (fpu_enable)
  ) fpu_comp
  (
    .reset (reset),
    .clock (clock),
    .fpu_in (fpu_in),
    .fpu_out (fpu_out)
  );

  assign imemory_valid = imem_in.mem_valid;
  assign imemory_instr = imem_in.mem_instr;
  assign imemory_addr = imem_in.mem_addr;
  assign imemory_wdata = imem_in.mem_wdata;
  assign imemory_wstrb = imem_in.mem_wstrb;
  assign imem_out.mem_rdata = imemory_rdata;
  assign imem_out.mem_ready = imemory_ready;

  assign dmemory_valid = dmem_in.mem_valid;
  assign dmemory_instr = dmem_in.mem_instr;
  assign dmemory_addr = dmem_in.mem_addr;
  assign dmemory_wdata = dmem_in.mem_wdata;
  assign dmemory_wstrb = dmem_in.mem_wstrb;
  assign dmem_out.mem_rdata = dmemory_rdata;
  assign dmem_out.mem_ready = dmemory_ready;

endmodule
