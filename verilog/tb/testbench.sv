import configure::*;
import wires::*;

module testbench ();

  timeunit 1ns; timeprecision 1ps;

  logic reset;
  logic clock;
  wire sclk;
  wire mosi;
  wire miso;
  wire ss;
  wire rx;
  wire tx;
  wire sram_ce_n;
  wire sram_we_n;
  wire sram_oe_n;
  wire sram_ub_n;
  wire sram_lb_n;
  wire [17:0] sram_addr;
  wire [15:0] sram_dq;

  verify_out_type ver0_out;
  verify_out_type ver1_out;

  logic [31 : 0] host[0:0];

  logic [31 : 0] stoptime = 10000000;
  logic [31 : 0] counter = 0;

  integer reg_file;
  integer csr_file;
  integer mem_file;
  integer freg_file;

  initial begin
    $readmemh("host.dat", host);
  end

  initial begin
    string filename;
    if ($value$plusargs("FILENAME=%s", filename)) begin
      $dumpfile(filename);
      $dumpvars(0, testbench);
    end
  end

  initial begin
    string maxtime;
    if ($value$plusargs("MAXTIME=%s", maxtime)) begin
      stoptime = maxtime.atoi();
    end
  end

  initial begin
    reset = 0;
    clock = 1;
  end

  initial begin
    #10 reset = 1;
  end

  always #0.5 clock = ~clock;

  initial begin
    string filename;
    if ($value$plusargs("REGFILE=%s", filename)) begin
      reg_file = $fopen(filename, "w");
      for (int i = 0; i < stoptime; i = i + 1) begin
        @(posedge clock);
        if (ver0_out.wren == 1) begin
          $fwrite(reg_file, "PERIOD = %t\t", $time);
          $fwrite(reg_file, "PC = %x\t", ver0_out.pc);
          $fwrite(reg_file, "WADDR = %x\t", ver0_out.waddr);
          $fwrite(reg_file, "WDATA = %x\n", ver0_out.wdata);
        end
        if (ver1_out.wren == 1) begin
          $fwrite(reg_file, "PERIOD = %t\t", $time);
          $fwrite(reg_file, "PC = %x\t", ver1_out.pc);
          $fwrite(reg_file, "WADDR = %x\t", ver1_out.waddr);
          $fwrite(reg_file, "WDATA = %x\n", ver1_out.wdata);
        end
      end
      $fclose(reg_file);
    end
  end

  initial begin
    string filename;
    if ($value$plusargs("CSRFILE=%s", filename)) begin
      csr_file = $fopen(filename, "w");
      for (int i = 0; i < stoptime; i = i + 1) begin
        @(posedge clock);
        if (ver0_out.cwren == 1) begin
          $fwrite(csr_file, "PERIOD = %t\t", $time);
          $fwrite(csr_file, "PC = %x\t", ver0_out.pc);
          $fwrite(csr_file, "WADDR = %x\t", ver0_out.caddr);
          $fwrite(csr_file, "WDATA = %x\n", ver0_out.cwdata);
        end else if (ver1_out.cwren == 1) begin
          $fwrite(csr_file, "PERIOD = %t\t", $time);
          $fwrite(csr_file, "PC = %x\t", ver1_out.pc);
          $fwrite(csr_file, "WADDR = %x\t", ver1_out.caddr);
          $fwrite(csr_file, "WDATA = %x\n", ver1_out.cwdata);
        end
      end
      $fclose(csr_file);
    end
  end

  initial begin
    string filename;
    if ($value$plusargs("MEMFILE=%s", filename)) begin
      mem_file = $fopen(filename, "w");
      for (int i = 0; i < stoptime; i = i + 1) begin
        @(posedge clock);
        if (ver0_out.store == 1) begin
          if (|ver0_out.byteenable == 1) begin
            $fwrite(mem_file, "PERIOD = %t\t", $time);
            $fwrite(mem_file, "PC = %x\t", ver0_out.pc);
            $fwrite(mem_file, "WADDR = %x\t", ver0_out.address);
            $fwrite(mem_file, "WSTRB = %b\t", ver0_out.byteenable);
            $fwrite(mem_file, "WDATA = %x\n", ver0_out.sdata);
          end
        end else if (ver1_out.store == 1) begin
          if (|ver1_out.byteenable == 1) begin
            $fwrite(mem_file, "PERIOD = %t\t", $time);
            $fwrite(mem_file, "PC = %x\t", ver1_out.pc);
            $fwrite(mem_file, "WADDR = %x\t", ver1_out.address);
            $fwrite(mem_file, "WSTRB = %b\t", ver1_out.byteenable);
            $fwrite(mem_file, "WDATA = %x\n", ver1_out.sdata);
          end
        end
      end
      $fclose(mem_file);
    end
  end

  always @(posedge clock) begin
    if (counter == stoptime) begin
      $finish;
    end else begin
      counter <= counter + 1;
    end
  end

  always @(posedge clock) begin
    if (ver0_out.store == 1) begin
      if (ver0_out.address[31:3] == host[0][31:3]) begin
        if (|ver0_out.byteenable == 1) begin
          $display("%d", ver0_out.wdata[31:0]);
          $finish;
        end
      end
    end
    if (ver1_out.store == 1) begin
      if (ver1_out.address[31:3] == host[0][31:3]) begin
        if (|ver1_out.byteenable == 1) begin
          $display("%d", ver1_out.wdata[31:0]);
          $finish;
        end
      end
    end
  end

  soc soc_comp (
      .reset(reset),
      .clock(clock),
      .sclk(sclk),
      .mosi(mosi),
      .miso(miso),
      .ss(ss),
      .rx(rx),
      .tx(tx),
      .sram_ce_n(sram_ce_n),
      .sram_we_n(sram_we_n),
      .sram_oe_n(sram_oe_n),
      .sram_ub_n(sram_ub_n),
      .sram_lb_n(sram_lb_n),
      .sram_dq(sram_dq),
      .sram_addr(sram_addr),
      .ver0_out(ver0_out),
      .ver1_out(ver1_out)
  );

endmodule
