import configure::*;

module avl
(
  input  wire reset,
  input  wire clock,
  /////////////////////////////////
  input  logic [0  : 0] avl_valid,
  input  logic [0  : 0] avl_instr,
  input  logic [31 : 0] avl_addr,
  input  logic [63 : 0] avl_wdata,
  input  logic [7  : 0] avl_wstrb,
  output logic [63 : 0] avl_rdata,
  output logic [0  : 0] avl_ready,
  /////////////////////////////////
  output logic [31 : 0] avm_address,
  output logic [7  : 0] avm_byteenable,
  output logic [0  : 0] avm_lock,
  output logic [0  : 0] avm_read,
  output logic [63 : 0] avm_writedata,
  output logic [0  : 0] avm_write,
  output logic [2  : 0] avm_burstcount,
  /////////////////////////////////
  input logic [31 : 0] avm_readdata,
  input logic [1  : 0] avm_response,
  input logic [0  : 0] avm_waitrequest,
  input logic [0  : 0] avm_readdatavalid,
  input logic [0  : 0] avm_writeresponsevalid
  /////////////////////////////////
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [1:0] idle = 0;
  localparam [1:0] load = 1;
  localparam [1:0] store = 2;

  logic [1 :0] state;
  logic [1 :0] state_reg;

  logic [31:0] address;
  logic [31:0] address_reg;
  logic [7 :0] byteenable;
  logic [7 :0] byteenable_reg;
  logic [0 :0] read;
  logic [0 :0] read_reg;
  logic [63:0] writedata;
  logic [63:0] writedata_reg;
  logic [0 :0] write;
  logic [0 :0] write_reg;

  logic [63:0] rdata;
  logic [63:0] rdata_reg;
  logic [0 :0] ready;
  logic [0 :0] ready_reg;

  always @(*) begin
    state = state_reg;
    address = 0;
    byteenable = 0;
    read = 0;
    writedata = 0;
    write = 0;
    rdata = 0;
    ready = 0;
    case (state)
      idle : begin
        if (avl_valid == 1) begin
          if (|avl_wstrb == 0) begin
            state = load;
            read = 1;
            byteenable = 4'hF;
          end else if (|avl_wstrb == 1) begin
            state = store;
            write = 1;
            byteenable = avl_wstrb;
          end
          address = {avl_addr[31:2],2'b0};
          writedata = avl_wdata;
        end
      end
      load : begin
        if (avm_readdatavalid == 1) begin
          state = idle;
          rdata = avm_readdata;
          ready = 1;
        end else if (avm_waitrequest == 1) begin
          address = address_reg;
          byteenable = byteenable_reg;
          read = read_reg;
          writedata = writedata_reg;
          write = write_reg;
        end
      end
      store : begin
        if (avm_waitrequest == 0) begin
          state = idle;
          ready = 1;
        end else if (avm_waitrequest == 1) begin
          address = address_reg;
          byteenable = byteenable_reg;
          read = read_reg;
          writedata = writedata_reg;
          write = write_reg;
        end
      end
      default : begin
      end
    endcase
  end

  assign avm_address = address_reg;
  assign avm_byteenable = byteenable_reg;
  assign avm_lock = 1'b0;
  assign avm_read = read_reg;
  assign avm_writedata = writedata_reg;
  assign avm_write = write_reg;
  assign avm_burstcount = 3'b001;

  assign avl_rdata = rdata_reg;
  assign avl_ready = ready_reg;

  always @(posedge clock) begin

    if (reset == 0) begin
      state_reg <= 0;
      address_reg <= 0;
      byteenable_reg <= 0;
      read_reg <= 0;
      writedata_reg <= 0;
      write_reg <= 0;
      rdata_reg <= 0;
      ready_reg <= 0;
    end else begin
      state_reg <= state;
      address_reg <= address;
      byteenable_reg <= byteenable;
      read_reg <= read;
      writedata_reg <= writedata;
      write_reg <= write;
      rdata_reg <= rdata;
      ready_reg <= ready;
    end

  end

endmodule