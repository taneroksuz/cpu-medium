import wires::*;

module forwarding
(
  input forwarding_register_in_type forwarding0_rin,
  input forwarding_register_in_type forwarding1_rin,
  input forwarding_execute_in_type forwarding0_ein,
  input forwarding_execute_in_type forwarding1_ein,
  input forwarding_memory_in_type forwarding0_min,
  input forwarding_memory_in_type forwarding1_min,
  output forwarding_out_type forwarding0_out,
  output forwarding_out_type forwarding1_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] res0_1;
  logic [31:0] res0_2;

  logic [31:0] res1_1;
  logic [31:0] res1_2;

  always_comb begin
    res0_1 = 0;
    res0_2 = 0;
    if (forwarding0_rin.rden1 == 1) begin
      res0_1 = forwarding0_rin.rdata1;
      if (forwarding0_min.wren == 1 & forwarding0_rin.raddr1 == forwarding0_min.waddr) begin
        res0_1 = forwarding0_min.wdata;
      end
      if (forwarding1_min.wren == 1 & forwarding0_rin.raddr1 == forwarding1_min.waddr) begin
        res0_1 = forwarding1_min.wdata;
      end
      if (forwarding0_ein.wren == 1 & forwarding0_rin.raddr1 == forwarding0_ein.waddr) begin
        res0_1 = forwarding0_ein.wdata;
      end
      if (forwarding1_ein.wren == 1 & forwarding0_rin.raddr1 == forwarding1_ein.waddr) begin
        res0_1 = forwarding1_ein.wdata;
      end
    end
    if (forwarding0_rin.rden2 == 1) begin
      res0_2 = forwarding0_rin.rdata2;
      if (forwarding0_min.wren == 1 & forwarding0_rin.raddr2 == forwarding0_min.waddr) begin
        res0_2 = forwarding0_min.wdata;
      end
      if (forwarding1_min.wren == 1 & forwarding0_rin.raddr2 == forwarding1_min.waddr) begin
        res0_2 = forwarding1_min.wdata;
      end
      if (forwarding0_ein.wren == 1 & forwarding0_rin.raddr2 == forwarding0_ein.waddr) begin
        res0_2 = forwarding0_ein.wdata;
      end
      if (forwarding1_ein.wren == 1 & forwarding0_rin.raddr2 == forwarding1_ein.waddr) begin
        res0_2 = forwarding1_ein.wdata;
      end
    end
    forwarding0_out.data1 = res0_1;
    forwarding0_out.data2 = res0_2;
  end

  always_comb begin
    res1_1 = 0;
    res1_2 = 0;
    if (forwarding1_rin.rden1 == 1) begin
      res1_1 = forwarding1_rin.rdata1;
      if (forwarding0_min.wren == 1 & forwarding1_rin.raddr1 == forwarding0_min.waddr) begin
        res1_1 = forwarding0_min.wdata;
      end
      if (forwarding1_min.wren == 1 & forwarding1_rin.raddr1 == forwarding1_min.waddr) begin
        res1_1 = forwarding1_min.wdata;
      end
      if (forwarding0_ein.wren == 1 & forwarding1_rin.raddr1 == forwarding0_ein.waddr) begin
        res1_1 = forwarding0_ein.wdata;
      end
      if (forwarding1_ein.wren == 1 & forwarding1_rin.raddr1 == forwarding1_ein.waddr) begin
        res1_1 = forwarding1_ein.wdata;
      end
    end
    if (forwarding1_rin.rden2 == 1) begin
      res1_2 = forwarding1_rin.rdata2;
      if (forwarding0_min.wren == 1 & forwarding1_rin.raddr2 == forwarding0_min.waddr) begin
        res1_2 = forwarding0_min.wdata;
      end
      if (forwarding1_min.wren == 1 & forwarding1_rin.raddr2 == forwarding1_min.waddr) begin
        res1_2 = forwarding1_min.wdata;
      end
      if (forwarding0_ein.wren == 1 & forwarding1_rin.raddr2 == forwarding0_ein.waddr) begin
        res1_2 = forwarding0_ein.wdata;
      end
      if (forwarding1_ein.wren == 1 & forwarding1_rin.raddr2 == forwarding1_ein.waddr) begin
        res1_2 = forwarding1_ein.wdata;
      end
    end
    forwarding1_out.data1 = res1_1;
    forwarding1_out.data2 = res1_2;
  end

endmodule
