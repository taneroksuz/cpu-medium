package wires;
  timeunit 1ns;
  timeprecision 1ps;

  import fp_wire::*;

  typedef struct packed{
    logic [0:0] bit_sh1add;
    logic [0:0] bit_sh2add;
    logic [0:0] bit_sh3add;
  } zba_op_type;

  parameter zba_op_type init_zba_op = '{
    bit_sh1add : 0,
    bit_sh2add : 0,
    bit_sh3add : 0
  };

  typedef struct packed{
    logic [0:0] bit_andn;
    logic [0:0] bit_orn;
    logic [0:0] bit_xnor;
    logic [0:0] bit_clz;
    logic [0:0] bit_cpop;
    logic [0:0] bit_ctz;
    logic [0:0] bit_max;
    logic [0:0] bit_maxu;
    logic [0:0] bit_min;
    logic [0:0] bit_minu;
    logic [0:0] bit_orcb;
    logic [0:0] bit_rev8;
    logic [0:0] bit_rol;
    logic [0:0] bit_ror;
    logic [0:0] bit_sextb;
    logic [0:0] bit_sexth;
    logic [0:0] bit_zexth;
  } zbb_op_type;

  parameter zbb_op_type init_zbb_op = '{
    bit_andn  : 0,
    bit_orn   : 0,
    bit_xnor  : 0,
    bit_clz   : 0,
    bit_cpop  : 0,
    bit_ctz   : 0,
    bit_max   : 0,
    bit_maxu  : 0,
    bit_min   : 0,
    bit_minu  : 0,
    bit_orcb  : 0,
    bit_rev8  : 0,
    bit_rol   : 0,
    bit_ror   : 0,
    bit_sextb : 0,
    bit_sexth : 0,
    bit_zexth : 0
  };

  typedef struct packed{
    logic [0:0] bit_clmul_;
    logic [0:0] bit_clmulh;
    logic [0:0] bit_clmulr;
  } zbc_op_type;

  parameter zbc_op_type init_zbc_op = '{
    bit_clmul_ : 0,
    bit_clmulh : 0,
    bit_clmulr : 0
  };

  typedef struct packed{
    logic [0:0] bit_bclr;
    logic [0:0] bit_bext;
    logic [0:0] bit_binv;
    logic [0:0] bit_bset;
  } zbs_op_type;

  parameter zbs_op_type init_zbs_op = '{
    bit_bclr : 0,
    bit_bext : 0,
    bit_binv : 0,
    bit_bset : 0
  };

  typedef struct packed{
    logic [0:0] bit_imm;
    logic [0:0] bit_alu_;
    logic [0:0] bit_clmul_;
    zba_op_type bit_zba;
    zbb_op_type bit_zbb;
    zbc_op_type bit_zbc;
    zbs_op_type bit_zbs;
  } bit_op_type;

  parameter bit_op_type init_bit_op = '{
    bit_imm    : 0,
    bit_alu_   : 0,
    bit_clmul_ : 0,
    bit_zba    : init_zba_op,
    bit_zbb    : init_zbb_op,
    bit_zbc    : init_zbc_op,
    bit_zbs    : init_zbs_op
  };

  typedef struct packed{
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [31:0] imm;
    logic [0:0] sel;
    bit_op_type bit_op;
  } bit_alu_in_type;

  typedef struct packed{
    logic [31:0] result;
  } bit_alu_out_type;

  typedef struct packed{
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [0:0] enable;
    zbc_op_type op;
  } bit_clmul_in_type;

  typedef struct packed{
    logic [31:0] result;
    logic [0:0] ready;
  } bit_clmul_out_type;

  typedef struct packed{
    logic [1:0] state;
    logic [4:0] counter;
    logic [5:0] index;
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [31:0] swap;
    logic [31:0] result;
    logic [0:0] ready;
    zbc_op_type op;
  } bit_clmul_reg_type;

  parameter bit_clmul_reg_type init_bit_clmul_reg = '{
    state   : 0,
    counter : 0,
    index   : 0,
    rdata1  : 0,
    rdata2  : 0,
    swap    : 0,
    result  : 0,
    ready   : 0,
    op      : init_zbc_op
  };

  typedef struct packed{
    logic [0 : 0] alu_add;
    logic [0 : 0] alu_sub;
    logic [0 : 0] alu_sll;
    logic [0 : 0] alu_srl;
    logic [0 : 0] alu_sra;
    logic [0 : 0] alu_slt;
    logic [0 : 0] alu_sltu;
    logic [0 : 0] alu_and;
    logic [0 : 0] alu_or;
    logic [0 : 0] alu_xor;
  } alu_op_type;

  parameter alu_op_type init_alu_op = '{
    alu_add : 0,
    alu_sub : 0,
    alu_sll : 0,
    alu_srl : 0,
    alu_sra : 0,
    alu_slt : 0,
    alu_sltu : 0,
    alu_and : 0,
    alu_or : 0,
    alu_xor : 0
  };

  typedef struct packed{
    logic [0 : 0] divs;
    logic [0 : 0] divu;
    logic [0 : 0] rem;
    logic [0 : 0] remu;
  } div_op_type;

  parameter div_op_type init_div_op = '{
    divs : 0,
    divu : 0,
    rem : 0,
    remu : 0
  };

  typedef struct packed{
    logic [0 : 0] muls;
    logic [0 : 0] mulh;
    logic [0 : 0] mulhsu;
    logic [0 : 0] mulhu;
  } mul_op_type;

  parameter mul_op_type init_mul_op = '{
    muls : 0,
    mulh : 0,
    mulhsu : 0,
    mulhu : 0
  };

  typedef struct packed{
    logic [0 : 0] lsu_lb;
    logic [0 : 0] lsu_lbu;
    logic [0 : 0] lsu_lh;
    logic [0 : 0] lsu_lhu;
    logic [0 : 0] lsu_lw;
    logic [0 : 0] lsu_sb;
    logic [0 : 0] lsu_sh;
    logic [0 : 0] lsu_sw;
  } lsu_op_type;

  parameter lsu_op_type init_lsu_op = '{
    lsu_lb : 0,
    lsu_lbu : 0,
    lsu_lh : 0,
    lsu_lhu : 0,
    lsu_lw : 0,
    lsu_sb : 0,
    lsu_sh : 0,
    lsu_sw : 0
  };

  typedef struct packed{
    logic [0 : 0] bcu_beq;
    logic [0 : 0] bcu_bne;
    logic [0 : 0] bcu_blt;
    logic [0 : 0] bcu_bge;
    logic [0 : 0] bcu_bltu;
    logic [0 : 0] bcu_bgeu;
  } bcu_op_type;

  parameter bcu_op_type init_bcu_op = '{
    bcu_beq : 0,
    bcu_bne : 0,
    bcu_blt : 0,
    bcu_bge : 0,
    bcu_bltu : 0,
    bcu_bgeu : 0
  };

  typedef struct packed{
    logic [0 : 0] csrrw;
    logic [0 : 0] csrrs;
    logic [0 : 0] csrrc;
    logic [0 : 0] csrrwi;
    logic [0 : 0] csrrsi;
    logic [0 : 0] csrrci;
  } csr_op_type;

  parameter csr_op_type init_csr_op = '{
    csrrw : 0,
    csrrs : 0,
    csrrc : 0,
    csrrwi : 0,
    csrrsi : 0,
    csrrci : 0
  };

  typedef struct packed{
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
    logic [31 : 0] imm;
    logic [0  : 0] sel;
    alu_op_type alu_op;
  } alu_in_type;

  typedef struct packed{
    logic [31 : 0] result;
  } alu_out_type;

  typedef struct packed{
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
    logic [0  : 0] enable;
    div_op_type div_op;
  } div_in_type;

  typedef struct packed{
    logic [31 : 0] result;
    logic [0  : 0] ready;
  } div_out_type;

  typedef struct packed{
    logic [31 : 0] data1;
    logic [31 : 0] data2;
    logic [31 : 0] op1;
    logic [31 : 0] op2;
    logic [0  : 0] op1_signed;
    logic [0  : 0] op2_signed;
    logic [0  : 0] op1_neg;
    logic [5  : 0] counter;
    logic [64 : 0] result;
    logic [0  : 0] division;
    logic [0  : 0] negativ;
    logic [0  : 0] divisionbyzero;
    logic [0  : 0] overflow;
    logic [0  : 0] ready;
    div_op_type div_op;
  } div_reg_type;

  parameter div_reg_type init_div_reg = '{
    data1 : 0,
    data2 : 0,
    op1 : 0,
    op2 : 0,
    op1_signed : 0,
    op2_signed : 0,
    op1_neg : 0,
    counter : 0,
    result : 0,
    division : 0,
    negativ : 0,
    divisionbyzero : 0,
    overflow : 0,
    ready : 0,
    div_op : init_div_op
  };

  typedef struct packed{
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
    mul_op_type mul_op;
  } mul_in_type;

  typedef struct packed{
    logic [31 : 0] result;
  } mul_out_type;

  typedef struct packed{
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
    logic [0  : 0] enable;
    bcu_op_type bcu_op;
  } bcu_in_type;

  typedef struct packed{
    logic [0 : 0] branch;
  } bcu_out_type;

  typedef struct packed{
    logic [31 : 0] rdata1;
    logic [31 : 0] imm;
    logic [31 : 0] pc;
    logic [0  : 0] auipc;
    logic [0  : 0] jal;
    logic [0  : 0] jalr;
    logic [0  : 0] branch;
    logic [0  : 0] load;
    logic [0  : 0] store;
    lsu_op_type lsu_op;
  } agu_in_type;

  typedef struct packed{
    logic [31 : 0] address;
    logic [3  : 0] byteenable;
    logic [0  : 0] exception;
    logic [3  : 0] ecause;
    logic [31 : 0] etval;
  } agu_out_type;

  typedef struct packed{
    logic [31 : 0] ldata;
    logic [3  : 0] byteenable;
    lsu_op_type lsu_op;
  } lsu_in_type;

  typedef struct packed{
    logic [31 : 0] result;
  } lsu_out_type;

  typedef struct packed{
    logic [31 : 0] cdata;
    logic [31 : 0] rdata1;
    logic [31 : 0] imm;
    logic [0  : 0] sel;
    csr_op_type csr_op;
  } csr_alu_in_type;

  typedef struct packed{
    logic [31 : 0] cdata;
  } csr_alu_out_type;

  typedef struct packed{
    logic [31 : 0] get_pc0;
    logic [31 : 0] get_pc1;
    logic [31 : 0] upd_pc0;
    logic [31 : 0] upd_pc1;
    logic [31 : 0] upd_npc0;
    logic [31 : 0] upd_npc1;
    logic [31 : 0] upd_addr0;
    logic [31 : 0] upd_addr1;
    logic [0  : 0] upd_jal0;
    logic [0  : 0] upd_jal1;
    logic [0  : 0] upd_jalr0;
    logic [0  : 0] upd_jalr1;
    logic [0  : 0] upd_branch0;
    logic [0  : 0] upd_branch1;
    logic [0  : 0] upd_jump0;
    logic [0  : 0] upd_jump1;
    logic [0  : 0] stall;
    logic [0  : 0] clear;
  } btac_in_type;

  typedef struct packed{
    logic [31 : 0] pred_baddr;
    logic [0  : 0] pred_branch;
    logic [31 : 0] pred_pc;
    logic [31 : 0] pred_npc;
    logic [31 : 0] pred_maddr;
    logic [0  : 0] pred_miss;
    logic [0  : 0] pred_hazard;
  } btac_out_type;

  typedef struct packed{
    logic [0  : 0] wren;
    logic [0  : 0] rden1;
    logic [0  : 0] rden2;
    logic [0  : 0] cwren;
    logic [0  : 0] crden;
    logic [0  : 0] fwren;
    logic [0  : 0] frden1;
    logic [0  : 0] frden2;
    logic [0  : 0] frden3;
    logic [0  : 0] alu;
    logic [0  : 0] auipc;
    logic [0  : 0] lui;
    logic [0  : 0] jal;
    logic [0  : 0] jalr;
    logic [0  : 0] branch;
    logic [0  : 0] load;
    logic [0  : 0] store;
    logic [0  : 0] fload;
    logic [0  : 0] fstore;
    logic [0  : 0] nop;
    logic [0  : 0] csreg;
    logic [0  : 0] division;
    logic [0  : 0] mult;
    logic [0  : 0] bitm;
    logic [0  : 0] bitc;
    logic [0  : 0] fence;
    logic [0  : 0] ecall;
    logic [0  : 0] ebreak;
    logic [0  : 0] mret;
    logic [0  : 0] wfi;
    logic [0  : 0] fpu;
    logic [0  : 0] fpuc;
    logic [0  : 0] fpuf;
    logic [0  : 0] jump;
    logic [0  : 0] exception;
    logic [0  : 0] valid;
  } operation_type;

  parameter operation_type init_operation = '{
    wren : 0,
    rden1 : 0,
    rden2 : 0,
    cwren : 0,
    crden : 0,
    fwren : 0,
    frden1 : 0,
    frden2 : 0,
    frden3 : 0,
    alu : 0,
    auipc : 0,
    lui : 0,
    jal : 0,
    jalr : 0,
    branch : 0,
    load : 0,
    store : 0,
    fload : 0,
    fstore : 0,
    nop : 0,
    csreg : 0,
    division : 0,
    mult : 0,
    bitm : 0,
    bitc : 0,
    fence : 0,
    ecall : 0,
    ebreak : 0,
    mret : 0,
    wfi : 0,
    fpu : 0,
    fpuc : 0,
    fpuf : 0,
    jump : 0,
    exception : 0,
    valid : 0
  };

  typedef struct packed{
    logic [31 : 0] pc;
    logic [31 : 0] npc;
    logic [31 : 0] instr;
    logic [47 : 0] instr_str;
    logic [31 : 0] imm;
    logic [4  : 0] waddr;
    logic [4  : 0] raddr1;
    logic [4  : 0] raddr2;
    logic [4  : 0] raddr3;
    logic [11 : 0] caddr;
    logic [1  : 0] fmt;
    logic [2  : 0] rm;
    operation_type op;
    operation_type op_b;
    alu_op_type alu_op;
    bcu_op_type bcu_op;
    lsu_op_type lsu_op;
    csr_op_type csr_op;
    div_op_type div_op;
    mul_op_type mul_op;
    bit_op_type bit_op;
    fp_operation_type fpu_op;
  } instruction_type;

  parameter instruction_type init_instruction = '{
    pc : 32'hFFFFFFFF,
    npc : 32'hFFFFFFFF,
    instr : 0,
    instr_str : "",
    imm : 0,
    waddr : 0,
    raddr1 : 0,
    raddr2 : 0,
    raddr3 : 0,
    caddr : 0,
    fmt : 0,
    rm : 0,
    op : init_operation,
    op_b : init_operation,
    alu_op : init_alu_op,
    bcu_op : init_bcu_op,
    lsu_op : init_lsu_op,
    csr_op : init_csr_op,
    div_op : init_div_op,
    mul_op : init_mul_op,
    bit_op : init_bit_op,
    fpu_op : init_fp_operation
  };

  typedef struct packed{
    logic [0  : 0] taken;
    logic [31 : 0] taddr;
    logic [31 : 0] tpc;
    logic [31 : 0] tnpc;
  } prediction_type;

  parameter prediction_type init_prediction = '{
    taken : 0,
    taddr : 0,
    tpc : 0,
    tnpc : 0
  };

  typedef struct packed{
    logic [31 : 0] pc;
    logic [31 : 0] npc;
    logic [31 : 0] instr;
    logic [31 : 0] imm;
    logic [4  : 0] waddr;
    logic [4  : 0] raddr1;
    logic [4  : 0] raddr2;
    logic [4  : 0] raddr3;
    logic [11 : 0] caddr;
    logic [1  : 0] fmt;
    logic [2  : 0] rm;
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
    logic [31 : 0] frdata1;
    logic [31 : 0] frdata2;
    logic [31 : 0] frdata3;
    logic [31 : 0] cdata;
    logic [31 : 0] bdata;
    logic [31 : 0] mdata;
    logic [31 : 0] wdata;
    logic [31 : 0] fdata;
    logic [31 : 0] ldata;
    logic [31 : 0] sdata;
    logic [31 : 0] ddata;
    logic [31 : 0] bcdata;
    logic [0  : 0] fready;
    logic [0  : 0] dready;
    logic [0  : 0] bcready;
    logic [31 : 0] address;
    logic [3  : 0] byteenable;
    logic [3  : 0] ecause;
    logic [31 : 0] etval;
    logic [4  : 0] flags;
    operation_type op;
    operation_type op_b;
    alu_op_type alu_op;
    bcu_op_type bcu_op;
    lsu_op_type lsu_op;
    csr_op_type csr_op;
    div_op_type div_op;
    mul_op_type mul_op;
    bit_op_type bit_op;
    fp_operation_type fpu_op;
  } calculation_type;

  parameter calculation_type init_calculation = '{
    pc : 32'hFFFFFFFF,
    npc : 32'hFFFFFFFF,
    instr : 0,
    imm : 0,
    waddr : 0,
    raddr1 : 0,
    raddr2 : 0,
    raddr3 : 0,
    caddr : 0,
    fmt : 0,
    rm : 0,
    rdata1 : 0,
    rdata2 : 0,
    frdata1 : 0,
    frdata2 : 0,
    frdata3 : 0,
    cdata : 0,
    bdata : 0,
    mdata : 0,
    wdata : 0,
    fdata : 0,
    sdata : 0,
    ldata : 0,
    ddata : 0,
    bcdata : 0,
    fready : 0,
    dready : 0,
    bcready : 0,
    address : 0,
    byteenable : 0,
    ecause : 0,
    etval : 0,
    flags : 0,
    op : init_operation,
    op_b : init_operation,
    alu_op : init_alu_op,
    bcu_op : init_bcu_op,
    lsu_op : init_lsu_op,
    csr_op : init_csr_op,
    div_op : init_div_op,
    mul_op : init_mul_op,
    bit_op : init_bit_op,
    fpu_op : init_fp_operation
  };

  typedef struct packed{
    instruction_type instr0;
    instruction_type instr1;
    logic [0  : 0] clear;
    logic [0  : 0] stall;
  } hazard_in_type;

  typedef struct packed{
    calculation_type calc0;
    calculation_type calc1;
    logic [0  : 0] stall;
  } hazard_out_type;

  typedef struct packed{
    logic [31 : 0] instr;
  } decoder_in_type;

  typedef struct packed{
    logic [47 : 0] instr_str;
    logic [31 : 0] imm;
    logic [0  : 0] wren;
    logic [0  : 0] rden1;
    logic [0  : 0] rden2;
    logic [0  : 0] cwren;
    logic [0  : 0] crden;
    logic [0  : 0] alu;
    logic [0  : 0] auipc;
    logic [0  : 0] lui;
    logic [0  : 0] jal;
    logic [0  : 0] jalr;
    logic [0  : 0] branch;
    logic [0  : 0] load;
    logic [0  : 0] store;
    logic [0  : 0] nop;
    logic [0  : 0] csreg;
    logic [0  : 0] division;
    logic [0  : 0] mult;
    logic [0  : 0] bitm;
    logic [0  : 0] bitc;
    logic [0  : 0] fence;
    logic [0  : 0] ecall;
    logic [0  : 0] ebreak;
    logic [0  : 0] mret;
    logic [0  : 0] wfi;
    logic [0  : 0] valid;
    alu_op_type alu_op;
    bcu_op_type bcu_op;
    lsu_op_type lsu_op;
    csr_op_type csr_op;
    div_op_type div_op;
    mul_op_type mul_op;
    bit_op_type bit_op;
  } decoder_out_type;

  typedef struct packed{
    logic [31 : 0] instr;
  } fp_decode_in_type;

  typedef struct packed{
    logic [47 : 0] instr_str;
    logic [31 : 0] imm;
    logic [0  : 0] wren;
    logic [0  : 0] rden1;
    logic [0  : 0] fwren;
    logic [0  : 0] frden1;
    logic [0  : 0] frden2;
    logic [0  : 0] frden3;
    logic [0  : 0] fload;
    logic [0  : 0] fstore;
    logic [1  : 0] fmt;
    logic [2  : 0] rm;
    logic [0  : 0] fpu;
    logic [0  : 0] fpuc;
    logic [0  : 0] fpuf;
    logic [0  : 0] valid;
    lsu_op_type lsu_op;
    fp_operation_type fpu_op;
  } fp_decode_out_type;

  typedef struct packed{
    logic [31 : 0] data1;
    logic [31 : 0] data2;
    logic [31 : 0] data3;
    fp_operation_type fpu_op;
    logic [1  : 0] fmt;
    logic [2  : 0] rm;
    logic [0  : 0] enable;
  } fp_execute_in_type;

  typedef struct packed{
    logic [31 : 0] result;
    logic [4  : 0] flags;
    logic [0  : 0] ready;
  } fp_execute_out_type;

  typedef struct packed{
    logic [0  : 0] rden1;
    logic [4  : 0] raddr1;
    logic [0  : 0] rden2;
    logic [4  : 0] raddr2;
    logic [0  : 0] rden3;
    logic [4  : 0] raddr3;
  } fp_register_read_in_type;

  typedef struct packed{
    logic [0  : 0] wren;
    logic [4  : 0] waddr;
    logic [31 : 0] wdata;
  } fp_register_write_in_type;

  typedef struct packed{
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
    logic [31 : 0] rdata3;
  } fp_register_out_type;

  typedef struct packed{
    logic [0  : 0] rden1;
    logic [4  : 0] raddr1;
    logic [0  : 0] rden2;
    logic [4  : 0] raddr2;
  } register_read_in_type;

  typedef struct packed{
    logic [0  : 0] wren;
    logic [4  : 0] waddr;
    logic [31 : 0] wdata;
  } register_write_in_type;

  typedef struct packed{
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
  } register_out_type;

  typedef struct packed{
    logic [31 : 0] pc;
    logic [63 : 0] rdata;
    logic [0  : 0] ready;
  } fetch_out_type;

  typedef struct packed{
    logic [31 : 0] pc;
    logic [63 : 0] rdata;
    logic [0  : 0] ready;
    logic [0  : 0] valid;
    logic [0  : 0] fence;
    logic [0  : 0] spec;
    logic [1  : 0] state;
    logic [0  : 0] stall;
  } fetch_reg_type;

  parameter fetch_reg_type init_fetch_reg = '{
    pc : 0,
    rdata : 0,
    ready : 0,
    valid : 0,
    fence : 0,
    spec : 0,
    state : 0,
    stall : 0
  };

  typedef struct packed{
    instruction_type instr0;
    instruction_type instr1;
    logic [0  : 0] stall;
  } decode_out_type;

  typedef struct packed{
    instruction_type instr0;
    instruction_type instr1;
    logic [0  : 0] stall;
    logic [0  : 0] clear;
  } decode_reg_type;

  parameter decode_reg_type init_decode_reg = '{
    instr0 : init_instruction,
    instr1 : init_instruction,
    stall : 0,
    clear : 0
  };

  typedef struct packed{
    calculation_type calc0;
    calculation_type calc1;
    logic [0  : 0] halt;
    logic [0  : 0] stall;
  } issue_out_type;

  typedef struct packed{
    calculation_type calc0;
    calculation_type calc1;
    logic [0  : 0] halt;
    logic [0  : 0] stall;
    logic [0  : 0] clear;
  } issue_reg_type;

  parameter issue_reg_type init_issue_reg = '{
    calc0 : init_calculation,
    calc1 : init_calculation,
    halt : 0,
    stall : 0,
    clear : 0
  };

  typedef struct packed{
    calculation_type calc0;
    calculation_type calc1;
    logic [0  : 0] stall;
  } execute_out_type;

  typedef struct packed{
    calculation_type calc0;
    calculation_type calc1;
    logic [0  : 0] enable;
    logic [0  : 0] stall;
    logic [0  : 0] clear;
  } execute_reg_type;

  parameter execute_reg_type init_execute_reg = '{
    calc0 : init_calculation,
    calc1 : init_calculation,
    enable : 0,
    stall : 0,
    clear : 0
  };

  typedef struct packed{
    calculation_type calc0;
    calculation_type calc1;
    logic [0  : 0] stall;
  } memory_out_type;

  typedef struct packed{
    calculation_type calc0;
    calculation_type calc1;
    logic [0  : 0] stall;
    logic [0  : 0] clear;
  } memory_reg_type;

  parameter memory_reg_type init_memory_reg = '{
    calc0 : init_calculation,
    calc1 : init_calculation,
    stall : 0,
    clear : 0
  };

  typedef struct packed{
    logic [0  : 0] stall;
    logic [0  : 0] clear;
  } writeback_out_type;

  typedef struct packed{
    calculation_type calc0;
    calculation_type calc1;
    logic [0  : 0] stall;
    logic [0  : 0] clear;
  } writeback_reg_type;

  parameter writeback_reg_type init_writeback_reg = '{
    calc0 : init_calculation,
    calc1 : init_calculation,
    stall : 0,
    clear : 1
  };

  typedef struct packed{
    logic [11:11] meip;
    logic [9:9] seip;
    logic [8:8] ueip;
    logic [7:7] mtip;
    logic [5:5] stip;
    logic [4:4] utip;
    logic [3:3] msip;
    logic [1:1] ssip;
    logic [0:0] usip;
  } csr_mip_reg_type;

  parameter csr_mip_reg_type init_csr_mip_reg = '{
    meip : 0,
    seip : 0,
    ueip : 0,
    mtip : 0,
    stip : 0,
    utip : 0,
    msip : 0,
    ssip : 0,
    usip : 0
  };

  typedef struct packed{
    logic [11:11] meie;
    logic [9:9] seie;
    logic [8:8] ueie;
    logic [7:7] mtie;
    logic [5:5] stie;
    logic [4:4] utie;
    logic [3:3] msie;
    logic [1:1] ssie;
    logic [0:0] usie;
  } csr_mie_reg_type;

  parameter csr_mie_reg_type init_csr_mie_reg = '{
    meie : 0,
    seie : 0,
    ueie : 0,
    mtie : 0,
    stie : 0,
    utie : 0,
    msie : 0,
    ssie : 0,
    usie : 0
  };

  typedef struct packed{
    logic [31:31] sd;
    logic [22:22] tsr;
    logic [21:21] tw;
    logic [20:20] tvm;
    logic [19:19] mxr;
    logic [18:18] sum;
    logic [17:17] mprv;
    logic [16:15] xs;
    logic [14:13] fs;
    logic [12:11] mpp;
    logic [8:8] spp;
    logic [7:7] mpie;
    logic [5:5] spie;
    logic [4:4] upie;
    logic [3:3] mie;
    logic [1:1] sie;
    logic [0:0] uie;
  } csr_mstatus_reg_type;

  parameter csr_mstatus_reg_type init_csr_mstatus_reg = '{
    sd : 0,
    tsr : 0,
    tw : 0,
    tvm : 0,
    mxr : 0,
    sum : 0,
    mprv : 0,
    xs : 0,
    fs : 0,
    mpp : 0,
    spp : 0,
    mpie : 0,
    spie : 0,
    upie : 0,
    mie : 0,
    sie : 0,
    uie : 0
  };

  typedef struct packed{
    csr_mstatus_reg_type mstatus;
    logic [31 : 0] mtvec;
    logic [63 : 0] mcycle;
    logic [63 : 0] minstret;
    logic [31 : 0] mscratch;
    logic [31 : 0] mepc;
    logic [31 : 0] mcause;
    logic [31 : 0] mtval;
    csr_mip_reg_type mip;
    csr_mie_reg_type mie;
  } csr_machine_reg_type;

  parameter csr_machine_reg_type init_csr_machine_reg = '{
    mstatus : init_csr_mstatus_reg,
    mtvec : 0,
    mscratch : 0,
    mepc : 0,
    mcause : 0,
    mtval : 0,
    mcycle : 0,
    minstret : 0,
    mip : init_csr_mip_reg,
    mie : init_csr_mie_reg
  };

  typedef struct packed{
    logic [0  : 0] crden;
    logic [11 : 0] craddr;
  } fp_csr_read_in_type;

  typedef struct packed{
    logic [0  : 0] cwren;
    logic [11 : 0] cwaddr;
    logic [31 : 0] cdata;
  } fp_csr_write_in_type;

  typedef struct packed{
    logic [0  : 0] fpu;
    logic [4  : 0] fflags;
  } fp_csr_exception_in_type;

  typedef struct packed{
    logic [31 : 0] cdata;
    logic [0  : 0] ready;
    logic [2  : 0] frm;
  } fp_csr_out_type;

  typedef struct packed{
    logic [0  : 0] crden;
    logic [11 : 0] craddr;
  } csr_read_in_type;

  typedef struct packed{
    logic [0  : 0] cwren;
    logic [11 : 0] cwaddr;
    logic [31 : 0] cdata;
  } csr_write_in_type;

  typedef struct packed{
    logic [0  : 0] valid;
    logic [0  : 0] mret;
    logic [0  : 0] exception;
    logic [31 : 0] epc;
    logic [3  : 0] ecause;
    logic [31 : 0] etval;
  } csr_exception_in_type;

  typedef struct packed{
    logic [0  : 0] trap;
    logic [0  : 0] mret;
    logic [31 : 0] mtvec;
    logic [31 : 0] mepc;
    logic [31 : 0] cdata;
    logic [1  : 0] fs;
  } csr_out_type;

  typedef struct packed{
    logic [0  : 0] rden1;
    logic [0  : 0] rden2;
    logic [0  : 0] rden3;
    logic [4  : 0] raddr1;
    logic [4  : 0] raddr2;
    logic [4  : 0] raddr3;
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
    logic [31 : 0] rdata3;
  } fp_forwarding_register_in_type;

  typedef struct packed{
    logic [0  : 0] wren;
    logic [4  : 0] waddr;
    logic [31 : 0] wdata;
  } fp_forwarding_memory_in_type;

  typedef struct packed{
    logic [0  : 0] wren;
    logic [4  : 0] waddr;
    logic [31 : 0] wdata;
  } fp_forwarding_writeback_in_type;

  typedef struct packed{
    logic [31 : 0] data1;
    logic [31 : 0] data2;
    logic [31 : 0] data3;
  } fp_forwarding_out_type;

  typedef struct packed{
    logic [0  : 0] rden1;
    logic [0  : 0] rden2;
    logic [4  : 0] raddr1;
    logic [4  : 0] raddr2;
    logic [31 : 0] rdata1;
    logic [31 : 0] rdata2;
  } forwarding_register_in_type;

  typedef struct packed{
    logic [0  : 0] wren;
    logic [4  : 0] waddr;
    logic [31 : 0] wdata;
  } forwarding_memory_in_type;

  typedef struct packed{
    logic [0  : 0] wren;
    logic [4  : 0] waddr;
    logic [31 : 0] wdata;
  } forwarding_writeback_in_type;

  typedef struct packed{
    logic [31 : 0] data1;
    logic [31 : 0] data2;
  } forwarding_out_type;

  typedef struct packed{
    fetch_out_type f;
    decode_out_type d;
    issue_out_type i;
    execute_out_type e;
    memory_out_type m;
    writeback_out_type w;
  } fetch_in_type;

  typedef struct packed{
    fetch_out_type f;
    decode_out_type d;
    issue_out_type i;
    execute_out_type e;
    memory_out_type m;
    writeback_out_type w;
  } issue_in_type;

  typedef struct packed{
    fetch_out_type f;
    decode_out_type d;
    issue_out_type i;
    execute_out_type e;
    memory_out_type m;
    writeback_out_type w;
  } decode_in_type;

  typedef struct packed{
    fetch_out_type f;
    decode_out_type d;
    issue_out_type i;
    execute_out_type e;
    memory_out_type m;
    writeback_out_type w;
  } execute_in_type;

  typedef struct packed{
    fetch_out_type f;
    decode_out_type d;
    issue_out_type i;
    execute_out_type e;
    memory_out_type m;
    writeback_out_type w;
  } memory_in_type;

  typedef struct packed{
    fetch_out_type f;
    decode_out_type d;
    issue_out_type i;
    execute_out_type e;
    memory_out_type m;
    writeback_out_type w;
  } writeback_in_type;

  typedef struct packed{
    fp_decode_in_type fp_decode0_in;
    fp_decode_in_type fp_decode1_in;
    fp_execute_in_type fp_execute_in;
    fp_register_read_in_type fp_register_rin;
    fp_register_write_in_type fp_register_win;
    fp_csr_read_in_type fp_csr_rin;
    fp_csr_write_in_type fp_csr_win;
    fp_csr_exception_in_type fp_csr_ein;
    fp_forwarding_register_in_type fp_forwarding_rin;
    fp_forwarding_memory_in_type fp_forwarding_min;
    fp_forwarding_writeback_in_type fp_forwarding_win;
  } fpu_in_type;

  typedef struct packed{
    fp_decode_out_type fp_decode0_out;
    fp_decode_out_type fp_decode1_out;
    fp_execute_out_type fp_execute_out;
    fp_register_out_type fp_register_out;
    fp_csr_out_type fp_csr_out;
    fp_forwarding_out_type fp_forwarding_out;
  } fpu_out_type;

  typedef struct packed{
    logic [0  : 0] mem_valid;
    logic [0  : 0] mem_fence;
    logic [0  : 0] mem_spec;
    logic [0  : 0] mem_instr;
    logic [31 : 0] mem_addr;
    logic [63 : 0] mem_wdata;
    logic [3  : 0] mem_wstrb;
  } itim_in_type;

  typedef struct packed{
    logic [0  : 0] mem_ready;
    logic [63 : 0] mem_rdata;
  } itim_out_type;

  typedef struct packed{
    logic [0  : 0] mem_valid;
    logic [0  : 0] mem_fence;
    logic [0  : 0] mem_spec;
    logic [0  : 0] mem_instr;
    logic [31 : 0] mem_addr;
    logic [31 : 0] mem_wdata;
    logic [3  : 0] mem_wstrb;
  } dtim_in_type;

  typedef struct packed{
    logic [0  : 0] mem_ready;
    logic [31 : 0] mem_rdata;
  } dtim_out_type;

  typedef struct packed{
    logic [0  : 0] mem_valid;
    logic [0  : 0] mem_fence;
    logic [0  : 0] mem_spec;
    logic [0  : 0] mem_instr;
    logic [31 : 0] mem_addr;
    logic [31 : 0] mem_wdata;
    logic [3  : 0] mem_wstrb;
  } mem_in_type;

  typedef struct packed{
    logic [0  : 0] mem_ready;
    logic [31 : 0] mem_rdata;
  } mem_out_type;

endpackage
