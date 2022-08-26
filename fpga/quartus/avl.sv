import configure::*;

module avl
(
  input logic rst,
  input logic clk,
  /////////////////////////////////
  input logic [0   : 0] avl_valid,
  input logic [0   : 0] avl_instr,
  input logic [31  : 0] avl_addr,
  input logic [31  : 0] avl_wdata,
  input logic [3   : 0] avl_wstrb,
  output logic [31 : 0] avl_rdata,
  output logic [0  : 0] avl_ready,
  /////////////////////////////////
  output logic m_avl_clk,
  output logic m_avl_resetn,
  /////////////////////////////////
  output logic [31 : 0] m_avl_address,
  output logic [3  : 0] m_avl_byteenable,
  output logic [0  : 0] m_avl_lock,
  output logic [0  : 0] m_avl_read,
  output logic [31 : 0] m_avl_writedata,
  output logic [0  : 0] m_avl_write,
  output logic [0  : 0] m_avl_burstcount,
  /////////////////////////////////
  input logic [31 : 0] m_avl_readdata,
  input logic [1  : 0] m_avl_response,
  input logic [0  : 0] m_avl_waitrequest,
  input logic [0  : 0] m_avl_readdatavalid,
  input logic [0  : 0] m_avl_writeresponsevalid
  /////////////////////////////////
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] address;
  logic [31:0] address_n;
  logic [3 :0] byteenable;
  logic [3 :0] byteenable_n;
  logic [0 :0] read;
  logic [0 :0] read_n;
  logic [31:0] writedata;
  logic [31:0] writedata_n;
  logic [0 :0] write;
  logic [0 :0] write_n;

  assign address = m_avl_waitrequest == 0 ? avl_addr : address_n;
  assign byteenable = m_avl_waitrequest == 0 ? avl_wstrb : byteenable_n;
  assign read = m_avl_waitrequest == 0 ? (avl_valid & ~(|avl_wstrb)) : read_n;
  assign writedata = m_avl_waitrequest == 0 ? avl_wdata : writedata_n;
  assign write = m_avl_waitrequest == 0 ? (avl_valid & |avl_wstrb) : write_n;

  assign m_avl_clk = clk;
  assign m_avl_resetn = rst;
  assign m_avl_address = address;
  assign m_avl_byteenable = byteenable;
  assign m_avl_lock = 0;
  assign m_avl_read = read;
  assign m_avl_writedata = writedata;
  assign m_avl_write = write;
  assign m_avl_burstcount = 0;

  assign avl_rdata = (m_avl_waitrequest == 0 && m_avl_response == 0) ? m_avl_readdata : 0;
  assign avl_ready = (m_avl_waitrequest == 0 && m_avl_response == 0) ? (read_n & m_avl_readdatavalid) | (write_n & m_avl_writeresponsevalid) : 0;

  always_ff @(posedge m_avl_hclk) begin

    if (m_avl_hresetn == 0) begin
      address_n <= 0;
      byteenable_n <= 0;
      read_n <= 0;
      writedata_n <= 0;
      write_n <= 0;
    end else begin
      address_n <= address;
      byteenable_n <= byteenable;
      read_n <= read;
      writedata_n <= writedata;
      write_n <= write;
    end

  end

endmodule
