import configure::*;
import wires::*;

module dram (
  input  logic        clk_200MHz_i,
  input  logic        rst_i,
  input  mem_in_type  dram_in,
  output mem_out_type dram_out,
  output logic [12:0] ddr2_addr,
  output logic [2:0]  ddr2_ba,
  output logic        ddr2_ras_n,
  output logic        ddr2_cas_n,
  output logic        ddr2_we_n,
  output logic        ddr2_ck_p,
  output logic        ddr2_ck_n,
  output logic        ddr2_cke,
  output logic        ddr2_cs_n,
  output logic [1:0]  ddr2_dm,
  output logic        ddr2_odt,
  inout  tri   [15:0] ddr2_dq,
  inout  tri   [1:0]  ddr2_dqs_p,
  inout  tri   [1:0]  ddr2_dqs_n,
  output logic        ddr2_complete
);
  timeunit 1ns; timeprecision 1ps;

  typedef enum logic [2:0] { stIdle, stPreset, stSendData, stSetCmdRd, stSetCmdWr, stWaitCen } state_t;

  mem_in_type   mem_in;
  mem_out_type  mem_out;

  logic [1:0]   rst_sync;
  logic         rstn;

  logic         mem_ui_clk;
  logic         mem_ui_rst;
  logic         calib_complete;

  logic [26:0]  mem_addr;
  logic [2:0]   mem_cmd;
  logic         mem_en;
  logic [127:0] mem_wdf_data;
  logic         mem_wdf_end;
  logic [15:0]  mem_wdf_mask;
  logic         mem_wdf_wren;

  logic         mem_rdy;
  logic         mem_wdf_rdy;
  logic [127:0] mem_rd_data;
  logic         mem_rd_data_valid;
  logic         mem_rd_data_end;

  state_t       cState, nState;

  always_ff @(posedge mem_ui_clk) begin
    mem_in <= dram_in;
    dram_out <= mem_out;
  end

  always_ff @(posedge clk_200MHz_i)
    if (rst_i == 0) rst_sync <= 2'b11;
    else            rst_sync <= {rst_sync[0],1'b0};

  assign rstn = ~rst_sync[1];

  assign ddr2_complete = calib_complete;

  mig u_mig (
    .ddr2_dq             (ddr2_dq),
    .ddr2_dqs_p          (ddr2_dqs_p),
    .ddr2_dqs_n          (ddr2_dqs_n),
    .ddr2_addr           (ddr2_addr),
    .ddr2_ba             (ddr2_ba),
    .ddr2_ras_n          (ddr2_ras_n),
    .ddr2_cas_n          (ddr2_cas_n),
    .ddr2_we_n           (ddr2_we_n),
    .ddr2_ck_p           (ddr2_ck_p),
    .ddr2_ck_n           (ddr2_ck_n),
    .ddr2_cke            (ddr2_cke),
    .ddr2_cs_n           (ddr2_cs_n),
    .ddr2_dm             (ddr2_dm),
    .ddr2_odt            (ddr2_odt),
    .sys_clk_i           (clk_200MHz_i),
    .sys_rst             (rstn),
    .app_addr            (mem_addr),
    .app_cmd             (mem_cmd),
    .app_en              (mem_en),
    .app_wdf_data        (mem_wdf_data),
    .app_wdf_end         (mem_wdf_end),
    .app_wdf_mask        (mem_wdf_mask),
    .app_wdf_wren        (mem_wdf_wren),
    .app_rd_data         (mem_rd_data),
    .app_rd_data_end     (mem_rd_data_end),
    .app_rd_data_valid   (mem_rd_data_valid),
    .app_rdy             (mem_rdy),
    .app_wdf_rdy         (mem_wdf_rdy),
    .app_sr_req          (1'b0),
    .app_ref_req         (1'b0),
    .app_zq_req          (1'b0),
    .app_sr_active       (),
    .app_ref_ack         (),
    .app_zq_ack          (),
    .ui_clk              (mem_ui_clk),
    .ui_clk_sync_rst     (mem_ui_rst),
    .init_calib_complete (calib_complete)
  );

  always_ff @(posedge mem_ui_clk)
    if (mem_ui_rst) cState <= stIdle;
    else            cState <= nState;

  always_comb begin
    nState = cState;
    unique case (cState)
      stIdle     : if (mem_in.mem_valid && calib_complete) nState = stPreset;
      stPreset   : nState = stSendData;
      stSendData : if (mem_wdf_rdy) nState = stSetCmdWr;
      stSetCmdWr : if (mem_rdy)     nState = stWaitCen;
      stSetCmdRd : if (mem_rdy)     nState = stWaitCen;
      stWaitCen  : nState = stIdle;
      default    : nState = stIdle;
    endcase
  end

  always_comb begin
    mem_wdf_wren = 1'b0;
    mem_wdf_end  = 1'b0;
    mem_en       = 1'b0;
    mem_cmd      = 3'b000;
    unique case (cState)
      stSendData : begin
        mem_wdf_wren = 1'b1;
        mem_wdf_end  = 1'b1;
      end
      stSetCmdWr : begin
        mem_en  = 1'b1;
        mem_cmd = 3'b000;
      end
      stSetCmdRd : begin
        mem_en  = 1'b1;
        mem_cmd = 3'b001;
      end
      default: ;
    endcase
  end

  always_ff @(posedge mem_ui_clk) begin
    if (cState == stPreset) begin
      mem_wdf_data <= {mem_in.mem_wdata,mem_in.mem_wdata};
      mem_wdf_mask <= {16'hFFFF};
      mem_addr <= {mem_in.mem_addr[26:4],4'b0000};
      if (mem_in.mem_addr[3] == 0) begin
        mem_wdf_mask[7:0] <= ~mem_in.mem_wstrb;
      end
      if (mem_in.mem_addr[3] == 1) begin
        mem_wdf_mask[15:8] <= ~mem_in.mem_wstrb;
      end
    end
  end

  always_ff @(posedge mem_ui_clk) begin
    mem_out.mem_rdata <= 0;
    mem_out.mem_ready <= 0;
    if (cState==stWaitCen && mem_rd_data_valid && mem_rd_data_end) begin
      if (mem_in.mem_addr[3] == 0) begin
        mem_out.mem_rdata <= mem_rd_data[63:0];
        mem_out.mem_ready <= 1;
      end
      if (mem_in.mem_addr[3] == 1) begin
        mem_out.mem_rdata <= mem_rd_data[127:64];
        mem_out.mem_ready <= 1;
      end
    end
  end

endmodule
