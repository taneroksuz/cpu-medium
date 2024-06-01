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

  logic [0  : 0] irom_valid;
  logic [0  : 0] irom_instr;
  logic [31 : 0] irom_addr;
  logic [31 : 0] irom_wdata;
  logic [3  : 0] irom_wstrb;
  logic [31 : 0] irom_rdata;
  logic [0  : 0] irom_ready;

  logic [0  : 0] drom_valid;
  logic [0  : 0] drom_instr;
  logic [31 : 0] drom_addr;
  logic [31 : 0] drom_wdata;
  logic [3  : 0] drom_wstrb;
  logic [31 : 0] drom_rdata;
  logic [0  : 0] drom_ready;

  logic [0  : 0] rom_valid;
  logic [0  : 0] rom_instr;
  logic [31 : 0] rom_addr;
  logic [31 : 0] rom_wdata;
  logic [3  : 0] rom_wstrb;
  logic [31 : 0] rom_rdata;
  logic [0  : 0] rom_ready;

  logic [0  : 0] iprint_valid;
  logic [0  : 0] iprint_instr;
  logic [31 : 0] iprint_addr;
  logic [31 : 0] iprint_wdata;
  logic [3  : 0] iprint_wstrb;
  logic [31 : 0] iprint_rdata;
  logic [0  : 0] iprint_ready;

  logic [0  : 0] dprint_valid;
  logic [0  : 0] dprint_instr;
  logic [31 : 0] dprint_addr;
  logic [31 : 0] dprint_wdata;
  logic [3  : 0] dprint_wstrb;
  logic [31 : 0] dprint_rdata;
  logic [0  : 0] dprint_ready;

  logic [0  : 0] print_valid;
  logic [0  : 0] print_instr;
  logic [31 : 0] print_addr;
  logic [31 : 0] print_wdata;
  logic [3  : 0] print_wstrb;
  logic [31 : 0] print_rdata;
  logic [0  : 0] print_ready;

  logic [0  : 0] iclint_valid;
  logic [0  : 0] iclint_instr;
  logic [31 : 0] iclint_addr;
  logic [31 : 0] iclint_wdata;
  logic [3  : 0] iclint_wstrb;
  logic [31 : 0] iclint_rdata;
  logic [0  : 0] iclint_ready;

  logic [0  : 0] dclint_valid;
  logic [0  : 0] dclint_instr;
  logic [31 : 0] dclint_addr;
  logic [31 : 0] dclint_wdata;
  logic [3  : 0] dclint_wstrb;
  logic [31 : 0] dclint_rdata;
  logic [0  : 0] dclint_ready;

  logic [0  : 0] clint_valid;
  logic [0  : 0] clint_instr;
  logic [31 : 0] clint_addr;
  logic [31 : 0] clint_wdata;
  logic [3  : 0] clint_wstrb;
  logic [31 : 0] clint_rdata;
  logic [0  : 0] clint_ready;

  logic [0  : 0] itim0_valid;
  logic [0  : 0] itim0_instr;
  logic [31 : 0] itim0_addr;
  logic [31 : 0] itim0_wdata;
  logic [3  : 0] itim0_wstrb;
  logic [31 : 0] itim0_rdata;
  logic [0  : 0] itim0_ready;

  logic [0  : 0] dtim0_valid;
  logic [0  : 0] dtim0_instr;
  logic [31 : 0] dtim0_addr;
  logic [31 : 0] dtim0_wdata;
  logic [3  : 0] dtim0_wstrb;
  logic [31 : 0] dtim0_rdata;
  logic [0  : 0] dtim0_ready;

  logic [0  : 0] tim0_valid;
  logic [0  : 0] tim0_instr;
  logic [31 : 0] tim0_addr;
  logic [31 : 0] tim0_wdata;
  logic [3  : 0] tim0_wstrb;
  logic [31 : 0] tim0_rdata;
  logic [0  : 0] tim0_ready;

  logic [0  : 0] itim1_valid;
  logic [0  : 0] itim1_instr;
  logic [31 : 0] itim1_addr;
  logic [31 : 0] itim1_wdata;
  logic [3  : 0] itim1_wstrb;
  logic [31 : 0] itim1_rdata;
  logic [0  : 0] itim1_ready;

  logic [0  : 0] dtim1_valid;
  logic [0  : 0] dtim1_instr;
  logic [31 : 0] dtim1_addr;
  logic [31 : 0] dtim1_wdata;
  logic [3  : 0] dtim1_wstrb;
  logic [31 : 0] dtim1_rdata;
  logic [0  : 0] dtim1_ready;

  logic [0  : 0] tim1_valid;
  logic [0  : 0] tim1_instr;
  logic [31 : 0] tim1_addr;
  logic [31 : 0] tim1_wdata;
  logic [3  : 0] tim1_wstrb;
  logic [31 : 0] tim1_rdata;
  logic [0  : 0] tim1_ready;

  logic [0  : 0] iram_valid;
  logic [0  : 0] iram_instr;
  logic [31 : 0] iram_addr;
  logic [31 : 0] iram_wdata;
  logic [3  : 0] iram_wstrb;
  logic [31 : 0] iram_rdata;
  logic [0  : 0] iram_ready;

  logic [0  : 0] dram_valid;
  logic [0  : 0] dram_instr;
  logic [31 : 0] dram_addr;
  logic [31 : 0] dram_wdata;
  logic [3  : 0] dram_wstrb;
  logic [31 : 0] dram_rdata;
  logic [0  : 0] dram_ready;

  logic [0  : 0] ram_valid;
  logic [0  : 0] ram_instr;
  logic [31 : 0] ram_addr;
  logic [31 : 0] ram_wdata;
  logic [3  : 0] ram_wstrb;
  logic [31 : 0] ram_rdata;
  logic [0  : 0] ram_ready;

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] imem_addr;
  logic [31 : 0] dmem_addr;

  logic [31 : 0] ibase_addr;
  logic [31 : 0] dbase_addr;

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
          $fwrite(reg_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.m.calc0.pc);
          $fwrite(reg_file,"WADDR = %d\t",soc.cpu_comp.register_comp.register0_win.waddr);
          $fwrite(reg_file,"WDATA = %x\n",soc.cpu_comp.register_comp.register0_win.wdata);
        end
        if (soc.cpu_comp.register_comp.register1_win.wren == 1) begin
          $fwrite(reg_file,"PERIOD = %t\t",$time);
          $fwrite(reg_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.m.calc1.pc);
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
          if (soc.cpu_comp.execute_stage_comp.a.m.calc0.op.cwren == 1) begin
            $fwrite(csr_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.m.calc0.pc);
          end else begin
            $fwrite(csr_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.m.calc1.pc);
          end
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
        if (soc.ram_comp.ram_valid == 1) begin
          if (|soc.ram_comp.ram_wstrb == 1) begin
            $fwrite(mem_file,"PERIOD = %t\t",$time);
            $fwrite(mem_file,"WADDR = %x\t",soc.ram_comp.ram_addr);
            $fwrite(mem_file,"WSTRB = %b\t",soc.ram_comp.ram_wstrb);
            $fwrite(mem_file,"WDATA = %x\n",soc.ram_comp.ram_wdata);
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
          if (soc.cpu_comp.execute_stage_comp.a.m.calc0.op.fwren == 1) begin
            $fwrite(freg_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.m.calc0.pc);
          end else begin
            $fwrite(freg_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.m.calc1.pc);
          end
          $fwrite(freg_file,"WADDR = %d\t",soc.cpu_comp.fpu_comp.fpu_generate.fpu_register_comp.fp_register_win.waddr);
          $fwrite(freg_file,"WDATA = %x\n",soc.cpu_comp.fpu_comp.fpu_generate.fpu_register_comp.fp_register_win.wdata);
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
    if (soc.cpu_comp.memory_stage_comp.dmem_in.mem_valid == 1) begin
      if (soc.cpu_comp.memory_stage_comp.dmem_in.mem_addr[31:2] == host[0][31:2]) begin
        if (|soc.cpu_comp.memory_stage_comp.dmem_in.mem_wstrb == 1) begin
          if (|soc.cpu_comp.memory_stage_comp.dmem_in.mem_wdata == 1) begin
            $finish;
          end
        end
      end
    end
  end

  always_comb begin

    irom_valid = 0;
    iprint_valid = 0;
    iclint_valid = 0;
    itim0_valid = 0;
    itim1_valid = 0;
    iram_valid = 0;

    ibase_addr = 0;

    if (imemory_valid == 1) begin
      if (imemory_addr >= ram_base_addr && imemory_addr < ram_top_addr) begin
          iram_valid = imemory_valid;
          ibase_addr = ram_base_addr;
      end else if (imemory_addr >= tim1_base_addr && imemory_addr < tim1_top_addr) begin
          itim1_valid = imemory_valid;
          ibase_addr = tim1_base_addr;
      end else if (imemory_addr >= tim0_base_addr && imemory_addr < tim0_top_addr) begin
          itim0_valid = imemory_valid;
          ibase_addr = tim0_base_addr;
      end else if (imemory_addr >= clint_base_addr && imemory_addr < clint_top_addr) begin
          iclint_valid = imemory_valid;
          ibase_addr = clint_base_addr;
      end else if (imemory_addr >= print_base_addr && imemory_addr < print_top_addr) begin
          iprint_valid = imemory_valid;
          ibase_addr = print_base_addr;
      end else if (imemory_addr >= rom_base_addr && imemory_addr < rom_top_addr) begin
          irom_valid = imemory_valid;
          ibase_addr = rom_base_addr;
      end
    end

    imem_addr = imemory_addr - ibase_addr;

    irom_instr = imemory_instr;
    irom_addr = imem_addr;
    irom_wdata = imemory_wdata;
    irom_wstrb = imemory_wstrb;

    iprint_instr = imemory_instr;
    iprint_addr = imem_addr;
    iprint_wdata = imemory_wdata;
    iprint_wstrb = imemory_wstrb;

    iclint_instr = imemory_instr;
    iclint_addr = imem_addr;
    iclint_wdata = imemory_wdata;
    iclint_wstrb = imemory_wstrb;

    itim0_instr = imemory_instr;
    itim0_addr = imem_addr;
    itim0_wdata = imemory_wdata;
    itim0_wstrb = imemory_wstrb;

    itim1_instr = imemory_instr;
    itim1_addr = imem_addr;
    itim1_wdata = imemory_wdata;
    itim1_wstrb = imemory_wstrb;

    iram_instr = imemory_instr;
    iram_addr = imem_addr;
    iram_wdata = imemory_wdata;
    iram_wstrb = imemory_wstrb;

    if (irom_ready == 1) begin
      imemory_rdata = irom_rdata;
      imemory_ready = irom_ready;
    end else if  (iprint_ready == 1) begin
      imemory_rdata = iprint_rdata;
      imemory_ready = iprint_ready;
    end else if  (iclint_ready == 1) begin
      imemory_rdata = iclint_rdata;
      imemory_ready = iclint_ready;
    end else if (itim0_ready == 1) begin
      imemory_rdata = itim0_rdata;
      imemory_ready = itim0_ready;
    end else if (itim1_ready == 1) begin
      imemory_rdata = itim1_rdata;
      imemory_ready = itim1_ready;
    end else if (iram_ready == 1) begin
      imemory_rdata = iram_rdata;
      imemory_ready = iram_ready;
    end else begin
      imemory_rdata = 0;
      imemory_ready = 0;
    end

  end

  always_comb begin

    drom_valid = 0;
    dprint_valid = 0;
    dclint_valid = 0;
    dtim0_valid = 0;
    dtim1_valid = 0;
    dram_valid = 0;

    dbase_addr = 0;

    if (dmemory_valid == 1) begin
      if (dmemory_addr >= ram_base_addr && dmemory_addr < ram_top_addr) begin
          dram_valid = dmemory_valid;
          dbase_addr = ram_base_addr;
      end else if (dmemory_addr >= tim1_base_addr && dmemory_addr < tim1_top_addr) begin
          dtim1_valid = dmemory_valid;
          dbase_addr = tim1_base_addr;
      end else if (dmemory_addr >= tim0_base_addr && dmemory_addr < tim0_top_addr) begin
          dtim0_valid = dmemory_valid;
          dbase_addr = tim0_base_addr;
      end else if (dmemory_addr >= clint_base_addr && dmemory_addr < clint_top_addr) begin
          dclint_valid = dmemory_valid;
          dbase_addr = clint_base_addr;
      end else if (dmemory_addr >= print_base_addr && dmemory_addr < print_top_addr) begin
          dprint_valid = dmemory_valid;
          dbase_addr = print_base_addr;
      end else if (dmemory_addr >= rom_base_addr && dmemory_addr < rom_top_addr) begin
          drom_valid = dmemory_valid;
          dbase_addr = rom_base_addr;
      end
    end

    dmem_addr = dmemory_addr - dbase_addr;

    drom_instr = dmemory_instr;
    drom_addr = dmem_addr;
    drom_wdata = dmemory_wdata;
    drom_wstrb = dmemory_wstrb;

    dprint_instr = dmemory_instr;
    dprint_addr = dmem_addr;
    dprint_wdata = dmemory_wdata;
    dprint_wstrb = dmemory_wstrb;

    dclint_instr = dmemory_instr;
    dclint_addr = dmem_addr;
    dclint_wdata = dmemory_wdata;
    dclint_wstrb = dmemory_wstrb;

    dtim0_instr = dmemory_instr;
    dtim0_addr = dmem_addr;
    dtim0_wdata = dmemory_wdata;
    dtim0_wstrb = dmemory_wstrb;

    dtim1_instr = dmemory_instr;
    dtim1_addr = dmem_addr;
    dtim1_wdata = dmemory_wdata;
    dtim1_wstrb = dmemory_wstrb;

    dram_instr = dmemory_instr;
    dram_addr = dmem_addr;
    dram_wdata = dmemory_wdata;
    dram_wstrb = dmemory_wstrb;

    if (drom_ready == 1) begin
      dmemory_rdata = drom_rdata;
      dmemory_ready = drom_ready;
    end else if  (dprint_ready == 1) begin
      dmemory_rdata = dprint_rdata;
      dmemory_ready = dprint_ready;
    end else if  (clint_ready == 1) begin
      dmemory_rdata = dclint_rdata;
      dmemory_ready = dclint_ready;
    end else if (dtim0_ready == 1) begin
      dmemory_rdata = dtim0_rdata;
      dmemory_ready = dtim0_ready;
    end else if (dtim1_ready == 1) begin
      dmemory_rdata = dtim1_rdata;
      dmemory_ready = dtim1_ready;
    end else if (dram_ready == 1) begin
      dmemory_rdata = dram_rdata;
      dmemory_ready = dram_ready;
    end else begin
      dmemory_rdata = 0;
      dmemory_ready = 0;
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

  arbiter arbiter_rom_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (irom_valid),
    .imemory_instr (irom_instr),
    .imemory_addr (irom_addr),
    .imemory_wdata (irom_wdata),
    .imemory_wstrb (irom_wstrb),
    .imemory_rdata (irom_rdata),
    .imemory_ready (irom_ready),
    .dmemory_valid (drom_valid),
    .dmemory_instr (drom_instr),
    .dmemory_addr (drom_addr),
    .dmemory_wdata (drom_wdata),
    .dmemory_wstrb (drom_wstrb),
    .dmemory_rdata (drom_rdata),
    .dmemory_ready (drom_ready),
    .memory_valid (rom_valid),
    .memory_instr (rom_instr),
    .memory_addr (rom_addr),
    .memory_wdata (rom_wdata),
    .memory_wstrb (rom_wstrb),
    .memory_rdata (rom_rdata),
    .memory_ready (rom_ready)
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

  arbiter arbiter_print_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (iprint_valid),
    .imemory_instr (iprint_instr),
    .imemory_addr (iprint_addr),
    .imemory_wdata (iprint_wdata),
    .imemory_wstrb (iprint_wstrb),
    .imemory_rdata (iprint_rdata),
    .imemory_ready (iprint_ready),
    .dmemory_valid (dprint_valid),
    .dmemory_instr (dprint_instr),
    .dmemory_addr (dprint_addr),
    .dmemory_wdata (dprint_wdata),
    .dmemory_wstrb (dprint_wstrb),
    .dmemory_rdata (dprint_rdata),
    .dmemory_ready (dprint_ready),
    .memory_valid (print_valid),
    .memory_instr (print_instr),
    .memory_addr (print_addr),
    .memory_wdata (print_wdata),
    .memory_wstrb (print_wstrb),
    .memory_rdata (print_rdata),
    .memory_ready (print_ready)
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

  arbiter arbiter_clint_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (iclint_valid),
    .imemory_instr (iclint_instr),
    .imemory_addr (iclint_addr),
    .imemory_wdata (iclint_wdata),
    .imemory_wstrb (iclint_wstrb),
    .imemory_rdata (iclint_rdata),
    .imemory_ready (iclint_ready),
    .dmemory_valid (dclint_valid),
    .dmemory_instr (dclint_instr),
    .dmemory_addr (dclint_addr),
    .dmemory_wdata (dclint_wdata),
    .dmemory_wstrb (dclint_wstrb),
    .dmemory_rdata (dclint_rdata),
    .dmemory_ready (dclint_ready),
    .memory_valid (clint_valid),
    .memory_instr (clint_instr),
    .memory_addr (clint_addr),
    .memory_wdata (clint_wdata),
    .memory_wstrb (clint_wstrb),
    .memory_rdata (clint_rdata),
    .memory_ready (clint_ready)
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

  arbiter arbiter_tim0_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (itim0_valid),
    .imemory_instr (itim0_instr),
    .imemory_addr (itim0_addr),
    .imemory_wdata (itim0_wdata),
    .imemory_wstrb (itim0_wstrb),
    .imemory_rdata (itim0_rdata),
    .imemory_ready (itim0_ready),
    .dmemory_valid (dtim0_valid),
    .dmemory_instr (dtim0_instr),
    .dmemory_addr (dtim0_addr),
    .dmemory_wdata (dtim0_wdata),
    .dmemory_wstrb (dtim0_wstrb),
    .dmemory_rdata (dtim0_rdata),
    .dmemory_ready (dtim0_ready),
    .memory_valid (tim0_valid),
    .memory_instr (tim0_instr),
    .memory_addr (tim0_addr),
    .memory_wdata (tim0_wdata),
    .memory_wstrb (tim0_wstrb),
    .memory_rdata (tim0_rdata),
    .memory_ready (tim0_ready)
  );

  tim tim0_comp
  (
    .reset (reset),
    .clock (clock),
    .tim_valid (tim0_valid),
    .tim_instr (tim0_instr),
    .tim_addr (tim0_addr),
    .tim_wdata (tim0_wdata),
    .tim_wstrb (tim0_wstrb),
    .tim_rdata (tim0_rdata),
    .tim_ready (tim0_ready)
  );

  arbiter arbiter_tim1_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (itim1_valid),
    .imemory_instr (itim1_instr),
    .imemory_addr (itim1_addr),
    .imemory_wdata (itim1_wdata),
    .imemory_wstrb (itim1_wstrb),
    .imemory_rdata (itim1_rdata),
    .imemory_ready (itim1_ready),
    .dmemory_valid (dtim1_valid),
    .dmemory_instr (dtim1_instr),
    .dmemory_addr (dtim1_addr),
    .dmemory_wdata (dtim1_wdata),
    .dmemory_wstrb (dtim1_wstrb),
    .dmemory_rdata (dtim1_rdata),
    .dmemory_ready (dtim1_ready),
    .memory_valid (tim1_valid),
    .memory_instr (tim1_instr),
    .memory_addr (tim1_addr),
    .memory_wdata (tim1_wdata),
    .memory_wstrb (tim1_wstrb),
    .memory_rdata (tim1_rdata),
    .memory_ready (tim1_ready)
  );

  tim tim1_comp
  (
    .reset (reset),
    .clock (clock),
    .tim_valid (tim1_valid),
    .tim_instr (tim1_instr),
    .tim_addr (tim1_addr),
    .tim_wdata (tim1_wdata),
    .tim_wstrb (tim1_wstrb),
    .tim_rdata (tim1_rdata),
    .tim_ready (tim1_ready)
  );

  arbiter arbiter_ram_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (iram_valid),
    .imemory_instr (iram_instr),
    .imemory_addr (iram_addr),
    .imemory_wdata (iram_wdata),
    .imemory_wstrb (iram_wstrb),
    .imemory_rdata (iram_rdata),
    .imemory_ready (iram_ready),
    .dmemory_valid (dram_valid),
    .dmemory_instr (dram_instr),
    .dmemory_addr (dram_addr),
    .dmemory_wdata (dram_wdata),
    .dmemory_wstrb (dram_wstrb),
    .dmemory_rdata (dram_rdata),
    .dmemory_ready (dram_ready),
    .memory_valid (ram_valid),
    .memory_instr (ram_instr),
    .memory_addr (ram_addr),
    .memory_wdata (ram_wdata),
    .memory_wstrb (ram_wstrb),
    .memory_rdata (ram_rdata),
    .memory_ready (ram_ready)
  );

  ram ram_comp
  (
    .reset (reset),
    .clock (clock),
    .ram_valid (ram_valid),
    .ram_instr (ram_instr),
    .ram_addr (ram_addr),
    .ram_wdata (ram_wdata),
    .ram_wstrb (ram_wstrb),
    .ram_rdata (ram_rdata),
    .ram_ready (ram_ready)
  );

endmodule
