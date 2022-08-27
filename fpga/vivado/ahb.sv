import configure::*;

module ahb
(
  input logic rst,
  input logic clk,
  /////////////////////////////////
  input logic [0   : 0] ahb_valid,
  input logic [0   : 0] ahb_instr,
  input logic [31  : 0] ahb_addr,
  input logic [31  : 0] ahb_wdata,
  input logic [3   : 0] ahb_wstrb,
  output logic [31 : 0] ahb_rdata,
  output logic [0  : 0] ahb_ready
  /////////////////////////////////
  output logic m_ahb_hclk,
  output logic m_ahb_hresetn,
  /////////////////////////////////
  output logic [31 : 0] m_ahb_haddr,
  output logic [2  : 0] m_ahb_hbrust,
  output logic [0  : 0] m_ahb_hmastlock,
  output logic [3  : 0] m_ahb_hprot,
  output logic [2  : 0] m_ahb_hsize,
  output logic [1  : 0] m_ahb_htrans,
  output logic [31 : 0] m_ahb_hwdata,
  output logic [0  : 0] m_ahb_hwrite,
  /////////////////////////////////
  input logic [31 : 0] m_ahb_hrdata,
  input logic [0  : 0] m_ahb_hready,
  input logic [0  : 0] m_ahb_hresp
  /////////////////////////////////
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 :0] state;
  logic [0 :0] state_n;

  logic [31:0] haddr;
  logic [31:0] haddr_n;
  logic [31:0] hwdata;
  logic [31:0] hwdata_n;
  logic [0 :0] hwrite;
  logic [0 :0] hwrite_n;
  logic [3 :0] hprot;
  logic [3 :0] hprot_n;
  logic [1 :0] htrans;
  logic [1 :0] htrans_n;

  assign haddr = state == 0 ? ahb_addr : haddr_n;
  assign hprot = state == 0 ? {3'b000,~ahb_instr} : hprot_n;
  assign htrans = state == 0 ? {ahb_valid,1'b0} : htrans_n;
  assign hwdata = state == 0 ? ahb_wdata : hwdata_n;
  assign hwrite = state == 0 ? |ahb_wstrb : hwrite_n;

  assign m_ahb_clk = clk;
  assign m_ahb_resetn = rst;
  assign m_ahb_haddr = haddr;
  assign m_ahb_hbrust = 3'b000; // single
  assign m_ahb_hmastlock = 1'b0; // unlocked
  assign m_ahb_hprot = hprot;
  assign m_ahb_hsize = 3'b010; // word
  assign m_ahb_htrans = htrans;
  assign m_ahb_hwdata = hwdata_n;
  assign m_ahb_hwrite = hwrite;

  assign ahb_rdata = state == 1 ? m_ahb_hrdata : 0;
  assign ahb_ready = state == 1 ? m_ahb_hready : 0;

  always_comb begin
    state <= state_n;
    case (state)
      1'b0 : state = ahb_valid == 1 ? 1 : 0;
      1'b1 : state = m_ahb_hready == 1 ? 0 : 1;
    endcase
  end

  always_ff @(posedge m_ahb_hclk) begin

    if (m_ahb_hresetn == 0) begin
      state_n <= 0;
      haddr_n <= 0;
      hprot_n <= 0;
      htrans_n <= 0;
      hwdata_n <= 0;
      hwrite_n <= 0;
    end else begin
      state_n <= state;
      haddr_n <= haddr;
      hprot_n <= hprot;
      htrans_n <= htrans;
      hwdata_n <= hwdata;
      hwrite_n <= hwrite;
    end

  end

endmodule
