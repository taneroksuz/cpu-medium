import configure::*;

module axi
(
  input  logic reset,
  input  logic clock,
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
  logic [1 :0] state_reg;

  logic [0 :0] awvalid;
  logic [0 :0] awvalid_reg;
  logic [0 :0] wvalid;
  logic [0 :0] wvalid_reg;
  logic [0 :0] bready;
  logic [0 :0] bready_reg;
  logic [0 :0] arvalid;
  logic [0 :0] arvalid_reg;
  logic [0 :0] rready;
  logic [0 :0] rready_reg;
  logic [31:0] addr;
  logic [31:0] addr_reg;
  logic [2 :0] prot;
  logic [2 :0] prot_reg;
  logic [31:0] wdata;
  logic [31:0] wdata_reg;
  logic [3 :0] wstrb;
  logic [3 :0] wstrb_reg;
  logic [0 :0] wlast;
  logic [0 :0] wlast_reg;

  logic [31:0] rdata;
  logic [31:0] rdata_reg;
  logic [0 :0] ready;
  logic [0 :0] ready_reg;

  always_comb begin
    state = state_reg;
    arvalid = 0;
    awvalid = 0;
    addr = 0;
    prot = 0;
    wvalid = 0;
    wdata = 0;
    wstrb = 0;
    wlast = 0;
    rready = 0;
    bready = 0;
    rdata = 0;
    ready = 0;
    case (state_reg)
      idle : begin
        if (axi_valid == 1) begin
          if (|axi_wstrb == 0) begin
            state = load;
            arvalid = 1;
            rready = 1;
          end else if (|axi_wstrb == 1) begin
            state = store;
            awvalid = 1;
            wvalid = 1;
            bready = 1;
          end
          addr = {axi_addr[31:2],2'b0};
          prot = {axi_instr,2'b00};
          wdata = axi_wdata;
          wstrb = axi_wstrb;
          wlast = |axi_wstrb;
        end
      end
      load : begin
        if (m_axi_arready == 0) begin
          arvalid = arvalid_reg;
          addr = addr_reg;
          prot = prot_reg;
        end
        if (m_axi_rvalid == 1) begin
          state = idle;
          rdata = m_axi_rdata;
          ready = 1;
        end else if (m_axi_rvalid == 0) begin
          rready = rready_reg;
        end
      end
      store : begin
        if (m_axi_awready == 0) begin
          awvalid = awvalid_reg;
          addr = addr_reg;
          prot = prot_reg;
        end
        if (m_axi_wready == 0) begin
          wvalid = wvalid_reg;
          wdata = wdata_reg;
          wstrb = wstrb_reg;
          wlast = wlast_reg;
        end
        if (m_axi_bvalid == 1) begin
          state = idle;
          ready = 1;
        end else if (m_axi_bvalid == 0) begin
          bready = bready_reg;
        end
      end
      default : begin
      end
    endcase
  end

  assign m_axi_awaddr = addr_reg;
  assign m_axi_awlen = 8'b00000000;
  assign m_axi_awsize = 3'b000;
  assign m_axi_awburst = 2'b00;
  assign m_axi_awlock = 1'b0;
  assign m_axi_awcache = 4'b0000;
  assign m_axi_awprot = prot_reg;
  assign m_axi_awqos = 4'b0000;
  assign m_axi_awvalid = awvalid_reg;

  assign m_axi_wdata = wdata_reg;
  assign m_axi_wstrb = wstrb_reg;
  assign m_axi_wlast = wlast_reg;
  assign m_axi_wvalid = wvalid_reg;

  assign m_axi_bready = bready_reg;

  assign m_axi_araddr = addr_reg;
  assign m_axi_arlen = 8'b00000000;
  assign m_axi_arsize = 3'b000;
  assign m_axi_arburst = 2'b00;
  assign m_axi_arlock = 1'b0;
  assign m_axi_arcache = 4'b0000;
  assign m_axi_arprot = prot_reg;
  assign m_axi_arqos = 4'b0000;
  assign m_axi_arvalid = arvalid_reg;

  assign m_axi_rready = rready_reg;

  assign axi_rdata = rdata_reg;
  assign axi_ready = ready_reg;

  always_ff @(posedge clock) begin

    if (reset == 0) begin
      state_reg <= 0;
      arvalid_reg <= 0;
      awvalid_reg <= 0;
      addr_reg <= 0;
      prot_reg <= 0;
      wvalid_reg <= 0;
      wdata_reg <= 0;
      wstrb_reg <= 0;
      wlast_reg <= 0;
      rready_reg <= 0;
      bready_reg <= 0;
      rdata_reg <= 0;
      ready_reg <= 0;
    end else begin
      state_reg <= state;
      arvalid_reg <= arvalid;
      awvalid_reg <= awvalid;
      addr_reg <= addr;
      prot_reg <= prot;
      wvalid_reg <= wvalid;
      wdata_reg <= wdata;
      wstrb_reg <= wstrb;
      wlast_reg <= wlast;
      rready_reg <= rready;
      bready_reg <= bready;
      rdata_reg <= rdata;
      ready_reg <= ready;
    end

  end

endmodule
