import configure::*;

module axi
(
  input  logic rst,
  input  logic clk,
  /////////////////////////////////
  input  logic [0  : 0] axi_valid,
  input  logic [0  : 0] axi_instr,
  input  logic [31 : 0] axi_addr,
  input  logic [31 : 0] axi_wdata,
  input  logic [3  : 0] axi_wstrb,
  output logic [31 : 0] axi_rdata,
  output logic [0  : 0] axi_ready,
  /////////////////////////////////
  // Write address channel
  output logic [31 : 0] m_axi_awaddr,
  output logic [7  : 0] m_axi_awlen,
  output logic [2  : 0] m_axi_awsize,
  output logic [1  : 0] m_axi_awburst,
  output logic [0  : 0] m_axi_awlock,
  output logic [3  : 0] m_axi_awcache,
  output logic [2  : 0] m_axi_awprot,
  output logic [3  : 0] m_axi_awqos,
  output logic [0  : 0] m_axi_awvalid,
  input  logic [0  : 0] m_axi_awready,
  /////////////////////////////////
  // Write data channel
  output logic [31 : 0] m_axi_wdata,
  output logic [3  : 0] m_axi_wstrb,
  output logic [0  : 0] m_axi_wlast,
  output logic [0  : 0] m_axi_wvalid,
  input  logic [0  : 0] m_axi_wready,
  /////////////////////////////////
  // Write response channel
  input  logic [1  : 0] m_axi_bresp,
  input  logic [0  : 0] m_axi_bvalid,
  output logic [0  : 0] m_axi_bready,
  /////////////////////////////////
  // Read address channel
  output logic [31 : 0] m_axi_araddr,
  output logic [7  : 0] m_axi_arlen,
  output logic [2  : 0] m_axi_arsize,
  output logic [1  : 0] m_axi_arburst,
  output logic [0  : 0] m_axi_arlock,
  output logic [3  : 0] m_axi_arcache,
  output logic [2  : 0] m_axi_arprot,
  output logic [3  : 0] m_axi_arqos,
  output logic [0  : 0] m_axi_arvalid,
  input  logic [0  : 0] m_axi_arready,
  /////////////////////////////////
  // Read data channel
  input  logic [31 : 0] m_axi_rdata,
  input  logic [1  : 0] m_axi_rresp,
  input  logic [0  : 0] m_axi_rlast,
  input  logic [0  : 0] m_axi_rvalid,
  output logic [0  : 0] m_axi_rready
  /////////////////////////////////
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [1:0] idle = 0;
  localparam [1:0] load = 1;
  localparam [1:0] store = 2;

  logic [1 :0] state;
  logic [1 :0] state_n;

  logic [31:0] rdata;
  logic [0 :0] ready;

  always_comb begin
    state = state_n;
    rdata = 0;
    ready = 0;
    case (state_n)
      idle : begin
      end
      load : begin
      end
      store : begin
      end
    endcase
  end

  assign axi_rdata = rdata;
  assign axi_ready = ready;

  always_ff @(posedge clk) begin

    if (rst == 0) begin
      state_n <= 0;
    end else begin
      state_n <= state;
    end

  end

endmodule
