import configure::*;

module ram2ddr
(
    // Common
    input           reset,
    input           clock,
    input  [11 : 0] device_temp_i,
    // RAM interface
    input           ram_cen,
    input           ram_oen,
    input           ram_wen,
    input           ram_ub,
    input           ram_lb,
    inout  [15 : 0] ram_dq,
    input  [17 : 0] ram_a,
    // DDR2 interface
    output [12 : 0] ddr2_addr,
    output [ 2 : 0] ddr2_ba,
    output          ddr2_ras_n,
    output          ddr2_cas_n,
    output          ddr2_we_n,
    output [ 0 : 0] ddr2_ck_p,
    output [ 0 : 0] ddr2_ck_n,
    output [ 0 : 0] ddr2_cke,
    output [ 0 : 0] ddr2_cs_n,
    output [ 1 : 0] ddr2_dm,
    output [ 0 : 0] ddr2_odt,
    inout  [15 : 0] ddr2_dq,
    inout  [ 1 : 0] ddr2_dqs_p,
    inout  [ 1 : 0] ddr2_dqs_n
);

  timeunit 1ns; timeprecision 1ps;

  localparam [2:0] stIdle     = 0;
  localparam [2:0] stPreset   = 1;
  localparam [2:0] stSendData = 2;
  localparam [2:0] stSetCmdRd = 3;
  localparam [2:0] stSetCmdWr = 4;
  localparam [2:0] stWaitCen  = 5;

  localparam [2:0] CMD_WRITE = 0;
  localparam [2:0] CMD_READ  = 0;

  logic [ 2 : 0] cState;
  logic [ 2 : 0] nState;

  logic          mem_ui_clk;
  logic          mem_ui_rst;
  logic          rst;
  logic          rstn;
  logic [ 1 : 0] sreg;

  logic [17 : 0] ram_a_int;
  logic [15 : 0] ram_dq_i_int;
  logic [15 : 0] ram_dq_o_int;
  logic          ram_cen_int;
  logic          ram_oen_int;
  logic          ram_wen_int;
  logic          ram_ub_int;
  logic          ram_lb_int;

  logic [ 26 : 0] mem_addr;
  logic [  2 : 0] mem_cmd;
  logic           mem_en;
  logic           mem_rdy;
  logic           mem_wdf_rdy;
  logic [127 : 0] mem_wdf_data;
  logic           mem_wdf_end;
  logic [ 15 : 0] mem_wdf_mask;
  logic           mem_wdf_wren;
  logic [127 : 0] mem_rd_data;
  logic           mem_rd_data_end;
  logic           mem_rd_data_valid;
  logic           calib_complete;

  always_ff @(posedge clock) begin : RSTSYNC
    sreg <= {sreg[0],reset};
    rstn <= ~sreg[1];
  end

  mig_7series_0 ddr_comp (
      .ddr2_dq              (ddr2_dq),
      .ddr2_dqs_p           (ddr2_dqs_p),
      .ddr2_dqs_n           (ddr2_dqs_n),
      .ddr2_addr            (ddr2_addr),
      .ddr2_ba              (ddr2_ba),
      .ddr2_ras_n           (ddr2_ras_n),
      .ddr2_cas_n           (ddr2_cas_n),
      .ddr2_we_n            (ddr2_we_n),
      .ddr2_ck_p            (ddr2_ck_p),
      .ddr2_ck_n            (ddr2_ck_n),
      .ddr2_cke             (ddr2_cke),
      .ddr2_cs_n            (ddr2_cs_n),
      .ddr2_dm              (ddr2_dm),
      .ddr2_odt             (ddr2_odt),
      .sys_clk_i            (clock),
      .sys_rst              (rstn),
      .app_addr             (mem_addr),
      .app_cmd              (mem_cmd),
      .app_en               (mem_en),
      .app_wdf_data         (mem_wdf_data),
      .app_wdf_end          (mem_wdf_end),
      .app_wdf_mask         (mem_wdf_mask),
      .app_wdf_wren         (mem_wdf_wren),
      .app_rd_data          (mem_rd_data),
      .app_rd_data_end      (mem_rd_data_end),
      .app_rd_data_valid    (mem_rd_data_valid),
      .app_rdy              (mem_rdy),
      .app_wdf_rdy          (mem_wdf_rdy),
      .app_sr_req           (0),
      .app_sr_active        (),
      .app_ref_req          (0),
      .app_ref_ack          (),
      .app_zq_req           (0),
      .app_zq_ack           (),
      .ui_clk               (mem_ui_clk),
      .ui_clk_sync_rst      (mem_ui_rst),
      .device_temp_i        (device_temp_i),
      .init_calib_complete  (calib_complete)
  );

  always_ff @(posedge mem_ui_clk) begin : REG_IN
    ram_a_int <= ram_a;
    ram_dq_i_int <= ram_wen == 0 ? ram_dq : 'bz;
    ram_cen_int <= ram_cen;
    ram_oen_int <= ram_oen;
    ram_wen_int <= ram_wen;
    ram_ub_int <= ram_ub;
    ram_lb_int <= ram_lb;
  end

  always_ff @(posedge mem_ui_clk) begin : SYNC_PROCESS
    if (mem_ui_rst == 1) begin
      cState <= stIdle;
    end else begin
      cState <= nState;
    end
  end

  always_comb begin : NEXT_STATE_DECODE
    nState = cState;
    case(cState)
      stIdle : begin
        if (ram_cen_int == 0 && calib_complete == 1) begin
          nState = stPreset;
        end
      end
      stPreset : begin
        if (ram_wen_int == 0) begin
          nState = stSendData;
        end else if (ram_oen_int == 0) begin
          nState = stSetCmdRd;
        end
      end
      stSendData : begin
        if (mem_rdy == 1) begin
          nState = stSetCmdWr;
        end
      end
      stSetCmdRd : begin
        if (mem_rdy == 1) begin
          nState = stWaitCen;
        end
      end
      stSetCmdWr : begin
        if (mem_rdy == 1) begin
          nState = stWaitCen;
        end
      end
      stWaitCen : begin
        if (ram_cen_int == 1) begin
          nState = stIdle;
        end
      end
      default : begin
        nState = stIdle;
      end
    endcase
  end

  always_comb begin : MEM_WR_CTL
    if (cState == stSendData) begin
      mem_wdf_wren = 1;
      mem_wdf_end = 1;
    end else begin
      mem_wdf_wren = 0;
      mem_wdf_end = 0;
    end
  end

  always_comb begin : MEM_CTL
    if (cState == stSetCmdRd) begin
      mem_en = 1;
      mem_cmd = CMD_READ;
    end else if (cState == stSetCmdWr) begin
      mem_en = 1;
      mem_cmd = CMD_WRITE;
    end else begin
      mem_en = 0;
      mem_cmd = 0;
    end
  end

  always_ff @(posedge mem_ui_clk) begin : WR_DATA_MSK
    if (cState == stPreset) begin
      case(ram_a_int[2:0])
        0 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            mem_wdf_mask <= 16'b1111111111111101;
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            mem_wdf_mask <= 16'b1111111111111110;
          end else begin
            mem_wdf_mask <= 16'b1111111111111100;
          end
        end
        1 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            mem_wdf_mask <= 16'b1111111111110111;
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            mem_wdf_mask <= 16'b1111111111111011;
          end else begin
            mem_wdf_mask <= 16'b1111111111110011;
          end
        end
        2 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            mem_wdf_mask <= 16'b1111111111011111;
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            mem_wdf_mask <= 16'b1111111111101111;
          end else begin
            mem_wdf_mask <= 16'b1111111111001111;
          end
        end
        3 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            mem_wdf_mask <= 16'b1111111101111111;
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            mem_wdf_mask <= 16'b1111111110111111;
          end else begin
            mem_wdf_mask <= 16'b1111111100111111;
          end
        end
        4 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            mem_wdf_mask <= 16'b1111110111111111;
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            mem_wdf_mask <= 16'b1111111011111111;
          end else begin
            mem_wdf_mask <= 16'b1111110011111111;
          end
        end
        5 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            mem_wdf_mask <= 16'b1111011111111111;
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            mem_wdf_mask <= 16'b1111101111111111;
          end else begin
            mem_wdf_mask <= 16'b1111001111111111;
          end
        end
        6 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            mem_wdf_mask <= 16'b1101111111111111;
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            mem_wdf_mask <= 16'b1110111111111111;
          end else begin
            mem_wdf_mask <= 16'b1100111111111111;
          end
        end
        7 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            mem_wdf_mask <= 16'b0111111111111111;
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            mem_wdf_mask <= 16'b1011111111111111;
          end else begin
            mem_wdf_mask <= 16'b0011111111111111;
          end
        end
        default : begin
        end
      endcase
    end
  end

  always_ff @(posedge mem_ui_clk) begin : WR_DATA_ADDR
    if (cState == stPreset) begin
      mem_wdf_data <= {ram_dq_i_int,ram_dq_i_int,ram_dq_i_int,ram_dq_i_int,
                        ram_dq_i_int,ram_dq_i_int,ram_dq_i_int,ram_dq_i_int};
    end
  end

  always_ff @(posedge mem_ui_clk) begin : WR_ADDR
    if (cState == stPreset) begin
      mem_addr <= {9'b000000000,ram_a_int[17:3],3'b000};
    end
  end

  always_ff @(posedge mem_ui_clk) begin : RD_DATA
    if (cState == stWaitCen && mem_rd_data_valid == 1 && mem_rd_data_end == 1) begin
      case(ram_a_int[2:0])
        0 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            ram_dq_o_int <= {mem_rd_data[15:8],mem_rd_data[15:8]};
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            ram_dq_o_int <= {mem_rd_data[7:0],mem_rd_data[7:0]};
          end else begin
            ram_dq_o_int <= mem_rd_data[15:0];
          end
        end
        1 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            ram_dq_o_int <= {mem_rd_data[31:24],mem_rd_data[31:24]};
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            ram_dq_o_int <= {mem_rd_data[23:16],mem_rd_data[23:16]};
          end else begin
            ram_dq_o_int <= mem_rd_data[31:16];
          end
        end
        2 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            ram_dq_o_int <= {mem_rd_data[47:40],mem_rd_data[47:40]};
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            ram_dq_o_int <= {mem_rd_data[39:32],mem_rd_data[39:32]};
          end else begin
            ram_dq_o_int <= mem_rd_data[47:32];
          end
        end
        3 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            ram_dq_o_int <= {mem_rd_data[63:56],mem_rd_data[63:56]};
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            ram_dq_o_int <= {mem_rd_data[55:48],mem_rd_data[55:48]};
          end else begin
            ram_dq_o_int <= mem_rd_data[63:48];
          end
        end
        4 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            ram_dq_o_int <= {mem_rd_data[79:72],mem_rd_data[79:72]};
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            ram_dq_o_int <= {mem_rd_data[71:64],mem_rd_data[71:64]};
          end else begin
            ram_dq_o_int <= mem_rd_data[79:64];
          end
        end
        5 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            ram_dq_o_int <= {mem_rd_data[95:88],mem_rd_data[95:88]};
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            ram_dq_o_int <= {mem_rd_data[87:80],mem_rd_data[87:80]};
          end else begin
            ram_dq_o_int <= mem_rd_data[95:80];
          end
        end
        6 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            ram_dq_o_int <= {mem_rd_data[111:104],mem_rd_data[111:104]};
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            ram_dq_o_int <= {mem_rd_data[103:96],mem_rd_data[103:96]};
          end else begin
            ram_dq_o_int <= mem_rd_data[111:96];
          end
        end
        7 : begin
          if (ram_ub_int == 0 && ram_lb_int == 1) begin
            ram_dq_o_int <= {mem_rd_data[127:120],mem_rd_data[127:120]};
          end else if (ram_ub_int == 1 && ram_lb_int == 0) begin
            ram_dq_o_int <= {mem_rd_data[119:112],mem_rd_data[119:112]};
          end else begin
            ram_dq_o_int <= mem_rd_data[127:112];
          end
        end
        default : begin
        end
      endcase
    end
  end

  assign ram_dq = ram_oen == 0 ? ram_dq_o_int : 'bz;

endmodule