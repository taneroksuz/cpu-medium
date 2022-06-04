package functions;
  timeunit 1ns;
  timeprecision 1ps;

  function [31:0] multiplexer;
    input [31:0] data0;
    input [31:0] data1;
    input [0:0] sel;
    begin
      if (sel == 0)
        multiplexer = data0;
      else
        multiplexer = data1;
    end
  endfunction

  function [31:0] store_data;
    input [31:0] sdata;
    input [0:0] sb;
    input [0:0] sh;
    input [0:0] sw;
    begin
      if (sb == 1)
        store_data = {sdata[7:0],sdata[7:0],sdata[7:0],sdata[7:0]};
      else if (sh == 1)
        store_data = {sdata[15:0],sdata[15:0]};
      else if (sw == 1)
        store_data = sdata;
      else
        store_data = 0;
    end
  endfunction

  function [31:0] bit_andn;
    input [31:0] rs1;
    input [31:0] rs2;
    begin
      bit_andn = rs1 & ~(rs2);
    end
  endfunction

  function [31:0] bit_clz;
    input [31:0] rs1;
    logic [5:0] res;
    integer i;
    begin
      res = 0;
      for (i = 31; i >= 0; i=i-1) begin
        if (rs1[i] == 1) begin
          break;
        end
        res = res + 6'b1;
      end
      bit_clz = {26'h0,res};
    end
  endfunction

  function [31:0] bit_cpop;
    input [31:0] rs1;
    logic [5:0] res;
    integer i;
    begin
      res = 0;
      for (i = 0; i < 32; i=i+1) begin
        if (rs1[i] == 1) begin
          res = res + 6'b1;
        end
      end
      bit_cpop = {26'h0,res};
    end
  endfunction

  function [31:0] bit_ctz;
    input [31:0] rs1;
    logic [5:0] res;
    integer i;
    begin
      res = 0;
      for (i = 0; i < 32; i=i+1) begin
        if (rs1[i] == 1) begin
          break;
        end
        res = res + 6'b1;
      end
      bit_ctz = {26'h0,res};
    end
  endfunction

  function [31:0] bit_minmax;
    input [31:0] rs1;
    input [31:0] rs2;
    input [1:0] op;
    logic [32:0] r1;
    logic [32:0] r2;
    begin
      r1 = {1'b0,rs1};
      r2 = {1'b0,rs2};
      if (op == 0 || op == 2) begin // max & min
        r1[32] = rs1[31];
        r2[32] = rs2[31];
      end
      if (op == 2 || op == 3) begin // min & minu
        r1 = -r1;
        r2 = -r2;
      end
      if ($signed(r1) < $signed(r2)) begin
        bit_minmax = rs2;
      end else begin
        bit_minmax = rs1;
      end
    end
  endfunction

  function [31:0] bit_orcb;
    input [31:0] rs1;
    logic [31:0] res;
    integer i;
    begin
      res = 0;
      for (i=0; i<32; i=i+8) begin
        if (|(rs1[i+:8]) == 1) begin
          res[i+:8] = 8'hFF;
        end
      end
      bit_orcb = res;
    end
  endfunction

  function [31:0] bit_orn;
    input [31:0] rs1;
    input [31:0] rs2;
    begin
      bit_orn = rs1 | ~(rs2);
    end
  endfunction

  function [31:0] bit_rev8;
    input [31:0] rs1;
    logic [31:0] res;
    integer i;
    begin
      res = 0;
      for (i=0; i<32; i=i+8) begin
        res[i+:8] = rs1[(24-i)+:8];
      end
      bit_rev8 = res;
    end
  endfunction

  function [31:0] bit_rol;
    input [31:0] rs1;
    input [31:0] rs2;
    logic [31:0] res;
    begin
      res = rs1 << rs2[4:0];
      res = res | (rs1 >> (32-rs2[4:0]));
      bit_rol = res;
    end
  endfunction

  function [31:0] bit_ror;
    input [31:0] rs1;
    input [31:0] rs2;
    logic [31:0] res;
    begin
      res = rs1 >> rs2[4:0];
      res = res | (rs1 << (32-rs2[4:0]));
      bit_ror = res;
    end
  endfunction

  function [31:0] bit_bset;
    input [31:0] rs1;
    input [31:0] rs2;
    logic [31:0] res;
    begin
      res = rs1;
      res[rs2[4:0]] = 1'b1;
      bit_bset = res;
    end
  endfunction

  function [31:0] bit_bclr;
    input [31:0] rs1;
    input [31:0] rs2;
    logic [31:0] res;
    begin
      res = rs1;
      res[rs2[4:0]] = 1'b0;
      bit_bclr = res;
    end
  endfunction

  function [31:0] bit_binv;
    input [31:0] rs1;
    input [31:0] rs2;
    logic [31:0] res;
    begin
      res = rs1;
      res[rs2[4:0]] = ~(res[rs2[4:0]]);
      bit_binv = res;
    end
  endfunction

  function [31:0] bit_bext;
    input [31:0] rs1;
    input [31:0] rs2;
    begin
      if (rs1[rs2[4:0]] == 1) begin
        bit_bext = 1;
      end else begin
        bit_bext = 0;
      end
    end
  endfunction

  function [31:0] bit_sextb;
    input [31:0] rs1;
    begin
      bit_sextb = {{24{rs1[7]}},rs1[7:0]};
    end
  endfunction

  function [31:0] bit_sexth;
    input [31:0] rs1;
    begin
      bit_sexth = {{16{rs1[15]}},rs1[15:0]};
    end
  endfunction

  function [31:0] bit_shadd;
    input [31:0] rs1;
    input [31:0] rs2;
    input [1:0] index;
    begin
      bit_shadd = rs2 + (rs1 << index);
    end
  endfunction

  function [31:0] bit_xnor;
    input [31:0] rs1;
    input [31:0] rs2;
    begin
      bit_xnor = ~(rs1 ^ rs2);
    end
  endfunction

  function [31:0] bit_zexth;
    input [31:0] rs1;
    begin
      bit_zexth = {16'h0,rs1[15:0]};
    end
  endfunction

endpackage
