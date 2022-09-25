import constants::*;
import wires::*;

module csr
(
  input logic rst,
  input logic clk,
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

  csr_user_reg_type csr_user_reg;

  logic [0:0] exception = 0;
  logic [0:0] mret = 0;

  always_comb begin
    if (csr_rin.crden == 1) begin
      case (csr_rin.craddr)
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
        csr_misa : csr_out.cdata = {csr_machine_reg.misa.mxl,
                                    4'h0,
                                    csr_machine_reg.misa.z,
                                    csr_machine_reg.misa.y,
                                    csr_machine_reg.misa.x,
                                    csr_machine_reg.misa.w,
                                    csr_machine_reg.misa.v,
                                    csr_machine_reg.misa.u,
                                    csr_machine_reg.misa.t,
                                    csr_machine_reg.misa.s,
                                    csr_machine_reg.misa.r,
                                    csr_machine_reg.misa.q,
                                    csr_machine_reg.misa.p,
                                    csr_machine_reg.misa.o,
                                    csr_machine_reg.misa.n,
                                    csr_machine_reg.misa.m,
                                    csr_machine_reg.misa.l,
                                    csr_machine_reg.misa.k,
                                    csr_machine_reg.misa.j,
                                    csr_machine_reg.misa.i,
                                    csr_machine_reg.misa.h,
                                    csr_machine_reg.misa.g,
                                    csr_machine_reg.misa.f,
                                    csr_machine_reg.misa.e,
                                    csr_machine_reg.misa.d,
                                    csr_machine_reg.misa.c,
                                    csr_machine_reg.misa.b,
                                    csr_machine_reg.misa.a};
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
        csr_fflags : csr_out.cdata = {27'h0,csr_user_reg.fflags};
        csr_frm : csr_out.cdata = {29'h0,csr_user_reg.frm};
        csr_fcsr : csr_out.cdata = {24'h0,csr_user_reg.frm,csr_user_reg.fflags};
        default : csr_out.cdata = 0;
      endcase
    end else begin
      csr_out.cdata = 0;
    end

    csr_out.exception = exception;
    csr_out.mret = mret;
    csr_out.mepc = csr_machine_reg.mepc;
    if (csr_machine_reg.mtvec[1:0] == 1) begin
      csr_out.mtvec = {(csr_machine_reg.mtvec[31:2] + {26'b0,csr_machine_reg.mcause[3:0]}),2'b0};
    end else begin
      csr_out.mtvec = {csr_machine_reg.mtvec[31:2],2'b0};
    end
    csr_out.frm = csr_user_reg.frm;

  end

  always_ff @(posedge clk) begin

    if (rst == 0) begin
      csr_machine_reg <= init_csr_machine_reg;
      csr_user_reg <= init_csr_user_reg;
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
            csr_machine_reg.mstatus.mpp <= csr_win.cdata[12:11];
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
          csr_fflags : csr_user_reg.fflags <= csr_win.cdata[4:0];
          csr_frm : csr_user_reg.frm <= csr_win.cdata[2:0];
          csr_fcsr : begin
            csr_user_reg.fflags <= csr_win.cdata[4:0];
            csr_user_reg.frm <= csr_win.cdata[7:5];
          end
          default :;
        endcase
      end

      if (csr_ein.valid == 1) begin
        csr_machine_reg.minstret <= csr_machine_reg.minstret + 1;
      end

      if (csr_ein.fpu == 1) begin
        csr_user_reg.fflags <= csr_ein.fflags;
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
        exception <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.mtie == 1 &&
                   csr_machine_reg.mip.mtip == 1 &&
                   csr_ein.valid == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mepc <= csr_ein.epc;
        csr_machine_reg.mtval <= csr_ein.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_timer};
        exception <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.msie == 1 &&
                   csr_machine_reg.mip.msip == 1 &&
                   csr_ein.valid == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mepc <= csr_ein.epc;
        csr_machine_reg.mtval <= csr_ein.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_soft};
        exception <= 1;
      end else begin
        exception <= 0;
      end

      if (csr_ein.mret == 1) begin
        csr_machine_reg.mstatus.mie <= csr_machine_reg.mstatus.mpie;
        csr_machine_reg.mstatus.mpie <= 0;
        mret <= 1;
      end else begin
        mret <= 0;
      end

    end

  end

endmodule
