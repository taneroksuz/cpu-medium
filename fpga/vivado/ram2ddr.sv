import configure::*;

/*--------------------------------------------------------------------
 * Ram2Ddr.sv  –  Static-RAM ⇄ DDR2 bridge with XADC temperature feed
 * Originally VHDL by Mihaita Nagy (Digilent RO, 2014)
 * Fully converted to SystemVerilog – 6 Jul 2025
 *------------------------------------------------------------------*/
module ram2ddr (
    //--------------------------------------------------------------
    // Common
    input  logic        clk_200MHz_i,      // 200 MHz sys-clk
    input  logic        rst_i,             // async, high-true

    //--------------------------------------------------------------
    // Static-RAM interface (16-bit, UB/LB byte lanes)
    input  logic [17:0] ram_a,
    input  logic [15:0] ram_dq_i,
    output logic [15:0] ram_dq_o,
    input  logic        ram_cen,           // low-true
    input  logic        ram_oen,           // low-true
    input  logic        ram_wen,           // low-true
    input  logic        ram_ub,            // low-true
    input  logic        ram_lb,            // low-true

    //--------------------------------------------------------------
    // DDR2 PHY (MIG) – 16-bit memory bus
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
    //--------------------------------------------------------------
    output logic        ddr2_complete
);
    timeunit 1ns; timeprecision 1ps;

    //--------------------------------------------------------------
    // ── Local signals ────────────────────────────────────────────
    //--------------------------------------------------------------
    typedef enum logic [2:0] { stIdle, stPreset, stSendData,
                               stSetCmdRd, stSetCmdWr, stWaitCen } state_t;

    /* reset sync for MIG (active-low) */
    logic [1:0] rst_sync;
    logic       rstn;

    /* MIG application interface */
    logic         mem_ui_clk;
    logic         mem_ui_rst;
    logic         calib_complete;

    logic [26:0]  mem_addr;          // MIG expects 27 bits
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

    /* registered SRAM inputs (clk_200MHz domain) */
    logic [17:0] ram_a_int;
    logic [15:0] ram_dq_i_int;
    logic        ram_cen_int, ram_oen_int, ram_wen_int;
    logic        ram_ub_int, ram_lb_int;

    /* FSM */
    state_t cState, nState;

    //--------------------------------------------------------------
    // ── Reset synchroniser (to 200 MHz domain → rstn low-true) ───
    //--------------------------------------------------------------
    always_ff @(posedge clk_200MHz_i)
        if (rst_i == 0) rst_sync <= 2'b11;
        else            rst_sync <= {rst_sync[0],1'b0};

    assign rstn = ~rst_sync[1];

    //--------------------------------------------------------------
    // ── MIG instance (generated separately with Xilinx MIG) ──────
    //--------------------------------------------------------------
    mig u_mig (
        // DDR2 I/O
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

        // Clocks & reset
        .sys_clk_i           (clk_200MHz_i),
        .sys_rst             (rstn),

        // APP interface
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

        // Power-down / refresh not used
        .app_sr_req          (1'b0),
        .app_ref_req         (1'b0),
        .app_zq_req          (1'b0),
        .app_sr_active       (),
        .app_ref_ack         (),
        .app_zq_ack          (),

        // User-clk domain
        .ui_clk              (mem_ui_clk),
        .ui_clk_sync_rst     (mem_ui_rst),
        .init_calib_complete (calib_complete)
    );

    assign ddr2_complete = calib_complete;

    //--------------------------------------------------------------
    // ── Register SRAM inputs to mem_ui_clk domain ────────────────
    //--------------------------------------------------------------
    always_ff @(posedge mem_ui_clk) begin
        ram_a_int   <= ram_a;
        ram_dq_i_int<= ram_dq_i;
        ram_cen_int <= ram_cen;
        ram_oen_int <= ram_oen;
        ram_wen_int <= ram_wen;
        ram_ub_int  <= ram_ub;
        ram_lb_int  <= ram_lb;
    end

    //--------------------------------------------------------------
    // ── FSM: state register (mem_ui_clk domain) ──────────────────
    //--------------------------------------------------------------
    always_ff @(posedge mem_ui_clk)
        if (mem_ui_rst) cState <= stIdle;
        else            cState <= nState;

    //--------------------------------------------------------------
    // ── FSM: next-state logic ────────────────────────────────────
    //--------------------------------------------------------------
    always_comb begin
        nState = cState;
        unique case (cState)
            stIdle     : if (!ram_cen_int && calib_complete) nState = stPreset;
            stPreset   : nState = stSendData;
            stSendData : if (mem_wdf_rdy) nState = stSetCmdWr;
            stSetCmdWr : if (mem_rdy)     nState = stWaitCen;
            stSetCmdRd : if (mem_rdy)     nState = stWaitCen;
            stWaitCen  : if (ram_cen_int) nState = stIdle;
            default    : nState = stIdle;
        endcase
    end

    //--------------------------------------------------------------
    // ── APP-interface control signals ────────────────────────────
    //--------------------------------------------------------------
    always_comb begin
        /* defaults */
        mem_wdf_wren = 1'b0;
        mem_wdf_end  = 1'b0;
        mem_en       = 1'b0;
        mem_cmd      = 3'b000;           // WRITE

        unique case (cState)
            stSendData : begin
                mem_wdf_wren = 1'b1;
                mem_wdf_end  = 1'b1;
            end
            stSetCmdWr : begin
                mem_en  = 1'b1;
                mem_cmd = 3'b000;        // WRITE
            end
            stSetCmdRd : begin
                mem_en  = 1'b1;
                mem_cmd = 3'b001;        // READ
            end
            default: ;
        endcase
    end

    //--------------------------------------------------------------
    // ── Write-data mask generation & address latching ────────────
    //--------------------------------------------------------------
    always_ff @(posedge mem_ui_clk) begin
        if (cState == stPreset) begin
            // 128-bit bus → replicate the 16-bit SRAM word eight times
            mem_wdf_data <= {8{ram_dq_i_int}};

            // Align to 128-bit boundary (3 LSBs cleared)
            mem_addr <= {9'b000000000,ram_a_int[17:3],3'b000};

            /* 16-bit (two-byte) lane mask
             * logic ‘0’ = write-enable; ‘1’ = protect/keep.
             */
            unique case (ram_a_int[2:0])
                3'b000 : mem_wdf_mask <= (!ram_ub_int &&  ram_lb_int) ? 16'hFFFD :
                                       ( ram_ub_int && !ram_lb_int) ? 16'hFFFE : 16'hFFFC;
                3'b001 : mem_wdf_mask <= (!ram_ub_int &&  ram_lb_int) ? 16'hFFFB :
                                       ( ram_ub_int && !ram_lb_int) ? 16'hFFFD : 16'hFFF3;
                3'b010 : mem_wdf_mask <= (!ram_ub_int &&  ram_lb_int) ? 16'hFFDF :
                                       ( ram_ub_int && !ram_lb_int) ? 16'hFFEF : 16'hFFCF;
                3'b011 : mem_wdf_mask <= (!ram_ub_int &&  ram_lb_int) ? 16'hFDFF :
                                       ( ram_ub_int && !ram_lb_int) ? 16'hFEFF : 16'hFCFF;
                3'b100 : mem_wdf_mask <= (!ram_ub_int &&  ram_lb_int) ? 16'hFBFF :
                                       ( ram_ub_int && !ram_lb_int) ? 16'hFDFF : 16'hF3FF;
                3'b101 : mem_wdf_mask <= (!ram_ub_int &&  ram_lb_int) ? 16'hEFFF :
                                       ( ram_ub_int && !ram_lb_int) ? 16'hF7FF : 16'hCFFF;
                3'b110 : mem_wdf_mask <= (!ram_ub_int &&  ram_lb_int) ? 16'hDFFF :
                                       ( ram_ub_int && !ram_lb_int) ? 16'hEFFF : 16'hCFFF;
                3'b111 : mem_wdf_mask <= (!ram_ub_int &&  ram_lb_int) ? 16'h7FFF :
                                       ( ram_ub_int && !ram_lb_int) ? 16'hBFFF : 16'h3FFF;
                default: mem_wdf_mask <= {16'hFFFF};
            endcase
        end
    end

    //--------------------------------------------------------------
    // ── Read-data extraction back to 16-bit SRAM bus ─────────────
    //--------------------------------------------------------------
    always_ff @(posedge mem_ui_clk) begin
        if (cState==stWaitCen && mem_rd_data_valid && mem_rd_data_end) begin
            unique case (ram_a_int[2:0])
                3'b000: ram_dq_o <= (!ram_ub_int &&  ram_lb_int)  ? {mem_rd_data[15:8],  mem_rd_data[15:8]}  :
                                   ( ram_ub_int && !ram_lb_int) ? {mem_rd_data[7:0],    mem_rd_data[7:0]}   :
                                                                  mem_rd_data[15:0];

                3'b001: ram_dq_o <= (!ram_ub_int &&  ram_lb_int)  ? {mem_rd_data[31:24], mem_rd_data[31:24]} :
                                   ( ram_ub_int && !ram_lb_int) ? {mem_rd_data[23:16], mem_rd_data[23:16]} :
                                                                  mem_rd_data[31:16];

                3'b010: ram_dq_o <= (!ram_ub_int &&  ram_lb_int)  ? {mem_rd_data[47:40], mem_rd_data[47:40]} :
                                   ( ram_ub_int && !ram_lb_int) ? {mem_rd_data[39:32], mem_rd_data[39:32]} :
                                                                  mem_rd_data[47:32];

                3'b011: ram_dq_o <= (!ram_ub_int &&  ram_lb_int)  ? {mem_rd_data[63:56], mem_rd_data[63:56]} :
                                   ( ram_ub_int && !ram_lb_int) ? {mem_rd_data[55:48], mem_rd_data[55:48]} :
                                                                  mem_rd_data[63:48];

                3'b100: ram_dq_o <= (!ram_ub_int &&  ram_lb_int)  ? {mem_rd_data[79:72], mem_rd_data[79:72]} :
                                   ( ram_ub_int && !ram_lb_int) ? {mem_rd_data[71:64], mem_rd_data[71:64]} :
                                                                  mem_rd_data[79:64];

                3'b101: ram_dq_o <= (!ram_ub_int &&  ram_lb_int)  ? {mem_rd_data[95:88], mem_rd_data[95:88]} :
                                   ( ram_ub_int && !ram_lb_int) ? {mem_rd_data[87:80], mem_rd_data[87:80]} :
                                                                  mem_rd_data[95:80];

                3'b110: ram_dq_o <= (!ram_ub_int &&  ram_lb_int)  ? {mem_rd_data[111:104], mem_rd_data[111:104]} :
                                   ( ram_ub_int && !ram_lb_int) ? {mem_rd_data[103:96],  mem_rd_data[103:96]}  :
                                                                   mem_rd_data[111:96];

                3'b111: ram_dq_o <= (!ram_ub_int &&  ram_lb_int)  ? {mem_rd_data[127:120], mem_rd_data[127:120]} :
                                   ( ram_ub_int && !ram_lb_int) ? {mem_rd_data[119:112], mem_rd_data[119:112]} :
                                                                   mem_rd_data[127:112];

                default: ram_dq_o <= '0;
            endcase
        end
    end

endmodule
