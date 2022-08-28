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
  output logic [0  : 0] ahb_ready,
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

  localparam [0:0] idle = 0;
  localparam [0:0] activ = 1;

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

  logic [31:0] rdata;
  logic [0 :0] ready;

  assign state = state_n;

  assign haddr = state == idle ? ahb_addr : haddr_n;
  assign hprot = state == idle ? {3'b000,~ahb_instr} : hprot_n;
  assign htrans = state == idle ? {ahb_valid,1'b0} : htrans_n;
  assign hwdata = state == idle ? ahb_wdata : hwdata_n;
  assign hwrite = state == idle ? |ahb_wstrb : hwrite_n;

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

  always_comb begin
    rdata = 0;
    ready = 0;
    case (state)
      idle : begin
        if (ahb_valid == 1) begin
          state = activ;
        end
      end
      activ : begin
        if (m_ahb_hready == 1) begin
          state = idle;
          rdata = m_ahb_hrdata;
          ready = m_ahb_hready;
        end
      end
    endcase
  end

  assign ahb_rdata = rdata;
  assign ahb_ready = ready;

  always_ff @(posedge clk) begin

    if (rst == 0) begin
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
