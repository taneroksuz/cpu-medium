import wires::*;

module div
(
  input logic rst,
  input logic clk,
  input div_in_type div_in,
  output div_out_type div_out
);
  timeunit 1ns;
  timeprecision 1ps;

  div_reg_type r,rin;
  div_reg_type v;

  integer i;

  always_comb begin

    v = r;

    case (r.counter)
      0 : begin
        v.data1 = div_in.rdata1;
        v.data2 = div_in.rdata2;
        v.div_op = div_in.div_op;
        v.division = v.div_op.divs | v.div_op.rem |
                v.div_op.divu | v.div_op.remu;
        v.op1_signed = v.div_op.divs | v.div_op.rem;
        v.op2_signed = v.div_op.divs | v.div_op.rem;
        v.negativ = 0;
        v.op1_neg = 0;
        if (v.op1_signed == 1 && v.data1[31] == 1) begin
          v.negativ = ~v.negativ;
          v.op1 = -v.data1;
          v.op1_neg = 1;
        end else begin
          v.op1 = v.data1;
        end
        if (v.op2_signed == 1 && v.data2[31] == 1) begin
          v.negativ = ~v.negativ;
          v.op2 = -v.data2;
        end else begin
          v.op2 = v.data2;
        end
        for (i=31; i>=0; i=i-1) begin
          v.counter = i[5:0];
          if (v.op1[i] == 1) begin
            break;
          end
        end
        v.counter = 6'h1F - v.counter;
        v.divisionbyzero = 0;
        if (v.division == 1 && v.op2 == 0) begin
          v.divisionbyzero = 1;
          v.counter = 32;
        end
        v.overflow = 0;
        if ((v.div_op.divs == 1 | v.div_op.rem == 1) &&
            v.op1 == 32'h80000000 && v.op2 == 32'hFFFFFFFF) begin
          v.overflow = 1;
          v.counter = 32;
        end
        if (v.division == 1) begin
          v.result = {33'b0,v.op1};
          v.result = v.result << v.counter;
        end
        if (div_in.enable == 0) begin
          v.counter = 0;
        end else if (div_in.enable == 1) begin
          v.counter = v.counter + 6'h1;
        end
        div_out.result = 0;
        div_out.ready = 0;
      end
      33 : begin
        if (v.negativ == 1) begin
          if (v.division == 1) begin
            v.result[31:0] = -v.result[31:0];
          end
        end
        if (v.op1_neg == 1) begin
          if (v.division == 1) begin
            v.result[63:32] = -v.result[63:32];
          end
        end
        v.counter = 0;
        if (v.div_op.divs == 1) begin
          if (v.divisionbyzero == 1) begin
            div_out.result = 32'hFFFFFFFF;
          end else if (v.overflow == 1) begin
            div_out.result = 32'h80000000;
          end else begin
            div_out.result = v.result[31:0];
          end
        end else if (v.div_op.divu == 1) begin
          if (v.divisionbyzero == 1) begin
            div_out.result = 32'hFFFFFFFF;
          end else begin
            div_out.result = v.result[31:0];
          end
        end else if (v.div_op.rem == 1) begin
          if (v.divisionbyzero == 1) begin
            div_out.result = v.data1;
          end else if (v.overflow == 1) begin
            div_out.result = 0;
          end else begin
            div_out.result = v.result[63:32];
          end
        end else if (v.div_op.remu == 1) begin
          if (v.divisionbyzero == 1) begin
            div_out.result = v.data1;
          end else begin
            div_out.result = v.result[63:32];
          end
        end else begin
          div_out.result = 0;
        end
        div_out.ready = 1;
      end
      default : begin
        if (v.division == 1) begin
          v.result = {v.result[63:0],1'b0};
          v.result[64:32] = v.result[64:32] - {1'b0,v.op2};
          if (v.result[64] == 0) begin
            v.result[0] = 1;
          end else if (v.result[64] == 1) begin
            v.result = {r.result[63:0],1'b0};
          end
        end
        v.counter = v.counter + 6'h1;
        div_out.result = 0;
        div_out.ready = 0;
      end
    endcase

    rin = v;

  end

  always_ff @ (posedge clk) begin
    if (rst == 0) begin
      r <= init_div_reg;
    end else begin
      r <= rin;
    end

  end

endmodule
