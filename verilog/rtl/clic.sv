import configure::*;
import constants::*;
import wires::*;

module clic (
    input logic reset,
    input logic clock,
    input mem_in_type clic_in,
    output mem_out_type clic_out,
    output logic [0 : 0] clic_meip,
    output logic [11 : 0] clic_meid,
    input logic [31 : 0] clic_irpt
);
  timeunit 1ns; timeprecision 1ps;

  localparam clic_interrupt = 32;
  localparam clic_trigger = 32;
  localparam clic_intctlbit = 8;

  localparam clic_cfg_start = 0;
  localparam clic_cfg_end = clic_cfg_start + 1;
  localparam clic_info_start = 4;
  localparam clic_info_end = clic_info_start + 4;
  localparam clic_trig_start = 64;
  localparam clic_trig_end = clic_trig_start + clic_trigger * 4;
  localparam clic_int_start = 4096;
  localparam clic_int_end = clic_int_start + clic_interrupt * 4;

  typedef struct packed {
    logic [1 : 0] nmbits;
    logic [3 : 0] nlbits;
    logic [0 : 0] nvbits;
  } clic_cfg_type;

  parameter clic_cfg_type init_clic_cfg = '{nmbits : 0, nlbits : 0, nvbits : 0};

  typedef struct packed {
    logic [5 : 0]  num_trigger;
    logic [3 : 0]  num_intctlbit;
    logic [3 : 0]  arch_version;
    logic [3 : 0]  impl_version;
    logic [12 : 0] num_interrupt;
  } clic_info_type;

  parameter clic_info_type init_clic_info = '{
      num_trigger : clic_trigger,
      num_intctlbit : clic_intctlbit,
      arch_version : 0,
      impl_version : 0,
      num_interrupt : clic_interrupt
  };

  typedef struct packed {
    logic [0 : 0]  enable;
    logic [12 : 0] num_interrupt;
  } clic_trig_type;

  parameter clic_trig_type init_clic_trig = '{enable : 0, num_interrupt : 0};

  typedef struct packed {
    logic [1 : 0] mode;
    logic [1 : 0] trig;
    logic [0 : 0] shv;
  } clic_attr_type;

  parameter clic_attr_type init_clic_attr = '{mode : 0, trig : 0, shv : 0};

  clic_cfg_type clic_cfg;
  clic_info_type clic_info = init_clic_info;

  clic_trig_type clic_int_trig[0:clic_trigger-1];

  clic_attr_type clic_int_attr[0:clic_interrupt-1];

  logic [0 : 0] clic_irpt_reg[0:clic_interrupt-1];

  logic [0 : 0] clic_int_ip[0:clic_interrupt-1];
  logic [0 : 0] clic_int_ie[0:clic_interrupt-1];
  logic [7 : 0] clic_int_ctl[0:clic_interrupt-1];

  logic [0 : 0] clic_int_ip_reg[0:clic_interrupt-1];
  logic [0 : 0] clic_int_ie_reg[0:clic_interrupt-1];
  logic [7 : 0] clic_int_ctl_reg[0:clic_interrupt-1];

  logic [63 : 0] rdata_cfg = 0;
  logic [63 : 0] rdata_info = 0;
  logic [63 : 0] rdata_trig = 0;
  logic [63 : 0] rdata_irpt = 0;

  logic [0 : 0] ready_cfg = 0;
  logic [0 : 0] ready_info = 0;
  logic [0 : 0] ready_trig = 0;
  logic [0 : 0] ready_irpt = 0;

  logic [7 : 0] prio[0:clic_interrupt-1];
  logic [7 : 0] level[0:clic_interrupt-1];

  logic [11 : 0] max_id[0:clic_interrupt-1];
  logic [7 : 0] max_prio[0:clic_interrupt-1];
  logic [7 : 0] max_level[0:clic_interrupt-1];

  logic [0 : 0] meip = 0;
  logic [11 : 0] meid = 0;

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      rdata_cfg <= 0;
      ready_cfg <= 0;
    end else begin
      rdata_cfg <= 0;
      ready_cfg <= 0;
      if (clic_in.mem_valid == 1) begin
        if (clic_in.mem_addr < clic_cfg_end) begin
          if (|clic_in.mem_wstrb == 0) begin
            rdata_cfg[6:5] <= clic_cfg.nmbits;
            rdata_cfg[4:1] <= clic_cfg.nlbits;
            rdata_cfg[0:0] <= clic_cfg.nvbits;
          end else begin
            clic_cfg.nmbits <= clic_in.mem_wdata[6:5];
            clic_cfg.nlbits <= clic_in.mem_wdata[4:1];
            clic_cfg.nvbits <= clic_in.mem_wdata[0:0];
          end
          ready_cfg <= 1;
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      rdata_info <= 0;
      ready_info <= 0;
    end else begin
      rdata_info <= 0;
      ready_info <= 0;
      if (clic_in.mem_valid == 1) begin
        if (clic_in.mem_addr >= clic_info_start && clic_in.mem_addr < clic_info_end) begin
          if (|clic_in.mem_wstrb == 0) begin
            rdata_info[30:25] <= clic_info.num_trigger;
            rdata_info[24:21] <= clic_info.num_intctlbit;
            rdata_info[20:17] <= clic_info.arch_version;
            rdata_info[16:13] <= clic_info.impl_version;
            rdata_info[12:0]  <= clic_info.num_interrupt;
          end
          ready_info <= 1;
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      rdata_trig <= 0;
      ready_trig <= 0;
    end else begin
      rdata_trig <= 0;
      ready_trig <= 0;
      if (clic_in.mem_valid == 1) begin
        if (clic_in.mem_addr >= clic_trig_start && clic_in.mem_addr < clic_trig_end) begin
          if (|clic_in.mem_wstrb == 0) begin
            rdata_trig[31] <= clic_int_trig[clic_in.mem_addr[$clog2(clic_trigger)+1:2]].enable;
            rdata_trig[12:0] <= clic_int_trig[clic_in.mem_addr[$clog2(
                clic_trigger
            )+1:2]].num_interrupt;
          end else begin
            clic_int_trig[clic_in.mem_addr[$clog2(
                clic_trigger
            )+1:2]].enable <= clic_in.mem_wdata[31];
            clic_int_trig[clic_in.mem_addr[$clog2(
                clic_trigger
            )+1:2]].num_interrupt <= clic_in.mem_wdata[12:0];
          end
          ready_trig <= 1;
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      rdata_irpt <= 0;
      ready_irpt <= 0;
    end else begin
      rdata_irpt <= 0;
      ready_irpt <= 0;
      if (clic_in.mem_valid == 1) begin
        if (clic_in.mem_addr >= clic_int_start && clic_in.mem_addr < clic_int_end) begin
          if (|clic_in.mem_wstrb == 0) begin
            rdata_irpt[0:0]   <= clic_int_ip[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]];
            rdata_irpt[8:8]   <= clic_int_ie[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]];
            rdata_irpt[16:16] <= clic_int_attr[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]].shv;
            rdata_irpt[18:17] <= clic_int_attr[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]].trig;
            rdata_irpt[23:22] <= clic_int_attr[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]].mode;
            rdata_irpt[31:24] <= clic_int_ctl[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]];
          end else begin
            if (clic_in.mem_wstrb[0] == 1 && clic_int_attr[clic_in.mem_addr[$clog2(
                    clic_interrupt
                )+1:2]].trig[0] == 1) begin
              clic_int_ip[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]] <= clic_in.mem_wdata[0:0];
            end
            if (clic_in.mem_wstrb[1] == 1) begin
              clic_int_ie[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]] <= clic_in.mem_wdata[8:8];
            end
            if (clic_in.mem_wstrb[2] == 1) begin
              clic_int_attr[clic_in.mem_addr[$clog2(
                  clic_interrupt
              )+1:2]].shv <= clic_in.mem_wdata[16:16];
              clic_int_attr[clic_in.mem_addr[$clog2(
                  clic_interrupt
              )+1:2]].trig <= clic_in.mem_wdata[18:17];
              clic_int_attr[clic_in.mem_addr[$clog2(
                  clic_interrupt
              )+1:2]].mode <= clic_in.mem_wdata[23:22];
            end
            if (clic_in.mem_wstrb[3] == 1) begin
              clic_int_ctl[clic_in.mem_addr[$clog2(clic_interrupt)+1:2]] <=
                  clic_in.mem_wdata[31:24];
            end
          end
          ready_irpt <= 1;
        end
      end
      for (int i = 0; i < clic_interrupt; i = i + 1) begin
        if (clic_int_attr[i].trig[0] == 0) begin
          if (clic_irpt[i] == 1) begin
            clic_int_ip[i][0] <= 1;
          end else if (clic_irpt[i] == 0) begin
            clic_int_ip[i][0] <= 0;
          end
        end else if (clic_int_attr[i].trig[0] == 1) begin
          if (clic_int_attr[i].trig[1] == 0) begin
            if (clic_irpt_reg[i] == 0 && clic_irpt[i] == 1) begin
              clic_int_ip[i][0] <= 1;
            end
          end else if (clic_int_attr[i].trig[1] == 1) begin
            if (clic_irpt_reg[i] == 1 && clic_irpt[i] == 0) begin
              clic_int_ip[i][0] <= 1;
            end
          end
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      clic_irpt_reg <= '{default: '0};
      clic_int_ip_reg <= '{default: '0};
      clic_int_ie_reg <= '{default: '0};
      clic_int_ctl_reg <= '{default: '0};
    end else begin
      for (int i = 0; i < clic_interrupt; i = i + 1) begin
        clic_irpt_reg[i] <= clic_irpt[i];
        clic_int_ip_reg[i] <= clic_int_ip[i];
        clic_int_ie_reg[i] <= clic_int_ie[i];
        clic_int_ctl_reg[i] <= clic_int_ctl[i];
      end
    end
  end

  always_comb begin
    prio  = '{default: '0};
    level = '{default: '0};
    for (int i = 1; i < clic_interrupt; i = i + 1) begin
      if (clic_cfg.nlbits >= clic_info.num_intctlbit) begin
        prio[i] = 8'hFF;
        for (int j = 0; j < 8; j = j + 1) begin
          if (j < clic_info.num_intctlbit) begin
            level[i][j] = 1;
          end else begin
            level[i][j] = clic_int_ctl_reg[i][j];
          end
        end
      end else if (clic_cfg.nlbits < clic_info.num_intctlbit) begin
        for (int j = 0; j < 8; j = j + 1) begin
          if (j < clic_info.num_intctlbit) begin
            prio[i][j] = 1;
          end else begin
            prio[i][j] = clic_int_ctl_reg[i][j];
          end
        end
        for (int j = 0; j < 8; j = j + 1) begin
          if (j < clic_cfg.nlbits) begin
            level[i][j] = 1;
          end else begin
            level[i][j] = clic_int_ctl_reg[i][j];
          end
        end
      end
      prio[i]  = {8{clic_int_ip_reg[i][0]}} & prio[i];
      prio[i]  = {8{clic_int_ie_reg[i][0]}} & prio[i];
      level[i] = {8{clic_int_ip_reg[i][0]}} & level[i];
      level[i] = {8{clic_int_ie_reg[i][0]}} & level[i];
    end
  end

  always_comb begin
    max_id = '{default: '0};
    max_prio = '{default: '0};
    max_level = '{default: '0};
    for (int i = 1; i < clic_interrupt; i = i + 1) begin
      if (level[i] > max_level[i-1] || (level[i] == max_level[i-1] && prio[i] > max_prio[i-1])) begin
        max_id[i] = i[11:0];
        max_prio[i] = prio[i];
        max_level[i] = level[i];
      end else begin
        max_id[i] = max_id[i-1];
        max_prio[i] = max_prio[i-1];
        max_level[i] = max_level[i-1];
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      meip <= 0;
      meid <= 0;
    end else begin
      if (max_id[clic_interrupt-1] > 0) begin
        meip <= 1;
        meid <= max_id[clic_interrupt-1];
      end else begin
        meip <= 0;
        meid <= 0;
      end
    end
  end

  assign clic_out.mem_rdata = (ready_cfg == 1) ? rdata_cfg :
                              (ready_info == 1) ? rdata_info :
                              (ready_trig == 1) ? rdata_trig :
                              (ready_irpt == 1) ? rdata_irpt : 0;
  assign clic_out.mem_ready = ready_cfg | ready_info | ready_trig | ready_irpt;

  assign clic_meip = meip;
  assign clic_meid = meid;

endmodule
