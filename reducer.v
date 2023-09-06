// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2014.2
// Copyright (C) 2014 Xilinx Inc. All rights reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="reducer,hls_ip_2014_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7z100ffg900-2,HLS_INPUT_CLOCK=8.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=6.780000,HLS_SYN_LAT=2,HLS_SYN_TPT=none,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=0,HLS_SYN_LUT=0}" *)

module reducer (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        key,
        pt,
        sum_address0,
        sum_ce0,
        sum_q0,
        sum_address1,
        sum_ce1,
        sum_we1,
        sum_d1,
        counter_address0,
        counter_ce0,
        counter_q0,
        counter_address1,
        counter_ce1,
        counter_we1,
        counter_d1
);

parameter    ap_const_logic_1 = 1'b1;
parameter    ap_const_logic_0 = 1'b0;
parameter    ap_ST_st1_fsm_0 = 2'b00;
parameter    ap_ST_st2_fsm_1 = 2'b1;
parameter    ap_ST_st3_fsm_2 = 2'b10;
parameter    ap_const_lv32_40 = 32'b1000000;
parameter    ap_const_lv32_7F = 32'b1111111;
parameter    ap_const_lv32_80 = 32'b10000000;
parameter    ap_const_lv32_BF = 32'b10111111;
parameter    ap_const_lv32_C0 = 32'b11000000;
parameter    ap_const_lv32_FF = 32'b11111111;
parameter    ap_const_lv32_1 = 32'b1;
parameter    ap_const_lv32_10 = 32'b10000;
parameter    ap_const_lv32_1F = 32'b11111;
parameter    ap_const_lv32_20 = 32'b100000;
parameter    ap_const_lv32_2F = 32'b101111;
parameter    ap_const_lv32_30 = 32'b110000;
parameter    ap_const_lv32_3F = 32'b111111;
parameter    ap_true = 1'b1;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
input  [15:0] key;
input  [63:0] pt;
output  [2:0] sum_address0;
output   sum_ce0;
input  [255:0] sum_q0;
output  [2:0] sum_address1;
output   sum_ce1;
output   sum_we1;
output  [255:0] sum_d1;
output  [2:0] counter_address0;
output   counter_ce0;
input  [31:0] counter_q0;
output  [2:0] counter_address1;
output   counter_ce1;
output   counter_we1;
output  [31:0] counter_d1;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg sum_ce0;
reg sum_ce1;
reg sum_we1;
reg counter_ce0;
reg counter_ce1;
reg counter_we1;
reg   [1:0] ap_CS_fsm = 2'b00;
reg   [2:0] sum_addr_reg_231;
reg   [2:0] counter_addr_reg_237;
wire   [63:0] tmp_4_fu_107_p1;
reg   [63:0] tmp_4_reg_243;
reg   [63:0] tmp_7_reg_248;
reg   [63:0] tmp_5_reg_253;
reg   [63:0] tmp_10_reg_258;
wire   [31:0] tmp_fu_101_p1;
wire   [15:0] tmp_3_fu_148_p1;
wire   [63:0] tmp_s_fu_152_p1;
wire   [15:0] tmp_6_fu_161_p4;
wire   [63:0] tmp_2_1_fu_171_p1;
wire   [15:0] tmp_9_fu_180_p4;
wire   [63:0] tmp_2_2_fu_190_p1;
wire   [15:0] tmp_8_fu_199_p4;
wire   [63:0] tmp_2_3_fu_209_p1;
wire   [63:0] tmp_3_3_fu_213_p2;
wire   [63:0] tmp_3_2_fu_194_p2;
wire   [63:0] tmp_3_1_fu_175_p2;
wire   [63:0] tmp_2_fu_156_p2;
reg   [1:0] ap_NS_fsm;




/// the current state (ap_CS_fsm) of the state machine. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_CS_fsm
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_st1_fsm_0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0))) begin
        counter_addr_reg_237 <= tmp_fu_101_p1;
        sum_addr_reg_231 <= tmp_fu_101_p1;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((ap_ST_st2_fsm_1 == ap_CS_fsm)) begin
        tmp_10_reg_258 <= {{sum_q0[ap_const_lv32_FF : ap_const_lv32_C0]}};
        tmp_4_reg_243 <= tmp_4_fu_107_p1;
        tmp_5_reg_253 <= {{sum_q0[ap_const_lv32_BF : ap_const_lv32_80]}};
        tmp_7_reg_248 <= {{sum_q0[ap_const_lv32_7F : ap_const_lv32_40]}};
    end
end

/// ap_done assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st3_fsm_2 == ap_CS_fsm)) begin
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
    if ((ap_ST_st3_fsm_2 == ap_CS_fsm)) begin
        ap_ready = ap_const_logic_1;
    end else begin
        ap_ready = ap_const_logic_0;
    end
end

/// counter_ce0 assign process. ///
always @ (ap_start or ap_CS_fsm)
begin
    if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0))) begin
        counter_ce0 = ap_const_logic_1;
    end else begin
        counter_ce0 = ap_const_logic_0;
    end
end

/// counter_ce1 assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st2_fsm_1 == ap_CS_fsm)) begin
        counter_ce1 = ap_const_logic_1;
    end else begin
        counter_ce1 = ap_const_logic_0;
    end
end

/// counter_we1 assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st2_fsm_1 == ap_CS_fsm)) begin
        counter_we1 = ap_const_logic_1;
    end else begin
        counter_we1 = ap_const_logic_0;
    end
end

/// sum_ce0 assign process. ///
always @ (ap_start or ap_CS_fsm)
begin
    if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0))) begin
        sum_ce0 = ap_const_logic_1;
    end else begin
        sum_ce0 = ap_const_logic_0;
    end
end

/// sum_ce1 assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st3_fsm_2 == ap_CS_fsm)) begin
        sum_ce1 = ap_const_logic_1;
    end else begin
        sum_ce1 = ap_const_logic_0;
    end
end

/// sum_we1 assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st3_fsm_2 == ap_CS_fsm)) begin
        sum_we1 = ap_const_logic_1;
    end else begin
        sum_we1 = ap_const_logic_0;
    end
end
/// the next state (ap_NS_fsm) of the state machine. ///
always @ (ap_start or ap_CS_fsm)
begin
    case (ap_CS_fsm)
        ap_ST_st1_fsm_0 : 
        begin
            if (~(ap_start == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end else begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end
        end
        ap_ST_st2_fsm_1 : 
        begin
            ap_NS_fsm = ap_ST_st3_fsm_2;
        end
        ap_ST_st3_fsm_2 : 
        begin
            ap_NS_fsm = ap_ST_st1_fsm_0;
        end
        default : 
        begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign counter_address0 = tmp_fu_101_p1;
assign counter_address1 = counter_addr_reg_237;
assign counter_d1 = (counter_q0 + ap_const_lv32_1);
assign sum_address0 = tmp_fu_101_p1;
assign sum_address1 = sum_addr_reg_231;
assign sum_d1 = {{{{{{tmp_3_3_fu_213_p2}, {tmp_3_2_fu_194_p2}}}, {tmp_3_1_fu_175_p2}}}, {tmp_2_fu_156_p2}};
assign tmp_2_1_fu_171_p1 = $unsigned(tmp_6_fu_161_p4);
assign tmp_2_2_fu_190_p1 = $unsigned(tmp_9_fu_180_p4);
assign tmp_2_3_fu_209_p1 = $unsigned(tmp_8_fu_199_p4);
assign tmp_2_fu_156_p2 = (tmp_4_reg_243 + tmp_s_fu_152_p1);
assign tmp_3_1_fu_175_p2 = (tmp_7_reg_248 + tmp_2_1_fu_171_p1);
assign tmp_3_2_fu_194_p2 = (tmp_5_reg_253 + tmp_2_2_fu_190_p1);
assign tmp_3_3_fu_213_p2 = (tmp_10_reg_258 + tmp_2_3_fu_209_p1);
assign tmp_3_fu_148_p1 = pt[15:0];
assign tmp_4_fu_107_p1 = sum_q0[63:0];
assign tmp_6_fu_161_p4 = {{pt[ap_const_lv32_1F : ap_const_lv32_10]}};
assign tmp_8_fu_199_p4 = {{pt[ap_const_lv32_3F : ap_const_lv32_30]}};
assign tmp_9_fu_180_p4 = {{pt[ap_const_lv32_2F : ap_const_lv32_20]}};
assign tmp_fu_101_p1 = $unsigned(key);
assign tmp_s_fu_152_p1 = $unsigned(tmp_3_fu_148_p1);


endmodule //reducer

