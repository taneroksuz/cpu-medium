import constants::*;
import wires::*;

module csr
(
  input logic reset,
  input logic clock,
  input csr_read_in_type csr_rin,
  input csr_write_in_type csr_win,
  input csr_exception_in_type csr_ein,
  output csr_out_type csr_out,
  input logic [0:0] meip,
  input logic [0:0] msip,
  input logic [0:0] mtip,
  input logic [63:0] mtime
);
  timeunit 1ns;
  timeprecision 1ps;

  csr_machine_reg_type csr_machine_reg;

  logic [0:0] exception = 0;
  logic [0:0] interrupt = 0;
  logic [0:0] mret = 0;

  always_comb begin
    if (csr_rin.crden == 1) begin
      case (csr_rin.craddr)
        csr_misa : csr_out.cdata = 32'h40001124;
        csr_mvendorid : csr_out.cdata = 32'h00000000;
        csr_marchid : csr_out.cdata = 32'h00000000;
        csr_mimpid : csr_out.cdata = 32'h00000000;
        csr_mhartid : csr_out.cdata = 32'h00000000;
        csr_mstatus : csr_out.cdata = {csr_machine_reg.mstatus.sd,
                                       8'h0,
                                       csr_machine_reg.mstatus.tsr,
                                       csr_machine_reg.mstatus.tw,
                                       csr_machine_reg.mstatus.tvm,
                                       csr_machine_reg.mstatus.mxr,
                                       csr_machine_reg.mstatus.sum,
                                       csr_machine_reg.mstatus.mprv,
                                       csr_machine_reg.mstatus.xs,
                                       csr_machine_reg.mstatus.fs,
                                       csr_machine_reg.mstatus.mpp,
                                       2'h0,
                                       csr_machine_reg.mstatus.spp,
                                       csr_machine_reg.mstatus.mpie,
                                       1'h0,
                                       csr_machine_reg.mstatus.spie,
                                       csr_machine_reg.mstatus.upie,
                                       csr_machine_reg.mstatus.mie,
                                       1'h0,
                                       csr_machine_reg.mstatus.sie,
                                       csr_machine_reg.mstatus.uie};
        csr_mie : csr_out.cdata = {20'h0,
                                   csr_machine_reg.mie.meie,
                                   1'h0,
                                   csr_machine_reg.mie.seie,
                                   csr_machine_reg.mie.ueie,
                                   csr_machine_reg.mie.mtie,
                                   1'h0,
                                   csr_machine_reg.mie.stie,
                                   csr_machine_reg.mie.utie,
                                   csr_machine_reg.mie.msie,
                                   1'h0,
                                   csr_machine_reg.mie.ssie,
                                   csr_machine_reg.mie.usie};
        csr_mtvec : csr_out.cdata = csr_machine_reg.mtvec;
        csr_mscratch : csr_out.cdata = csr_machine_reg.mscratch;
        csr_mepc : csr_out.cdata = csr_machine_reg.mepc;
        csr_mcause : csr_out.cdata = csr_machine_reg.mcause;
        csr_mtval : csr_out.cdata = csr_machine_reg.mtval;
        csr_mip : csr_out.cdata = {20'h0,
                                   csr_machine_reg.mip.meip,
                                   1'h0,
                                   csr_machine_reg.mip.seip,
                                   csr_machine_reg.mip.ueip,
                                   csr_machine_reg.mip.mtip,
                                   1'h0,
                                   csr_machine_reg.mip.stip,
                                   csr_machine_reg.mip.utip,
                                   csr_machine_reg.mip.msip,
                                   1'h0,
                                   csr_machine_reg.mip.ssip,
                                   csr_machine_reg.mip.usip};
        csr_mcycle : csr_out.cdata = csr_machine_reg.mcycle[31:0];
        csr_mcycleh : csr_out.cdata = csr_machine_reg.mcycle[63:32];
        csr_minstret : csr_out.cdata = csr_machine_reg.minstret[31:0];
        csr_minstreth : csr_out.cdata = csr_machine_reg.minstret[63:32];
        default : csr_out.cdata = 0;
      endcase
    end else begin
      csr_out.cdata = 0;
    end

    csr_out.trap = exception | interrupt;
    csr_out.mret = mret;
    csr_out.mepc = csr_machine_reg.mepc;
    if (csr_machine_reg.mtvec[1:0] == 1 && csr_machine_reg.mcause[31] == 1) begin
      csr_out.mtvec = {(csr_machine_reg.mtvec[31:2] + {26'b0,csr_machine_reg.mcause[3:0]}),2'b0};
    end else begin
      csr_out.mtvec = {csr_machine_reg.mtvec[31:2],2'b0};
    end
    csr_out.fs = csr_machine_reg.mstatus.fs;

  end

  always_ff @(posedge clock) begin

    if (reset == 0) begin
      csr_machine_reg <= init_csr_machine_reg;
      exception <= 0;
      interrupt <= 0;
      mret <= 0;
    end else begin
      if (csr_win.cwren == 1) begin
        case (csr_win.cwaddr)
          csr_mstatus : begin
            csr_machine_reg.mstatus.sd <= csr_win.cdata[31];
            csr_machine_reg.mstatus.tsr <= csr_win.cdata[22];
            csr_machine_reg.mstatus.tw <= csr_win.cdata[21];
            csr_machine_reg.mstatus.tvm <= csr_win.cdata[20];
            csr_machine_reg.mstatus.mxr <= csr_win.cdata[19];
            csr_machine_reg.mstatus.sum <= csr_win.cdata[18];
            csr_machine_reg.mstatus.mprv <= csr_win.cdata[17];
            csr_machine_reg.mstatus.xs <= csr_win.cdata[16:15];
            csr_machine_reg.mstatus.fs <= csr_win.cdata[14:13];
            if (csr_win.cdata[12:11] == m_mode || csr_win.cdata[12:11] == u_mode) begin
              csr_machine_reg.mstatus.mpp <= csr_win.cdata[12:11];
            end
            csr_machine_reg.mstatus.spp <= csr_win.cdata[8];
            csr_machine_reg.mstatus.mpie <= csr_win.cdata[7];
            csr_machine_reg.mstatus.spie <= csr_win.cdata[5];
            csr_machine_reg.mstatus.upie <= csr_win.cdata[4];
            csr_machine_reg.mstatus.mie <= csr_win.cdata[3];
            csr_machine_reg.mstatus.sie <= csr_win.cdata[1];
            csr_machine_reg.mstatus.uie <= csr_win.cdata[0];
          end
          csr_mtvec : csr_machine_reg.mtvec <= csr_win.cdata;
          csr_mscratch : csr_machine_reg.mscratch <= csr_win.cdata;
          csr_mepc : csr_machine_reg.mepc <= csr_win.cdata;
          csr_mcause : csr_machine_reg.mcause <= csr_win.cdata;
          csr_mtval : csr_machine_reg.mtval <= csr_win.cdata;
          csr_mie : begin
            csr_machine_reg.mie.meie <= csr_win.cdata[11];
            csr_machine_reg.mie.seie <= csr_win.cdata[9];
            csr_machine_reg.mie.ueie <= csr_win.cdata[8];
            csr_machine_reg.mie.mtie <= csr_win.cdata[7];
            csr_machine_reg.mie.stie <= csr_win.cdata[5];
            csr_machine_reg.mie.ueie <= csr_win.cdata[4];
            csr_machine_reg.mie.msie <= csr_win.cdata[3];
            csr_machine_reg.mie.ssie <= csr_win.cdata[1];
            csr_machine_reg.mie.usie <= csr_win.cdata[0];
          end
          csr_mip : begin
            csr_machine_reg.mip.seip <= csr_win.cdata[9];
            csr_machine_reg.mip.ueip <= csr_win.cdata[8];
            csr_machine_reg.mip.stip <= csr_win.cdata[5];
            csr_machine_reg.mip.ueip <= csr_win.cdata[4];
            csr_machine_reg.mip.ssip <= csr_win.cdata[1];
            csr_machine_reg.mip.usip <= csr_win.cdata[0];
          end
          csr_mcycle : csr_machine_reg.mcycle[31:0] <= csr_win.cdata;
          csr_mcycleh : csr_machine_reg.mcycle[63:32] <= csr_win.cdata;
          csr_minstret : csr_machine_reg.minstret[31:0] <= csr_win.cdata;
          csr_minstreth : csr_machine_reg.minstret[63:32] <= csr_win.cdata;
          default :;
        endcase
      end

      if (csr_ein.valid == 1) begin
        csr_machine_reg.minstret <= csr_machine_reg.minstret + 1;
      end

      if (meip == 1) begin
        csr_machine_reg.mip.meip <= 1;
      end else begin
        csr_machine_reg.mip.meip <= 0;
      end

      if (mtip == 1) begin
        csr_machine_reg.mip.mtip <= 1;
      end else begin
        csr_machine_reg.mip.mtip <= 0;
      end

      if (msip == 1) begin
        csr_machine_reg.mip.msip <= 1;
      end else begin
        csr_machine_reg.mip.msip <= 0;
      end

      csr_machine_reg.mcycle <= csr_machine_reg.mcycle + 1;

      exception <= 0;
      interrupt <= 0;

      if (csr_ein.exception == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mepc <= csr_ein.epc;
        csr_machine_reg.mtval <= csr_ein.etval;
        csr_machine_reg.mcause <= {28'b0,csr_ein.ecause};
        exception <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.meie == 1 &&
                   csr_machine_reg.mip.meip == 1 &&
                   csr_ein.valid == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mepc <= csr_ein.epc;
        csr_machine_reg.mtval <= csr_ein.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_extern};
        interrupt <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.mtie == 1 &&
                   csr_machine_reg.mip.mtip == 1 &&
                   csr_ein.valid == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mepc <= csr_ein.epc;
        csr_machine_reg.mtval <= csr_ein.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_timer};
        interrupt <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.msie == 1 &&
                   csr_machine_reg.mip.msip == 1 &&
                   csr_ein.valid == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mepc <= csr_ein.epc;
        csr_machine_reg.mtval <= csr_ein.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_soft};
        interrupt <= 1;
      end

      mret <= 0;

      if (csr_ein.mret == 1) begin
        csr_machine_reg.mstatus.mie <= csr_machine_reg.mstatus.mpie;
        csr_machine_reg.mstatus.mpie <= 0;
        mret <= 1;
      end

    end

  end

endmodule
