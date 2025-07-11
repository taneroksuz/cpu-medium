import configure::*;
import wires::*;

module dram (
  input  logic        reset_cpu,
  input  logic        clock_cpu,
  input  logic        clock_ddr,
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

  logic [1:0]   reset_sync;
  logic         reset_ddr;

  logic         app_ui_clk;
  logic         app_ui_rst;
  logic         calib_complete;

  typedef enum logic [2:0] { stIdle, stPreset, stSendData, stSetCmdRd, stSetCmdWr, stWaitCen } state_t;

  typedef struct packed {
    logic [0:0]   mem_valid;
    logic [0:0]   mem_instr;
    logic [1:0]   mem_mode;
    logic [31:0]  mem_addr;
    logic [63:0]  mem_wdata;
    logic [7:0]   mem_wstrb;
    logic [26:0]  app_addr;
    logic [2:0]   app_cmd;
    logic         app_en;
    logic [127:0] app_wdf_data;
    logic         app_wdf_end;
    logic [15:0]  app_wdf_mask;
    logic         app_wdf_wren;
    state_t       state;
  } register_in_type;

  register_in_type init_register_in = '{
      mem_valid : 0,
      mem_instr : 0,
      mem_mode : 0,
      mem_addr : 0,
      mem_wdata : 0,
      mem_wstrb : 0,
      app_addr : 0,
      app_cmd : 0,
      app_en : 0,
      app_wdf_data : 0,
      app_wdf_end : 0,
      app_wdf_mask : 0,
      app_wdf_wren : 0,
      state : stIdle
  };

  typedef struct packed {
    logic         app_rdy;
    logic         app_wdf_rdy;
    logic [127:0] app_rd_data;
    logic         app_rd_data_valid;
    logic         app_rd_data_end;
  } register_out_type;

  register_in_type r_in, rin_in, v_in;
  register_out_type r_out;

  always_comb begin

    v_in = r_in;

    unique case (r_in.state)
      stIdle     : begin
        if (mem_in.mem_valid && calib_complete) begin
          v_in.state = stPreset;
        end
      end
      stPreset   : begin
        if (|v_in.mem_wstrb) begin
          v_in.state = stSendData;
        end else begin
          v_in.state = stSetCmdRd;
        end
      end
      stSendData : begin
        if (r_out.app_wdf_rdy) begin
          v_in.state = stSetCmdWr;
        end
      end
      stSetCmdWr : begin
        if (r_out.app_rdy) begin
          v_in.state = stWaitCen;
        end
      end
      stSetCmdRd : begin
        if (r_out.app_rdy) begin
          v_in.state = stWaitCen;
        end
      end
      stWaitCen  : begin
        if (~mem_in.mem_valid) begin
          v_in.state = stIdle;
        end
      end
      default    : begin
        v_in.state = stIdle;
      end
    endcase

    unique case (r_in.state)
      stSendData : begin
        v_in.app_wdf_wren = 1'b1;
        v_in.app_wdf_end  = 1'b1;
      end
      default    : begin
        v_in.app_wdf_wren = 1'b0;
        v_in.app_wdf_end  = 1'b0;
      end
    endcase

    unique case (r_in.state)
      stSetCmdWr : begin
        v_in.app_en  = 1'b1;
        v_in.app_cmd = 3'b000;
      end
      stSetCmdRd : begin
        v_in.app_en  = 1'b1;
        v_in.app_cmd = 3'b001;
      end
      default    : begin
        v_in.app_en  = 1'b0;
        v_in.app_cmd = 3'b000;
      end
    endcase

    if (r_in.state == stIdle) begin
      if (mem_in.mem_valid) begin
        v_in.mem_valid = mem_in.mem_valid;
        v_in.mem_instr = mem_in.mem_instr;
        v_in.mem_mode  = mem_in.mem_mode;
        v_in.mem_addr  = mem_in.mem_addr;
        v_in.mem_wdata = mem_in.mem_wdata;
        v_in.mem_wstrb = mem_in.mem_wstrb;
      end
    end

    if (r_in.state == stPreset) begin
      v_in.app_wdf_data = {v_in.mem_wdata,v_in.mem_wdata};
      v_in.app_wdf_mask = 16'hFFFF;
      v_in.app_addr     = {v_in.mem_addr[26:4],4'b0000};
      unique case (v_in.mem_addr[3])
        0 : v_in.app_wdf_mask[7:0] <= ~v_in.mem_wstrb;
        1 : v_in.app_wdf_mask[15:8] <= ~v_in.mem_wstrb;
        default : ;
      endcase
    end

    rin_in = v_in;

    mem_out.mem_rdata = 0;
    mem_out.mem_ready = 0;
    mem_out.mem_error = 0;

    if (r_in.state == stWaitCen) begin
      if (r_out.app_rd_data_valid && r_out.app_rd_data_end) begin
        mem_out.mem_ready <= 1;
        unique case (v_in.mem_addr[3])
          0 : mem_out.mem_rdata <= r_out.app_rd_data[63:0];
          1 : mem_out.mem_rdata <= r_out.app_rd_data[127:64];
          default : ;
        endcase
      end
    end

  end

  always_ff @(posedge app_ui_clk) begin
    if (app_ui_rst == 1) begin
      r_in <= init_register_in;
    end else begin
      r_in <= rin_in;
    end
  end

  always_ff @(posedge clock_ddr)
    if (reset_cpu == 0) reset_sync <= 2'b00;
    else                reset_sync <= {reset_sync[0],1'b1};

  assign reset_ddr = reset_sync[1];

  assign ddr2_complete = calib_complete;

  cdc cdc_comp (
    .src_clk(clock_cpu),
    .src_rstn(reset_cpu),
    .src_mem_in(dram_in),
    .src_mem_out(dram_out),
    .dst_clk(app_ui_clk),
    .dst_rstn(app_ui_rst),
    .dst_mem_in(mem_in),
    .dst_mem_out(mem_out)
  );

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
    .sys_clk_i           (clock_ddr),
    .sys_rst             (reset_ddr),
    .app_addr            (r_in.app_addr),
    .app_cmd             (r_in.app_cmd),
    .app_en              (r_in.app_en),
    .app_wdf_data        (r_in.app_wdf_data),
    .app_wdf_end         (r_in.app_wdf_end),
    .app_wdf_mask        (r_in.app_wdf_mask),
    .app_wdf_wren        (r_in.app_wdf_wren),
    .app_rd_data         (r_out.app_rd_data),
    .app_rd_data_end     (r_out.app_rd_data_end),
    .app_rd_data_valid   (r_out.app_rd_data_valid),
    .app_rdy             (r_out.app_rdy),
    .app_wdf_rdy         (r_out.app_wdf_rdy),
    .app_sr_req          (1'b0),
    .app_ref_req         (1'b0),
    .app_zq_req          (1'b0),
    .app_sr_active       (),
    .app_ref_ack         (),
    .app_zq_ack          (),
    .ui_clk              (app_ui_clk),
    .ui_clk_sync_rst     (app_ui_rst),
    .init_calib_complete (calib_complete)
  );

endmodule
