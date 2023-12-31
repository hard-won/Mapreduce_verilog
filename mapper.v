// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2014.2
// Copyright (C) 2014 Xilinx Inc. All rights reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="mapper,hls_ip_2014_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7z100ffg900-2,HLS_INPUT_CLOCK=8.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=5.550000,HLS_SYN_LAT=15,HLS_SYN_TPT=none,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=0,HLS_SYN_LUT=0}" *)

module mapper (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        pt,
        centres_address0,
        centres_ce0,
        centres_q0,
        ap_return
);

parameter    ap_const_logic_1 = 1'b1;
parameter    ap_const_logic_0 = 1'b0;
parameter    ap_ST_st1_fsm_0 = 2'b00;
parameter    ap_ST_pp0_stg0_fsm_1 = 2'b1;
parameter    ap_ST_st7_fsm_2 = 2'b10;
parameter    ap_const_lv1_0 = 1'b0;
parameter    ap_const_lv64_FFFFFFFFFFFFFFFF = 64'b1111111111111111111111111111111111111111111111111111111111111111;
parameter    ap_const_lv4_0 = 4'b0000;
parameter    ap_const_lv4_A = 4'b1010;
parameter    ap_const_lv4_1 = 4'b1;
parameter    ap_const_lv32_10 = 32'b10000;
parameter    ap_const_lv32_1F = 32'b11111;
parameter    ap_const_lv32_20 = 32'b100000;
parameter    ap_const_lv32_2F = 32'b101111;
parameter    ap_const_lv32_30 = 32'b110000;
parameter    ap_const_lv32_3F = 32'b111111;
parameter    ap_const_lv32_1 = 32'b1;
parameter    ap_true = 1'b1;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
input  [63:0] pt;
output  [3:0] centres_address0;
output   centres_ce0;
input  [63:0] centres_q0;
output  [15:0] ap_return;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg centres_ce0;
reg   [1:0] ap_CS_fsm = 2'b00;
reg   [63:0] min_dist_reg_78;
reg   [15:0] min_index_s_reg_90;
reg   [3:0] i_reg_102;
reg   [3:0] ap_reg_ppstg_i_reg_102_pp0_it1;
reg    ap_reg_ppiten_pp0_it0 = 1'b0;
reg    ap_reg_ppiten_pp0_it1 = 1'b0;
reg    ap_reg_ppiten_pp0_it2 = 1'b0;
reg    ap_reg_ppiten_pp0_it3 = 1'b0;
reg    ap_reg_ppiten_pp0_it4 = 1'b0;
reg   [3:0] ap_reg_ppstg_i_reg_102_pp0_it2;
reg   [3:0] ap_reg_ppstg_i_reg_102_pp0_it3;
wire   [0:0] exitcond2_fu_115_p2;
reg   [0:0] exitcond2_reg_527;
reg   [0:0] ap_reg_ppstg_exitcond2_reg_527_pp0_it1;
reg   [0:0] ap_reg_ppstg_exitcond2_reg_527_pp0_it2;
reg   [0:0] ap_reg_ppstg_exitcond2_reg_527_pp0_it3;
wire   [3:0] i_1_fu_121_p2;
reg   [3:0] i_1_reg_531;
wire   [0:0] tmp_2_fu_139_p2;
reg   [0:0] tmp_2_reg_541;
reg   [0:0] ap_reg_ppstg_tmp_2_reg_541_pp0_it2;
wire   [32:0] tmp_6_fu_159_p1;
wire   [32:0] tmp_8_fu_175_p1;
wire   [0:0] tmp_2_1_fu_204_p2;
reg   [0:0] tmp_2_1_reg_558;
reg   [0:0] ap_reg_ppstg_tmp_2_1_reg_558_pp0_it2;
wire   [32:0] tmp_11_fu_224_p1;
wire   [32:0] tmp_12_fu_240_p1;
wire   [0:0] tmp_2_2_fu_269_p2;
reg   [0:0] tmp_2_2_reg_575;
reg   [0:0] ap_reg_ppstg_tmp_2_2_reg_575_pp0_it2;
wire   [32:0] tmp_16_fu_289_p1;
wire   [32:0] tmp_17_fu_305_p1;
wire   [0:0] tmp_2_3_fu_334_p2;
reg   [0:0] tmp_2_3_reg_592;
reg   [0:0] ap_reg_ppstg_tmp_2_3_reg_592_pp0_it2;
wire   [32:0] tmp_21_fu_354_p1;
wire   [32:0] tmp_22_fu_370_p1;
wire   [33:0] addconv_fu_484_p2;
reg   [33:0] addconv_reg_609;
wire   [63:0] total_dist_1_min_dist_fu_503_p3;
wire   [15:0] min_index_0_min_index_s_fu_511_p3;
reg   [3:0] i_phi_fu_106_p4;
wire   [31:0] i_cast4_fu_127_p1;
wire   [15:0] tmp_3_fu_132_p1;
wire   [15:0] tmp_4_fu_136_p1;
wire   [16:0] tmp_22_cast_fu_145_p1;
wire   [16:0] tmp_23_cast_fu_149_p1;
wire   [16:0] tmp_5_fu_153_p2;
wire   [16:0] grp_fu_163_p0;
wire   [16:0] grp_fu_163_p1;
wire   [16:0] tmp_s_fu_169_p2;
wire   [16:0] grp_fu_179_p0;
wire   [16:0] grp_fu_179_p1;
wire   [15:0] tmp_9_fu_185_p4;
wire   [15:0] tmp_10_fu_195_p4;
wire   [16:0] tmp_3_1_cast_fu_210_p1;
wire   [16:0] tmp_4_1_cast_fu_214_p1;
wire   [16:0] tmp_5_1_fu_218_p2;
wire   [16:0] grp_fu_228_p0;
wire   [16:0] grp_fu_228_p1;
wire   [16:0] tmp_1_7_fu_234_p2;
wire   [16:0] grp_fu_244_p0;
wire   [16:0] grp_fu_244_p1;
wire   [15:0] tmp_14_fu_250_p4;
wire   [15:0] tmp_15_fu_260_p4;
wire   [16:0] tmp_3_2_cast_fu_275_p1;
wire   [16:0] tmp_4_2_cast_fu_279_p1;
wire   [16:0] tmp_5_2_fu_283_p2;
wire   [16:0] grp_fu_293_p0;
wire   [16:0] grp_fu_293_p1;
wire   [16:0] tmp_2_8_fu_299_p2;
wire   [16:0] grp_fu_309_p0;
wire   [16:0] grp_fu_309_p1;
wire   [15:0] tmp_19_fu_315_p4;
wire   [15:0] tmp_20_fu_325_p4;
wire   [16:0] tmp_3_3_cast_fu_340_p1;
wire   [16:0] tmp_4_3_cast_fu_344_p1;
wire   [16:0] tmp_5_3_fu_348_p2;
wire   [16:0] grp_fu_358_p0;
wire   [16:0] grp_fu_358_p1;
wire   [16:0] tmp_3_9_fu_364_p2;
wire   [16:0] grp_fu_374_p0;
wire   [16:0] grp_fu_374_p1;
wire   [32:0] grp_fu_163_p2;
wire   [32:0] grp_fu_179_p2;
wire   [32:0] p_pn_in_fu_380_p3;
wire   [31:0] tmp_7_fu_387_p4;
wire   [32:0] grp_fu_228_p2;
wire   [32:0] grp_fu_244_p2;
wire   [32:0] p_pn_in_1_fu_401_p3;
wire   [31:0] tmp_13_fu_408_p4;
wire   [32:0] grp_fu_293_p2;
wire   [32:0] grp_fu_309_p2;
wire   [32:0] p_pn_in_2_fu_422_p3;
wire   [31:0] tmp_18_fu_429_p4;
wire   [32:0] grp_fu_358_p2;
wire   [32:0] grp_fu_374_p2;
wire   [32:0] p_pn_in_3_fu_443_p3;
wire   [31:0] tmp_23_fu_450_p4;
wire   [32:0] tmp2_fu_464_p0;
wire   [32:0] tmp2_fu_464_p1;
wire   [32:0] tmp2_fu_464_p2;
wire   [32:0] tmp3_fu_474_p0;
wire   [32:0] tmp3_fu_474_p1;
wire   [32:0] tmp3_fu_474_p2;
wire   [33:0] addconv_fu_484_p0;
wire   [33:0] addconv_fu_484_p1;
wire   [63:0] tmp_fu_493_p0;
wire   [63:0] total_dist_3_cast_fu_490_p1;
wire   [0:0] tmp_fu_493_p2;
wire   [63:0] total_dist_1_min_dist_fu_503_p1;
wire   [15:0] min_index_fu_499_p1;
wire    grp_fu_163_ce;
wire    grp_fu_179_ce;
wire    grp_fu_228_ce;
wire    grp_fu_244_ce;
wire    grp_fu_293_ce;
wire    grp_fu_309_ce;
wire    grp_fu_358_ce;
wire    grp_fu_374_ce;
reg   [1:0] ap_NS_fsm;


mapper_mul_17s_17s_33_3 #(
    .ID( 1 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 17 ),
    .dout_WIDTH( 33 ))
mapper_mul_17s_17s_33_3_U1(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .din0( grp_fu_163_p0 ),
    .din1( grp_fu_163_p1 ),
    .ce( grp_fu_163_ce ),
    .dout( grp_fu_163_p2 )
);

mapper_mul_17s_17s_33_3 #(
    .ID( 2 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 17 ),
    .dout_WIDTH( 33 ))
mapper_mul_17s_17s_33_3_U2(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .din0( grp_fu_179_p0 ),
    .din1( grp_fu_179_p1 ),
    .ce( grp_fu_179_ce ),
    .dout( grp_fu_179_p2 )
);

mapper_mul_17s_17s_33_3 #(
    .ID( 3 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 17 ),
    .dout_WIDTH( 33 ))
mapper_mul_17s_17s_33_3_U3(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .din0( grp_fu_228_p0 ),
    .din1( grp_fu_228_p1 ),
    .ce( grp_fu_228_ce ),
    .dout( grp_fu_228_p2 )
);

mapper_mul_17s_17s_33_3 #(
    .ID( 4 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 17 ),
    .dout_WIDTH( 33 ))
mapper_mul_17s_17s_33_3_U4(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .din0( grp_fu_244_p0 ),
    .din1( grp_fu_244_p1 ),
    .ce( grp_fu_244_ce ),
    .dout( grp_fu_244_p2 )
);

mapper_mul_17s_17s_33_3 #(
    .ID( 5 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 17 ),
    .dout_WIDTH( 33 ))
mapper_mul_17s_17s_33_3_U5(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .din0( grp_fu_293_p0 ),
    .din1( grp_fu_293_p1 ),
    .ce( grp_fu_293_ce ),
    .dout( grp_fu_293_p2 )
);

mapper_mul_17s_17s_33_3 #(
    .ID( 6 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 17 ),
    .dout_WIDTH( 33 ))
mapper_mul_17s_17s_33_3_U6(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .din0( grp_fu_309_p0 ),
    .din1( grp_fu_309_p1 ),
    .ce( grp_fu_309_ce ),
    .dout( grp_fu_309_p2 )
);

mapper_mul_17s_17s_33_3 #(
    .ID( 7 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 17 ),
    .dout_WIDTH( 33 ))
mapper_mul_17s_17s_33_3_U7(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .din0( grp_fu_358_p0 ),
    .din1( grp_fu_358_p1 ),
    .ce( grp_fu_358_ce ),
    .dout( grp_fu_358_p2 )
);

mapper_mul_17s_17s_33_3 #(
    .ID( 8 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 17 ),
    .dout_WIDTH( 33 ))
mapper_mul_17s_17s_33_3_U8(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .din0( grp_fu_374_p0 ),
    .din1( grp_fu_374_p1 ),
    .ce( grp_fu_374_ce ),
    .dout( grp_fu_374_p2 )
);



/// the current state (ap_CS_fsm) of the state machine. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_CS_fsm
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_st1_fsm_0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

/// ap_reg_ppiten_pp0_it0 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp0_it0
    if (ap_rst == 1'b1) begin
        ap_reg_ppiten_pp0_it0 <= ap_const_logic_0;
    end else begin
        if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & ~(exitcond2_fu_115_p2 == ap_const_lv1_0))) begin
            ap_reg_ppiten_pp0_it0 <= ap_const_logic_0;
        end else if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0))) begin
            ap_reg_ppiten_pp0_it0 <= ap_const_logic_1;
        end
    end
end

/// ap_reg_ppiten_pp0_it1 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp0_it1
    if (ap_rst == 1'b1) begin
        ap_reg_ppiten_pp0_it1 <= ap_const_logic_0;
    end else begin
        if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (exitcond2_fu_115_p2 == ap_const_lv1_0))) begin
            ap_reg_ppiten_pp0_it1 <= ap_const_logic_1;
        end else if ((((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0)) | ((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & ~(exitcond2_fu_115_p2 == ap_const_lv1_0)))) begin
            ap_reg_ppiten_pp0_it1 <= ap_const_logic_0;
        end
    end
end

/// ap_reg_ppiten_pp0_it2 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp0_it2
    if (ap_rst == 1'b1) begin
        ap_reg_ppiten_pp0_it2 <= ap_const_logic_0;
    end else begin
        if ((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm)) begin
            ap_reg_ppiten_pp0_it2 <= ap_reg_ppiten_pp0_it1;
        end
    end
end

/// ap_reg_ppiten_pp0_it3 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp0_it3
    if (ap_rst == 1'b1) begin
        ap_reg_ppiten_pp0_it3 <= ap_const_logic_0;
    end else begin
        if ((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm)) begin
            ap_reg_ppiten_pp0_it3 <= ap_reg_ppiten_pp0_it2;
        end
    end
end

/// ap_reg_ppiten_pp0_it4 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp0_it4
    if (ap_rst == 1'b1) begin
        ap_reg_ppiten_pp0_it4 <= ap_const_logic_0;
    end else begin
        if ((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm)) begin
            ap_reg_ppiten_pp0_it4 <= ap_reg_ppiten_pp0_it3;
        end else if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0))) begin
            ap_reg_ppiten_pp0_it4 <= ap_const_logic_0;
        end
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it1) & (exitcond2_reg_527 == ap_const_lv1_0))) begin
        i_reg_102 <= i_1_reg_531;
    end else if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0))) begin
        i_reg_102 <= ap_const_lv4_0;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it4) & (ap_reg_ppstg_exitcond2_reg_527_pp0_it3 == ap_const_lv1_0))) begin
        min_dist_reg_78 <= total_dist_1_min_dist_fu_503_p3;
    end else if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0))) begin
        min_dist_reg_78 <= ap_const_lv64_FFFFFFFFFFFFFFFF;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it3) & (ap_reg_ppstg_exitcond2_reg_527_pp0_it2 == ap_const_lv1_0))) begin
        addconv_reg_609 <= addconv_fu_484_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm)) begin
        ap_reg_ppstg_exitcond2_reg_527_pp0_it1 <= exitcond2_reg_527;
        ap_reg_ppstg_exitcond2_reg_527_pp0_it2 <= ap_reg_ppstg_exitcond2_reg_527_pp0_it1;
        ap_reg_ppstg_exitcond2_reg_527_pp0_it3 <= ap_reg_ppstg_exitcond2_reg_527_pp0_it2;
        ap_reg_ppstg_i_reg_102_pp0_it1 <= i_reg_102;
        ap_reg_ppstg_i_reg_102_pp0_it2 <= ap_reg_ppstg_i_reg_102_pp0_it1;
        ap_reg_ppstg_i_reg_102_pp0_it3 <= ap_reg_ppstg_i_reg_102_pp0_it2;
        ap_reg_ppstg_tmp_2_1_reg_558_pp0_it2 <= tmp_2_1_reg_558;
        ap_reg_ppstg_tmp_2_2_reg_575_pp0_it2 <= tmp_2_2_reg_575;
        ap_reg_ppstg_tmp_2_3_reg_592_pp0_it2 <= tmp_2_3_reg_592;
        ap_reg_ppstg_tmp_2_reg_541_pp0_it2 <= tmp_2_reg_541;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it0))) begin
        exitcond2_reg_527 <= exitcond2_fu_115_p2;
        i_1_reg_531 <= i_1_fu_121_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it4) & (ap_reg_ppstg_exitcond2_reg_527_pp0_it3 == ap_const_lv1_0))) begin
        min_index_s_reg_90 <= min_index_0_min_index_s_fu_511_p3;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it1) & (exitcond2_reg_527 == ap_const_lv1_0))) begin
        tmp_2_1_reg_558 <= tmp_2_1_fu_204_p2;
        tmp_2_2_reg_575 <= tmp_2_2_fu_269_p2;
        tmp_2_3_reg_592 <= tmp_2_3_fu_334_p2;
        tmp_2_reg_541 <= tmp_2_fu_139_p2;
    end
end

/// ap_done assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st7_fsm_2 == ap_CS_fsm)) begin
        ap_done = ap_const_logic_1;
    end else begin
        ap_done = ap_const_logic_0;
    end
end

/// ap_idle assign process. ///
always @ (ap_start or ap_CS_fsm)
begin
    if ((~(ap_const_logic_1 == ap_start) & (ap_ST_st1_fsm_0 == ap_CS_fsm))) begin
        ap_idle = ap_const_logic_1;
    end else begin
        ap_idle = ap_const_logic_0;
    end
end

/// ap_ready assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st7_fsm_2 == ap_CS_fsm)) begin
        ap_ready = ap_const_logic_1;
    end else begin
        ap_ready = ap_const_logic_0;
    end
end

/// centres_ce0 assign process. ///
always @ (ap_CS_fsm or ap_reg_ppiten_pp0_it0)
begin
    if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it0))) begin
        centres_ce0 = ap_const_logic_1;
    end else begin
        centres_ce0 = ap_const_logic_0;
    end
end

/// i_phi_fu_106_p4 assign process. ///
always @ (ap_CS_fsm or i_reg_102 or ap_reg_ppiten_pp0_it1 or exitcond2_reg_527 or i_1_reg_531)
begin
    if (((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it1) & (exitcond2_reg_527 == ap_const_lv1_0))) begin
        i_phi_fu_106_p4 = i_1_reg_531;
    end else begin
        i_phi_fu_106_p4 = i_reg_102;
    end
end
/// the next state (ap_NS_fsm) of the state machine. ///
always @ (ap_start or ap_CS_fsm or ap_reg_ppiten_pp0_it0 or ap_reg_ppiten_pp0_it1 or ap_reg_ppiten_pp0_it3 or ap_reg_ppiten_pp0_it4 or exitcond2_fu_115_p2)
begin
    case (ap_CS_fsm)
        ap_ST_st1_fsm_0 : 
        begin
            if (~(ap_start == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_pp0_stg0_fsm_1;
            end else begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end
        end
        ap_ST_pp0_stg0_fsm_1 : 
        begin
            if ((~((ap_ST_pp0_stg0_fsm_1 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it4) & ~(ap_const_logic_1 == ap_reg_ppiten_pp0_it3)) & ~((ap_const_logic_1 == ap_reg_ppiten_pp0_it0) & ~(exitcond2_fu_115_p2 == ap_const_lv1_0) & ~(ap_const_logic_1 == ap_reg_ppiten_pp0_it1)))) begin
                ap_NS_fsm = ap_ST_pp0_stg0_fsm_1;
            end else if (((ap_const_logic_1 == ap_reg_ppiten_pp0_it0) & ~(exitcond2_fu_115_p2 == ap_const_lv1_0) & ~(ap_const_logic_1 == ap_reg_ppiten_pp0_it1))) begin
                ap_NS_fsm = ap_ST_st7_fsm_2;
            end else begin
                ap_NS_fsm = ap_ST_st7_fsm_2;
            end
        end
        ap_ST_st7_fsm_2 : 
        begin
            ap_NS_fsm = ap_ST_st1_fsm_0;
        end
        default : 
        begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign addconv_fu_484_p0 = $signed(tmp3_fu_474_p2);
assign addconv_fu_484_p1 = $signed(tmp2_fu_464_p2);
assign addconv_fu_484_p2 = (addconv_fu_484_p0 + addconv_fu_484_p1);
assign ap_return = min_index_s_reg_90;
assign centres_address0 = i_cast4_fu_127_p1;
assign exitcond2_fu_115_p2 = (i_phi_fu_106_p4 == ap_const_lv4_A? 1'b1: 1'b0);
assign grp_fu_163_ce = ap_const_logic_1;
assign grp_fu_163_p0 = tmp_6_fu_159_p1;
assign grp_fu_163_p1 = tmp_6_fu_159_p1;
assign grp_fu_179_ce = ap_const_logic_1;
assign grp_fu_179_p0 = tmp_8_fu_175_p1;
assign grp_fu_179_p1 = tmp_8_fu_175_p1;
assign grp_fu_228_ce = ap_const_logic_1;
assign grp_fu_228_p0 = tmp_11_fu_224_p1;
assign grp_fu_228_p1 = tmp_11_fu_224_p1;
assign grp_fu_244_ce = ap_const_logic_1;
assign grp_fu_244_p0 = tmp_12_fu_240_p1;
assign grp_fu_244_p1 = tmp_12_fu_240_p1;
assign grp_fu_293_ce = ap_const_logic_1;
assign grp_fu_293_p0 = tmp_16_fu_289_p1;
assign grp_fu_293_p1 = tmp_16_fu_289_p1;
assign grp_fu_309_ce = ap_const_logic_1;
assign grp_fu_309_p0 = tmp_17_fu_305_p1;
assign grp_fu_309_p1 = tmp_17_fu_305_p1;
assign grp_fu_358_ce = ap_const_logic_1;
assign grp_fu_358_p0 = tmp_21_fu_354_p1;
assign grp_fu_358_p1 = tmp_21_fu_354_p1;
assign grp_fu_374_ce = ap_const_logic_1;
assign grp_fu_374_p0 = tmp_22_fu_370_p1;
assign grp_fu_374_p1 = tmp_22_fu_370_p1;
assign i_1_fu_121_p2 = (i_phi_fu_106_p4 + ap_const_lv4_1);
assign i_cast4_fu_127_p1 = $unsigned(i_phi_fu_106_p4);
assign min_index_0_min_index_s_fu_511_p3 = ((tmp_fu_493_p2)? min_index_fu_499_p1: min_index_s_reg_90);
assign min_index_fu_499_p1 = $unsigned(ap_reg_ppstg_i_reg_102_pp0_it3);
assign p_pn_in_1_fu_401_p3 = ((ap_reg_ppstg_tmp_2_1_reg_558_pp0_it2)? grp_fu_228_p2: grp_fu_244_p2);
assign p_pn_in_2_fu_422_p3 = ((ap_reg_ppstg_tmp_2_2_reg_575_pp0_it2)? grp_fu_293_p2: grp_fu_309_p2);
assign p_pn_in_3_fu_443_p3 = ((ap_reg_ppstg_tmp_2_3_reg_592_pp0_it2)? grp_fu_358_p2: grp_fu_374_p2);
assign p_pn_in_fu_380_p3 = ((ap_reg_ppstg_tmp_2_reg_541_pp0_it2)? grp_fu_163_p2: grp_fu_179_p2);
assign tmp2_fu_464_p0 = $signed(tmp_7_fu_387_p4);
assign tmp2_fu_464_p1 = $signed(tmp_18_fu_429_p4);
assign tmp2_fu_464_p2 = (tmp2_fu_464_p0 + tmp2_fu_464_p1);
assign tmp3_fu_474_p0 = $signed(tmp_13_fu_408_p4);
assign tmp3_fu_474_p1 = $signed(tmp_23_fu_450_p4);
assign tmp3_fu_474_p2 = (tmp3_fu_474_p0 + tmp3_fu_474_p1);
assign tmp_10_fu_195_p4 = {{pt[ap_const_lv32_1F : ap_const_lv32_10]}};
assign tmp_11_fu_224_p1 = $signed(tmp_5_1_fu_218_p2);
assign tmp_12_fu_240_p1 = $signed(tmp_1_7_fu_234_p2);
assign tmp_13_fu_408_p4 = {{p_pn_in_1_fu_401_p3[ap_const_lv32_20 : ap_const_lv32_1]}};
assign tmp_14_fu_250_p4 = {{centres_q0[ap_const_lv32_2F : ap_const_lv32_20]}};
assign tmp_15_fu_260_p4 = {{pt[ap_const_lv32_2F : ap_const_lv32_20]}};
assign tmp_16_fu_289_p1 = $signed(tmp_5_2_fu_283_p2);
assign tmp_17_fu_305_p1 = $signed(tmp_2_8_fu_299_p2);
assign tmp_18_fu_429_p4 = {{p_pn_in_2_fu_422_p3[ap_const_lv32_20 : ap_const_lv32_1]}};
assign tmp_19_fu_315_p4 = {{centres_q0[ap_const_lv32_3F : ap_const_lv32_30]}};
assign tmp_1_7_fu_234_p2 = (tmp_4_1_cast_fu_214_p1 - tmp_3_1_cast_fu_210_p1);
assign tmp_20_fu_325_p4 = {{pt[ap_const_lv32_3F : ap_const_lv32_30]}};
assign tmp_21_fu_354_p1 = $signed(tmp_5_3_fu_348_p2);
assign tmp_22_cast_fu_145_p1 = $unsigned(tmp_3_fu_132_p1);
assign tmp_22_fu_370_p1 = $signed(tmp_3_9_fu_364_p2);
assign tmp_23_cast_fu_149_p1 = $unsigned(tmp_4_fu_136_p1);
assign tmp_23_fu_450_p4 = {{p_pn_in_3_fu_443_p3[ap_const_lv32_20 : ap_const_lv32_1]}};
assign tmp_2_1_fu_204_p2 = (tmp_9_fu_185_p4 > tmp_10_fu_195_p4? 1'b1: 1'b0);
assign tmp_2_2_fu_269_p2 = (tmp_14_fu_250_p4 > tmp_15_fu_260_p4? 1'b1: 1'b0);
assign tmp_2_3_fu_334_p2 = (tmp_19_fu_315_p4 > tmp_20_fu_325_p4? 1'b1: 1'b0);
assign tmp_2_8_fu_299_p2 = (tmp_4_2_cast_fu_279_p1 - tmp_3_2_cast_fu_275_p1);
assign tmp_2_fu_139_p2 = (tmp_3_fu_132_p1 > tmp_4_fu_136_p1? 1'b1: 1'b0);
assign tmp_3_1_cast_fu_210_p1 = $unsigned(tmp_9_fu_185_p4);
assign tmp_3_2_cast_fu_275_p1 = $unsigned(tmp_14_fu_250_p4);
assign tmp_3_3_cast_fu_340_p1 = $unsigned(tmp_19_fu_315_p4);
assign tmp_3_9_fu_364_p2 = (tmp_4_3_cast_fu_344_p1 - tmp_3_3_cast_fu_340_p1);
assign tmp_3_fu_132_p1 = centres_q0[15:0];
assign tmp_4_1_cast_fu_214_p1 = $unsigned(tmp_10_fu_195_p4);
assign tmp_4_2_cast_fu_279_p1 = $unsigned(tmp_15_fu_260_p4);
assign tmp_4_3_cast_fu_344_p1 = $unsigned(tmp_20_fu_325_p4);
assign tmp_4_fu_136_p1 = pt[15:0];
assign tmp_5_1_fu_218_p2 = (tmp_3_1_cast_fu_210_p1 - tmp_4_1_cast_fu_214_p1);
assign tmp_5_2_fu_283_p2 = (tmp_3_2_cast_fu_275_p1 - tmp_4_2_cast_fu_279_p1);
assign tmp_5_3_fu_348_p2 = (tmp_3_3_cast_fu_340_p1 - tmp_4_3_cast_fu_344_p1);
assign tmp_5_fu_153_p2 = (tmp_22_cast_fu_145_p1 - tmp_23_cast_fu_149_p1);
assign tmp_6_fu_159_p1 = $signed(tmp_5_fu_153_p2);
assign tmp_7_fu_387_p4 = {{p_pn_in_fu_380_p3[ap_const_lv32_20 : ap_const_lv32_1]}};
assign tmp_8_fu_175_p1 = $signed(tmp_s_fu_169_p2);
assign tmp_9_fu_185_p4 = {{centres_q0[ap_const_lv32_1F : ap_const_lv32_10]}};
assign tmp_fu_493_p0 = total_dist_3_cast_fu_490_p1;
assign tmp_fu_493_p2 = (tmp_fu_493_p0 < min_dist_reg_78? 1'b1: 1'b0);
assign tmp_s_fu_169_p2 = (tmp_23_cast_fu_149_p1 - tmp_22_cast_fu_145_p1);
assign total_dist_1_min_dist_fu_503_p1 = total_dist_3_cast_fu_490_p1;
assign total_dist_1_min_dist_fu_503_p3 = ((tmp_fu_493_p2)? total_dist_1_min_dist_fu_503_p1: min_dist_reg_78);
assign total_dist_3_cast_fu_490_p1 = $signed(addconv_reg_609);


endmodule //mapper

