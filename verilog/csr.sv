import constants::*;
import wires::*;

module csr
(
  input logic rst,
  input logic clk,
  input csr_decode_in_type csr_din,
  input csr_execute_in_type csr_ein,
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
  logic [0:0] mret = 0;

  always_comb begin
    if (csr_din.crden == 1) begin
      case (csr_din.craddr)
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

  end

  always_ff @(posedge clk) begin

    if (rst == 0) begin
      csr_machine_reg <= init_csr_machine_reg;
    end else begin
      if (csr_ein.cwren == 1) begin
        case (csr_ein.cwaddr)
          csr_mstatus : begin
            csr_machine_reg.mstatus.sd <= csr_ein.cdata[31];
            csr_machine_reg.mstatus.tsr <= csr_ein.cdata[22];
            csr_machine_reg.mstatus.tw <= csr_ein.cdata[21];
            csr_machine_reg.mstatus.tvm <= csr_ein.cdata[20];
            csr_machine_reg.mstatus.mxr <= csr_ein.cdata[19];
            csr_machine_reg.mstatus.sum <= csr_ein.cdata[18];
            csr_machine_reg.mstatus.mprv <= csr_ein.cdata[17];
            csr_machine_reg.mstatus.xs <= csr_ein.cdata[16:15];
            csr_machine_reg.mstatus.fs <= csr_ein.cdata[14:13];
            csr_machine_reg.mstatus.mpp <= csr_ein.cdata[12:11];
            csr_machine_reg.mstatus.spp <= csr_ein.cdata[8];
            csr_machine_reg.mstatus.mpie <= csr_ein.cdata[7];
            csr_machine_reg.mstatus.spie <= csr_ein.cdata[5];
            csr_machine_reg.mstatus.upie <= csr_ein.cdata[4];
            csr_machine_reg.mstatus.mie <= csr_ein.cdata[3];
            csr_machine_reg.mstatus.sie <= csr_ein.cdata[1];
            csr_machine_reg.mstatus.uie <= csr_ein.cdata[0];
          end
          csr_misa : begin
            csr_machine_reg.misa.mxl <= csr_ein.cdata[31:30];
            csr_machine_reg.misa.z <= csr_ein.cdata[25];
            csr_machine_reg.misa.y <= csr_ein.cdata[24];
            csr_machine_reg.misa.x <= csr_ein.cdata[23];
            csr_machine_reg.misa.w <= csr_ein.cdata[22];
            csr_machine_reg.misa.v <= csr_ein.cdata[21];
            csr_machine_reg.misa.u <= csr_ein.cdata[20];
            csr_machine_reg.misa.t <= csr_ein.cdata[19];
            csr_machine_reg.misa.s <= csr_ein.cdata[18];
            csr_machine_reg.misa.r <= csr_ein.cdata[17];
            csr_machine_reg.misa.q <= csr_ein.cdata[16];
            csr_machine_reg.misa.p <= csr_ein.cdata[15];
            csr_machine_reg.misa.o <= csr_ein.cdata[14];
            csr_machine_reg.misa.n <= csr_ein.cdata[13];
            csr_machine_reg.misa.m <= csr_ein.cdata[12];
            csr_machine_reg.misa.l <= csr_ein.cdata[11];
            csr_machine_reg.misa.k <= csr_ein.cdata[10];
            csr_machine_reg.misa.j <= csr_ein.cdata[9];
            csr_machine_reg.misa.i <= csr_ein.cdata[8];
            csr_machine_reg.misa.h <= csr_ein.cdata[7];
            csr_machine_reg.misa.g <= csr_ein.cdata[6];
            csr_machine_reg.misa.f <= csr_ein.cdata[5];
            csr_machine_reg.misa.e <= csr_ein.cdata[4];
            csr_machine_reg.misa.d <= csr_ein.cdata[3];
            csr_machine_reg.misa.c <= csr_ein.cdata[2];
            csr_machine_reg.misa.b <= csr_ein.cdata[1];
            csr_machine_reg.misa.a <= csr_ein.cdata[0];
          end
          csr_mtvec : csr_machine_reg.mtvec <= csr_ein.cdata;
          csr_mscratch : csr_machine_reg.mscratch <= csr_ein.cdata;
          csr_mepc : csr_machine_reg.mepc <= csr_ein.cdata;
          csr_mcause : csr_machine_reg.mcause <= csr_ein.cdata;
          csr_mtval : csr_machine_reg.mtval <= csr_ein.cdata;
          csr_mie : begin
            csr_machine_reg.mie.meie <= csr_ein.cdata[11];
            csr_machine_reg.mie.seie <= csr_ein.cdata[9];
            csr_machine_reg.mie.ueie <= csr_ein.cdata[8];
            csr_machine_reg.mie.mtie <= csr_ein.cdata[7];
            csr_machine_reg.mie.stie <= csr_ein.cdata[5];
            csr_machine_reg.mie.ueie <= csr_ein.cdata[4];
            csr_machine_reg.mie.msie <= csr_ein.cdata[3];
            csr_machine_reg.mie.ssie <= csr_ein.cdata[1];
            csr_machine_reg.mie.usie <= csr_ein.cdata[0];
          end
          csr_mip : begin
            csr_machine_reg.mip.seip <= csr_ein.cdata[9];
            csr_machine_reg.mip.ueip <= csr_ein.cdata[8];
            csr_machine_reg.mip.stip <= csr_ein.cdata[5];
            csr_machine_reg.mip.ueip <= csr_ein.cdata[4];
            csr_machine_reg.mip.ssip <= csr_ein.cdata[1];
            csr_machine_reg.mip.usip <= csr_ein.cdata[0];
          end
          csr_mcycle : csr_machine_reg.mcycle[31:0] <= csr_ein.cdata;
          csr_mcycleh : csr_machine_reg.mcycle[63:32] <= csr_ein.cdata;
          csr_minstret : csr_machine_reg.minstret[31:0] <= csr_ein.cdata;
          csr_minstreth : csr_machine_reg.minstret[63:32] <= csr_ein.cdata;
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

      if (csr_din.exception == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mepc <= csr_din.d_epc;
        csr_machine_reg.mtval <= csr_din.etval;
        csr_machine_reg.mcause <= {28'b0,csr_din.ecause};
        exception <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.meie == 1 &&
                   csr_machine_reg.mip.meip == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        if (csr_din.d_valid == 1) begin
          csr_machine_reg.mepc <= csr_din.d_epc;
        end else if (csr_din.e_valid == 1) begin
          csr_machine_reg.mepc <= csr_din.e_epc;
        end
        csr_machine_reg.mtval <= csr_din.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_extern};
        exception <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.mtie == 1 &&
                   csr_machine_reg.mip.mtip == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        if (csr_din.d_valid == 1) begin
          csr_machine_reg.mepc <= csr_din.d_epc;
        end else if (csr_din.e_valid == 1) begin
          csr_machine_reg.mepc <= csr_din.e_epc;
        end
        csr_machine_reg.mtval <= csr_din.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_timer};
        exception <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.msie == 1 &&
                   csr_machine_reg.mip.msip == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        if (csr_din.d_valid == 1) begin
          csr_machine_reg.mepc <= csr_din.d_epc;
        end else if (csr_din.e_valid == 1) begin
          csr_machine_reg.mepc <= csr_din.e_epc;
        end
        csr_machine_reg.mtval <= csr_din.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_soft};
        exception <= 1;
      end else begin
        exception <= 0;
      end

      if (csr_din.mret == 1) begin
        csr_machine_reg.mstatus.mie <= csr_machine_reg.mstatus.mpie;
        csr_machine_reg.mstatus.mpie <= 0;
        mret <= 1;
      end else begin
        mret <= 0;
      end

    end

  end

endmodule
