import constants::*;
import wires::*;

module hazard
(
  input hazard_in_type hazard_in,
  output hazard_out_type hazard_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] instr [0:1];

  logic [4 : 0] waddr [0:1];
  logic [4 : 0] raddr1 [0:1];
  logic [4 : 0] raddr2 [0:1];
  logic [4 : 0] raddr3 [0:1];

  logic [0 : 0] wren [0:1];
  logic [0 : 0] rden1 [0:1];
  logic [0 : 0] rden2 [0:1];

  logic [0 : 0] fwren [0:1];
  logic [0 : 0] frden1 [0:1];
  logic [0 : 0] frden2 [0:1];
  logic [0 : 0] frden3 [0:1];

  always_comb begin

    instr[0] = hazard_in.ready ? hazard_in.rdata[31:0] : nop_instr;
    instr[1] = hazard_in.ready ? hazard_in.rdata[63:32] : nop_instr;

    waddr = '{default:'0};
    raddr1 = '{default:'0};
    raddr2 = '{default:'0};
    raddr3 = '{default:'0};

    wren = '{default:'0};
    rden1 = '{default:'0};
    rden2 = '{default:'0};

    fwren = '{default:'0};
    frden1 = '{default:'0};
    frden2 = '{default:'0};
    frden3 = '{default:'0};

    hazard_out.instr0 = instr[0];
    hazard_out.instr1 = instr[1];

  end

endmodule
