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
  localparam [1:0] read = 1;
  localparam [1:0] write = 2;

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
    awvalid = 0;
    wvalid = 0;
    bready = 0;
    arvalid = 0;
    rready = 0;
    addr = 0;
    prot = 0;
    wdata = 0;
    wstrb = 0;
    wlast = 0;
    rdata = 0;
    ready = 0;
    case (state_reg)
      idle : begin
        if (axi_valid == 1) begin
          if (|axi_wstrb == 0) begin
            state = read;
            arvalid = 1;
            rready = 1;
          end else if (|axi_wstrb == 1) begin
            state = write;
            awvalid = 1;
            wvalid = 1;
            bready = 1;
          end
          addr = axi_addr;
          prot = {axi_instr,2'b00};
          wdata = axi_wdata;
          wstrb = axi_wstrb;
          wlast = |axi_wstrb;
        end
      end
      read : begin
        arvalid = arvalid_reg;
        rready = rready_reg;
        addr = addr_reg;
        prot = prot_reg;
        if (m_axi_arready == 1) begin
          arvalid = 0;
        end
        if (m_axi_rvalid == 1 && m_axi_rlast == 1 && m_axi_rresp == 0) begin
          state = idle;
          rready = 0;
          rdata = m_axi_rdata;
          ready = 1;
        end
      end
      write : begin
        awvalid = awvalid_reg;
        wvalid = wvalid_reg;
        bready = bready_reg;
        addr = addr_reg;
        prot = prot_reg;
        wdata = wdata_reg;
        wstrb = wstrb_reg;
        wlast = wlast_reg;
        if (m_axi_awready == 1) begin
          awvalid = 0;
        end
        if (m_axi_wready == 1) begin
          wlast = 0;
          wvalid = 0;
        end
        if (m_axi_bvalid == 1 && m_axi_bresp == 0) begin
          state = idle;
          bready = 0;
          ready = 1;
        end
      end
    endcase
  end

  assign m_axi_awaddr = addr_reg;
  assign m_axi_awlen = 8'b00000000;
  assign m_axi_awsize = 3'b010; // 4 Byte
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
  assign m_axi_arsize = 3'b010; // 4 Byte
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
      awvalid_reg <= 0;
      wvalid_reg <= 0;
      bready_reg <= 0;
      arvalid_reg <= 0;
      rready_reg <= 0;
      addr_reg <= 0;
      prot_reg <= 0;
      wdata_reg <= 0;
      wstrb_reg <= 0;
      wlast_reg <= 0;
      rdata_reg <= 0;
      ready_reg <= 0;
    end else begin
      state_reg <= state;
      awvalid_reg <= awvalid;
      wvalid_reg <= wvalid;
      bready_reg <= bready;
      arvalid_reg <= arvalid;
      rready_reg <= rready;
      addr_reg <= addr;
      prot_reg <= prot;
      wdata_reg <= wdata;
      wstrb_reg <= wstrb;
      wlast_reg <= wlast;
      rdata_reg <= rdata;
      ready_reg <= ready;
    end

  end

endmodule
