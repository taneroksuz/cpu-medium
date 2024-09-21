import configure::*;
import constants::*;
import wires::*;

module pmp (
    input logic reset,
    input logic clock,
    output logic pmp_ierror,
    output logic pmp_derror,
    input csr_pmp_in_type csr_pmp_in,
    output csr_pmp_out_type csr_pmp_out,
    input mem_in_type imem_in,
    output mem_out_type imem_out,
    input mem_in_type dmem_in,
    output mem_out_type dmem_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam [1:0] OFF = 0;
  localparam [1:0] TOR = 1;
  localparam [1:0] NA4 = 2;
  localparam [1:0] NAPOT = 3;

  typedef struct packed {
    logic [0 : 0] L;
    logic [1 : 0] A;
    logic [0 : 0] X;
    logic [0 : 0] W;
    logic [0 : 0] R;
  } csr_pmpcfg_type;

  parameter csr_pmpcfg_type init_csr_pmpcfg = '{L : 0, A : 0, X : 0, W : 0, R : 0};

  csr_pmpcfg_type csr_pmpcfg[0:pmp_region-1];

  logic [31 : 0] csr_pmpaddr[0:pmp_region-1];

  logic [0 : 0] ipass;
  logic [0 : 0] icheck;
  logic [0 : 0] ierror;
  logic [0 : 0] iready;

  logic [0 : 0] ierror_reg;
  logic [0 : 0] iready_reg;

  logic [29 : 0] ishifted;
  logic [31 : 0] ilowaddr;
  logic [31 : 0] ihighaddr;

  logic [0 : 0] dpass;
  logic [0 : 0] dcheck;
  logic [0 : 0] derror;
  logic [0 : 0] dready;

  logic [0 : 0] derror_reg;
  logic [0 : 0] dready_reg;

  logic [29 : 0] dshifted;
  logic [31 : 0] dlowaddr;
  logic [31 : 0] dhighaddr;

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      csr_pmpcfg  <= '{default: init_csr_pmpcfg};
      csr_pmpaddr <= '{default: '0};
    end else begin
      if (csr_pmp_in.cwren == 1) begin
        for (int i = 0; i < pmp_region; i = i + 4) begin
          if (csr_pmp_in.cwaddr == (csr_pmpcfg0 + (i[11:0] >> 2))) begin
            if (csr_pmpcfg[i+3].L == 0) begin
              csr_pmpcfg[i+3].L <= csr_pmp_in.cwdata[31];
              csr_pmpcfg[i+3].A <= csr_pmp_in.cwdata[28:27];
              csr_pmpcfg[i+3].X <= csr_pmp_in.cwdata[26];
              csr_pmpcfg[i+3].W <= csr_pmp_in.cwdata[25];
              csr_pmpcfg[i+3].R <= csr_pmp_in.cwdata[24];
            end
            if (csr_pmpcfg[i+2].L == 0) begin
              csr_pmpcfg[i+2].L <= csr_pmp_in.cwdata[23];
              csr_pmpcfg[i+2].A <= csr_pmp_in.cwdata[20:19];
              csr_pmpcfg[i+2].X <= csr_pmp_in.cwdata[18];
              csr_pmpcfg[i+2].W <= csr_pmp_in.cwdata[17];
              csr_pmpcfg[i+2].R <= csr_pmp_in.cwdata[16];
            end
            if (csr_pmpcfg[i+1].L == 0) begin
              csr_pmpcfg[i+1].L <= csr_pmp_in.cwdata[15];
              csr_pmpcfg[i+1].A <= csr_pmp_in.cwdata[12:11];
              csr_pmpcfg[i+1].X <= csr_pmp_in.cwdata[10];
              csr_pmpcfg[i+1].W <= csr_pmp_in.cwdata[9];
              csr_pmpcfg[i+1].R <= csr_pmp_in.cwdata[8];
            end
            if (csr_pmpcfg[i].L == 0) begin
              csr_pmpcfg[i].L <= csr_pmp_in.cwdata[7];
              csr_pmpcfg[i].A <= csr_pmp_in.cwdata[4:3];
              csr_pmpcfg[i].X <= csr_pmp_in.cwdata[2];
              csr_pmpcfg[i].W <= csr_pmp_in.cwdata[1];
              csr_pmpcfg[i].R <= csr_pmp_in.cwdata[0];
            end
          end
        end
        for (int i = 0; i < pmp_region; i = i + 1) begin
          if (csr_pmp_in.cwaddr == (csr_pmpaddr0 + i[11:0])) begin
            if (i == (pmp_region - 1)) begin
              if (csr_pmpcfg[i].L == 0) begin
                csr_pmpaddr[i] <= csr_pmp_in.cwdata;
              end
            end else begin
              if (csr_pmpcfg[i].L == 0 && !(csr_pmpcfg[i+1].L == 1 && csr_pmpcfg[i+1].A == 1)) begin
                csr_pmpaddr[i] <= csr_pmp_in.cwdata;
              end
            end
          end
        end
      end
    end
  end

  always_comb begin
    csr_pmp_out.crdata = 0;
    csr_pmp_out.cready = 0;
    if (csr_pmp_in.crden == 1) begin
      for (int i = 0; i < pmp_region; i = i + 4) begin
        if (csr_pmp_in.craddr == (csr_pmpcfg0 + (i[11:0] >> 2))) begin
          csr_pmp_out.crdata[31:24] = {
            csr_pmpcfg[i+3].L,
            2'b0,
            csr_pmpcfg[i+3].A,
            csr_pmpcfg[i+3].X,
            csr_pmpcfg[i+3].W,
            csr_pmpcfg[i+3].R
          };
          csr_pmp_out.crdata[23:16] = {
            csr_pmpcfg[i+2].L,
            2'b0,
            csr_pmpcfg[i+2].A,
            csr_pmpcfg[i+2].X,
            csr_pmpcfg[i+2].W,
            csr_pmpcfg[i+2].R
          };
          csr_pmp_out.crdata[15:8] = {
            csr_pmpcfg[i+1].L,
            2'b0,
            csr_pmpcfg[i+1].A,
            csr_pmpcfg[i+1].X,
            csr_pmpcfg[i+1].W,
            csr_pmpcfg[i+1].R
          };
          csr_pmp_out.crdata[7:0] = {
            csr_pmpcfg[i].L,
            2'b0,
            csr_pmpcfg[i].A,
            csr_pmpcfg[i].X,
            csr_pmpcfg[i].W,
            csr_pmpcfg[i].R
          };
          csr_pmp_out.cready = 1;
        end
      end
      for (int i = 0; i < pmp_region; i = i + 1) begin
        if (csr_pmp_in.craddr == (csr_pmpaddr0 + i[11:0])) begin
          csr_pmp_out.crdata = csr_pmpaddr[i];
          csr_pmp_out.cready = 1;
        end
      end
    end
  end

  always_comb begin
    ipass = 0;
    icheck = 0;
    ierror = 0;
    iready = 0;
    ishifted = 0;
    ilowaddr = 0;
    ihighaddr = 0;
    if (imem_in.mem_valid == 1) begin
      for (int i = 0; i < pmp_region; i = i + 1) begin
        if (imem_in.mem_instr == 1) begin
          if (csr_pmpcfg[i].L == 1 && csr_pmpcfg[i].X == 1) begin
            icheck = 1;
          end else if (csr_pmpcfg[i].L == 0 && (csr_pmpcfg[i].X == 1 || imem_in.mem_mode == m_mode)) begin
            icheck = 1;
          end
        end
        if (icheck == 1) begin
          if (csr_pmpcfg[i].A == OFF) begin
            continue;
          end
          if (csr_pmpcfg[i].A == TOR) begin
            if (i == 0) begin
              ilowaddr  = 0;
              ihighaddr = csr_pmpaddr[0];
            end else begin
              ilowaddr  = csr_pmpaddr[i-1];
              ihighaddr = csr_pmpaddr[i];
            end
            ihighaddr = ihighaddr - 1;
          end else if (csr_pmpcfg[i].A == NA4) begin
            ilowaddr  = {csr_pmpaddr[i][29:0], 2'h0};
            ihighaddr = {csr_pmpaddr[i][29:0], 2'h3};
          end else if (csr_pmpcfg[i].A == NAPOT) begin
            ishifted  = csr_pmpaddr[i][29:0] + 1;
            ilowaddr  = {(csr_pmpaddr[i][29:0] & ishifted), 2'h0};
            ihighaddr = {(csr_pmpaddr[i][29:0] | ishifted), 2'h3};
          end
          if (ilowaddr <= ihighaddr && imem_in.mem_addr >= ilowaddr && imem_in.mem_addr <= ihighaddr) begin
            ipass = 1;
            break;
          end
        end
      end
      if (ipass == 0 && imem_in.mem_mode != m_mode) begin
        ierror = 1;
        iready = 1;
      end
    end
    pmp_ierror = ierror;
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      ierror_reg <= 0;
      iready_reg <= 0;
    end else begin
      ierror_reg <= ierror;
      iready_reg <= iready;
    end
  end

  assign imem_out.mem_rdata = 0;
  assign imem_out.mem_error = ierror_reg;
  assign imem_out.mem_ready = iready_reg;

  always_comb begin
    dpass = 0;
    dcheck = 0;
    derror = 0;
    dready = 0;
    dshifted = 0;
    dlowaddr = 0;
    dhighaddr = 0;
    if (dmem_in.mem_valid == 1) begin
      for (int i = 0; i < pmp_region; i = i + 1) begin
        if (dmem_in.mem_instr == 0) begin
          if (|dmem_in.mem_wstrb == 1) begin
            if (csr_pmpcfg[i].L == 1 && csr_pmpcfg[i].W == 1) begin
              dcheck = 1;
            end else if (csr_pmpcfg[i].L == 0 && (csr_pmpcfg[i].W == 1 || dmem_in.mem_mode == m_mode)) begin
              dcheck = 1;
            end
          end else if (|dmem_in.mem_wstrb == 0) begin
            if (csr_pmpcfg[i].L == 1 && csr_pmpcfg[i].R == 1) begin
              dcheck = 1;
            end else if (csr_pmpcfg[i].L == 0 && (csr_pmpcfg[i].R == 1 || dmem_in.mem_mode == m_mode)) begin
              dcheck = 1;
            end
          end
        end
        if (dcheck == 1) begin
          if (csr_pmpcfg[i].A == OFF) begin
            continue;
          end
          if (csr_pmpcfg[i].A == TOR) begin
            if (i == 0) begin
              dlowaddr  = 0;
              dhighaddr = csr_pmpaddr[0];
            end else begin
              dlowaddr  = csr_pmpaddr[i-1];
              dhighaddr = csr_pmpaddr[i];
            end
            dhighaddr = dhighaddr - 1;
          end else if (csr_pmpcfg[i].A == NA4) begin
            dlowaddr  = {csr_pmpaddr[i][29:0], 2'h0};
            dhighaddr = {csr_pmpaddr[i][29:0], 2'h3};
          end else if (csr_pmpcfg[i].A == NAPOT) begin
            dshifted  = csr_pmpaddr[i][29:0] + 1;
            dlowaddr  = {(csr_pmpaddr[i][29:0] & dshifted), 2'h0};
            dhighaddr = {(csr_pmpaddr[i][29:0] | dshifted), 2'h3};
          end
          if (dlowaddr <= dhighaddr && dmem_in.mem_addr >= dlowaddr && dmem_in.mem_addr <= dhighaddr) begin
            dpass = 1;
            break;
          end
        end
      end
      if (dpass == 0 && dmem_in.mem_mode != m_mode) begin
        derror = 1;
        dready = 1;
      end
    end
    pmp_derror = derror;
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      derror_reg <= 0;
      dready_reg <= 0;
    end else begin
      derror_reg <= derror;
      dready_reg <= dready;
    end
  end

  assign dmem_out.mem_rdata = 0;
  assign dmem_out.mem_error = derror_reg;
  assign dmem_out.mem_ready = dready_reg;

endmodule
