import wires::*;

module forwarding
(
  input forwarding_register_in_type forwarding_rin,
  input forwarding_execute_in_type forwarding_ein,
  input forwarding_memory_in_type forwarding_min,
  output forwarding_out_type forwarding_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] res1;
  logic [31:0] res2;

  always_comb begin
    res1 = 0;
    res2 = 0;
    if (forwarding_rin.rden1 == 1) begin
      res1 = forwarding_rin.rdata1;
      if (forwarding_min.wren == 1 & forwarding_rin.raddr1 == forwarding_min.waddr) begin
        res1 = forwarding_min.wdata;
      end
      if (forwarding_ein.wren == 1 & forwarding_rin.raddr1 == forwarding_ein.waddr) begin
        res1 = forwarding_ein.wdata;
      end
    end
    if (forwarding_rin.rden2 == 1) begin
      res2 = forwarding_rin.rdata2;
      if (forwarding_min.wren == 1 & forwarding_rin.raddr2 == forwarding_min.waddr) begin
        res2 = forwarding_min.wdata;
      end
      if (forwarding_ein.wren == 1 & forwarding_rin.raddr2 == forwarding_ein.waddr) begin
        res2 = forwarding_ein.wdata;
      end
    end
    forwarding_out.data1 = res1;
    forwarding_out.data2 = res2;
  end

endmodule
