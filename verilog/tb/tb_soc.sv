import configure::*;

module tb_soc();

  timeunit 1ns;
  timeprecision 1ps;

  logic reset;
  logic clock;
  logic clock_slow;

  logic [0  : 0] print_valid;
  logic [0  : 0] print_instr;
  logic [31 : 0] print_addr;
  logic [63 : 0] print_wdata;
  logic [7  : 0] print_wstrb;
  logic [63 : 0] print_rdata;
  logic [0  : 0] print_ready;

  logic [31 : 0] host[0:0];

  logic [31 : 0] stoptime = 1000;
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
    if ($value$plusargs("FILENAME=%s",filename)) begin
      $dumpfile(filename);
      $dumpvars(0, soc);
    end
  end

  initial begin
    string maxtime;
    if ($value$plusargs("MAXTIME=%s",maxtime)) begin
      stoptime = maxtime.atoi();
    end
  end

  initial begin
    reset = 0;
    clock = 1;
    clock_slow = 1;
  end

  initial begin
    #10 reset = 1;
  end

  always #0.5 clock = ~clock;
  always #5.0 clock_slow = ~clock_slow;

  initial begin
    string filename;
    if ($value$plusargs("REGFILE=%s",filename)) begin
      reg_file = $fopen(filename,"w");
      for (int i=0; i<stoptime; i=i+1) begin
        @(posedge clock);
        if (tb_soc.soc_comp.cpu_comp.register_comp.register0_win.wren == 1) begin
          $fwrite(reg_file,"PERIOD = %t\t",$time);
          $fwrite(reg_file,"PC = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.pc);
          $fwrite(reg_file,"WADDR = %x\t",tb_soc.soc_comp.cpu_comp.register_comp.register0_win.waddr);
          $fwrite(reg_file,"WDATA = %x\n",tb_soc.soc_comp.cpu_comp.register_comp.register0_win.wdata);
        end
        if (tb_soc.soc_comp.cpu_comp.register_comp.register1_win.wren == 1) begin
          $fwrite(reg_file,"PERIOD = %t\t",$time);
          $fwrite(reg_file,"PC = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.pc);
          $fwrite(reg_file,"WADDR = %x\t",tb_soc.soc_comp.cpu_comp.register_comp.register1_win.waddr);
          $fwrite(reg_file,"WDATA = %x\n",tb_soc.soc_comp.cpu_comp.register_comp.register1_win.wdata);
        end
      end
      $fclose(reg_file);
    end
  end

  initial begin
    string filename;
    if ($value$plusargs("CSRFILE=%s",filename)) begin
      csr_file = $fopen(filename,"w");
      for (int i=0; i<stoptime; i=i+1) begin
        @(posedge clock);
        if (tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.op.cwren == 1) begin
          $fwrite(csr_file,"PERIOD = %t\t",$time);
          $fwrite(csr_file,"PC = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.pc);
          $fwrite(csr_file,"WADDR = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.caddr);
          $fwrite(csr_file,"WDATA = %x\n",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.cdata);
        end else if (tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.op.cwren == 1) begin
          $fwrite(csr_file,"PERIOD = %t\t",$time);
          $fwrite(csr_file,"PC = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.pc);
          $fwrite(csr_file,"WADDR = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.caddr);
          $fwrite(csr_file,"WDATA = %x\n",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.cdata);
        end
      end
      $fclose(csr_file);
    end
  end

  initial begin
    string filename;
    if ($value$plusargs("MEMFILE=%s",filename)) begin
      mem_file = $fopen(filename,"w");
      for (int i=0; i<stoptime; i=i+1) begin
        @(posedge clock);
        if ((tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.op.store | tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.op.fstore) == 1) begin
          if (|tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.byteenable == 1) begin
            $fwrite(mem_file,"PERIOD = %t\t",$time);
            $fwrite(mem_file,"PC = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.pc);
            $fwrite(mem_file,"WADDR = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.address);
            $fwrite(mem_file,"WSTRB = %b\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.byteenable);
            $fwrite(mem_file,"WDATA = %x\n",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.sdata);
          end
        end else if ((tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.op.store | tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.op.fstore) == 1) begin
          if (|tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.byteenable == 1) begin
            $fwrite(mem_file,"PERIOD = %t\t",$time);
            $fwrite(mem_file,"PC = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.pc);
            $fwrite(mem_file,"WADDR = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.address);
            $fwrite(mem_file,"WSTRB = %b\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.byteenable);
            $fwrite(mem_file,"WDATA = %x\n",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.sdata);
          end
        end
      end
      $fclose(mem_file);
    end
  end

  initial begin
    string filename;
    if ($value$plusargs("FREGFILE=%s",filename)) begin
      freg_file = $fopen(filename,"w");
      for (int i=0; i<stoptime; i=i+1) begin
        @(posedge clock);
        if (tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.op.fwren == 1) begin
          $fwrite(freg_file,"PERIOD = %t\t",$time);
          $fwrite(freg_file,"PC = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.pc);
          $fwrite(freg_file,"WADDR = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.waddr);
          $fwrite(freg_file,"WDATA = %x\n",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc0.fdata);
        end else if (tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.op.fwren == 1) begin
          $fwrite(freg_file,"PERIOD = %t\t",$time);
          $fwrite(freg_file,"PC = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.pc);
          $fwrite(freg_file,"WADDR = %x\t",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.waddr);
          $fwrite(freg_file,"WDATA = %x\n",tb_soc.soc_comp.cpu_comp.execute_stage_comp.a.m.calc1.fdata);
        end
      end
      $fclose(freg_file);
    end
  end

  always_ff @(posedge clock) begin
    if (counter == stoptime) begin
      $finish;
    end else begin
      counter <= counter + 1;
    end
  end

  always_ff @(posedge clock) begin
    if (tb_soc.soc_comp.cpu_comp.memory_stage_comp.dmem_in.mem_valid == 1) begin
      if (tb_soc.soc_comp.cpu_comp.memory_stage_comp.dmem_in.mem_addr[31:3] == host[0][31:3]) begin
        if (|tb_soc.soc_comp.cpu_comp.memory_stage_comp.dmem_in.mem_wstrb == 1) begin
          $display("%d",tb_soc.soc_comp.cpu_comp.memory_stage_comp.dmem_in.mem_wdata[31:0]);
          $finish;
        end
      end
    end
  end

  soc soc_comp
  (
    .reset (reset),
    .clock (clock),
    .clock_slow (clock_slow),
    .uart_valid (print_valid),
    .uart_instr (print_instr),
    .uart_addr (print_addr),
    .uart_wdata (print_wdata),
    .uart_wstrb (print_wstrb),
    .uart_rdata (print_rdata),
    .uart_ready (print_ready)
  );

  print print_comp
  (
    .reset (reset),
    .clock (clock),
    .print_valid (print_valid),
    .print_instr (print_instr),
    .print_addr (print_addr),
    .print_wdata (print_wdata),
    .print_wstrb (print_wstrb),
    .print_rdata (print_rdata),
    .print_ready (print_ready)
  );

endmodule
