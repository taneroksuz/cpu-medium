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

  mem_in_type   mem_in;
  mem_out_type  mem_out;

  logic [1:0]   rst_sync;
  logic         rstn;

  logic         mem_ui_clk;
  logic         mem_ui_rst;
  logic         calib_complete;

  typedef enum logic [2:0] { stIdle, stPreset, stSendData, stSetCmdRd, stSetCmdWr, stWaitCen } state_t;

  typedef struct packed {
    logic [26:0]  mem_addr;
    logic [2:0]   mem_cmd;
    logic         mem_en;
    logic [127:0] mem_wdf_data;
    logic         mem_wdf_end;
    logic [15:0]  mem_wdf_mask;
    logic         mem_wdf_wren;
    state_t       state;
  } register_in_type;

  register_in_type init_register_in = '{
      mem_addr : 0,
      mem_cmd : 0,
      mem_en : 0,
      mem_wdf_data : 0,
      mem_wdf_end : 0,
      mem_wdf_mask : 0,
      mem_wdf_wren : 0,
      state : stIdle
  };

  typedef struct packed {
    logic         mem_rdy;
    logic         mem_wdf_rdy;
    logic [127:0] mem_rd_data;
    logic         mem_rd_data_valid;
    logic         mem_rd_data_end;
  } register_out_type;

  register_in_type r_in, rin_in, v_in;
  register_out_type r_out;

  always_comb begin

    v_in = r_in;

    v_in.mem_wdf_wren = 1'b0;
    v_in.mem_wdf_end  = 1'b0;
    v_in.mem_en       = 1'b0;
    v_in.mem_cmd      = 3'b000;

    v_in.mem_wdf_data = {mem_in.mem_wdata,mem_in.mem_wdata,mem_in.mem_wdata,mem_in.mem_wdata};
    v_in.mem_wdf_mask = 16'hFFFF;
    v_in.mem_addr     = {mem_in.mem_addr[26:4],4'b0000};

    unique case (r_in.state)
      stIdle     : if (mem_in.mem_valid && calib_complete) v_in.state = stPreset;
      stPreset   : v_in.state = stSendData;
      stSendData : if (r_out.mem_wdf_rdy) v_in.state = stSetCmdWr;
      stSetCmdWr : if (r_out.mem_rdy)     v_in.state = stWaitCen;
      stSetCmdRd : if (r_out.mem_rdy)     v_in.state = stWaitCen;
      stWaitCen  : v_in.state = stIdle;
      default    : v_in.state = stIdle;
    endcase

    unique case (r_in.state)
      stSendData : begin
        v_in.mem_wdf_wren = 1'b1;
        v_in.mem_wdf_end  = 1'b1;
      end
      stSetCmdWr : begin
        v_in.mem_en  = 1'b1;
        v_in.mem_cmd = 3'b000;
      end
      stSetCmdRd : begin
        v_in.mem_en  = 1'b1;
        v_in.mem_cmd = 3'b001;
      end
      default: ;
    endcase

    if (r_in.state == stPreset) begin
      unique case (mem_in.mem_addr[3])
        0 : v_in.mem_wdf_mask[7:0] <= ~mem_in.mem_wstrb;
        1 : v_in.mem_wdf_mask[15:8] <= ~mem_in.mem_wstrb;
        default : ;
      endcase
    end

    rin_in = v_in;

    mem_out.mem_rdata = 0;
    mem_out.mem_ready = 0;

    if (r_in.state == stWaitCen) begin
      if (r_out.mem_rd_data_valid && r_out.mem_rd_data_end) begin
        mem_out.mem_ready <= 1;
        unique case (mem_in.mem_addr[3])
          0 : mem_out.mem_rdata <= r_out.mem_rd_data[63:0];
          1 : mem_out.mem_rdata <= r_out.mem_rd_data[127:64];
          default : ;
        endcase
      end
    end

  end

  always_ff @(posedge mem_ui_clk) begin
    if (mem_ui_rst == 0) begin
      r_in <= init_register_in;
    end else begin
      r_in <= rin_in;
    end
  end

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
    .app_addr            (r_in.mem_addr),
    .app_cmd             (r_in.mem_cmd),
    .app_en              (r_in.mem_en),
    .app_wdf_data        (r_in.mem_wdf_data),
    .app_wdf_end         (r_in.mem_wdf_end),
    .app_wdf_mask        (r_in.mem_wdf_mask),
    .app_wdf_wren        (r_in.mem_wdf_wren),
    .app_rd_data         (r_out.mem_rd_data),
    .app_rd_data_end     (r_out.mem_rd_data_end),
    .app_rd_data_valid   (r_out.mem_rd_data_valid),
    .app_rdy             (r_out.mem_rdy),
    .app_wdf_rdy         (r_out.mem_wdf_rdy),
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

endmodule
