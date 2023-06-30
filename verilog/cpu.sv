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

  alu_in_type alu0_in;
  alu_out_type alu0_out;
  alu_in_type alu1_in;
  alu_out_type alu1_out;
  agu_in_type agu0_in;
  agu_out_type agu0_out;
  agu_in_type agu1_in;
  agu_out_type agu1_out;
  bcu_in_type bcu_in;
  bcu_out_type bcu_out;
  lsu_in_type lsu0_in;
  lsu_out_type lsu0_out;
  lsu_in_type lsu1_in;
  lsu_out_type lsu1_out;
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
  btac_in_type btac_in;
  btac_out_type btac_out;
  hazard_in_type hazard_in;
  hazard_out_type hazard_out;
  decoder_in_type decoder0_in;
  decoder_out_type decoder0_out;
  decoder_in_type decoder1_in;
  decoder_out_type decoder1_out;
  forwarding_register_in_type forwarding0_rin;
  forwarding_register_in_type forwarding1_rin;
  forwarding_memory_in_type forwarding0_min;
  forwarding_memory_in_type forwarding1_min;
  forwarding_writeback_in_type forwarding0_win;
  forwarding_writeback_in_type forwarding1_win;
  forwarding_out_type forwarding0_out;
  forwarding_out_type forwarding1_out;
  csr_read_in_type csr_rin;
  csr_write_in_type csr_win;
  csr_exception_in_type csr_ein;
  csr_out_type csr_out;
  register_read_in_type register0_rin;
  register_read_in_type register1_rin;
  register_write_in_type register0_win;
  register_write_in_type register1_win;
  register_out_type register0_out;
  register_out_type register1_out;
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
  itim_in_type itim_in;
  itim_out_type itim_out;
  dtim_in_type dtim0_in;
  dtim_out_type dtim0_out;
  dtim_in_type dtim1_in;
  dtim_out_type dtim1_out;
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

  alu alu0_comp
  (
    .alu_in (alu0_in),
    .alu_out (alu0_out)
  );

  alu alu1_comp
  (
    .alu_in (alu1_in),
    .alu_out (alu1_out)
  );

  agu agu0_comp
  (
    .agu_in (agu0_in),
    .agu_out (agu0_out)
  );

  agu agu1_comp
  (
    .agu_in (agu1_in),
    .agu_out (agu1_out)
  );

  bcu bcu_comp
  (
    .bcu_in (bcu_in),
    .bcu_out (bcu_out)
  );

  lsu lsu0_comp
  (
    .lsu_in (lsu0_in),
    .lsu_out (lsu0_out)
  );

  lsu lsu1_comp
  (
    .lsu_in (lsu1_in),
    .lsu_out (lsu1_out)
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
    .forwarding0_rin (forwarding0_rin),
    .forwarding1_rin (forwarding1_rin),
    .forwarding0_win (forwarding0_win),
    .forwarding1_win (forwarding1_win),
    .forwarding0_min (forwarding0_min),
    .forwarding1_min (forwarding1_min),
    .forwarding0_out (forwarding0_out),
    .forwarding1_out (forwarding1_out)
  );

  btac btac_comp
  (
    .reset (reset),
    .clock (clock),
    .btac_in (btac_in),
    .btac_out (btac_out)
  );

  hazard hazard_comp
  (
    .reset (reset),
    .clock (clock),
    .hazard_in (hazard_in),
    .hazard_out (hazard_out)
  );

  decoder decoder0_comp
  (
    .decoder_in (decoder0_in),
    .decoder_out (decoder0_out)
  );

  decoder decoder1_comp
  (
    .decoder_in (decoder1_in),
    .decoder_out (decoder1_out)
  );

  register register_comp
  (
    .reset (reset),
    .clock (clock),
    .register0_rin (register0_rin),
    .register1_rin (register1_rin),
    .register0_win (register0_win),
    .register1_win (register1_win),
    .register0_out (register0_out),
    .register1_out (register1_out)
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
    .btac_out (btac_out),
    .btac_in (btac_in),
    .imem_out (itim_out),
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
    .csr_out (csr_out),
    .btac_out (btac_out),
    .a (buffer_in_a),
    .d (buffer_in_d),
    .y (buffer_out_y),
    .q (buffer_out_q)
  );

  decode_stage decode_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .decoder0_out (decoder0_out),
    .decoder0_in (decoder0_in),
    .decoder1_out (decoder1_out),
    .decoder1_in (decoder1_in),
    .fp_decode_out (fp_decode_out),
    .fp_decode_in (fp_decode_in),
    .register0_rin (register0_rin),
    .register1_rin (register1_rin),
    .fp_register_rin (fp_register_rin),
    .csr_out (csr_out),
    .csr_rin (csr_rin),
    .fp_csr_out (fp_csr_out),
    .fp_csr_rin (fp_csr_rin),
    .btac_out (btac_out),
    .a (decode_in_a),
    .d (decode_in_d),
    .y (decode_out_y),
    .q (decode_out_q)
  );

  execute_stage execute_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .alu0_out (alu0_out),
    .alu0_in (alu0_in),
    .alu1_out (alu1_out),
    .alu1_in (alu1_in),
    .agu0_out (agu0_out),
    .agu0_in (agu0_in),
    .agu1_out (agu1_out),
    .agu1_in (agu1_in),
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
    .register0_out (register0_out),
    .register1_out (register1_out),
    .fp_register_out (fp_register_out),
    .forwarding0_out (forwarding0_out),
    .forwarding1_out (forwarding1_out),
    .forwarding0_rin (forwarding0_rin),
    .forwarding1_rin (forwarding1_rin),
    .fp_forwarding_out (fp_forwarding_out),
    .fp_forwarding_rin (fp_forwarding_rin),
    .csr_out (csr_out),
    .btac_out (btac_out),
    .a (execute_in_a),
    .d (execute_in_d),
    .y (execute_out_y),
    .q (execute_out_q)
  );

  memory_stage memory_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .lsu0_out (lsu0_out),
    .lsu0_in (lsu0_in),
    .lsu1_out (lsu1_out),
    .lsu1_in (lsu1_in),
    .dmem0_out (dtim0_out),
    .dmem0_in (dtim0_in),
    .dmem1_out (dtim1_out),
    .dmem1_in (dtim1_in),
    .forwarding0_min (forwarding0_min),
    .forwarding1_min (forwarding1_min),
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
    .register0_win (register0_win),
    .register1_win (register1_win),
    .fp_register_win (fp_register_win),
    .forwarding0_win (forwarding0_win),
    .forwarding1_win (forwarding1_win),
    .fp_forwarding_win (fp_forwarding_win),
    .a (writeback_in_a),
    .d (writeback_in_d),
    .y (writeback_out_y),
    .q (writeback_out_q)
  );

  itim itim_comp
  (
    .reset (reset),
    .clock (clock),
    .itim_in (itim_in),
    .itim_out (itim_out),
    .imem_out (imem_out),
    .imem_in (imem_in)
  );

  dtim dtim_comp
  (
    .reset (reset),
    .clock (clock),
    .dtim0_in (dtim0_in),
    .dtim0_out (dtim0_out),
    .dtim1_in (dtim1_in),
    .dtim1_out (dtim1_out),
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
