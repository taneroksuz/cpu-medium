import configure::*;

module soc();

  timeunit 1ns;
  timeprecision 1ps;

  logic reset;
  logic clock;

  logic [0  : 0] imemory_valid;
  logic [0  : 0] imemory_instr;
  logic [31 : 0] imemory_addr;
  logic [31 : 0] imemory_wdata;
  logic [3  : 0] imemory_wstrb;
  logic [31 : 0] imemory_rdata;
  logic [0  : 0] imemory_ready;

  logic [0  : 0] dmemory_valid;
  logic [0  : 0] dmemory_instr;
  logic [31 : 0] dmemory_addr;
  logic [31 : 0] dmemory_wdata;
  logic [3  : 0] dmemory_wstrb;
  logic [31 : 0] dmemory_rdata;
  logic [0  : 0] dmemory_ready;

  logic [0  : 0] memory_valid;
  logic [0  : 0] memory_instr;
  logic [31 : 0] memory_addr;
  logic [31 : 0] memory_wdata;
  logic [3  : 0] memory_wstrb;
  logic [31 : 0] memory_rdata;
  logic [0  : 0] memory_ready;

  logic [0  : 0] rom_valid;
  logic [0  : 0] rom_instr;
  logic [31 : 0] rom_addr;
  logic [31 : 0] rom_rdata;
  logic [0  : 0] rom_ready;

  logic [0  : 0] print_valid;
  logic [0  : 0] print_instr;
  logic [31 : 0] print_addr;
  logic [31 : 0] print_wdata;
  logic [3  : 0] print_wstrb;
  logic [31 : 0] print_rdata;
  logic [0  : 0] print_ready;

  logic [0  : 0] clint_valid;
  logic [0  : 0] clint_instr;
  logic [31 : 0] clint_addr;
  logic [31 : 0] clint_wdata;
  logic [3  : 0] clint_wstrb;
  logic [31 : 0] clint_rdata;
  logic [0  : 0] clint_ready;

  logic [0  : 0] bram_valid;
  logic [0  : 0] bram_instr;
  logic [31 : 0] bram_addr;
  logic [31 : 0] bram_wdata;
  logic [3  : 0] bram_wstrb;
  logic [31 : 0] bram_rdata;
  logic [0  : 0] bram_ready;

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] mem_addr;

  logic [31 : 0] base_addr;

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
  end

  initial begin
    #10 reset = 1;
  end

  always #0.5 clock = ~clock;

  initial begin
    string filename;
    if ($value$plusargs("REGFILE=%s",filename)) begin
      reg_file = $fopen(filename,"w");
      for (int i=0; i<stoptime; i=i+1) begin
        @(posedge clock);
        if (soc.cpu_comp.register_comp.register0_win.wren == 1) begin
          $fwrite(reg_file,"PERIOD = %t\t",$time);
          $fwrite(reg_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.d.e.calc0.pc);
          $fwrite(reg_file,"WADDR = %d\t",soc.cpu_comp.register_comp.register0_win.waddr);
          $fwrite(reg_file,"WDATA = %x\n",soc.cpu_comp.register_comp.register0_win.wdata);
        end
        if (soc.cpu_comp.register_comp.register1_win.wren == 1) begin
          $fwrite(reg_file,"PERIOD = %t\t",$time);
          $fwrite(reg_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.d.e.calc1.pc);
          $fwrite(reg_file,"WADDR = %d\t",soc.cpu_comp.register_comp.register1_win.waddr);
          $fwrite(reg_file,"WDATA = %x\n",soc.cpu_comp.register_comp.register1_win.wdata);
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
        if (soc.cpu_comp.csr_comp.csr_win.cwren == 1) begin
          $fwrite(csr_file,"PERIOD = %t\t",$time);
          $fwrite(csr_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.d.e.calc0.pc);
          $fwrite(csr_file,"WADDR = %x\t",soc.cpu_comp.csr_comp.csr_win.cwaddr);
          $fwrite(csr_file,"WDATA = %x\n",soc.cpu_comp.csr_comp.csr_win.cdata);
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
        if (soc.bram_comp.bram_valid == 1) begin
          if (|soc.bram_comp.bram_wstrb == 1) begin
            $fwrite(mem_file,"PERIOD = %t\t",$time);
            $fwrite(mem_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.d.e.calc0.pc);
            $fwrite(mem_file,"WADDR = %x\t",soc.bram_comp.bram_addr);
            $fwrite(mem_file,"WSTRB = %b\t",soc.bram_comp.bram_wstrb);
            $fwrite(mem_file,"WDATA = %x\n",soc.bram_comp.bram_wdata);
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
        if (soc.cpu_comp.fpu_comp.fpu_generate.fpu_register_comp.fp_register_win.wren == 1) begin
          $fwrite(freg_file,"PERIOD = %t\t",$time);
          $fwrite(freg_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.d.e.calc0.pc);
          $fwrite(freg_file,"WADDR = %d\t",soc.cpu_comp.fpu_comp.fpu_generate.fpu_register_comp.fp_register_win.waddr);
          $fwrite(freg_file,"WDATA = %x\n",soc.cpu_comp.fpu_comp.fpu_generate.fpu_register_comp.fp_register_win.wdata);
        end
      end
      $fclose(freg_file);
    end
  end

  always_ff @(posedge clock) begin
    if (counter == stoptime) begin
      $write("%c[1;33m",8'h1B);
      $display("TEST STOPPED");
      $write("%c[0m",8'h1B);
      $finish;
    end else begin
      counter <= counter + 1;
    end
  end

  always_ff @(posedge clock) begin
    if (soc.cpu_comp.dtim_comp.dtim_in.mem_valid == 1) begin
      if (soc.cpu_comp.dtim_comp.dtim_in.mem_addr[31:2] == host[0][31:2]) begin
        if (|soc.cpu_comp.dtim_comp.dtim_in.mem_wstrb == 1) begin
          if (soc.cpu_comp.dtim_comp.dtim_in.mem_wdata == 32'h1) begin
            $write("%c[1;32m",8'h1B);
            $display("TEST SUCCEEDED");
            $write("%c[0m",8'h1B);
            $finish;
          end else begin
            $write("%c[1;31m",8'h1B);
            $display("TEST FAILED");
            $write("%c[0m",8'h1B);
            $finish;
          end
        end
      end
    end
  end

  always_comb begin

    rom_valid = 0;
    print_valid = 0;
    clint_valid = 0;
    bram_valid = 0;

    base_addr = 0;

    if (memory_valid == 1) begin
      if (memory_addr >= bram_base_addr &&
        memory_addr < bram_top_addr) begin
          rom_valid = 0;
          print_valid = 0;
          clint_valid = 0;
          bram_valid = memory_valid;
          base_addr = bram_base_addr;
      end else if (memory_addr >= clint_base_addr &&
        memory_addr < clint_top_addr) begin
          rom_valid = 0;
          print_valid = 0;
          clint_valid = memory_valid;
          bram_valid = 0;
          base_addr = clint_base_addr;
      end else if (memory_addr >= print_base_addr &&
        memory_addr < print_top_addr) begin
          rom_valid = 0;
          print_valid = memory_valid;
          clint_valid = 0;
          bram_valid = 0;
          base_addr = print_base_addr;
      end else if (memory_addr >= rom_base_addr &&
        memory_addr < rom_top_addr) begin
          rom_valid = memory_valid;
          print_valid = 0;
          clint_valid = 0;
          bram_valid = 0;
          base_addr = rom_base_addr;
      end else begin
          rom_valid = 0;
          print_valid = 0;
          clint_valid = 0;
          bram_valid = 0;
          base_addr = 0;
      end
    end

    mem_addr = memory_addr - base_addr;

    rom_instr = memory_instr;
    rom_addr = mem_addr;

    print_instr = memory_instr;
    print_addr = mem_addr;
    print_wdata = memory_wdata;
    print_wstrb = memory_wstrb;

    clint_instr = memory_instr;
    clint_addr = mem_addr;
    clint_wdata = memory_wdata;
    clint_wstrb = memory_wstrb;

    bram_instr = memory_instr;
    bram_addr = mem_addr;
    bram_wdata = memory_wdata;
    bram_wstrb = memory_wstrb;

    if (rom_ready == 1) begin
      memory_rdata = rom_rdata;
      memory_ready = rom_ready;
    end else if  (print_ready == 1) begin
      memory_rdata = print_rdata;
      memory_ready = print_ready;
    end else if  (clint_ready == 1) begin
      memory_rdata = clint_rdata;
      memory_ready = clint_ready;
    end else if (bram_ready == 1) begin
      memory_rdata = bram_rdata;
      memory_ready = bram_ready;
    end else begin
      memory_rdata = 0;
      memory_ready = 0;
    end

  end

  cpu cpu_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (imemory_valid),
    .imemory_instr (imemory_instr),
    .imemory_addr (imemory_addr),
    .imemory_wdata (imemory_wdata),
    .imemory_wstrb (imemory_wstrb),
    .imemory_rdata (imemory_rdata),
    .imemory_ready (imemory_ready),
    .dmemory_valid (dmemory_valid),
    .dmemory_instr (dmemory_instr),
    .dmemory_addr (dmemory_addr),
    .dmemory_wdata (dmemory_wdata),
    .dmemory_wstrb (dmemory_wstrb),
    .dmemory_rdata (dmemory_rdata),
    .dmemory_ready (dmemory_ready),
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  arbiter arbiter_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (imemory_valid),
    .imemory_instr (imemory_instr),
    .imemory_addr (imemory_addr),
    .imemory_wdata (imemory_wdata),
    .imemory_wstrb (imemory_wstrb),
    .imemory_rdata (imemory_rdata),
    .imemory_ready (imemory_ready),
    .dmemory_valid (dmemory_valid),
    .dmemory_instr (dmemory_instr),
    .dmemory_addr (dmemory_addr),
    .dmemory_wdata (dmemory_wdata),
    .dmemory_wstrb (dmemory_wstrb),
    .dmemory_rdata (dmemory_rdata),
    .dmemory_ready (dmemory_ready),
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready)
  );

  rom rom_comp
  (
    .reset (reset),
    .clock (clock),
    .rom_valid (rom_valid),
    .rom_instr (rom_instr),
    .rom_addr (rom_addr),
    .rom_rdata (rom_rdata),
    .rom_ready (rom_ready)
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

  clint clint_comp
  (
    .reset (reset),
    .clock (clock),
    .clint_valid (clint_valid),
    .clint_instr (clint_instr),
    .clint_addr (clint_addr),
    .clint_wdata (clint_wdata),
    .clint_wstrb (clint_wstrb),
    .clint_rdata (clint_rdata),
    .clint_ready (clint_ready),
    .clint_msip (msip),
    .clint_mtip (mtip),
    .clint_mtime (mtime)
  );

  bram bram_comp
  (
    .reset (reset),
    .clock (clock),
    .bram_valid (bram_valid),
    .bram_instr (bram_instr),
    .bram_addr (bram_addr),
    .bram_wdata (bram_wdata),
    .bram_wstrb (bram_wstrb),
    .bram_rdata (bram_rdata),
    .bram_ready (bram_ready)
  );

endmodule
