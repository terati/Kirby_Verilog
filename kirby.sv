//-------------------------------------------------------------------------
//    Kirby.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  Kirby ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input logic   is_kirby, is_block, 
               input logic [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_kirby_temp, is_waddle0_temp, is_block_temp, is_attack_temp, is_testblock, is_kirbysub, is_atk_temp, boss, is_flame,       // Whether current pixel belongs to Kirby or background
					output [31:0] kirby_dir,   		//kirby direction
					input [31:0]  keycode,
					output [15:0]  Kirby_X_Pos, Kirby_Y_Pos, 
										
					output logic  LorR,  				 // L = 0 and R = 1
					output logic [9:0]  FLOAT_FSM, REGWALK_FSM, STILL_FSM,
					output logic [19:0] ADDR, KADDR, WADDR, ATKADDR, BATKADDR,
					output logic BOSSTIME,
					output logic [3:0] health

              );
    
    parameter [9:0] Kirby_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Kirby_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Kirby_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Kirby_X_Max = 10'd640;     // Rightmost point on the X axis
	 parameter [9:0] xmin_line = 10'd90;
	 parameter [9:0] xmax_line = 10'd590;
    parameter [9:0] Kirby_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Kirby_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] Kirby_X_Step = 10'd2;      // Step size on the X axis
    parameter [9:0] Kirby_Y_Step = 10'd2;      // Step size on the Y axis
    parameter [9:0] Kirby_Size = 10'd4;        // Kirby size
	 

	 
    logic [15:0] prev_press = 0;
	 logic [15:0] curr_press = 0;
	 logic [31:0] UP_COUNT = 0;
	 logic [31:0] WALK_COUNT = 0;
	 logic [31:0] STILL_COUNT = 0;
	 logic [31:0] ATK_COUNT = 0;
	 logic [9:0]  KATKFSM;
	 logic 		  U,D,L,R,A = 0;
	 logic [31:0] ref_x = 32'd500;
	 logic [9:0]  move_x = 0;
	 logic 		  NO_DOWN, NO_UP, NO_LEFT, NO_RIGHT;
	 logic [15:0] rotate, rcounter;
	 logic [31:0] temp1,temp2,row,col;
	 logic [15:0] block0_X_Pos, block0_Y_Pos,
block1_X_Pos, block1_Y_Pos,
block2_X_Pos, block2_Y_Pos,
block3_X_Pos, block3_Y_Pos,
block4_X_Pos, block4_Y_Pos,
block5_X_Pos, block5_Y_Pos,
block6_X_Pos, block6_Y_Pos,
block7_X_Pos, block7_Y_Pos,
block8_X_Pos, block8_Y_Pos,
block9_X_Pos, block9_Y_Pos,
block10_X_Pos, block10_Y_Pos,
block11_X_Pos, block11_Y_Pos,
block12_X_Pos, block12_Y_Pos,
block13_X_Pos, block13_Y_Pos,
block14_X_Pos, block14_Y_Pos,
block15_X_Pos, block15_Y_Pos,
block16_X_Pos, block16_Y_Pos,
block17_X_Pos, block17_Y_Pos,
block18_X_Pos, block18_Y_Pos,
block19_X_Pos, block19_Y_Pos,
block20_X_Pos, block20_Y_Pos,
block21_X_Pos, block21_Y_Pos,
block22_X_Pos, block22_Y_Pos,
block23_X_Pos, block23_Y_Pos,
block24_X_Pos, block24_Y_Pos,
block25_X_Pos, block25_Y_Pos,
block26_X_Pos, block26_Y_Pos,
block27_X_Pos, block27_Y_Pos,
block28_X_Pos, block28_Y_Pos,
block29_X_Pos, block29_Y_Pos,
block30_X_Pos, block30_Y_Pos,
block31_X_Pos, block31_Y_Pos,
block32_X_Pos, block32_Y_Pos,
block33_X_Pos, block33_Y_Pos,
block34_X_Pos, block34_Y_Pos,
block35_X_Pos, block35_Y_Pos,
block36_X_Pos, block36_Y_Pos,
block37_X_Pos, block37_Y_Pos,
block38_X_Pos, block38_Y_Pos,
block39_X_Pos, block39_Y_Pos,
block40_X_Pos, block40_Y_Pos,
block41_X_Pos, block41_Y_Pos,
block42_X_Pos, block42_Y_Pos,
block43_X_Pos, block43_Y_Pos,
block44_X_Pos, block44_Y_Pos,
block45_X_Pos, block45_Y_Pos,
block46_X_Pos, block46_Y_Pos,
block47_X_Pos, block47_Y_Pos,
block48_X_Pos, block48_Y_Pos,
block49_X_Pos, block49_Y_Pos,
block50_X_Pos, block50_Y_Pos,
block51_X_Pos, block51_Y_Pos,
block52_X_Pos, block52_Y_Pos,
block53_X_Pos, block53_Y_Pos,
block54_X_Pos, block54_Y_Pos,
block55_X_Pos, block55_Y_Pos,
block56_X_Pos, block56_Y_Pos,
block57_X_Pos, block57_Y_Pos,
block58_X_Pos, block58_Y_Pos,
block59_X_Pos, block59_Y_Pos,
block60_X_Pos, block60_Y_Pos,
block61_X_Pos, block61_Y_Pos,
block62_X_Pos, block62_Y_Pos,
block63_X_Pos, block63_Y_Pos,
block64_X_Pos, block64_Y_Pos,
block65_X_Pos, block65_Y_Pos,
block66_X_Pos, block66_Y_Pos,
block67_X_Pos, block67_Y_Pos,
block68_X_Pos, block68_Y_Pos,
block69_X_Pos, block69_Y_Pos,
block70_X_Pos, block70_Y_Pos,
block71_X_Pos, block71_Y_Pos,
block72_X_Pos, block72_Y_Pos,
block73_X_Pos, block73_Y_Pos,
block74_X_Pos, block74_Y_Pos,
block75_X_Pos, block75_Y_Pos,
block76_X_Pos, block76_Y_Pos,
block77_X_Pos, block77_Y_Pos,
block78_X_Pos, block78_Y_Pos,
block79_X_Pos, block79_Y_Pos,
block80_X_Pos, block80_Y_Pos,
block81_X_Pos, block81_Y_Pos,
block82_X_Pos, block82_Y_Pos,
block83_X_Pos, block83_Y_Pos,
block84_X_Pos, block84_Y_Pos,
block85_X_Pos, block85_Y_Pos,
block86_X_Pos, block86_Y_Pos,
block87_X_Pos, block87_Y_Pos,
block88_X_Pos, block88_Y_Pos,
block89_X_Pos, block89_Y_Pos,
block90_X_Pos, block90_Y_Pos,
block91_X_Pos, block91_Y_Pos,
block92_X_Pos, block92_Y_Pos,
block93_X_Pos, block93_Y_Pos,
block94_X_Pos, block94_Y_Pos,
block95_X_Pos, block95_Y_Pos,
block96_X_Pos, block96_Y_Pos,
block97_X_Pos, block97_Y_Pos,
block98_X_Pos, block98_Y_Pos,
block99_X_Pos, block99_Y_Pos,
block100_X_Pos, block100_Y_Pos,
block101_X_Pos, block101_Y_Pos,
block102_X_Pos, block102_Y_Pos,
block103_X_Pos, block103_Y_Pos,
block104_X_Pos, block104_Y_Pos,
block105_X_Pos, block105_Y_Pos,
block106_X_Pos, block106_Y_Pos,
block107_X_Pos, block107_Y_Pos,
block108_X_Pos, block108_Y_Pos,
block109_X_Pos, block109_Y_Pos,
block110_X_Pos, block110_Y_Pos,
block111_X_Pos, block111_Y_Pos,
block112_X_Pos, block112_Y_Pos,
block113_X_Pos, block113_Y_Pos,
block114_X_Pos, block114_Y_Pos,
block115_X_Pos, block115_Y_Pos,
block116_X_Pos, block116_Y_Pos,
block117_X_Pos, block117_Y_Pos,
block118_X_Pos, block118_Y_Pos,
block119_X_Pos, block119_Y_Pos,
block120_X_Pos, block120_Y_Pos,
block121_X_Pos, block121_Y_Pos,
block122_X_Pos, block122_Y_Pos,
block123_X_Pos, block123_Y_Pos,
block124_X_Pos, block124_Y_Pos,
block125_X_Pos, block125_Y_Pos,
block126_X_Pos, block126_Y_Pos,
block127_X_Pos, block127_Y_Pos,
block128_X_Pos, block128_Y_Pos,
block129_X_Pos, block129_Y_Pos,
block130_X_Pos, block130_Y_Pos,
block131_X_Pos, block131_Y_Pos,
block132_X_Pos, block132_Y_Pos,
block133_X_Pos, block133_Y_Pos,
block134_X_Pos, block134_Y_Pos,
block135_X_Pos, block135_Y_Pos,
block136_X_Pos, block136_Y_Pos,
block137_X_Pos, block137_Y_Pos,
block138_X_Pos, block138_Y_Pos,
block139_X_Pos, block139_Y_Pos,
block140_X_Pos, block140_Y_Pos,
block141_X_Pos, block141_Y_Pos,
block142_X_Pos, block142_Y_Pos,
block143_X_Pos, block143_Y_Pos,
block144_X_Pos, block144_Y_Pos,
block145_X_Pos, block145_Y_Pos,
block146_X_Pos, block146_Y_Pos,
block147_X_Pos, block147_Y_Pos,
block148_X_Pos, block148_Y_Pos,
block149_X_Pos, block149_Y_Pos,
block150_X_Pos, block150_Y_Pos,
block151_X_Pos, block151_Y_Pos,
block152_X_Pos, block152_Y_Pos,
block153_X_Pos, block153_Y_Pos,
block154_X_Pos, block154_Y_Pos,
block155_X_Pos, block155_Y_Pos,
block156_X_Pos, block156_Y_Pos,
block157_X_Pos, block157_Y_Pos,
block158_X_Pos, block158_Y_Pos,
block159_X_Pos, block159_Y_Pos,
block160_X_Pos, block160_Y_Pos,
block161_X_Pos, block161_Y_Pos,
block162_X_Pos, block162_Y_Pos,
block163_X_Pos, block163_Y_Pos,
block164_X_Pos, block164_Y_Pos,
block165_X_Pos, block165_Y_Pos,
block166_X_Pos, block166_Y_Pos,
block167_X_Pos, block167_Y_Pos,
block168_X_Pos, block168_Y_Pos,
block169_X_Pos, block169_Y_Pos,
block170_X_Pos, block170_Y_Pos,
block171_X_Pos, block171_Y_Pos,
block172_X_Pos, block172_Y_Pos,
block173_X_Pos, block173_Y_Pos,
block174_X_Pos, block174_Y_Pos,
block175_X_Pos, block175_Y_Pos,
block176_X_Pos, block176_Y_Pos,
block177_X_Pos, block177_Y_Pos,
block178_X_Pos, block178_Y_Pos,
block179_X_Pos, block179_Y_Pos,
block180_X_Pos, block180_Y_Pos,
block181_X_Pos, block181_Y_Pos,
block182_X_Pos, block182_Y_Pos,
block183_X_Pos, block183_Y_Pos,
block184_X_Pos, block184_Y_Pos,
block185_X_Pos, block185_Y_Pos,
block186_X_Pos, block186_Y_Pos,
block187_X_Pos, block187_Y_Pos,
block188_X_Pos, block188_Y_Pos,
block189_X_Pos, block189_Y_Pos,
block190_X_Pos, block190_Y_Pos,
block191_X_Pos, block191_Y_Pos,
block192_X_Pos, block192_Y_Pos,
block193_X_Pos, block193_Y_Pos,
block194_X_Pos, block194_Y_Pos,
block195_X_Pos, block195_Y_Pos,
block196_X_Pos, block196_Y_Pos,
block197_X_Pos, block197_Y_Pos,
block198_X_Pos, block198_Y_Pos,
block199_X_Pos, block199_Y_Pos,
block200_X_Pos, block200_Y_Pos,

block201_X_Pos, block201_Y_Pos, //sky

block202_X_Pos, block202_Y_Pos, //ground

block203_X_Pos, block203_Y_Pos, //sky2

block204_X_Pos, block204_Y_Pos, //ground2


block205_X_Pos, block205_Y_Pos, //boss_background left
block206_X_Pos, block206_Y_Pos, //boss_background right
block207_X_Pos, block207_Y_Pos,
 
boss_X_Pos, boss_Y_Pos, //boss coordinates

f0_X_Pos, f0_Y_Pos,
f1_X_Pos, f1_Y_Pos,
f2_X_Pos, f2_Y_Pos;

	 logic block0,
block1,
block2,
block3,
block4,
block5,
block6,
block7,
block8,
block9,
block10,
block11,
block12,
block13,
block14,
block15,
block16,
block17,
block18,
block19,
block20,
block21,
block22,
block23,
block24,
block25,
block26,
block27,
block28,
block29,
block30,
block31,
block32,
block33,
block34,
block35,
block36,
block37,
block38,
block39,
block40,
block41,
block42,
block43,
block44,
block45,
block46,
block47,
block48,
block49,
block50,
block51,
block52,
block53,
block54,
block55,
block56,
block57,
block58,
block59,
block60,
block61,
block62,
block63,
block64,
block65,
block66,
block67,
block68,
block69,
block70,
block71,
block72,
block73,
block74,
block75,
block76,
block77,
block78,
block79,
block80,
block81,
block82,
block83,
block84,
block85,
block86,
block87,
block88,
block89,
block90,
block91,
block92,
block93,
block94,
block95,
block96,
block97,
block98,
block99,
block100,
block101,
block102,
block103,
block104,
block105,
block106,
block107,
block108,
block109,
block110,
block111,
block112,
block113,
block114,
block115,
block116,
block117,
block118,
block119,
block120,
block121,
block122,
block123,
block124,
block125,
block126,
block127,
block128,
block129,
block130,
block131,
block132,
block133,
block134,
block135,
block136,
block137,
block138,
block139,
block140,
block141,
block142,
block143,
block144,
block145,
block146,
block147,
block148,
block149,
block150,
block151,
block152,
block153,
block154,
block155,
block156,
block157,
block158,
block159,
block160,
block161,
block162,
block163,
block164,
block165,
block166,
block167,
block168,
block169,
block170,
block171,
block172,
block173,
block174,
block175,
block176,
block177,
block178,
block179,
block180,
block181,
block182,
block183,
block184,
block185,
block186,
block187,
block188,
block189,
block190,
block191,
block192,
block193,
block194,
block195,
block196,
block197,
block198,
block199,
block200,

block201,
block202,
block203,
block204,

block205,
block206,
block207,

f0,
f1,
f2;

    logic frame_clk_delayed, frame_clk_rising_edge;
	 logic SPIKE, hurtflag, healthstate;
	 logic [15:0] hurtcounter;
	 
	 
	 
	 
	 logic [15:0] atk_X_Pos, atk_Y_Pos;
	 logic active_atk, atk_enable;
	 logic [7:0] atkstate = 0;
	 logic [9:0] atkFSM, atkcount;
	 
	 	 
    logic [15:0] waddle0_X_Pos, waddle0_Y_Pos;
	 logic 		  waddle0attacked, waddle0_LorR;
	 logic [2:0] waddle0state;
	 logic [9:0] waddle0_right_count, waddle0_left_count, waddle0_hit_count;
	 
	 localparam waddle0walkright = 3'd0;
	 localparam waddle0walkleft = 3'd1;
	 localparam waddle0hit = 3'd2;
	 localparam waddle0dead = 3'd4;
	
	localparam healthidle = 1'b0;
	localparam healthwait = 1'b1;
	
	 logic [5:0] waddle0_right_FSM, waddle0_left_FSM;
	 logic [5:0] waddle0_FSM;
	 
	 logic [5:0] bstate = 0, bstill_FSM = 0, bfly_FSM = 0, bmid_FSM = 0, bfire_FSM = 0, bswoop_FSM = 0;
	 logic [15:0] bcounter;
	 logic bLorR = 0;
	 logic [3:0] bbcounter = 4'd0;
	 
	 
	 logic [5:0] fstate = 0; 
	 logic [15:0] fcount;
	 
	 
	 
	 initial begin
		
		move_x = '0;
	   rotate = 16'd0;
		rcounter = 16'd0;
		LorR = 1'b1;
		Kirby_X_Pos = 10'd40;
		Kirby_Y_Pos = 10'd240;
		atk_X_Pos = 16'd40;
		atk_Y_Pos = 16'd240;
		active_atk = 1'b0;
		
		
	  health = 4'd5;
	  hurtcounter = 16'd0;
	  hurtflag = 0;
	  
	  waddle0state = 3'd0;
	  waddle0_right_count = 10'd0;
	  waddle0_left_count = 10'd0;
	  waddle0_hit_count = 10'd0;
	  waddle0_X_Pos = 16'd135;
	  waddle0_Y_Pos = 16'd416;
	  waddle0_FSM = 6'd0;
	  waddle0_right_FSM = 6'd0;
	  waddle0_left_FSM = 6'd0;
	  waddle0attacked = 1'b0;
		
		block0_X_Pos = 16'd0;
		block0_Y_Pos = 16'd0;
		block1_X_Pos = 16'd0;
		block1_Y_Pos = 16'd32;
		block2_X_Pos = 16'd0;
		block2_Y_Pos = 16'd64;
		block3_X_Pos = 16'd0;
		block3_Y_Pos = 16'd96;
		block4_X_Pos = 16'd0;
		block4_Y_Pos = 16'd128;
		block5_X_Pos = 16'd0;
		block5_Y_Pos = 16'd160;
		block6_X_Pos = 16'd0;
		block6_Y_Pos = 16'd192;
		block7_X_Pos = 16'd0;
		block7_Y_Pos = 16'd224;
		block8_X_Pos = 16'd0;
		block8_Y_Pos = 16'd256;
		block9_X_Pos = 16'd0;
		block9_Y_Pos = 16'd288;
		block10_X_Pos = 16'd0;
		block10_Y_Pos = 16'd320;
		block11_X_Pos = 16'd0;
		block11_Y_Pos = 16'd352;
		block12_X_Pos = 16'd0;
		block12_Y_Pos = 16'd384;
		block13_X_Pos = 16'd0;
		block13_Y_Pos = 16'd416;
		block14_X_Pos = 16'd0;
		block14_Y_Pos = 16'd448;
		block15_X_Pos = 16'd32;
		block15_Y_Pos = 16'd0;
		block16_X_Pos = 16'd32;
		block16_Y_Pos = 16'd32;
		block17_X_Pos = 16'd32;
		block17_Y_Pos = 16'd64;
		block18_X_Pos = 16'd32;
		block18_Y_Pos = 16'd96;
		block19_X_Pos = 16'd32;
		block19_Y_Pos = 16'd128;
		block20_X_Pos = 16'd32;
		block20_Y_Pos = 16'd160;
		block21_X_Pos = 16'd32;
		block21_Y_Pos = 16'd192;
		block22_X_Pos = 16'd32;
		block22_Y_Pos = 16'd224;
		block23_X_Pos = 16'd32;
		block23_Y_Pos = 16'd256;
		block24_X_Pos = 16'd32;
		block24_Y_Pos = 16'd288;
		block25_X_Pos = 16'd32;
		block25_Y_Pos = 16'd320;
		block26_X_Pos = 16'd32;
		block26_Y_Pos = 16'd352;
		block27_X_Pos = 16'd32;
		block27_Y_Pos = 16'd384;
		block28_X_Pos = 16'd32;
		block28_Y_Pos = 16'd416;
		block29_X_Pos = 16'd32;
		block29_Y_Pos = 16'd448;
		block30_X_Pos = 16'd64;
		block30_Y_Pos = 16'd0;
		block31_X_Pos = 16'd64;
		block31_Y_Pos = 16'd32;
		block32_X_Pos = 16'd64;
		block32_Y_Pos = 16'd64;
		block33_X_Pos = 16'd64;
		block33_Y_Pos = 16'd96;
		block34_X_Pos = 16'd64;
		block34_Y_Pos = 16'd128;
		block35_X_Pos = 16'd64;
		block35_Y_Pos = 16'd160;
		block36_X_Pos = 16'd64;
		block36_Y_Pos = 16'd192;
		block37_X_Pos = 16'd64;
		block37_Y_Pos = 16'd224;
		block38_X_Pos = 16'd64;
		block38_Y_Pos = 16'd256;
		block39_X_Pos = 16'd64;
		block39_Y_Pos = 16'd288;
		block40_X_Pos = 16'd64;
		block40_Y_Pos = 16'd320;
		block41_X_Pos = 16'd64;
		block41_Y_Pos = 16'd352;
		block42_X_Pos = 16'd64;
		block42_Y_Pos = 16'd384;
		block43_X_Pos = 16'd64;
		block43_Y_Pos = 16'd416;
		block44_X_Pos = 16'd64;
		block44_Y_Pos = 16'd448;
		block45_X_Pos = 16'd96;
		block45_Y_Pos = 16'd0;
		block46_X_Pos = 16'd96;
		block46_Y_Pos = 16'd32;
		block47_X_Pos = 16'd96;
		block47_Y_Pos = 16'd64;
		block48_X_Pos = 16'd96;
		block48_Y_Pos = 16'd96;
		block49_X_Pos = 16'd96;
		block49_Y_Pos = 16'd128;
		block50_X_Pos = 16'd96;
		block50_Y_Pos = 16'd160;
		block51_X_Pos = 16'd96;
		block51_Y_Pos = 16'd192;
		block52_X_Pos = 16'd96;
		block52_Y_Pos = 16'd224;
		block53_X_Pos = 16'd96;
		block53_Y_Pos = 16'd256;
		block54_X_Pos = 16'd96;
		block54_Y_Pos = 16'd288;
		block55_X_Pos = 16'd96;
		block55_Y_Pos = 16'd320;
		block56_X_Pos = 16'd96;
		block56_Y_Pos = 16'd352;
		block57_X_Pos = 16'd96;
		block57_Y_Pos = 16'd384;
		block58_X_Pos = 16'd96;
		block58_Y_Pos = 16'd416;
		block59_X_Pos = 16'd96;
		block59_Y_Pos = 16'd448;
		block60_X_Pos = 16'd128;
		block60_Y_Pos = 16'd0;
		block61_X_Pos = 16'd128;
		block61_Y_Pos = 16'd32;
		block62_X_Pos = 16'd128;
		block62_Y_Pos = 16'd64;
		block63_X_Pos = 16'd128;
		block63_Y_Pos = 16'd96;
		block64_X_Pos = 16'd128;
		block64_Y_Pos = 16'd128;
		block65_X_Pos = 16'd128;
		block65_Y_Pos = 16'd160;
		block66_X_Pos = 16'd128;
		block66_Y_Pos = 16'd192;
		block67_X_Pos = 16'd128;
		block67_Y_Pos = 16'd224;
		block68_X_Pos = 16'd128;
		block68_Y_Pos = 16'd256;
		block69_X_Pos = 16'd128;
		block69_Y_Pos = 16'd288;
		block70_X_Pos = 16'd128;
		block70_Y_Pos = 16'd320;
		block71_X_Pos = 16'd128;
		block71_Y_Pos = 16'd352;
		block72_X_Pos = 16'd128;
		block72_Y_Pos = 16'd384;
		block73_X_Pos = 16'd128;
		block73_Y_Pos = 16'd416;
		block74_X_Pos = 16'd128;
		block74_Y_Pos = 16'd448;
		block75_X_Pos = 16'd160;
		block75_Y_Pos = 16'd0;
		block76_X_Pos = 16'd160;
		block76_Y_Pos = 16'd32;
		block77_X_Pos = 16'd160;
		block77_Y_Pos = 16'd64;
		block78_X_Pos = 16'd160;
		block78_Y_Pos = 16'd96;
		block79_X_Pos = 16'd160;
		block79_Y_Pos = 16'd128;
		block80_X_Pos = 16'd160;
		block80_Y_Pos = 16'd160;
		block81_X_Pos = 16'd160;
		block81_Y_Pos = 16'd192;
		block82_X_Pos = 16'd160;
		block82_Y_Pos = 16'd224;
		block83_X_Pos = 16'd160;
		block83_Y_Pos = 16'd256;
		block84_X_Pos = 16'd160;
		block84_Y_Pos = 16'd288;
		block85_X_Pos = 16'd160;
		block85_Y_Pos = 16'd320;
		block86_X_Pos = 16'd160;
		block86_Y_Pos = 16'd352;
		block87_X_Pos = 16'd160;
		block87_Y_Pos = 16'd384;
		block88_X_Pos = 16'd160;
		block88_Y_Pos = 16'd416;
		block89_X_Pos = 16'd160;
		block89_Y_Pos = 16'd448;
		block90_X_Pos = 16'd192;
		block90_Y_Pos = 16'd0;
		block91_X_Pos = 16'd192;
		block91_Y_Pos = 16'd32;
		block92_X_Pos = 16'd192;
		block92_Y_Pos = 16'd64;
		block93_X_Pos = 16'd192;
		block93_Y_Pos = 16'd96;
		block94_X_Pos = 16'd192;
		block94_Y_Pos = 16'd128;
		block95_X_Pos = 16'd192;
		block95_Y_Pos = 16'd160;
		block96_X_Pos = 16'd192;
		block96_Y_Pos = 16'd192;
		block97_X_Pos = 16'd192;
		block97_Y_Pos = 16'd224;
		block98_X_Pos = 16'd192;
		block98_Y_Pos = 16'd256;
		block99_X_Pos = 16'd192;
		block99_Y_Pos = 16'd288;
		block100_X_Pos = 16'd192;
		block100_Y_Pos = 16'd320;
		block101_X_Pos = 16'd192;
		block101_Y_Pos = 16'd352;
		block102_X_Pos = 16'd192;
		block102_Y_Pos = 16'd384;
		block103_X_Pos = 16'd192;
		block103_Y_Pos = 16'd416;
		block104_X_Pos = 16'd192;
		block104_Y_Pos = 16'd448;
		block105_X_Pos = 16'd224;
		block105_Y_Pos = 16'd0;
		block106_X_Pos = 16'd224;
		block106_Y_Pos = 16'd32;
		block107_X_Pos = 16'd224;
		block107_Y_Pos = 16'd64;
		block108_X_Pos = 16'd224;
		block108_Y_Pos = 16'd96;
		block109_X_Pos = 16'd224;
		block109_Y_Pos = 16'd128;
		block110_X_Pos = 16'd224;
		block110_Y_Pos = 16'd160;
		block111_X_Pos = 16'd224;
		block111_Y_Pos = 16'd192;
		block112_X_Pos = 16'd224;
		block112_Y_Pos = 16'd224;
		block113_X_Pos = 16'd224;
		block113_Y_Pos = 16'd256;
		block114_X_Pos = 16'd224;
		block114_Y_Pos = 16'd288;
		block115_X_Pos = 16'd224;
		block115_Y_Pos = 16'd320;
		block116_X_Pos = 16'd224;
		block116_Y_Pos = 16'd352;
		block117_X_Pos = 16'd224;
		block117_Y_Pos = 16'd384;
		block118_X_Pos = 16'd224;
		block118_Y_Pos = 16'd416;
		block119_X_Pos = 16'd224;
		block119_Y_Pos = 16'd448;
		block120_X_Pos = 16'd256;
		block120_Y_Pos = 16'd0;
		block121_X_Pos = 16'd256;
		block121_Y_Pos = 16'd32;
		block122_X_Pos = 16'd256;
		block122_Y_Pos = 16'd64;
		block123_X_Pos = 16'd256;
		block123_Y_Pos = 16'd96;
		block124_X_Pos = 16'd256;
		block124_Y_Pos = 16'd128;
		block125_X_Pos = 16'd256;
		block125_Y_Pos = 16'd160;
		block126_X_Pos = 16'd256;
		block126_Y_Pos = 16'd192;
		block127_X_Pos = 16'd256;
		block127_Y_Pos = 16'd224;
		block128_X_Pos = 16'd256;
		block128_Y_Pos = 16'd256;
		block129_X_Pos = 16'd256;
		block129_Y_Pos = 16'd288;
		block130_X_Pos = 16'd256;
		block130_Y_Pos = 16'd320;
		block131_X_Pos = 16'd256;
		block131_Y_Pos = 16'd352;
		block132_X_Pos = 16'd256;
		block132_Y_Pos = 16'd384;
		block133_X_Pos = 16'd256;
		block133_Y_Pos = 16'd416;
		block134_X_Pos = 16'd256;
		block134_Y_Pos = 16'd448;
		block135_X_Pos = 16'd288;
		block135_Y_Pos = 16'd0;
		block136_X_Pos = 16'd288;
		block136_Y_Pos = 16'd32;
		block137_X_Pos = 16'd288;
		block137_Y_Pos = 16'd64;
		block138_X_Pos = 16'd288;
		block138_Y_Pos = 16'd96;
		block139_X_Pos = 16'd288;
		block139_Y_Pos = 16'd128;
		block140_X_Pos = 16'd288;
		block140_Y_Pos = 16'd160;
		block141_X_Pos = 16'd288;
		block141_Y_Pos = 16'd192;
		block142_X_Pos = 16'd288;
		block142_Y_Pos = 16'd224;
		block143_X_Pos = 16'd288;
		block143_Y_Pos = 16'd256;
		block144_X_Pos = 16'd288;
		block144_Y_Pos = 16'd288;
		block145_X_Pos = 16'd288;
		block145_Y_Pos = 16'd320;
		block146_X_Pos = 16'd288;
		block146_Y_Pos = 16'd352;
		block147_X_Pos = 16'd288;
		block147_Y_Pos = 16'd384;
		block148_X_Pos = 16'd288;
		block148_Y_Pos = 16'd416;
		block149_X_Pos = 16'd288;
		block149_Y_Pos = 16'd448;
		block150_X_Pos = 16'd320;
		block150_Y_Pos = 16'd0;
		block151_X_Pos = 16'd320;
		block151_Y_Pos = 16'd32;
		block152_X_Pos = 16'd320;
		block152_Y_Pos = 16'd64;
		block153_X_Pos = 16'd320;
		block153_Y_Pos = 16'd96;
		block154_X_Pos = 16'd320;
		block154_Y_Pos = 16'd128;
		block155_X_Pos = 16'd320;
		block155_Y_Pos = 16'd160;
		block156_X_Pos = 16'd320;
		block156_Y_Pos = 16'd192;
		block157_X_Pos = 16'd320;
		block157_Y_Pos = 16'd224;
		block158_X_Pos = 16'd320;
		block158_Y_Pos = 16'd256;
		block159_X_Pos = 16'd320;
		block159_Y_Pos = 16'd288;
		block160_X_Pos = 16'd320;
		block160_Y_Pos = 16'd320;
		block161_X_Pos = 16'd320;
		block161_Y_Pos = 16'd352;
		block162_X_Pos = 16'd320;
		block162_Y_Pos = 16'd384;
		block163_X_Pos = 16'd320;
		block163_Y_Pos = 16'd416;
		block164_X_Pos = 16'd320;
		block164_Y_Pos = 16'd448;
		block165_X_Pos = 16'd352;
		block165_Y_Pos = 16'd0;
		block166_X_Pos = 16'd352;
		block166_Y_Pos = 16'd32;
		block167_X_Pos = 16'd352;
		block167_Y_Pos = 16'd64;
		block168_X_Pos = 16'd352;
		block168_Y_Pos = 16'd96;
		block169_X_Pos = 16'd352;
		block169_Y_Pos = 16'd128;
		block170_X_Pos = 16'd352;
		block170_Y_Pos = 16'd160;
		block171_X_Pos = 16'd352;
		block171_Y_Pos = 16'd192;
		block172_X_Pos = 16'd352;
		block172_Y_Pos = 16'd224;
		block173_X_Pos = 16'd352;
		block173_Y_Pos = 16'd256;
		block174_X_Pos = 16'd352;
		block174_Y_Pos = 16'd288;
		block175_X_Pos = 16'd352;
		block175_Y_Pos = 16'd320;
		block176_X_Pos = 16'd352;
		block176_Y_Pos = 16'd352;
		block177_X_Pos = 16'd352;
		block177_Y_Pos = 16'd384;
		block178_X_Pos = 16'd352;
		block178_Y_Pos = 16'd416;
		block179_X_Pos = 16'd352;
		block179_Y_Pos = 16'd448;
		block180_X_Pos = 16'd384;
		block180_Y_Pos = 16'd0;
		block181_X_Pos = 16'd384;
		block181_Y_Pos = 16'd32;
		block182_X_Pos = 16'd384;
		block182_Y_Pos = 16'd64;
		block183_X_Pos = 16'd384;
		block183_Y_Pos = 16'd96;
		block184_X_Pos = 16'd384;
		block184_Y_Pos = 16'd128;
		block185_X_Pos = 16'd384;
		block185_Y_Pos = 16'd160;
		block186_X_Pos = 16'd384;
		block186_Y_Pos = 16'd192;
		block187_X_Pos = 16'd384;
		block187_Y_Pos = 16'd224;
		block188_X_Pos = 16'd384;
		block188_Y_Pos = 16'd256;
		block189_X_Pos = 16'd384;
		block189_Y_Pos = 16'd288;
		block190_X_Pos = 16'd384;
		block190_Y_Pos = 16'd320;
		block191_X_Pos = 16'd384;
		block191_Y_Pos = 16'd352;
		block192_X_Pos = 16'd384;
		block192_Y_Pos = 16'd384;
		block193_X_Pos = 16'd384;
		block193_Y_Pos = 16'd416;
		block194_X_Pos = 16'd384;
		block194_Y_Pos = 16'd448;
		block195_X_Pos = 16'd416;
		block195_Y_Pos = 16'd0;
		block196_X_Pos = 16'd416;
		block196_Y_Pos = 16'd32;
		block197_X_Pos = 16'd416;
		block197_Y_Pos = 16'd64;
		block198_X_Pos = 16'd416;
		block198_Y_Pos = 16'd96;
		block199_X_Pos = 16'd416;
		block199_Y_Pos = 16'd128;
		block200_X_Pos = 16'd416;
		block200_Y_Pos = 16'd160;
		
		block201_X_Pos = 16'd256; //sky1
		block201_Y_Pos = 16'd0;  
		block202_X_Pos = 16'd416;  //ground1
		block202_Y_Pos = 16'd352;
		
		block203_X_Pos = 16'd768;  //sky2
		block203_Y_Pos = 16'd0;		
		block204_X_Pos = 16'd928;	//ground2
		block204_Y_Pos = 16'd352;
		
		block205_X_Pos = 16'd0;	//bb left
		block205_Y_Pos = 16'd0;
		
		block206_X_Pos = 16'd512;	//bb right
		block206_Y_Pos = 16'd0;
		
		block207_X_Pos = 16'd512;	
		block207_Y_Pos = 16'd256;
	 end
    //////// Do not modify the always_ff blocks. ////////
	 
	 //  1A == UP
	 //  16 == DOWN
	 //  04 == LEFT
	 //  07 == RIGHT
	 //  28 == ATTACK
    // Detect rising edge of frame_clk

    always_comb begin
		  is_atk_temp = 1'b0;
		//  atk_enable = 1'b0;
		  is_attack_temp = 1'b0;
		  is_waddle0_temp = 1'b0;
		  is_kirby_temp = 1'b0;
		  is_block_temp = 1'b0;
		  is_testblock = 1'b0;
		  is_kirbysub = 1'b0;
		  block0 = 1'b0;
block1 = 1'b0;
block2 = 1'b0;
block3 = 1'b0;
block4 = 1'b0;
block5 = 1'b0;
block6 = 1'b0;
block7 = 1'b0;
block8 = 1'b0;
block9 = 1'b0;
block10 = 1'b0;
block11 = 1'b0;
block12 = 1'b0;
block13 = 1'b0;
block14 = 1'b0;
block15 = 1'b0;
block16 = 1'b0;
block17 = 1'b0;
block18 = 1'b0;
block19 = 1'b0;
block20 = 1'b0;
block21 = 1'b0;
block22 = 1'b0;
block23 = 1'b0;
block24 = 1'b0;
block25 = 1'b0;
block26 = 1'b0;
block27 = 1'b0;
block28 = 1'b0;
block29 = 1'b0;
block30 = 1'b0;
block31 = 1'b0;
block32 = 1'b0;
block33 = 1'b0;
block34 = 1'b0;
block35 = 1'b0;
block36 = 1'b0;
block37 = 1'b0;
block38 = 1'b0;
block39 = 1'b0;
block40 = 1'b0;
block41 = 1'b0;
block42 = 1'b0;
block43 = 1'b0;
block44 = 1'b0;
block45 = 1'b0;
block46 = 1'b0;
block47 = 1'b0;
block48 = 1'b0;
block49 = 1'b0;
block50 = 1'b0;
block51 = 1'b0;
block52 = 1'b0;
block53 = 1'b0;
block54 = 1'b0;
block55 = 1'b0;
block56 = 1'b0;
block57 = 1'b0;
block58 = 1'b0;
block59 = 1'b0;
block60 = 1'b0;
block61 = 1'b0;
block62 = 1'b0;
block63 = 1'b0;
block64 = 1'b0;
block65 = 1'b0;
block66 = 1'b0;
block67 = 1'b0;
block68 = 1'b0;
block69 = 1'b0;
block70 = 1'b0;
block71 = 1'b0;
block72 = 1'b0;
block73 = 1'b0;
block74 = 1'b0;
block75 = 1'b0;
block76 = 1'b0;
block77 = 1'b0;
block78 = 1'b0;
block79 = 1'b0;
block80 = 1'b0;
block81 = 1'b0;
block82 = 1'b0;
block83 = 1'b0;
block84 = 1'b0;
block85 = 1'b0;
block86 = 1'b0;
block87 = 1'b0;
block88 = 1'b0;
block89 = 1'b0;
block90 = 1'b0;
block91 = 1'b0;
block92 = 1'b0;
block93 = 1'b0;
block94 = 1'b0;
block95 = 1'b0;
block96 = 1'b0;
block97 = 1'b0;
block98 = 1'b0;
block99 = 1'b0;
block100 = 1'b0;
block101 = 1'b0;
block102 = 1'b0;
block103 = 1'b0;
block104 = 1'b0;
block105 = 1'b0;
block106 = 1'b0;
block107 = 1'b0;
block108 = 1'b0;
block109 = 1'b0;
block110 = 1'b0;
block111 = 1'b0;
block112 = 1'b0;
block113 = 1'b0;
block114 = 1'b0;
block115 = 1'b0;
block116 = 1'b0;
block117 = 1'b0;
block118 = 1'b0;
block119 = 1'b0;
block120 = 1'b0;
block121 = 1'b0;
block122 = 1'b0;
block123 = 1'b0;
block124 = 1'b0;
block125 = 1'b0;
block126 = 1'b0;
block127 = 1'b0;
block128 = 1'b0;
block129 = 1'b0;
block130 = 1'b0;
block131 = 1'b0;
block132 = 1'b0;
block133 = 1'b0;
block134 = 1'b0;
block135 = 1'b0;
block136 = 1'b0;
block137 = 1'b0;
block138 = 1'b0;
block139 = 1'b0;
block140 = 1'b0;
block141 = 1'b0;
block142 = 1'b0;
block143 = 1'b0;
block144 = 1'b0;
block145 = 1'b0;
block146 = 1'b0;
block147 = 1'b0;
block148 = 1'b0;
block149 = 1'b0;
block150 = 1'b0;
block151 = 1'b0;
block152 = 1'b0;
block153 = 1'b0;
block154 = 1'b0;
block155 = 1'b0;
block156 = 1'b0;
block157 = 1'b0;
block158 = 1'b0;
block159 = 1'b0;
block160 = 1'b0;
block161 = 1'b0;
block162 = 1'b0;
block163 = 1'b0;
block164 = 1'b0;
block165 = 1'b0;
block166 = 1'b0;
block167 = 1'b0;
block168 = 1'b0;
block169 = 1'b0;
block170 = 1'b0;
block171 = 1'b0;
block172 = 1'b0;
block173 = 1'b0;
block174 = 1'b0;
block175 = 1'b0;
block176 = 1'b0;
block177 = 1'b0;
block178 = 1'b0;
block179 = 1'b0;
block180 = 1'b0;
block181 = 1'b0;
block182 = 1'b0;
block183 = 1'b0;
block184 = 1'b0;
block185 = 1'b0;
block186 = 1'b0;
block187 = 1'b0;
block188 = 1'b0;
block189 = 1'b0;
block190 = 1'b0;
block191 = 1'b0;
block192 = 1'b0;
block193 = 1'b0;
block194 = 1'b0;
block195 = 1'b0;
block196 = 1'b0;
block197 = 1'b0;
block198 = 1'b0;
block199 = 1'b0;
block200 = 1'b0;

block201 = 1'd0;
block202 = 1'd0;
block203 = 1'd0;
block204 = 1'd0;

block205 = 1'd0; //boss_background left
block206 = 1'd0;  //boss_background right
block207 = 1'd0;

f0 = 1'd0;
f1 = 1'd0;
f2 = 1'd0;
		  is_flame = 1'd0;
		  boss = 1'd0;
		  BOSSTIME = 1'd0;
		  NO_DOWN = 1'b0;
		  NO_UP = 1'b0;
		  NO_RIGHT = 1'b0;
		  NO_LEFT = 1'b0;
		  SPIKE = 1'b0;
		//kirby character detection
        if ((DrawX >= Kirby_X_Pos) && (DrawX < Kirby_X_Pos + 32) && (DrawY >= Kirby_Y_Pos) && (DrawY < Kirby_Y_Pos + 32)) begin  //always apparent
            is_kirby_temp = 1'b1;
				is_kirbysub = 1'b1;
		  end

		   if ((DrawX >= atk_X_Pos) && (DrawX < atk_X_Pos + 32) && (DrawY >= atk_Y_Pos) && (DrawY < atk_Y_Pos + 32) && (atk_enable)) begin //always apparent
            is_atk_temp = 1'b1;
		  end  

		
if(is_block) begin		
		  if ((DrawX >= waddle0_X_Pos) && (DrawX < waddle0_X_Pos + 32) && (DrawY >= waddle0_Y_Pos) && (DrawY < waddle0_Y_Pos + 32)) begin
            is_waddle0_temp = 1'b1;
		  end  
		  if(is_kirby_temp && is_waddle0_temp) begin
				SPIKE = 1'b1;
		  end
		///////////////////////////////////////////////////////////////////////////////////////
		//block0 (x,y) = (0,0)
		  if((DrawX >= block0_X_Pos) && (DrawX < block0_X_Pos + 32) && (DrawY >= block0_Y_Pos) && (DrawY < block0_Y_Pos + 32)) begin
				block0 = 1'b1;
        end 
	
		///////////////////////////////////////////////////////////////////////////////////////
		//block1 (x,y) = (0,1)
		  if((DrawX >= block1_X_Pos) && (DrawX < block1_X_Pos + 32) && (DrawY >= block1_Y_Pos) && (DrawY < block1_Y_Pos + 32)) begin
				block1 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block2 (x,y) = (0,2)
		  if((DrawX >= block2_X_Pos) && (DrawX < block2_X_Pos + 32) && (DrawY >= block2_Y_Pos) && (DrawY < block2_Y_Pos + 32)) begin
				block2 = 1'b1;
			end 
			
		  if((Kirby_X_Pos >= block2_X_Pos) && (Kirby_X_Pos < block2_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block2_Y_Pos) && (Kirby_Y_Pos + 16 < block2_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block3 (x,y) = (0,3)
		  if((DrawX >= block3_X_Pos) && (DrawX < block3_X_Pos + 32) && (DrawY >= block3_Y_Pos) && (DrawY < block3_Y_Pos + 32)) begin
				block3 = 1'b1;
        end 
		  if((Kirby_X_Pos >= block3_X_Pos) && (Kirby_X_Pos < block3_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block3_Y_Pos) && (Kirby_Y_Pos + 16 < block3_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block4 (x,y) = (0,4)
		  if((DrawX >= block4_X_Pos) && (DrawX < block4_X_Pos + 32) && (DrawY >= block4_Y_Pos) && (DrawY < block4_Y_Pos + 32)) begin
				block4 = 1'b1;
        end 
		
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block5 (x,y) = (0,5)
		  if((DrawX >= block5_X_Pos) && (DrawX < block5_X_Pos + 32) && (DrawY >= block5_Y_Pos) && (DrawY < block5_Y_Pos + 32)) begin
				block5 = 1'b1;
        end 
		 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block6 (x,y) = (0,6)
		  if((DrawX >= block6_X_Pos) && (DrawX < block6_X_Pos + 32) && (DrawY >= block6_Y_Pos) && (DrawY < block6_Y_Pos + 32)) begin
				block6 = 1'b1;
        end 
		
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block7 (x,y) = (0,7)
		  if((DrawX >= block7_X_Pos) && (DrawX < block7_X_Pos + 32) && (DrawY >= block7_Y_Pos) && (DrawY < block7_Y_Pos + 32)) begin
				block7 = 1'b1;
        end 

		  		///////////////////////////////////////////////////////////////////////////////////////
		//block8 (x,y) = (0,8)
		  if((DrawX >= block8_X_Pos) && (DrawX < block8_X_Pos + 32) && (DrawY >= block8_Y_Pos) && (DrawY < block8_Y_Pos + 32)) begin
				block8 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block9 (x,y) = (0,9)
		  if((DrawX >= block9_X_Pos) && (DrawX < block9_X_Pos + 32) && (DrawY >= block9_Y_Pos) && (DrawY < block9_Y_Pos + 32)) begin
				block9 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block9_X_Pos) && (Kirby_X_Pos + 16 < block9_X_Pos + 32) && (Kirby_Y_Pos >= block9_Y_Pos) && (Kirby_Y_Pos < block9_Y_Pos + 32)) begin
            NO_UP = 1'b1;
				SPIKE = 1'b1;
        end 

		  		///////////////////////////////////////////////////////////////////////////////////////
		//block10 (x,y) = (0,10)
		  if((DrawX >= block10_X_Pos) && (DrawX < block10_X_Pos + 32) && (DrawY >= block10_Y_Pos) && (DrawY < block10_Y_Pos + 32)) begin
				block10 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block11 (x,y) = (0,11)
		  if((DrawX >= block11_X_Pos) && (DrawX < block11_X_Pos + 32) && (DrawY >= block11_Y_Pos) && (DrawY < block11_Y_Pos + 32)) begin
				block11 = 1'b1;
			end
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block12 (x,y) = (0,12)
		  if((DrawX >= block12_X_Pos) && (DrawX < block12_X_Pos + 32) && (DrawY >= block12_Y_Pos) && (DrawY < block12_Y_Pos + 32)) begin
				block12 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block13 (x,y) = (0,13)
		  if((DrawX >= block13_X_Pos) && (DrawX < block13_X_Pos + 32) && (DrawY >= block13_Y_Pos) && (DrawY < block13_Y_Pos + 32)) begin
				block13 = 1'b1;
        end 
				  		///////////////////////////////////////////////////////////////////////////////////////
		//block14 (x,y) = (0,14)
		  if((DrawX >= block14_X_Pos) && (DrawX < block14_X_Pos + 32) && (DrawY >= block14_Y_Pos) && (DrawY < block14_Y_Pos + 32)) begin
				block14 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block14_X_Pos) && (Kirby_X_Pos + 16 < block14_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block14_Y_Pos) && (Kirby_Y_Pos + 32 < block14_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block15 (x,y) = (1,0)
		  if((DrawX >= block15_X_Pos) && (DrawX < block15_X_Pos + 32) && (DrawY >= block15_Y_Pos) && (DrawY < block15_Y_Pos + 32)) begin
				block15 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block16 (x,y) = (1,1)
		  if((DrawX >= block16_X_Pos) && (DrawX < block16_X_Pos + 32) && (DrawY >= block16_Y_Pos) && (DrawY < block16_Y_Pos + 32)) begin
				block16 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block16_X_Pos) && (Kirby_X_Pos + 16 < block16_X_Pos + 32) && (Kirby_Y_Pos >= block16_Y_Pos) && (Kirby_Y_Pos < block16_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  if((Kirby_X_Pos >= block16_X_Pos) && (Kirby_X_Pos < block16_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block16_Y_Pos) && (Kirby_Y_Pos + 16 < block16_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block17 (x,y) = (0,2)
		  if((DrawX >= block17_X_Pos) && (DrawX < block17_X_Pos + 32) && (DrawY >= block17_Y_Pos) && (DrawY < block17_Y_Pos + 32)) begin
				block17 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block18 (x,y) = (0,3)
		  if((DrawX >= block18_X_Pos) && (DrawX < block18_X_Pos + 32) && (DrawY >= block18_Y_Pos) && (DrawY < block18_Y_Pos + 32)) begin
				block18 = 1'b1;
        end  
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block19 (x,y) = (0,0)
		  if((DrawX >= block19_X_Pos) && (DrawX < block19_X_Pos + 32) && (DrawY >= block19_Y_Pos) && (DrawY < block19_Y_Pos + 32)) begin
				block19 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block19_X_Pos) && (Kirby_X_Pos + 16 < block19_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block19_Y_Pos) && (Kirby_Y_Pos + 32 < block19_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  if((Kirby_X_Pos >= block19_X_Pos) && (Kirby_X_Pos < block19_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block19_Y_Pos) && (Kirby_Y_Pos + 16 < block19_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block20 (x,y) = (0,0)
		  if((DrawX >= block20_X_Pos) && (DrawX < block20_X_Pos + 32) && (DrawY >= block20_Y_Pos) && (DrawY < block20_Y_Pos + 32)) begin
				block20 = 1'b1;
        end 
		  if((Kirby_X_Pos >= block20_X_Pos) && (Kirby_X_Pos < block20_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block20_Y_Pos) && (Kirby_Y_Pos + 16 < block20_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block21 (x,y) = (0,0)
		  if((DrawX >= block21_X_Pos) && (DrawX < block21_X_Pos + 32) && (DrawY >= block21_Y_Pos) && (DrawY < block21_Y_Pos + 32)) begin
				block21 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block22 (x,y) = (0,0)
		  if((DrawX >= block22_X_Pos) && (DrawX < block22_X_Pos + 32) && (DrawY >= block22_Y_Pos) && (DrawY < block22_Y_Pos + 32)) begin
				block22 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block23 (x,y) = (0,0)
		  if((DrawX >= block23_X_Pos) && (DrawX < block23_X_Pos + 32) && (DrawY >= block23_Y_Pos) && (DrawY < block23_Y_Pos + 32)) begin
				block23 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block24 (x,y) = (0,0)
		  if((DrawX >= block24_X_Pos) && (DrawX < block24_X_Pos + 32) && (DrawY >= block24_Y_Pos) && (DrawY < block24_Y_Pos + 32)) begin
				block24 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block24_X_Pos) && (Kirby_X_Pos + 16 < block24_X_Pos + 32) && (Kirby_Y_Pos >= block24_Y_Pos) && (Kirby_Y_Pos < block24_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  if((Kirby_X_Pos + 32 >= block24_X_Pos) && (Kirby_X_Pos + 32 < block24_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block24_Y_Pos) && (Kirby_Y_Pos + 16 < block24_Y_Pos + 32)) begin
            NO_RIGHT = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block25 (x,y) = (0,0)
		  if((DrawX >= block25_X_Pos) && (DrawX < block25_X_Pos + 32) && (DrawY >= block25_Y_Pos) && (DrawY < block25_Y_Pos + 32)) begin
				block25 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block26 (x,y) = (0,0)
		  if((DrawX >= block26_X_Pos) && (DrawX < block26_X_Pos + 32) && (DrawY >= block26_Y_Pos) && (DrawY < block26_Y_Pos + 32)) begin
				block26 = 1'b1;
        end 

		  		///////////////////////////////////////////////////////////////////////////////////////
		//block27 (x,y) = (0,0)
		  if((DrawX >= block27_X_Pos) && (DrawX < block27_X_Pos + 32) && (DrawY >= block27_Y_Pos) && (DrawY < block27_Y_Pos + 32)) begin
				block27 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block8 (x,y) = (0,0)
		  if((DrawX >= block28_X_Pos) && (DrawX < block28_X_Pos + 32) && (DrawY >= block28_Y_Pos) && (DrawY < block28_Y_Pos + 32)) begin
				block28 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block29 (x,y) = (0,0)
		  if((DrawX >= block29_X_Pos) && (DrawX < block29_X_Pos + 32) && (DrawY >= block29_Y_Pos) && (DrawY < block29_Y_Pos + 32)) begin
				block29 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block29_X_Pos) && (Kirby_X_Pos + 16 < block29_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block29_Y_Pos) && (Kirby_Y_Pos + 32 < block29_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block30 (x,y) = (0,0)
		  if((DrawX >= block30_X_Pos) && (DrawX < block30_X_Pos + 32) && (DrawY >= block30_Y_Pos) && (DrawY < block30_Y_Pos + 32)) begin
				block30 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block30_X_Pos) && (Kirby_X_Pos + 16 < block30_X_Pos + 32) && (Kirby_Y_Pos >= block30_Y_Pos) && (Kirby_Y_Pos < block30_Y_Pos + 32)) begin
            NO_UP = 1'b1;
			end
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block31 (x,y) = (0,0)
		  if((DrawX >= block31_X_Pos) && (DrawX < block31_X_Pos + 32) && (DrawY >= block31_Y_Pos) && (DrawY < block31_Y_Pos + 32)) begin
				block31 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block32 (x,y) = (0,0)
		  if((DrawX >= block32_X_Pos) && (DrawX < block32_X_Pos + 32) && (DrawY >= block32_Y_Pos) && (DrawY < block32_Y_Pos + 32)) begin
				block32 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block33 (x,y) = (0,0)
		  if((DrawX >= block33_X_Pos) && (DrawX < block33_X_Pos + 32) && (DrawY >= block33_Y_Pos) && (DrawY < block33_Y_Pos + 32)) begin
				block33 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block34 (x,y) = (0,0)
		  if((DrawX >= block34_X_Pos) && (DrawX < block34_X_Pos + 32) && (DrawY >= block34_Y_Pos) && (DrawY < block34_Y_Pos + 32)) begin
				block34 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block35 (x,y) = (0,0)
		  if((DrawX >= block35_X_Pos) && (DrawX < block35_X_Pos + 32) && (DrawY >= block35_Y_Pos) && (DrawY < block35_Y_Pos + 32)) begin
				block35 = 1'b1;
        end  
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block36 (x,y) = (0,0)
		  if((DrawX >= block36_X_Pos) && (DrawX < block36_X_Pos + 32) && (DrawY >= block36_Y_Pos) && (DrawY < block36_Y_Pos + 32)) begin
				block36 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block36_X_Pos) && (Kirby_X_Pos + 16 < block36_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block36_Y_Pos) && (Kirby_Y_Pos + 32 < block36_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block37 (x,y) = (0,0)
		  if((DrawX >= block37_X_Pos) && (DrawX < block37_X_Pos + 32) && (DrawY >= block37_Y_Pos) && (DrawY < block37_Y_Pos + 32)) begin
				block37 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block38 (x,y) = (0,0)
		  if((DrawX >= block38_X_Pos) && (DrawX < block38_X_Pos + 32) && (DrawY >= block38_Y_Pos) && (DrawY < block38_Y_Pos + 32)) begin
				block38 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block39 (x,y) = (0,0)
		  if((DrawX >= block39_X_Pos) && (DrawX < block39_X_Pos + 32) && (DrawY >= block39_Y_Pos) && (DrawY < block39_Y_Pos + 32)) begin
				block39 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block39_X_Pos) && (Kirby_X_Pos + 16 < block39_X_Pos + 32) && (Kirby_Y_Pos >= block39_Y_Pos) && (Kirby_Y_Pos < block39_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block40 (x,y) = (0,0)
		  if((DrawX >= block40_X_Pos) && (DrawX < block40_X_Pos + 32) && (DrawY >= block40_Y_Pos) && (DrawY < block40_Y_Pos + 32)) begin
				block40 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block41 (x,y) = (0,0)
		  if((DrawX >= block41_X_Pos) && (DrawX < block41_X_Pos + 32) && (DrawY >= block41_Y_Pos) && (DrawY < block41_Y_Pos + 32)) begin
				block41 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block42 (x,y) = (0,0)
		  if((DrawX >= block42_X_Pos) && (DrawX < block42_X_Pos + 32) && (DrawY >= block42_Y_Pos) && (DrawY < block42_Y_Pos + 32)) begin
				block42 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block43 (x,y) = (0,0)
		  if((DrawX >= block43_X_Pos) && (DrawX < block43_X_Pos + 32) && (DrawY >= block43_Y_Pos) && (DrawY < block43_Y_Pos + 32)) begin
				block43 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block44 (x,y) = (0,0)
		  if((DrawX >= block44_X_Pos) && (DrawX < block44_X_Pos + 32) && (DrawY >= block44_Y_Pos) && (DrawY < block44_Y_Pos + 32)) begin
				block44 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block44_X_Pos) && (Kirby_X_Pos + 16 < block44_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block44_Y_Pos) && (Kirby_Y_Pos + 32 < block44_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block45 (x,y) = (0,0)
		  if((DrawX >= block45_X_Pos) && (DrawX < block45_X_Pos + 32) && (DrawY >= block45_Y_Pos) && (DrawY < block45_Y_Pos + 32)) begin
				block45 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block45_X_Pos) && (Kirby_X_Pos + 16 < block45_X_Pos + 32) && (Kirby_Y_Pos >= block45_Y_Pos) && (Kirby_Y_Pos < block45_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block46 (x,y) = (0,0)
		  if((DrawX >= block46_X_Pos) && (DrawX < block46_X_Pos + 32) && (DrawY >= block46_Y_Pos) && (DrawY < block46_Y_Pos + 32)) begin
				block46 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block47 (x,y) = (0,0)
		  if((DrawX >= block47_X_Pos) && (DrawX < block47_X_Pos + 32) && (DrawY >= block47_Y_Pos) && (DrawY < block47_Y_Pos + 32)) begin
				block47 = 1'b1;
        end 

		  		///////////////////////////////////////////////////////////////////////////////////////
		//block48 (x,y) = (0,0)
		  if((DrawX >= block48_X_Pos) && (DrawX < block48_X_Pos + 32) && (DrawY >= block48_Y_Pos) && (DrawY < block48_Y_Pos + 32)) begin
				block48 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block49 (x,y) = (0,0)
		  if((DrawX >= block49_X_Pos) && (DrawX < block49_X_Pos + 32) && (DrawY >= block49_Y_Pos) && (DrawY < block49_Y_Pos + 32)) begin
				block49 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block50 (x,y) = (0,0)
		  if((DrawX >= block50_X_Pos) && (DrawX < block50_X_Pos + 32) && (DrawY >= block50_Y_Pos) && (DrawY < block50_Y_Pos + 32)) begin
				block50 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block51 (x,y) = (0,0)
		  if((DrawX >= block51_X_Pos) && (DrawX < block51_X_Pos + 32) && (DrawY >= block51_Y_Pos) && (DrawY < block51_Y_Pos + 32)) begin
				block51 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block51_X_Pos) && (Kirby_X_Pos + 16 < block51_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block51_Y_Pos) && (Kirby_Y_Pos + 32 < block51_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block52 (x,y) = (0,0)
		  if((DrawX >= block52_X_Pos) && (DrawX < block52_X_Pos + 32) && (DrawY >= block52_Y_Pos) && (DrawY < block52_Y_Pos + 32)) begin
				block52 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block53 (x,y) = (0,0)
		  if((DrawX >= block53_X_Pos) && (DrawX < block53_X_Pos + 32) && (DrawY >= block53_Y_Pos) && (DrawY < block53_Y_Pos + 32)) begin
				block53 = 1'b1;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block54 (x,y) = (0,0)
		  if((DrawX >= block54_X_Pos) && (DrawX < block54_X_Pos + 32) && (DrawY >= block54_Y_Pos) && (DrawY < block54_Y_Pos + 32)) begin
				block54 = 1'b1; 
		  end
		  if((Kirby_X_Pos >= block54_X_Pos) && (Kirby_X_Pos < block54_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block54_Y_Pos) && (Kirby_Y_Pos + 16 < block54_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
		  end
		  if((Kirby_X_Pos + 16 >= block54_X_Pos) && (Kirby_X_Pos + 16 < block54_X_Pos + 32) && (Kirby_Y_Pos >= block54_Y_Pos) && (Kirby_Y_Pos < block54_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end  
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block55 (x,y) = (0,0)
		  if((DrawX >= block55_X_Pos) && (DrawX < block55_X_Pos + 32) && (DrawY >= block55_Y_Pos) && (DrawY < block55_Y_Pos + 32)) begin
				block55 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block56 (x,y) = (0,0)
		  if((DrawX >= block56_X_Pos) && (DrawX < block56_X_Pos + 32) && (DrawY >= block56_Y_Pos) && (DrawY < block56_Y_Pos + 32)) begin
				block56 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block57 (x,y) = (0,0)
		  if((DrawX >= block57_X_Pos) && (DrawX < block57_X_Pos + 32) && (DrawY >= block57_Y_Pos) && (DrawY < block57_Y_Pos + 32)) begin
				block57 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block58 (x,y) = (0,0)
		  if((DrawX >= block58_X_Pos) && (DrawX < block58_X_Pos + 32) && (DrawY >= block58_Y_Pos) && (DrawY < block58_Y_Pos + 32)) begin
				block58 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block59 (x,y) = (0,0)
		  if((DrawX >= block59_X_Pos) && (DrawX < block59_X_Pos + 32) && (DrawY >= block59_Y_Pos) && (DrawY < block59_Y_Pos + 32)) begin
				block59 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block59_X_Pos) && (Kirby_X_Pos + 16 < block59_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block59_Y_Pos) && (Kirby_Y_Pos + 32 < block59_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block60 (x,y) = (0,0)
		  if((DrawX >= block60_X_Pos) && (DrawX < block60_X_Pos + 32) && (DrawY >= block60_Y_Pos) && (DrawY < block60_Y_Pos + 32)) begin
				block60 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block60_X_Pos) && (Kirby_X_Pos + 16 < block60_X_Pos + 32) && (Kirby_Y_Pos >= block60_Y_Pos) && (Kirby_Y_Pos < block60_Y_Pos + 32)) begin
            NO_UP = 1'b1;
				SPIKE = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block61 (x,y) = (0,0)
		  if((DrawX >= block61_X_Pos) && (DrawX < block61_X_Pos + 32) && (DrawY >= block61_Y_Pos) && (DrawY < block61_Y_Pos + 32)) begin
				block61 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block62 (x,y) = (0,0)
		  if((DrawX >= block62_X_Pos) && (DrawX < block62_X_Pos + 32) && (DrawY >= block62_Y_Pos) && (DrawY < block62_Y_Pos + 32)) begin
				block62 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block62_X_Pos) && (Kirby_X_Pos + 16 < block62_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block62_Y_Pos) && (Kirby_Y_Pos + 32 < block62_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end  
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block63 (x,y) = (0,0)
		  if((DrawX >= block63_X_Pos) && (DrawX < block63_X_Pos + 32) && (DrawY >= block63_Y_Pos) && (DrawY < block63_Y_Pos + 32)) begin
				block63 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block64 (x,y) = (0,0)
		  if((DrawX >= block64_X_Pos) && (DrawX < block64_X_Pos + 32) && (DrawY >= block64_Y_Pos) && (DrawY < block64_Y_Pos + 32)) begin
				block64 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block65 (x,y) = (0,0)
		  if((DrawX >= block65_X_Pos) && (DrawX < block65_X_Pos + 32) && (DrawY >= block65_Y_Pos) && (DrawY < block65_Y_Pos + 32)) begin
				block65 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block66 (x,y) = (0,0)
		  if((DrawX >= block66_X_Pos) && (DrawX < block66_X_Pos + 32) && (DrawY >= block66_Y_Pos) && (DrawY < block66_Y_Pos + 32)) begin
				block66 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block66_X_Pos) && (Kirby_X_Pos + 16 < block66_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block66_Y_Pos) && (Kirby_Y_Pos + 32 < block66_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		 
		  if((Kirby_X_Pos >= block66_X_Pos) && (Kirby_X_Pos < block66_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block66_Y_Pos) && (Kirby_Y_Pos + 16 < block66_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block67 (x,y) = (0,0)
		  if((DrawX >= block67_X_Pos) && (DrawX < block67_X_Pos + 32) && (DrawY >= block67_Y_Pos) && (DrawY < block67_Y_Pos + 32)) begin
				block67 = 1'b1;
        end  
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block68 (x,y) = (0,0)
		  if((DrawX >= block68_X_Pos) && (DrawX < block68_X_Pos + 32) && (DrawY >= block68_Y_Pos) && (DrawY < block68_Y_Pos + 32)) begin
				block68 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block68_X_Pos) && (Kirby_X_Pos + 16 < block68_X_Pos + 32) && (Kirby_Y_Pos >= block68_Y_Pos) && (Kirby_Y_Pos < block68_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block69 (x,y) = (0,0)
		  if((DrawX >= block69_X_Pos) && (DrawX < block69_X_Pos + 32) && (DrawY >= block69_Y_Pos) && (DrawY < block69_Y_Pos + 32)) begin
				block69 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block70 (x,y) = (0,0)
		  if((DrawX >= block70_X_Pos) && (DrawX < block70_X_Pos + 32) && (DrawY >= block70_Y_Pos) && (DrawY < block70_Y_Pos + 32)) begin
				block70 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block71 (x,y) = (0,0)
		  if((DrawX >= block71_X_Pos) && (DrawX < block71_X_Pos + 32) && (DrawY >= block71_Y_Pos) && (DrawY < block71_Y_Pos + 32)) begin
				block71 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block72 (x,y) = (0,0)
		  if((DrawX >= block72_X_Pos) && (DrawX < block72_X_Pos + 32) && (DrawY >= block72_Y_Pos) && (DrawY < block72_Y_Pos + 32)) begin
				block72 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block73 (x,y) = (0,0)
		  if((DrawX >= block73_X_Pos) && (DrawX < block73_X_Pos + 32) && (DrawY >= block73_Y_Pos) && (DrawY < block73_Y_Pos + 32)) begin
				block73 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block74 (x,y) = (0,0)
		  if((DrawX >= block74_X_Pos) && (DrawX < block74_X_Pos + 32) && (DrawY >= block74_Y_Pos) && (DrawY < block74_Y_Pos + 32)) begin
				block74 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block74_X_Pos) && (Kirby_X_Pos + 16 < block74_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block74_Y_Pos) && (Kirby_Y_Pos + 32 < block74_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end  
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block75 (x,y) = (0,0)
		  if((DrawX >= block75_X_Pos) && (DrawX < block75_X_Pos + 32) && (DrawY >= block75_Y_Pos) && (DrawY < block75_Y_Pos + 32)) begin
				block75 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block75_X_Pos) && (Kirby_X_Pos + 16 < block75_X_Pos + 32) && (Kirby_Y_Pos >= block75_Y_Pos) && (Kirby_Y_Pos < block75_Y_Pos + 32)) begin
            NO_UP = 1'b1;
				SPIKE = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block76 (x,y) = (0,0)
		  if((DrawX >= block76_X_Pos) && (DrawX < block76_X_Pos + 32) && (DrawY >= block76_Y_Pos) && (DrawY < block76_Y_Pos + 32)) begin
				block76 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block76_X_Pos) && (Kirby_X_Pos < block76_X_Pos + 32) && (Kirby_Y_Pos >= block76_Y_Pos) && (Kirby_Y_Pos < block76_Y_Pos + 32)) begin
				BOSSTIME = 1'd1;
        end 
		  
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block77 (x,y) = (0,0)
		  if((DrawX >= block77_X_Pos) && (DrawX < block77_X_Pos + 32) && (DrawY >= block77_Y_Pos) && (DrawY < block77_Y_Pos + 32)) begin
				block77 = 1'b1;
        end 
		   if((Kirby_X_Pos + 16 >= block77_X_Pos) && (Kirby_X_Pos + 16 < block77_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block77_Y_Pos) && (Kirby_Y_Pos + 32 < block77_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block78 (x,y) = (0,0)
		  if((DrawX >= block78_X_Pos) && (DrawX < block78_X_Pos + 32) && (DrawY >= block78_Y_Pos) && (DrawY < block78_Y_Pos + 32)) begin
				block78 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block79 (x,y) = (0,0)
		  if((DrawX >= block79_X_Pos) && (DrawX < block79_X_Pos + 32) && (DrawY >= block79_Y_Pos) && (DrawY < block79_Y_Pos + 32)) begin
				block79 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block80 (x,y) = (0,0)
		  if((DrawX >= block80_X_Pos) && (DrawX < block80_X_Pos + 32) && (DrawY >= block80_Y_Pos) && (DrawY < block80_Y_Pos + 32)) begin
				block80 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block81 (x,y) = (0,0)
		  if((DrawX >= block81_X_Pos) && (DrawX < block81_X_Pos + 32) && (DrawY >= block81_Y_Pos) && (DrawY < block81_Y_Pos + 32)) begin
				block81 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block82 (x,y) = (0,0)
		  if((DrawX >= block82_X_Pos) && (DrawX < block82_X_Pos + 32) && (DrawY >= block82_Y_Pos) && (DrawY < block82_Y_Pos + 32)) begin
				block82 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block82_X_Pos) && (Kirby_X_Pos + 16 < block82_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block82_Y_Pos) && (Kirby_Y_Pos + 32 < block82_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  if((Kirby_X_Pos >= block82_X_Pos) && (Kirby_X_Pos < block82_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block82_Y_Pos) && (Kirby_Y_Pos + 16 < block82_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block83 (x,y) = (0,0)
		  if((DrawX >= block83_X_Pos) && (DrawX < block83_X_Pos + 32) && (DrawY >= block83_Y_Pos) && (DrawY < block83_Y_Pos + 32)) begin
				block83 = 1'b1;
        end  
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block84 (x,y) = (0,0)
		  if((DrawX >= block84_X_Pos) && (DrawX < block84_X_Pos + 32) && (DrawY >= block84_Y_Pos) && (DrawY < block84_Y_Pos + 32)) begin
				block84 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block84_X_Pos) && (Kirby_X_Pos + 16 < block84_X_Pos + 32) && (Kirby_Y_Pos >= block84_Y_Pos) && (Kirby_Y_Pos < block84_Y_Pos + 32)) begin
            NO_UP = 1'b1;
				SPIKE = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block85 (x,y) = (0,0)
		  if((DrawX >= block85_X_Pos) && (DrawX < block85_X_Pos + 32) && (DrawY >= block85_Y_Pos) && (DrawY < block85_Y_Pos + 32)) begin
				block85 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block86 (x,y) = (0,0)
		  if((DrawX >= block86_X_Pos) && (DrawX < block86_X_Pos + 32) && (DrawY >= block86_Y_Pos) && (DrawY < block86_Y_Pos + 32)) begin
				block86 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block87 (x,y) = (0,0)
		  if((DrawX >= block87_X_Pos) && (DrawX < block87_X_Pos + 32) && (DrawY >= block87_Y_Pos) && (DrawY < block87_Y_Pos + 32)) begin
				block87 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block88 (x,y) = (0,0)
		  if((DrawX >= block88_X_Pos) && (DrawX < block88_X_Pos + 32) && (DrawY >= block88_Y_Pos) && (DrawY < block88_Y_Pos + 32)) begin
				block88 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block89 (x,y) = (0,0)
		  if((DrawX >= block89_X_Pos) && (DrawX < block89_X_Pos + 32) && (DrawY >= block89_Y_Pos) && (DrawY < block89_Y_Pos + 32)) begin
				block89 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block89_X_Pos) && (Kirby_X_Pos + 16 < block89_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block89_Y_Pos) && (Kirby_Y_Pos + 32 < block89_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block90 (x,y) = (0,0)
		  if((DrawX >= block90_X_Pos) && (DrawX < block90_X_Pos + 32) && (DrawY >= block90_Y_Pos) && (DrawY < block90_Y_Pos + 32)) begin
				block90 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block90_X_Pos) && (Kirby_X_Pos + 16 < block90_X_Pos + 32) && (Kirby_Y_Pos >= block90_Y_Pos) && (Kirby_Y_Pos < block90_Y_Pos + 32)) begin
            NO_UP = 1'b1;
				SPIKE = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block91 (x,y) = (0,0)
		  if((DrawX >= block91_X_Pos) && (DrawX < block91_X_Pos + 32) && (DrawY >= block91_Y_Pos) && (DrawY < block91_Y_Pos + 32)) begin
				block91 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block92 (x,y) = (0,0)
		  if((DrawX >= block92_X_Pos) && (DrawX < block92_X_Pos + 32) && (DrawY >= block92_Y_Pos) && (DrawY < block92_Y_Pos + 32)) begin
				block92 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block92_X_Pos) && (Kirby_X_Pos + 16 < block92_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block92_Y_Pos) && (Kirby_Y_Pos + 32 < block92_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block93 (x,y) = (0,0)
		  if((DrawX >= block93_X_Pos) && (DrawX < block93_X_Pos + 32) && (DrawY >= block93_Y_Pos) && (DrawY < block93_Y_Pos + 32)) begin
				block93 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block94 (x,y) = (0,0)
		  if((DrawX >= block94_X_Pos) && (DrawX < block94_X_Pos + 32) && (DrawY >= block94_Y_Pos) && (DrawY < block94_Y_Pos + 32)) begin
				block94 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block95 (x,y) = (0,0)
		  if((DrawX >= block95_X_Pos) && (DrawX < block95_X_Pos + 32) && (DrawY >= block95_Y_Pos) && (DrawY < block95_Y_Pos + 32)) begin
				block95 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block96 (x,y) = (0,0)
		  if((DrawX >= block96_X_Pos) && (DrawX < block96_X_Pos + 32) && (DrawY >= block96_Y_Pos) && (DrawY < block96_Y_Pos + 32)) begin
				block96 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block97 (x,y) = (0,0)
		  if((DrawX >= block97_X_Pos) && (DrawX < block97_X_Pos + 32) && (DrawY >= block97_Y_Pos) && (DrawY < block97_Y_Pos + 32)) begin
				block97 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block98 (x,y) = (0,0)
		  if((DrawX >= block98_X_Pos) && (DrawX < block98_X_Pos + 32) && (DrawY >= block98_Y_Pos) && (DrawY < block98_Y_Pos + 32)) begin
				block98 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block98_X_Pos) && (Kirby_X_Pos + 16 < block98_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block98_Y_Pos) && (Kirby_Y_Pos + 32 < block98_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block99 (x,y) = (0,0)
		  if((DrawX >= block99_X_Pos) && (DrawX < block99_X_Pos + 32) && (DrawY >= block99_Y_Pos) && (DrawY < block99_Y_Pos + 32)) begin
				block99 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block99_X_Pos) && (Kirby_X_Pos + 16 < block99_X_Pos + 32) && (Kirby_Y_Pos >= block99_Y_Pos) && (Kirby_Y_Pos < block99_Y_Pos + 32)) begin
            NO_UP = 1'b1;
				SPIKE = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block100 (x,y) = (0,0)
		  if((DrawX >= block100_X_Pos) && (DrawX < block100_X_Pos + 32) && (DrawY >= block100_Y_Pos) && (DrawY < block100_Y_Pos + 32)) begin
				block100 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block101 (x,y) = (0,0)
		  if((DrawX >= block101_X_Pos) && (DrawX < block101_X_Pos + 32) && (DrawY >= block101_Y_Pos) && (DrawY < block101_Y_Pos + 32)) begin
				block101 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block102 (x,y) = (0,0)
		  if((DrawX >= block102_X_Pos) && (DrawX < block102_X_Pos + 32) && (DrawY >= block102_Y_Pos) && (DrawY < block102_Y_Pos + 32)) begin
				block102 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block103 (x,y) = (0,0)
		  if((DrawX >= block103_X_Pos) && (DrawX < block103_X_Pos + 32) && (DrawY >= block103_Y_Pos) && (DrawY < block103_Y_Pos + 32)) begin
				block103 = 1'b1;
        end  
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block104 (x,y) = (0,0)
		  if((DrawX >= block104_X_Pos) && (DrawX < block104_X_Pos + 32) && (DrawY >= block104_Y_Pos) && (DrawY < block104_Y_Pos + 32)) begin
				block104 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block104_X_Pos) && (Kirby_X_Pos + 16 < block104_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block104_Y_Pos) && (Kirby_Y_Pos + 32 < block104_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block105 (x,y) = (0,0)
		  if((DrawX >= block105_X_Pos) && (DrawX < block105_X_Pos + 32) && (DrawY >= block105_Y_Pos) && (DrawY < block105_Y_Pos + 32)) begin
				block105 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block106 (x,y) = (0,0)
		  if((DrawX >= block106_X_Pos) && (DrawX < block106_X_Pos + 32) && (DrawY >= block106_Y_Pos) && (DrawY < block106_Y_Pos + 32)) begin
				block106 = 1'b1;
        end
		  if((Kirby_X_Pos + 32 >= block106_X_Pos) && (Kirby_X_Pos + 32 < block106_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block106_Y_Pos) && (Kirby_Y_Pos + 16 < block106_Y_Pos + 32)) begin
            NO_RIGHT = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block106_X_Pos) && (Kirby_X_Pos + 16 < block106_X_Pos + 32) && (Kirby_Y_Pos >= block106_Y_Pos) && (Kirby_Y_Pos < block106_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block107 (x,y) = (0,0)
		  if((DrawX >= block107_X_Pos) && (DrawX < block107_X_Pos + 32) && (DrawY >= block107_Y_Pos) && (DrawY < block107_Y_Pos + 32)) begin
				block107 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block108 (x,y) = (0,0)
		  if((DrawX >= block108_X_Pos) && (DrawX < block108_X_Pos + 32) && (DrawY >= block108_Y_Pos) && (DrawY < block108_Y_Pos + 32)) begin
				block108 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block109 (x,y) = (0,0)
		  if((DrawX >= block109_X_Pos) && (DrawX < block109_X_Pos + 32) && (DrawY >= block109_Y_Pos) && (DrawY < block109_Y_Pos + 32)) begin
				block109 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block110 (x,y) = (0,0)
		  if((DrawX >= block110_X_Pos) && (DrawX < block110_X_Pos + 32) && (DrawY >= block110_Y_Pos) && (DrawY < block110_Y_Pos + 32)) begin
				block110 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block111 (x,y) = (0,0)
		  if((DrawX >= block111_X_Pos) && (DrawX < block111_X_Pos + 32) && (DrawY >= block111_Y_Pos) && (DrawY < block111_Y_Pos + 32)) begin
				block111 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block112 (x,y) = (0,0)
		  if((DrawX >= block112_X_Pos) && (DrawX < block112_X_Pos + 32) && (DrawY >= block112_Y_Pos) && (DrawY < block112_Y_Pos + 32)) begin
				block112 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block113 (x,y) = (0,0)
		  if((DrawX >= block113_X_Pos) && (DrawX < block113_X_Pos + 32) && (DrawY >= block113_Y_Pos) && (DrawY < block113_Y_Pos + 32)) begin
				block113 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block113_X_Pos) && (Kirby_X_Pos + 16 < block113_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block113_Y_Pos) && (Kirby_Y_Pos + 32 < block113_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block114 (x,y) = (0,0)
		  if((DrawX >= block114_X_Pos) && (DrawX < block114_X_Pos + 32) && (DrawY >= block114_Y_Pos) && (DrawY < block114_Y_Pos + 32)) begin
				block114 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block114_X_Pos) && (Kirby_X_Pos + 16 < block114_X_Pos + 32) && (Kirby_Y_Pos >= block114_Y_Pos) && (Kirby_Y_Pos < block114_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block115 (x,y) = (0,0)
		  if((DrawX >= block115_X_Pos) && (DrawX < block115_X_Pos + 32) && (DrawY >= block115_Y_Pos) && (DrawY < block115_Y_Pos + 32)) begin
				block115 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block116 (x,y) = (0,0)
		  if((DrawX >= block116_X_Pos) && (DrawX < block116_X_Pos + 32) && (DrawY >= block116_Y_Pos) && (DrawY < block116_Y_Pos + 32)) begin
				block116 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block117 (x,y) = (0,0)
		  if((DrawX >= block117_X_Pos) && (DrawX < block117_X_Pos + 32) && (DrawY >= block117_Y_Pos) && (DrawY < block117_Y_Pos + 32)) begin
				block117 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block118 (x,y) = (0,0)
		  if((DrawX >= block118_X_Pos) && (DrawX < block118_X_Pos + 32) && (DrawY >= block118_Y_Pos) && (DrawY < block118_Y_Pos + 32)) begin
				block118 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block119 (x,y) = (0,0)
		  if((DrawX >= block119_X_Pos) && (DrawX < block119_X_Pos + 32) && (DrawY >= block119_Y_Pos) && (DrawY < block119_Y_Pos + 32)) begin
				block119 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block119_X_Pos) && (Kirby_X_Pos + 16 < block119_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block119_Y_Pos) && (Kirby_Y_Pos + 32 < block119_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block120 (x,y) = (0,0)
		  if((DrawX >= block120_X_Pos) && (DrawX < block120_X_Pos + 32) && (DrawY >= block120_Y_Pos) && (DrawY < block120_Y_Pos + 32)) begin
				block120 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block121 (x,y) = (0,0)
		  if((DrawX >= block121_X_Pos) && (DrawX < block121_X_Pos + 32) && (DrawY >= block121_Y_Pos) && (DrawY < block121_Y_Pos + 32)) begin
				block121 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block121_X_Pos) && (Kirby_X_Pos + 16 < block121_X_Pos + 32) && (Kirby_Y_Pos >= block121_Y_Pos) && (Kirby_Y_Pos < block121_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block122 (x,y) = (0,0)
		  if((DrawX >= block122_X_Pos) && (DrawX < block122_X_Pos + 32) && (DrawY >= block122_Y_Pos) && (DrawY < block122_Y_Pos + 32)) begin
				block122 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block123 (x,y) = (0,0)
		  if((DrawX >= block123_X_Pos) && (DrawX < block123_X_Pos + 32) && (DrawY >= block123_Y_Pos) && (DrawY < block123_Y_Pos + 32)) begin
				block123 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block124 (x,y) = (0,0)
		  if((DrawX >= block124_X_Pos) && (DrawX < block124_X_Pos + 32) && (DrawY >= block124_Y_Pos) && (DrawY < block124_Y_Pos + 32)) begin
				block124 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block125 (x,y) = (0,0)
		  if((DrawX >= block125_X_Pos) && (DrawX < block125_X_Pos + 32) && (DrawY >= block125_Y_Pos) && (DrawY < block125_Y_Pos + 32)) begin
				block125 = 1'b1;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block126 (x,y) = (0,0)
		  if((DrawX >= block126_X_Pos) && (DrawX < block126_X_Pos + 32) && (DrawY >= block126_Y_Pos) && (DrawY < block126_Y_Pos + 32)) begin
				block126 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block127 (x,y) = (0,0)
		  if((DrawX >= block127_X_Pos) && (DrawX < block127_X_Pos + 32) && (DrawY >= block127_Y_Pos) && (DrawY < block127_Y_Pos + 32)) begin
				block127 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block128 (x,y) = (0,0)
		  if((DrawX >= block128_X_Pos) && (DrawX < block128_X_Pos + 32) && (DrawY >= block128_Y_Pos) && (DrawY < block128_Y_Pos + 32)) begin
				block128 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block128_X_Pos) && (Kirby_X_Pos + 16 < block128_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block128_Y_Pos) && (Kirby_Y_Pos + 32 < block128_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block129 (x,y) = (0,0)
		  if((DrawX >= block129_X_Pos) && (DrawX < block129_X_Pos + 32) && (DrawY >= block129_Y_Pos) && (DrawY < block129_Y_Pos + 32)) begin
				block129 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block129_X_Pos) && (Kirby_X_Pos + 16 < block129_X_Pos + 32) && (Kirby_Y_Pos >= block129_Y_Pos) && (Kirby_Y_Pos < block129_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block130 (x,y) = (0,0)
		  if((DrawX >= block130_X_Pos) && (DrawX < block130_X_Pos + 32) && (DrawY >= block130_Y_Pos) && (DrawY < block130_Y_Pos + 32)) begin
				block130 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block131 (x,y) = (0,0)
		  if((DrawX >= block131_X_Pos) && (DrawX < block131_X_Pos + 32) && (DrawY >= block131_Y_Pos) && (DrawY < block131_Y_Pos + 32)) begin
				block131 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block132 (x,y) = (0,0)
		  if((DrawX >= block132_X_Pos) && (DrawX < block132_X_Pos + 32) && (DrawY >= block132_Y_Pos) && (DrawY < block132_Y_Pos + 32)) begin
				block132 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block133 (x,y) = (0,0)
		  if((DrawX >= block133_X_Pos) && (DrawX < block133_X_Pos + 32) && (DrawY >= block133_Y_Pos) && (DrawY < block133_Y_Pos + 32)) begin
				block133 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block134 (x,y) = (0,0)
		  if((DrawX >= block134_X_Pos) && (DrawX < block134_X_Pos + 32) && (DrawY >= block134_Y_Pos) && (DrawY < block134_Y_Pos + 32)) begin
				block134 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block134_X_Pos) && (Kirby_X_Pos + 16 < block134_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block134_Y_Pos) && (Kirby_Y_Pos + 32 < block134_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block135 (x,y) = (0,0)
		  if((DrawX >= block135_X_Pos) && (DrawX < block135_X_Pos + 32) && (DrawY >= block135_Y_Pos) && (DrawY < block135_Y_Pos + 32)) begin
				block135 = 1'b0;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block136 (x,y) = (0,0)
		  if((DrawX >= block136_X_Pos) && (DrawX < block136_X_Pos + 32) && (DrawY >= block136_Y_Pos) && (DrawY < block136_Y_Pos + 32)) begin
				block136 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block136_X_Pos) && (Kirby_X_Pos + 16 < block136_X_Pos + 32) && (Kirby_Y_Pos >= block136_Y_Pos) && (Kirby_Y_Pos < block136_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  if((Kirby_X_Pos >= block136_X_Pos) && (Kirby_X_Pos < block136_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block136_Y_Pos) && (Kirby_Y_Pos + 16 < block136_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
			  		///////////////////////////////////////////////////////////////////////////////////////
		//block137 (x,y) = (0,0)
		  if((DrawX >= block137_X_Pos) && (DrawX < block137_X_Pos + 32) && (DrawY >= block137_Y_Pos) && (DrawY < block137_Y_Pos + 32)) begin
				block137 = 1'b1;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block138 (x,y) = (0,0)
		  if((DrawX >= block138_X_Pos) && (DrawX < block138_X_Pos + 32) && (DrawY >= block138_Y_Pos) && (DrawY < block138_Y_Pos + 32)) begin
				block138 = 1'b1;
        end 
	 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block139 (x,y) = (0,0)
		  if((DrawX >= block139_X_Pos) && (DrawX < block139_X_Pos + 32) && (DrawY >= block139_Y_Pos) && (DrawY < block139_Y_Pos + 32)) begin
				block139 = 1'b1;
        end 
	 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block140 (x,y) = (0,0)
		  if((DrawX >= block140_X_Pos) && (DrawX < block140_X_Pos + 32) && (DrawY >= block140_Y_Pos) && (DrawY < block140_Y_Pos + 32)) begin
				block140 = 1'b1;
        end 
	 		  		
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block141 (x,y) = (0,0)
		  if((DrawX >= block141_X_Pos) && (DrawX < block141_X_Pos + 32) && (DrawY >= block141_Y_Pos) && (DrawY < block141_Y_Pos + 32)) begin
				block141 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block142 (x,y) = (0,0)
		  if((DrawX >= block142_X_Pos) && (DrawX < block142_X_Pos + 32) && (DrawY >= block142_Y_Pos) && (DrawY < block142_Y_Pos + 32)) begin
				block142 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block142_X_Pos) && (Kirby_X_Pos + 16 < block142_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block142_Y_Pos) && (Kirby_Y_Pos + 32 < block142_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block143 (x,y) = (0,0)
		  if((DrawX >= block143_X_Pos) && (DrawX < block143_X_Pos + 32) && (DrawY >= block143_Y_Pos) && (DrawY < block143_Y_Pos + 32)) begin
				block143 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block143_X_Pos) && (Kirby_X_Pos + 16 < block143_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block143_Y_Pos) && (Kirby_Y_Pos + 32 < block143_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block144 (x,y) = (0,0)
		  if((DrawX >= block144_X_Pos) && (DrawX < block144_X_Pos + 32) && (DrawY >= block144_Y_Pos) && (DrawY < block144_Y_Pos + 32)) begin
				block144 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block144_X_Pos) && (Kirby_X_Pos + 16 < block144_X_Pos + 32) && (Kirby_Y_Pos >= block144_Y_Pos) && (Kirby_Y_Pos < block144_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
			  		///////////////////////////////////////////////////////////////////////////////////////
		//block145 (x,y) = (0,0)
		  if((DrawX >= block145_X_Pos) && (DrawX < block145_X_Pos + 32) && (DrawY >= block145_Y_Pos) && (DrawY < block145_Y_Pos + 32)) begin
				block145 = 1'b1;
        end 
	 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block146 (x,y) = (0,0)
		  if((DrawX >= block146_X_Pos) && (DrawX < block146_X_Pos + 32) && (DrawY >= block146_Y_Pos) && (DrawY < block146_Y_Pos + 32)) begin
				block146 = 1'b1;
        end 
 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block147 (x,y) = (0,0)
		  if((DrawX >= block147_X_Pos) && (DrawX < block147_X_Pos + 32) && (DrawY >= block147_Y_Pos) && (DrawY < block147_Y_Pos + 32)) begin
				block147 = 1'b1;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block148 (x,y) = (0,0)
		  if((DrawX >= block148_X_Pos) && (DrawX < block148_X_Pos + 32) && (DrawY >= block148_Y_Pos) && (DrawY < block148_Y_Pos + 32)) begin
				block148 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block149 (x,y) = (0,0)
		  if((DrawX >= block149_X_Pos) && (DrawX < block149_X_Pos + 32) && (DrawY >= block149_Y_Pos) && (DrawY < block149_Y_Pos + 32)) begin
				block149 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block149_X_Pos) && (Kirby_X_Pos + 16 < block149_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block149_Y_Pos) && (Kirby_Y_Pos + 32 < block149_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end  
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block150 (x,y) = (0,0)
		  if((DrawX >= block150_X_Pos) && (DrawX < block150_X_Pos + 32) && (DrawY >= block150_Y_Pos) && (DrawY < block150_Y_Pos + 32)) begin
				block150 = 1'b0;
        end  
		  if((Kirby_X_Pos + 16 >= block150_X_Pos) && (Kirby_X_Pos + 16 < block150_X_Pos + 32) && (Kirby_Y_Pos >= block150_Y_Pos) && (Kirby_Y_Pos < block150_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block151 (x,y) = (0,0)
		  if((DrawX >= block151_X_Pos) && (DrawX < block151_X_Pos + 32) && (DrawY >= block151_Y_Pos) && (DrawY < block151_Y_Pos + 32)) begin
				block151 = 1'b0;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block152 (x,y) = (0,0)
		  if((DrawX >= block152_X_Pos) && (DrawX < block152_X_Pos + 32) && (DrawY >= block152_Y_Pos) && (DrawY < block152_Y_Pos + 32)) begin
				block152 = 1'b1;
        end 		  		
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block153 (x,y) = (0,0)
		  if((DrawX >= block153_X_Pos) && (DrawX < block153_X_Pos + 32) && (DrawY >= block153_Y_Pos) && (DrawY < block153_Y_Pos + 32)) begin
				block153 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block154 (x,y) = (0,0)
		  if((DrawX >= block154_X_Pos) && (DrawX < block154_X_Pos + 32) && (DrawY >= block154_Y_Pos) && (DrawY < block154_Y_Pos + 32)) begin
				block154 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block155 (x,y) = (0,0)
		  if((DrawX >= block155_X_Pos) && (DrawX < block155_X_Pos + 32) && (DrawY >= block155_Y_Pos) && (DrawY < block155_Y_Pos + 32)) begin
				block155 = 1'b1;
        end 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block156 (x,y) = (0,0)
		  if((DrawX >= block156_X_Pos) && (DrawX < block156_X_Pos + 32) && (DrawY >= block156_Y_Pos) && (DrawY < block156_Y_Pos + 32)) begin
				block156 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block157 (x,y) = (0,0)
		  if((DrawX >= block157_X_Pos) && (DrawX < block157_X_Pos + 32) && (DrawY >= block157_Y_Pos) && (DrawY < block157_Y_Pos + 32)) begin
				block157 = 1'b1;
        end 
 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block158 (x,y) = (0,0)
		  if((DrawX >= block158_X_Pos) && (DrawX < block158_X_Pos + 32) && (DrawY >= block158_Y_Pos) && (DrawY < block158_Y_Pos + 32)) begin
				block158 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block158_X_Pos) && (Kirby_X_Pos + 16 < block158_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block158_Y_Pos) && (Kirby_Y_Pos + 32 < block158_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  if((Kirby_X_Pos >= block158_X_Pos) && (Kirby_X_Pos < block158_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block158_Y_Pos) && (Kirby_Y_Pos + 16 < block158_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block159 (x,y) = (0,0)
		  if((DrawX >= block159_X_Pos) && (DrawX < block159_X_Pos + 32) && (DrawY >= block159_Y_Pos) && (DrawY < block159_Y_Pos + 32)) begin
				block159 = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block159_X_Pos) && (Kirby_X_Pos + 16 < block159_X_Pos + 32) && (Kirby_Y_Pos >= block159_Y_Pos) && (Kirby_Y_Pos < block159_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  if((Kirby_X_Pos >= block159_X_Pos) && (Kirby_X_Pos < block159_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block159_Y_Pos) && (Kirby_Y_Pos + 16 < block159_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
			  		///////////////////////////////////////////////////////////////////////////////////////
		//block160 (x,y) = (0,0)
		  if((DrawX >= block160_X_Pos) && (DrawX < block160_X_Pos + 32) && (DrawY >= block160_Y_Pos) && (DrawY < block160_Y_Pos + 32)) begin
				block160 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block161 (x,y) = (0,0)
		  if((DrawX >= block161_X_Pos) && (DrawX < block161_X_Pos + 32) && (DrawY >= block161_Y_Pos) && (DrawY < block161_Y_Pos + 32)) begin
				block161 = 1'b1;
        end 
			///////////////////////////////////////////////////////////////////////////////////////
		//block162 (x,y) = (0,0)
		  if((DrawX >= block162_X_Pos) && (DrawX < block162_X_Pos + 32) && (DrawY >= block162_Y_Pos) && (DrawY < block162_Y_Pos + 32)) begin
				block162 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block163 (x,y) = (0,0)
		  if((DrawX >= block163_X_Pos) && (DrawX < block163_X_Pos + 32) && (DrawY >= block163_Y_Pos) && (DrawY < block163_Y_Pos + 32)) begin
				block163 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block164 (x,y) = (0,0)
		  if((DrawX >= block164_X_Pos) && (DrawX < block164_X_Pos + 32) && (DrawY >= block164_Y_Pos) && (DrawY < block164_Y_Pos + 32)) begin
				block164 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block164_X_Pos) && (Kirby_X_Pos + 16 < block164_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block164_Y_Pos) && (Kirby_Y_Pos + 32 < block164_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end  		  		
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block165 (x,y) = (0,0)
		  if((DrawX >= block165_X_Pos) && (DrawX < block165_X_Pos + 32) && (DrawY >= block165_Y_Pos) && (DrawY < block165_Y_Pos + 32)) begin
				block165 = 1'b0;
        end 
		  if((Kirby_X_Pos + 16 >= block165_X_Pos) && (Kirby_X_Pos + 16 < block165_X_Pos + 32) && (Kirby_Y_Pos >= block165_Y_Pos) && (Kirby_Y_Pos < block165_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block166 (x,y) = (0,0)
		  if((DrawX >= block166_X_Pos) && (DrawX < block166_X_Pos + 32) && (DrawY >= block166_Y_Pos) && (DrawY < block166_Y_Pos + 32)) begin
				block166 = 1'b0;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block167 (x,y) = (0,0)
		  if((DrawX >= block167_X_Pos) && (DrawX < block167_X_Pos + 32) && (DrawY >= block167_Y_Pos) && (DrawY < block167_Y_Pos + 32)) begin
				block167 = 1'b0;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block168 (x,y) = (0,0)
		  if((DrawX >= block168_X_Pos) && (DrawX < block168_X_Pos + 32) && (DrawY >= block168_Y_Pos) && (DrawY < block168_Y_Pos + 32)) begin
				block168 = 1'b1;
        end 
 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block169 (x,y) = (0,0)
		  if((DrawX >= block169_X_Pos) && (DrawX < block169_X_Pos + 32) && (DrawY >= block169_Y_Pos) && (DrawY < block169_Y_Pos + 32)) begin
				block169 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block170 (x,y) = (0,0)
		  if((DrawX >= block170_X_Pos) && (DrawX < block170_X_Pos + 32) && (DrawY >= block170_Y_Pos) && (DrawY < block170_Y_Pos + 32)) begin
				block170 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block171 (x,y) = (0,0)
		  if((DrawX >= block171_X_Pos) && (DrawX < block171_X_Pos + 32) && (DrawY >= block171_Y_Pos) && (DrawY < block171_Y_Pos + 32)) begin
				block171 = 1'b1;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block172 (x,y) = (0,0)
		  if((DrawX >= block172_X_Pos) && (DrawX < block172_X_Pos + 32) && (DrawY >= block172_Y_Pos) && (DrawY < block172_Y_Pos + 32)) begin
				block172 = 1'b1;
        end 
 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block173 (x,y) = (0,0)
		  if((DrawX >= block173_X_Pos) && (DrawX < block173_X_Pos + 32) && (DrawY >= block173_Y_Pos) && (DrawY < block173_Y_Pos + 32)) begin
				block173 = 1'b1;
        end 
	
		///////////////////////////////////////////////////////////////////////////////////////
		//block174 (x,y) = (0,0)
		  if((DrawX >= block174_X_Pos) && (DrawX < block174_X_Pos + 32) && (DrawY >= block174_Y_Pos) && (DrawY < block174_Y_Pos + 32)) begin
				block174 = 1'b1;
        end 
	 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block175 (x,y) = (0,0)
		  if((DrawX >= block175_X_Pos) && (DrawX < block175_X_Pos + 32) && (DrawY >= block175_Y_Pos) && (DrawY < block175_Y_Pos + 32)) begin
				block175 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block176 (x,y) = (0,0)
		  if((DrawX >= block176_X_Pos) && (DrawX < block176_X_Pos + 32) && (DrawY >= block176_Y_Pos) && (DrawY < block176_Y_Pos + 32)) begin
				block176 = 1'b1;
        end 	  		
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block177 (x,y) = (0,0)
		  if((DrawX >= block177_X_Pos) && (DrawX < block177_X_Pos + 32) && (DrawY >= block177_Y_Pos) && (DrawY < block177_Y_Pos + 32)) begin
				block177 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block178 (x,y) = (0,0)
		  if((DrawX >= block178_X_Pos) && (DrawX < block178_X_Pos + 32) && (DrawY >= block178_Y_Pos) && (DrawY < block178_Y_Pos + 32)) begin
				block178 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block179 (x,y) = (0,0)
		  if((DrawX >= block179_X_Pos) && (DrawX < block179_X_Pos + 32) && (DrawY >= block179_Y_Pos) && (DrawY < block179_Y_Pos + 32)) begin
				block179 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block179_X_Pos) && (Kirby_X_Pos + 16 < block179_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block179_Y_Pos) && (Kirby_Y_Pos + 32 < block179_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block180 (x,y) = (0,0)
		  if((DrawX >= block180_X_Pos) && (DrawX < block180_X_Pos + 32) && (DrawY >= block180_Y_Pos) && (DrawY < block180_Y_Pos + 32)) begin
				block180 = 1'b0;
        end 
		  if((Kirby_X_Pos + 16 >= block180_X_Pos) && (Kirby_X_Pos + 16 < block180_X_Pos + 32) && (Kirby_Y_Pos >= block180_Y_Pos) && (Kirby_Y_Pos < block180_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
			  		///////////////////////////////////////////////////////////////////////////////////////
		//block181 (x,y) = (0,0)
		  if((DrawX >= block181_X_Pos) && (DrawX < block181_X_Pos + 32) && (DrawY >= block181_Y_Pos) && (DrawY < block181_Y_Pos + 32)) begin
				block181 = 1'b0;
        end 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block182 (x,y) = (0,0)
		  if((DrawX >= block182_X_Pos) && (DrawX < block182_X_Pos + 32) && (DrawY >= block182_Y_Pos) && (DrawY < block182_Y_Pos + 32)) begin
				block182 = 1'b0;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block183 (x,y) = (0,0)
		  if((DrawX >= block183_X_Pos) && (DrawX < block183_X_Pos + 32) && (DrawY >= block183_Y_Pos) && (DrawY < block183_Y_Pos + 32)) begin
				block183 = 1'b0;
        end 
		 if((Kirby_X_Pos + 16 >= block183_X_Pos) && (Kirby_X_Pos + 16 < block183_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block183_Y_Pos) && (Kirby_Y_Pos + 32 < block183_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block183_X_Pos) && (Kirby_X_Pos + 16 < block183_X_Pos + 32) && (Kirby_Y_Pos >= block183_Y_Pos) && (Kirby_Y_Pos < block183_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  if((Kirby_X_Pos + 32 >= block183_X_Pos) && (Kirby_X_Pos + 32 < block183_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block183_Y_Pos) && (Kirby_Y_Pos + 16 < block183_Y_Pos + 32)) begin
            NO_RIGHT = 1'b1;
        end 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block184 (x,y) = (0,0)
		  if((DrawX >= block184_X_Pos) && (DrawX < block184_X_Pos + 32) && (DrawY >= block184_Y_Pos) && (DrawY < block184_Y_Pos + 32)) begin
				block184 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block185 (x,y) = (0,0)
		  if((DrawX >= block185_X_Pos) && (DrawX < block185_X_Pos + 32) && (DrawY >= block185_Y_Pos) && (DrawY < block185_Y_Pos + 32)) begin
				block185 = 1'b1;
        end 
	
			///////////////////////////////////////////////////////////////////////////////////////
		//block186 (x,y) = (0,0)
		  if((DrawX >= block186_X_Pos) && (DrawX < block186_X_Pos + 32) && (DrawY >= block186_Y_Pos) && (DrawY < block186_Y_Pos + 32)) begin
				block186 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block186_X_Pos) && (Kirby_X_Pos + 16 < block186_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block186_Y_Pos) && (Kirby_Y_Pos + 32 < block186_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block186_X_Pos) && (Kirby_X_Pos + 16 < block186_X_Pos + 32) && (Kirby_Y_Pos >= block186_Y_Pos) && (Kirby_Y_Pos < block186_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  if((Kirby_X_Pos + 32 >= block186_X_Pos) && (Kirby_X_Pos + 32 < block186_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block186_Y_Pos) && (Kirby_Y_Pos + 16 < block186_Y_Pos + 32)) begin
            NO_RIGHT = 1'b1;
        end 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block187 (x,y) = (0,0)
		  if((DrawX >= block187_X_Pos) && (DrawX < block187_X_Pos + 32) && (DrawY >= block187_Y_Pos) && (DrawY < block187_Y_Pos + 32)) begin
				block187 = 1'b1;
        end 
	
      		  		///////////////////////////////////////////////////////////////////////////////////////
		//block188 (x,y) = (0,0)
		  if((DrawX >= block188_X_Pos) && (DrawX < block188_X_Pos + 32) && (DrawY >= block188_Y_Pos) && (DrawY < block188_Y_Pos + 32)) begin
				block188 = 1'b1;
        end 		  		
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block189 (x,y) = (0,0)
		  if((DrawX >= block189_X_Pos) && (DrawX < block189_X_Pos + 32) && (DrawY >= block189_Y_Pos) && (DrawY < block189_Y_Pos + 32)) begin
				block189 = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block190 (x,y) = (0,0)
		  if((DrawX >= block190_X_Pos) && (DrawX < block190_X_Pos + 32) && (DrawY >= block190_Y_Pos) && (DrawY < block190_Y_Pos + 32)) begin
				block190 = 1'b1;
        end  
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block191 (x,y) = (0,0)
		  if((DrawX >= block191_X_Pos) && (DrawX < block191_X_Pos + 32) && (DrawY >= block191_Y_Pos) && (DrawY < block191_Y_Pos + 32)) begin
				block191 = 1'b1;
        end 
		  		///////////////////////////////////////////////////////////////////////////////////////
		//block192 (x,y) = (0,0)
		  if((DrawX >= block192_X_Pos) && (DrawX < block192_X_Pos + 32) && (DrawY >= block192_Y_Pos) && (DrawY < block192_Y_Pos + 32)) begin
				block192 = 1'b1;
        end 
 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block193 (x,y) = (0,0)
		  if((DrawX >= block193_X_Pos) && (DrawX < block193_X_Pos + 32) && (DrawY >= block193_Y_Pos) && (DrawY < block193_Y_Pos + 32)) begin
				block193 = 1'b1;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block194 (x,y) = (0,0)
		  if((DrawX >= block194_X_Pos) && (DrawX < block194_X_Pos + 32) && (DrawY >= block194_Y_Pos) && (DrawY < block194_Y_Pos + 32)) begin
				block194 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block194_X_Pos) && (Kirby_X_Pos + 16 < block194_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block194_Y_Pos) && (Kirby_Y_Pos + 32 < block194_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  		  		///////////////////////////////////////////////////////////////////////////////////////
		//block195 (x,y) = (0,0)
		  if((DrawX >= block195_X_Pos) && (DrawX < block195_X_Pos + 32) && (DrawY >= block195_Y_Pos) && (DrawY < block195_Y_Pos + 32)) begin
				block195 = 1'b0;
        end 
		  if((Kirby_X_Pos + 16 >= block195_X_Pos) && (Kirby_X_Pos + 16 < block195_X_Pos + 32) && (Kirby_Y_Pos >= block195_Y_Pos) && (Kirby_Y_Pos < block195_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block196 (x,y) = (0,0)
		  if((DrawX >= block196_X_Pos) && (DrawX < block196_X_Pos + 32) && (DrawY >= block196_Y_Pos) && (DrawY < block196_Y_Pos + 32)) begin
				block196 = 1'b0;
        end 	
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block197 (x,y) = (0,0)
		  if((DrawX >= block197_X_Pos) && (DrawX < block197_X_Pos + 32) && (DrawY >= block197_Y_Pos) && (DrawY < block197_Y_Pos + 32)) begin
				block197 = 1'b0;
        end 
	
			///////////////////////////////////////////////////////////////////////////////////////
		//block198 (x,y) = (0,0)
		  if((DrawX >= block198_X_Pos) && (DrawX < block198_X_Pos + 32) && (DrawY >= block198_Y_Pos) && (DrawY < block198_Y_Pos + 32)) begin
				block198 = 1'b0;
        end 
		 if((Kirby_X_Pos + 16 >= block198_X_Pos) && (Kirby_X_Pos + 16 < block198_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block198_Y_Pos) && (Kirby_Y_Pos + 32 < block198_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block198_X_Pos) && (Kirby_X_Pos + 16 < block198_X_Pos + 32) && (Kirby_Y_Pos >= block198_Y_Pos) && (Kirby_Y_Pos < block198_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  if((Kirby_X_Pos >= block198_X_Pos) && (Kirby_X_Pos < block198_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block198_Y_Pos) && (Kirby_Y_Pos + 16 < block198_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
 		  		///////////////////////////////////////////////////////////////////////////////////////
		//block199 (x,y) = (0,0)
		  if((DrawX >= block199_X_Pos) && (DrawX < block199_X_Pos + 32) && (DrawY >= block199_Y_Pos) && (DrawY < block199_Y_Pos + 32)) begin
				block199 = 1'b0;
        end 
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block200 (x,y) = (0,0)
		  if((DrawX >= block200_X_Pos) && (DrawX < block200_X_Pos + 32) && (DrawY >= block200_Y_Pos) && (DrawY < block200_Y_Pos + 32)) begin
				block200 = 1'b1;
        end 
		  
		  
		  
		    ///////////////////////////////////////////////////////////////////////////////////////
		//block201 (x,y) = (0,0) //sky1
		  if(((DrawX >= block201_X_Pos) || (block201_X_Pos > 5000)) && (DrawX < block201_X_Pos + 512) && (DrawY >= block201_Y_Pos) && (DrawY < block201_Y_Pos + 352)) begin
				block201 = 1'b1;
        end 
		  
		 		//block202 (x,y) = (0,0) //ground1
		  if(((DrawX >= block202_X_Pos) || (block202_X_Pos > 5000)) && (DrawX < block202_X_Pos + 512) && (DrawY >= block202_Y_Pos) && (DrawY < block202_Y_Pos + 128)) begin
				block202 = 1'b1;
        end 
		   if((Kirby_X_Pos + 16 >= block202_X_Pos) && (Kirby_X_Pos + 16 < block202_X_Pos + 512) && (Kirby_Y_Pos + 32 >= block202_Y_Pos) && (Kirby_Y_Pos + 32 < block202_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end  
		  
		  		 		//block203 (x,y) = (0,0) //sky2
		  if(((DrawX >= block203_X_Pos) || (block203_X_Pos > 5000)) && (DrawX < block203_X_Pos + 512) && (DrawY >= block203_Y_Pos) && (DrawY < block203_Y_Pos + 352)) begin
				block203 = 1'b1;
        end 
		  
		  		 		//block204 (x,y) = (0,0) //ground1
		  if(((DrawX >= block204_X_Pos) || (block204_X_Pos > 5000)) && (DrawX < block204_X_Pos + 512) && (DrawY >= block204_Y_Pos) && (DrawY < block204_Y_Pos + 128)) begin
				block204 = 1'b1;
        end 
 
		  

end 
if(is_kirby) begin
		  		  		 		//block206 (x,y) = (0,0) boss_background right side
		  if(((DrawX >= block206_X_Pos) || (block206_X_Pos > 5000)) && (DrawX < block206_X_Pos + 128) && (DrawY >= block206_Y_Pos) && (DrawY < block206_Y_Pos + 256) ) begin
				block206 = 1'b1;
        end 
		  
		  		  		  		 //block205 (x,y) = (0,0)    boss_background left side
		  if(((DrawX >= block205_X_Pos) || (block205_X_Pos > 5000)) && (DrawX < block205_X_Pos + 512) && (DrawY >= block205_Y_Pos) && (DrawY < block205_Y_Pos + 480) ) begin
				block205 = 1'b1;
        end 
		  
		  		  		  		 //block207 (x,y) = (0,0)    small right side
		  if(((DrawX >= block207_X_Pos) || (block207_X_Pos > 5000)) && (DrawX < block207_X_Pos + 128) && (DrawY >= block207_Y_Pos) && (DrawY < block207_Y_Pos + 224) ) begin
				block207 = 1'b1;
        end 
		  
		  if((is_kirby) && (Kirby_Y_Pos + 32 >= 10'd440)) begin
				NO_DOWN = 1'b1;
		  end
		  
		  if(Kirby_X_Pos >= 10'd648) begin
				NO_RIGHT = 1'b1;
		  end
		  
		  if(((DrawX >= boss_X_Pos) || (boss_X_Pos > 5000)) && (DrawX < boss_X_Pos + 96) && (DrawY >= boss_Y_Pos) && (DrawY < boss_Y_Pos + 96)) begin
				boss = 1'b1;
        end 
		  
		   if(((DrawX >= f0_X_Pos) || (f0_X_Pos > 5000)) && (DrawX < f0_X_Pos + 32) && (DrawY >= f0_Y_Pos) && (DrawY < f0_Y_Pos + 32)) begin
				f0 = 1'b1;
				is_flame = 1'b1;
        end 
		  
		   if(((DrawX >= f1_X_Pos) || (f1_X_Pos > 5000)) && (DrawX < f1_X_Pos + 32) && (DrawY >= f1_Y_Pos) && (DrawY < f1_Y_Pos + 32)) begin
				f1 = 1'b1;
				is_flame = 1'b1;
        end 
		  
		   if(((DrawX >= f2_X_Pos) || (f2_X_Pos > 5000)) && (DrawX < f2_X_Pos + 32) && (DrawY >= f2_Y_Pos) && (DrawY < f2_Y_Pos + 32)) begin
				f2 = 1'b1;
				is_flame = 1'b1;
        end 
		  
end
 		/*  		
		  ///////////////////////////////////////////////////////////////////////////////////////
		//block1 (x,y) = (0,0)
		  if((DrawX >= block0_X_Pos) && (DrawX < block0_X_Pos + 32) && (DrawY >= block0_Y_Pos) && (DrawY < block0_Y_Pos + 32)) begin
				block0 = 1'b1;
        end 
		 if((Kirby_X_Pos + 16 >= block0_X_Pos) && (Kirby_X_Pos + 16 < block0_X_Pos + 32) && (Kirby_Y_Pos + 32 >= block0_Y_Pos) && (Kirby_Y_Pos + 32 < block0_Y_Pos + 32)) begin
            NO_DOWN = 1'b1;
        end 
		  if((Kirby_X_Pos + 16 >= block0_X_Pos) && (Kirby_X_Pos + 16 < block0_X_Pos + 32) && (Kirby_Y_Pos >= block0_Y_Pos) && (Kirby_Y_Pos < block0_Y_Pos + 32)) begin
            NO_UP = 1'b1;
        end 
		  if((Kirby_X_Pos >= block0_X_Pos) && (Kirby_X_Pos < block0_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block0_Y_Pos) && (Kirby_Y_Pos + 16 < block0_Y_Pos + 32)) begin
            NO_LEFT = 1'b1;
        end 
		  if((Kirby_X_Pos + 32 >= block0_X_Pos) && (Kirby_X_Pos + 32 < block0_X_Pos + 32) && (Kirby_Y_Pos + 16 >= block0_Y_Pos) && (Kirby_Y_Pos + 16 < block0_Y_Pos + 32)) begin
            NO_RIGHT = 1'b1;
        end   */
		  		  		
	

	
	/////////////////////////////////////////////////////////////////////////////////////////////
		  if(keycode[31:24] == 8'h1A | keycode[23:16] == 8'h1A | keycode[15: 8] == 8'h1A | keycode[ 7: 0] == 8'h1A) begin
				U = 1;
		  end else U = 0;
		  if(keycode[31:24] == 8'h16 | keycode[23:16] == 8'h16 | keycode[15: 8] == 8'h16 | keycode[ 7: 0] == 8'h16) begin
				D = 1;
		  end else D = 0;
		  if(keycode[31:24] == 8'h04 | keycode[23:16] == 8'h04 | keycode[15: 8] == 8'h04 | keycode[ 7: 0] == 8'h04) begin
				L = 1;
		  end else L = 0;
		  if(keycode[31:24] == 8'h07 | keycode[23:16] == 8'h07 | keycode[15: 8] == 8'h07 | keycode[ 7: 0] == 8'h07) begin
				R = 1;
		  end else R = 0;
		  if(keycode[31:24] == 8'h28 | keycode[23:16] == 8'h28 | keycode[15: 8] == 8'h28 | keycode[ 7: 0] == 8'h28) begin
				A = 1;
		  end else A = 0;
    end
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
  

    always_ff @ (posedge frame_clk ) begin
			
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
			  Kirby_Y_Pos <= Kirby_Y_Pos + (~(Kirby_Y_Step) + 1);
				
			  if ( Reset ) begin
					Kirby_Y_Pos <= Kirby_Y_Center;
					Kirby_X_Pos <= Kirby_X_Center;
			  end
			
			  prev_press <= curr_press;
			  curr_press <= keycode;
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	  
			//FLOATING KIRBY  
			  if (U) begin
						if(UP_COUNT == 32'hFFFFFFFF) begin
							UP_COUNT <= 0;
						end else begin
							UP_COUNT <= UP_COUNT + 1;			// Basically creates the images for floating Kirby
						end
						if((UP_COUNT%(8) == 0) && (UP_COUNT !== 0)) begin
							if(FLOAT_FSM == 10'd8) begin
								FLOAT_FSM <= 10'd1;
							end else begin 
								FLOAT_FSM <= FLOAT_FSM + 10'd1;
							end
						end			
			  end else begin
					UP_COUNT <= 0;
					FLOAT_FSM <= 10'd0;
			  end
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	  
			//NORMAL WALKING
			  if ((L || R) && (~U)) begin
						if(WALK_COUNT == 32'hFFFFFFFF) begin
							WALK_COUNT <= 0;
						end else begin
							WALK_COUNT <= WALK_COUNT + 1;			// Basically creates the images for regular walking Kirby
						end
						if((WALK_COUNT%(8) == 0) && (WALK_COUNT !== 0)) begin
							if(REGWALK_FSM == 10'd8) begin
								REGWALK_FSM <= 10'd1;
							end else begin 
								REGWALK_FSM <= REGWALK_FSM + 10'd1;
							end
						end			
			  end else begin
					WALK_COUNT <= 0;
					REGWALK_FSM <= 10'd0;
			  end 
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	  
			//ATTACK
				if(A) begin
					if(ATK_COUNT == 32'hFFFFFFFF) begin
						ATK_COUNT <= 0;
					end else begin
						ATK_COUNT <= ATK_COUNT + 1;
					end
					if((ATK_COUNT%(8) == 0) && (ATK_COUNT !== 0)) begin
						if(KATKFSM == 10'd8) begin
							KATKFSM <= 10'd1;
						end else begin
							KATKFSM <= KATKFSM + 10'd1;
						end
					end
				end else begin
					ATK_COUNT <= 0;
					KATKFSM <= 10'd0;
				end
			  
			  
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//STAYING STILL KIRBY
			  if (keycode == 32'd0) begin		
						if(STILL_COUNT == 32'hFFFFFFFF) begin
							STILL_COUNT <= 0;
						end else begin
							STILL_COUNT <= STILL_COUNT + 1;			// Basically creates the images for regular walking Kirby
						end
						if((STILL_COUNT%(8) == 0) && (STILL_COUNT !== 0)) begin
							if(STILL_FSM == 10'd8) begin
								STILL_FSM <= 10'd1;
							end else begin 
								STILL_FSM <= STILL_FSM + 10'd1;
							end
						end			
			  end else begin
					STILL_COUNT <= 0;
					STILL_FSM <= 10'd0;
			  end 



		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			  if(rcounter <= 2) begin
					  if(rotate <= 512) begin
							rotate <= rotate + 1;
					  end else begin
							rotate <= 0;
					  end
					  rcounter <= rcounter + 1;
			  end else begin
						rcounter <= 0;
			  end
			  
			 
			  

			  
			  
			  case (healthstate)
					healthidle: begin   //d0
						hurtflag <= 0;
						if(SPIKE ) begin
							health <= health - 1;
							healthstate <= 1;
						end
						healthstate <= healthwait;
					end
					
					healthwait: begin    //d1
						hurtflag <= 1;
						if(hurtcounter <= 30) begin
							hurtcounter <= hurtcounter + 1;
							healthstate <= healthwait;
						end else begin
							hurtcounter <= 0;
							healthstate <= healthidle;
						end				
					end 
			  endcase
			  
			  
			  
			  
			  case (bstate) 
					6'd0: begin				//lets make it start offscreen to the bottom to avoid potential glitch hits. 
						boss_X_Pos <= 16'd280;
						boss_Y_Pos <= 16'd600;
						f0_X_Pos <= 16'd280;
						f0_Y_Pos <= 16'd600;
						f1_X_Pos <= 16'd280;
						f1_Y_Pos <= 16'd600;
						f2_X_Pos <= 16'd280;
						f2_Y_Pos <= 16'd600;
						
						if(is_kirby) begin
							bstate <= bstate + 1;
						end
					end
					
					6'd1: begin				//initial starting of the boss level ~still state
						boss_X_Pos <= 16'd280;
						boss_Y_Pos <= 16'd180;
						if(bcounter <= 150) begin
							bcounter <= bcounter + 1;
							if((bcounter%(8) == 0) && (bcounter !== 0)) begin
								if(bstill_FSM == 10'd8) begin
									bstill_FSM <= '1;
								end else begin
									bstill_FSM <= bstill_FSM + 1;
								end
							end
						bstate <= 6'd1;
						end else begin
							bstill_FSM <= 0;
							bcounter <= 16'd0;
							bstate <= bstate + 1;
						end
					end
					
					6'd2: begin		//move from mid to left
						bLorR <= 0;    //left
						if(bcounter <= 110) begin  
							boss_X_Pos <= boss_X_Pos + (~(10'd2) + 1);
							bcounter <= bcounter + 1;
							if((bcounter%(8) == 0) && (bcounter !== 0)) begin
								if(bstill_FSM == 10'd8) begin
									bstill_FSM <= '1;
								end else begin
									bstill_FSM <= bstill_FSM + 1;
								end
							end
						bstate <= 6'd2;
						end else begin
							bstill_FSM <= 0;
							bcounter <= 16'd0;
							bstate <= bstate + 1;
						end
					end
					
					6'd3: begin  //move for left to right
						bLorR <= 1; //right
						if(bcounter <= 220) begin  
							boss_X_Pos <= boss_X_Pos + 2;
							bcounter <= bcounter + 1;
							if((bcounter%(8) == 0) && (bcounter !== 0)) begin
								if(bstill_FSM == 10'd8) begin
									bstill_FSM <= '1;
								end else begin
									bstill_FSM <= bstill_FSM + 1;
								end
							end
						bstate <= 6'd3;
						end else begin
							bstill_FSM <= 0;
							bcounter <= 16'd0;
							bstate <= bstate + 1;
						end
					end
					
					6'd4: begin //move right to mid
						bLorR <= 0;    //left
						if(bcounter <= 110) begin  
							boss_X_Pos <= boss_X_Pos + (~(10'd2) + 1);
							bcounter <= bcounter + 1;
							if((bcounter%(8) == 0) && (bcounter !== 0)) begin
								if(bstill_FSM == 10'd8) begin
									bstill_FSM <= '1;
								end else begin
									bstill_FSM <= bstill_FSM + 1;
								end
							end
						bstate <= 6'd4;
						end else begin
							bstill_FSM <= 0;
							bcounter <= 16'd0;
							bstate <=  bstate + 1;
						end
					end
					
					6'd5: begin  //following Kirby
						if(bcounter <= 450) begin
							bcounter <= bcounter + 1;
							if((bcounter%(8) == 0) && (bcounter !== 0)) begin
								if(bswoop_FSM == 10'd8) begin
									bswoop_FSM <= '1;
								end else begin
									bswoop_FSM <= bswoop_FSM + 1;
								end
							end
							if(boss_X_Pos > Kirby_X_Pos) begin
								bLorR <= 0;
								boss_X_Pos <= boss_X_Pos - 1;
							end else if(boss_X_Pos == Kirby_X_Pos) begin 
								boss_X_Pos <= boss_X_Pos + 0;
							end else begin
								bLorR <= 1;
								boss_X_Pos <= boss_X_Pos + 1;
							end
							
							if(boss_Y_Pos > Kirby_Y_Pos) begin
								boss_Y_Pos <= boss_Y_Pos - 1;
							end else if(boss_Y_Pos == Kirby_Y_Pos) begin 
								boss_Y_Pos <= boss_Y_Pos + 0;
							end else begin
								boss_Y_Pos <= boss_Y_Pos + 1;
							end
						bstate <= 6'd5;
						end else begin
							bswoop_FSM <= 0;
							bcounter <= 16'd0;
							bstate <= bstate + 1;
						end
					end
					
					
					6'd6: begin  //return to the middle
							if(boss_X_Pos > 16'd280) begin
								boss_X_Pos <= boss_X_Pos - 1;
							end else if(boss_X_Pos == 16'd280) begin 
								boss_X_Pos <= boss_X_Pos + 0;
							end else begin
								boss_X_Pos <= boss_X_Pos + 1;
							end
							
							if(boss_Y_Pos > 16'd180) begin
								boss_Y_Pos <= boss_Y_Pos - 1;
							end else if(boss_Y_Pos == 16'd180) begin 
								boss_Y_Pos <= boss_Y_Pos + 0;
							end else begin
								boss_Y_Pos <= boss_Y_Pos + 1;
							end
							
							bcounter <= bcounter + 1;
							if((bcounter%(8) == 0) && (bcounter !== 0)) begin
								if(bstill_FSM == 10'd8) begin
									bstill_FSM <= '1;
								end else begin
									bstill_FSM <= bstill_FSM + 1;
								end
							end
							
							if((boss_Y_Pos == 16'd180) && (boss_X_Pos == 16'd280)) begin
								bstill_FSM <= 0;
								bstate <= bstate + 1;
								bcounter <= 0;
							end
					end
					
					6'd7: begin   //start animation sequence for the fireballs 
						f0_X_Pos <= 16'd280;
						f0_Y_Pos <= 16'd180;
						f1_X_Pos <= 16'd280;
						f1_Y_Pos <= 16'd180;
						f2_X_Pos <= 16'd280;
						f2_Y_Pos <= 16'd180;
						if(bcounter <= 100) begin
							bcounter <= bcounter + 1;
							if((bcounter%(8) == 0) && (bcounter !== 0)) begin
								if(bmid_FSM == 10'd8) begin
										bmid_FSM <= '1;
									end else begin
										bmid_FSM <= bmid_FSM + 1;
									end
							end
						end else begin
							bmid_FSM <= 0;
							bcounter <= 0;
							bstate <= bstate + 1;
						end
					end
					
					6'd8: begin

						if(bcounter <= 400) begin
							bcounter <= bcounter + 1;
							if((bcounter%(8) == 0) && (bcounter !== 0)) begin
									if(bfire_FSM == 10'd8) begin
										bfire_FSM <= '1;
									end else begin
										bfire_FSM <= bfire_FSM + 1;
									end
							end
							if((bcounter%(12) == 0) && (bcounter !== 0)) begin
								if(bbcounter >= 4) begin
									bbcounter <= 1;
								end else begin
									bbcounter <= bbcounter + 1;
								end
							end
							if (bbcounter == 1) begin
								f0_X_Pos <= f0_X_Pos + 7;
								f0_Y_Pos <= f0_Y_Pos + 7;
								f1_X_Pos <= f1_X_Pos - 7;
								f1_Y_Pos <= f1_Y_Pos - 7;
								f2_X_Pos <= f2_X_Pos + 7;
								f2_Y_Pos <= f2_Y_Pos - 7;
							end else if (bbcounter == 2) begin
								f0_X_Pos <= f0_X_Pos + 7;
								f0_Y_Pos <= f0_Y_Pos + 0;
								f1_X_Pos <= f1_X_Pos - 0;
								f1_Y_Pos <= f1_Y_Pos - 7;
								f2_X_Pos <= f2_X_Pos - 7;
								f2_Y_Pos <= f2_Y_Pos + 7;
							end else if (bbcounter == 3) begin
								f0_X_Pos <= f0_X_Pos + 0;
								f0_Y_Pos <= f0_Y_Pos + 7;
								f1_X_Pos <= f1_X_Pos - 0;
								f1_Y_Pos <= f1_Y_Pos - 7;
								f2_X_Pos <= f2_X_Pos + 7;
								f2_Y_Pos <= f2_Y_Pos - 7;
							end else if (bbcounter == 4) begin
								f0_X_Pos <= f0_X_Pos + 7;
								f0_Y_Pos <= f0_Y_Pos - 7;
								f1_X_Pos <= f1_X_Pos - 7;
								f1_Y_Pos <= f1_Y_Pos + 7;
								f2_X_Pos <= f2_X_Pos + 7;
								f2_Y_Pos <= f2_Y_Pos - 0;
							end
							
							
							if((f0_X_Pos <= 10) || (f0_X_Pos >= 16'd640) || (f0_Y_Pos == 0) || (f0_Y_Pos == 16'd479)) begin
									f0_X_Pos <= 16'd280;
									f0_Y_Pos <= 16'd180;
							end
							
							if((f1_X_Pos <= 10) || (f1_X_Pos >= 16'd640) || (f1_Y_Pos == 0) || (f1_Y_Pos == 16'd479)) begin
									f1_X_Pos <= 16'd280;
									f1_Y_Pos <= 16'd180;
							end
							
							if((f2_X_Pos <= 10) || (f2_X_Pos >= 16'd640) || (f2_Y_Pos == 0) || (f2_Y_Pos == 16'd479)) begin
									f2_X_Pos <= 16'd280;
									f2_Y_Pos <= 16'd180;
							end
							
							
						end else begin
							f0_X_Pos <= 16'd280;
							f0_Y_Pos <= 16'd600;
							f1_X_Pos <= 16'd280;
							f1_Y_Pos <= 16'd600;
							f2_X_Pos <= 16'd280;
							f2_Y_Pos <= 16'd600;
							bfire_FSM <= 0;
							bbcounter <= 16'd0;
							bcounter <= 16'd0;
							bstate <= 6'd1;
						end
					end 
					
					
					
			  endcase
			  
			  
			  
			  
			  
			  case (waddle0state)
					waddle0walkright: begin 
						if(waddle0attacked) begin
							waddle0_right_count <= 0;
							waddle0_right_FSM <= 0;
							waddle0state <= waddle0hit;
						end
						waddle0_LorR <= 1'b1;
						waddle0_X_Pos <= waddle0_X_Pos + 1 + move_x;
						if(waddle0_right_count <= 150) begin
							waddle0_right_count <= waddle0_right_count + 1;
							if((waddle0_right_count%(8) == 0) && (waddle0_right_count !== 0)) begin
								if(waddle0_FSM == 10'd8) begin
									waddle0_FSM <= 10'd1;
								end else begin 
									waddle0_FSM <=  waddle0_FSM + 10'd1;
								end
							end	
							waddle0state <= waddle0walkright;
						end else begin
							waddle0_FSM <= 0;
							waddle0_right_count <= 0;
							waddle0state <= waddle0walkleft;
						end
					end
					
					
					waddle0walkleft: begin
						if(waddle0attacked) begin
							waddle0_left_count <= 0;
							waddle0_left_FSM <= 0;
							waddle0state <= waddle0hit;
						end
						waddle0_LorR <= 1'b0;
						waddle0_X_Pos <= waddle0_X_Pos - 1 + move_x;
						if(waddle0_left_count <= 150) begin
							waddle0_left_count <= waddle0_left_count + 1;
							if((waddle0_left_count%(8) == 0) && (waddle0_left_count !== 0)) begin
								if(waddle0_FSM == 10'd8) begin
									waddle0_FSM <= 10'd1;
								end else begin 
									waddle0_FSM <=  waddle0_FSM + 10'd1;
								end
							end	
							waddle0state <= waddle0walkleft;
						end else begin
							waddle0_FSM <= 0;
							waddle0_left_count <= 0;
							waddle0state <= waddle0walkright;
						end
					end
	
					waddle0hit: begin
						if(waddle0_hit_count <= 75) begin
							waddle0_hit_count <= waddle0_hit_count + 1;
							waddle0state <= waddle0hit;
						end else begin
							waddle0_hit_count <= 0;
							waddle0state <= waddle0dead;
						end
					end
					
					
					waddle0dead: begin
						waddle0_X_Pos <= 16'd135;
						waddle0_Y_Pos <= 16'd616;
						if(Reset) begin
							waddle0_X_Pos <= 16'd135;
							waddle0_Y_Pos <= 16'd416;
							waddle0state <= waddle0walkright;
						end
					end
			  endcase
			  
			  
			  
			  
			  
			  if ( (keycode[7:0] == 8'h04) || (keycode[15:8] == 8'h04)) begin  // if LEFT was pressed, mark L
						LorR <= 0;
			  end else if ( (keycode[7:0] == 8'h07) || (keycode[15:8] == 8'h07) ) begin //if RIGHT was pressed, mark R
						LorR <= 1; 
			  end
				
				
			  if ( U ) begin  //occurs when you only press UP
					if( (Kirby_Y_Pos <= Kirby_Y_Min) || (NO_UP) )
						Kirby_Y_Pos <= Kirby_Y_Pos + 0;
					else begin
						Kirby_Y_Pos <= Kirby_Y_Pos + (~(Kirby_Y_Step) + 1);
					end
			  end else if ( D) begin  //occurs when you only press DOWN
					if( (Kirby_Y_Pos + 32 >= Kirby_Y_Max) || (NO_DOWN)  )
						Kirby_Y_Pos <= Kirby_Y_Pos + 0;
					else 
						Kirby_Y_Pos <= Kirby_Y_Pos + (Kirby_Y_Step << 1) ;
			  end else begin
					if( (Kirby_Y_Pos + 32 >= Kirby_Y_Max) || (NO_DOWN)  ) //the default "gravity" should pull Kirby down
						Kirby_Y_Pos <= Kirby_Y_Pos + 0;
					else 
						Kirby_Y_Pos <= Kirby_Y_Pos + Kirby_Y_Step;
			  end
			  

			  
			  case (atkstate)
					8'd0: begin
						atk_X_Pos <= Kirby_X_Pos;
						atk_Y_Pos <= Kirby_Y_Pos;
						atkFSM <= 0;
						if(A) begin
							atk_enable <= 1;
							if(LorR)   begin//if kirby faces rightwards
								atkstate <= atkstate + 1;
							end else begin
								atkstate <= atkstate + 2;
							end
						end
					end
					
					
					8'd1: begin		//throw towards the right (A)
						atk_enable <= 1;
						if(atk_X_Pos < 16'd660) begin
							atk_X_Pos <= atk_X_Pos + 16'd4;
							if(atkcount <= 10'hFF) begin
								atkcount <= atkcount + 1;
							end else begin
								atkcount <= 1;
							end
							if((atkcount%(5) == 0) && (atkcount !== 0)) begin
								if(atkFSM == 10'd5) begin
									atkFSM <= 10'd1;
								end else begin
									atkFSM <= atkFSM + 10'd1;
								end
							end
						atkstate <= 8'd1;
						end else begin
							atkcount <= 0;
							atkFSM <= 0;
							atk_X_Pos <= atk_X_Pos + 0;
							atkstate <= atkstate + 2;
						end
					end
					
					
					8'd2: begin   //throw towards the left (B)
						atk_enable <= 1;
						if((atk_X_Pos >= 16'd5) && (atk_X_Pos < 16'd649)) begin
							atk_X_Pos <= atk_X_Pos + (~(16'd4) + 1);
							if(atkcount <= 10'hFF) begin
								atkcount <= atkcount + 1;
							end else begin
								atkcount <= 1;
							end
							if((atkcount%(5) == 0) && (atkcount !== 0)) begin
								if(atkFSM == 10'd5) begin
									atkFSM <= 10'd1;
								end else begin
									atkFSM <= atkFSM + 10'd1;
								end
							end
						end else begin
							atkcount <= 0;
							atkFSM <= 0;
							atk_X_Pos <= atk_X_Pos + 0;
							atkstate <= atkstate + 1;
						end
					end
					
					
					8'd3: begin 	
						atk_enable <= 0;
						atkstate <= 8'd0;
					end
					
			  endcase
			  
			  
			  
			  
			  if ( L ) begin  //occurs when you only press LEFT
					if((Kirby_X_Pos <= xmin_line) && (ref_x >= 10'd500) && (is_block)) begin
						Kirby_X_Pos <= Kirby_X_Pos + 0;
						ref_x <= ref_x - 1;
						move_x <= Kirby_X_Step;
						
						block0_X_Pos = block0_X_Pos + Kirby_X_Step;
						block1_X_Pos = block1_X_Pos + Kirby_X_Step;
						block2_X_Pos = block2_X_Pos + Kirby_X_Step;
						block3_X_Pos = block3_X_Pos + Kirby_X_Step;
						block4_X_Pos = block4_X_Pos + Kirby_X_Step;
						block5_X_Pos = block5_X_Pos + Kirby_X_Step;
						block6_X_Pos = block6_X_Pos + Kirby_X_Step;
						block7_X_Pos = block7_X_Pos + Kirby_X_Step;
						block8_X_Pos = block8_X_Pos + Kirby_X_Step;
						block9_X_Pos = block9_X_Pos + Kirby_X_Step;
						block10_X_Pos = block10_X_Pos + Kirby_X_Step;
						block11_X_Pos = block11_X_Pos + Kirby_X_Step;
						block12_X_Pos = block12_X_Pos + Kirby_X_Step;
						block13_X_Pos = block13_X_Pos + Kirby_X_Step;
						block14_X_Pos = block14_X_Pos + Kirby_X_Step;
						block15_X_Pos = block15_X_Pos + Kirby_X_Step;
						block16_X_Pos = block16_X_Pos + Kirby_X_Step;
						block17_X_Pos = block17_X_Pos + Kirby_X_Step;
						block18_X_Pos = block18_X_Pos + Kirby_X_Step;
						block19_X_Pos = block19_X_Pos + Kirby_X_Step;
						block20_X_Pos = block20_X_Pos + Kirby_X_Step;
						block21_X_Pos = block21_X_Pos + Kirby_X_Step;
						block22_X_Pos = block22_X_Pos + Kirby_X_Step;
						block23_X_Pos = block23_X_Pos + Kirby_X_Step;
						block24_X_Pos = block24_X_Pos + Kirby_X_Step;
						block25_X_Pos = block25_X_Pos + Kirby_X_Step;
						block26_X_Pos = block26_X_Pos + Kirby_X_Step;
						block27_X_Pos = block27_X_Pos + Kirby_X_Step;
						block28_X_Pos = block28_X_Pos + Kirby_X_Step;
						block29_X_Pos = block29_X_Pos + Kirby_X_Step;
						block30_X_Pos = block30_X_Pos + Kirby_X_Step;
						block31_X_Pos = block31_X_Pos + Kirby_X_Step;
						block32_X_Pos = block32_X_Pos + Kirby_X_Step;
						block33_X_Pos = block33_X_Pos + Kirby_X_Step;
						block34_X_Pos = block34_X_Pos + Kirby_X_Step;
						block35_X_Pos = block35_X_Pos + Kirby_X_Step;
						block36_X_Pos = block36_X_Pos + Kirby_X_Step;
						block37_X_Pos = block37_X_Pos + Kirby_X_Step;
						block38_X_Pos = block38_X_Pos + Kirby_X_Step;
						block39_X_Pos = block39_X_Pos + Kirby_X_Step;
						block40_X_Pos = block40_X_Pos + Kirby_X_Step;
						block41_X_Pos = block41_X_Pos + Kirby_X_Step;
						block42_X_Pos = block42_X_Pos + Kirby_X_Step;
						block43_X_Pos = block43_X_Pos + Kirby_X_Step;
						block44_X_Pos = block44_X_Pos + Kirby_X_Step;
						block45_X_Pos = block45_X_Pos + Kirby_X_Step;
						block46_X_Pos = block46_X_Pos + Kirby_X_Step;
						block47_X_Pos = block47_X_Pos + Kirby_X_Step;
						block48_X_Pos = block48_X_Pos + Kirby_X_Step;
						block49_X_Pos = block49_X_Pos + Kirby_X_Step;
						block50_X_Pos = block50_X_Pos + Kirby_X_Step;
						block51_X_Pos = block51_X_Pos + Kirby_X_Step;
						block52_X_Pos = block52_X_Pos + Kirby_X_Step;
						block53_X_Pos = block53_X_Pos + Kirby_X_Step;
						block54_X_Pos = block54_X_Pos + Kirby_X_Step;
						block55_X_Pos = block55_X_Pos + Kirby_X_Step;
						block56_X_Pos = block56_X_Pos + Kirby_X_Step;
						block57_X_Pos = block57_X_Pos + Kirby_X_Step;
						block58_X_Pos = block58_X_Pos + Kirby_X_Step;
						block59_X_Pos = block59_X_Pos + Kirby_X_Step;
						block60_X_Pos = block60_X_Pos + Kirby_X_Step;
						block61_X_Pos = block61_X_Pos + Kirby_X_Step;
						block62_X_Pos = block62_X_Pos + Kirby_X_Step;
						block63_X_Pos = block63_X_Pos + Kirby_X_Step;
						block64_X_Pos = block64_X_Pos + Kirby_X_Step;
						block65_X_Pos = block65_X_Pos + Kirby_X_Step;
						block66_X_Pos = block66_X_Pos + Kirby_X_Step;
						block67_X_Pos = block67_X_Pos + Kirby_X_Step;
						block68_X_Pos = block68_X_Pos + Kirby_X_Step;
						block69_X_Pos = block69_X_Pos + Kirby_X_Step;
						block70_X_Pos = block70_X_Pos + Kirby_X_Step;
						block71_X_Pos = block71_X_Pos + Kirby_X_Step;
						block72_X_Pos = block72_X_Pos + Kirby_X_Step;
						block73_X_Pos = block73_X_Pos + Kirby_X_Step;
						block74_X_Pos = block74_X_Pos + Kirby_X_Step;
						block75_X_Pos = block75_X_Pos + Kirby_X_Step;
						block76_X_Pos = block76_X_Pos + Kirby_X_Step;
						block77_X_Pos = block77_X_Pos + Kirby_X_Step;
						block78_X_Pos = block78_X_Pos + Kirby_X_Step;
						block79_X_Pos = block79_X_Pos + Kirby_X_Step;
						block80_X_Pos = block80_X_Pos + Kirby_X_Step;
						block81_X_Pos = block81_X_Pos + Kirby_X_Step;
						block82_X_Pos = block82_X_Pos + Kirby_X_Step;
						block83_X_Pos = block83_X_Pos + Kirby_X_Step;
						block84_X_Pos = block84_X_Pos + Kirby_X_Step;
						block85_X_Pos = block85_X_Pos + Kirby_X_Step;
						block86_X_Pos = block86_X_Pos + Kirby_X_Step;
						block87_X_Pos = block87_X_Pos + Kirby_X_Step;
						block88_X_Pos = block88_X_Pos + Kirby_X_Step;
						block89_X_Pos = block89_X_Pos + Kirby_X_Step;
						block90_X_Pos = block90_X_Pos + Kirby_X_Step;
						block91_X_Pos = block91_X_Pos + Kirby_X_Step;
						block92_X_Pos = block92_X_Pos + Kirby_X_Step;
						block93_X_Pos = block93_X_Pos + Kirby_X_Step;
						block94_X_Pos = block94_X_Pos + Kirby_X_Step;
						block95_X_Pos = block95_X_Pos + Kirby_X_Step;
						block96_X_Pos = block96_X_Pos + Kirby_X_Step;
						block97_X_Pos = block97_X_Pos + Kirby_X_Step;
						block98_X_Pos = block98_X_Pos + Kirby_X_Step;
						block99_X_Pos = block99_X_Pos + Kirby_X_Step;
						block100_X_Pos = block100_X_Pos + Kirby_X_Step;
						block101_X_Pos = block101_X_Pos + Kirby_X_Step;
						block102_X_Pos = block102_X_Pos + Kirby_X_Step;
						block103_X_Pos = block103_X_Pos + Kirby_X_Step;
						block104_X_Pos = block104_X_Pos + Kirby_X_Step;
						block105_X_Pos = block105_X_Pos + Kirby_X_Step;
						block106_X_Pos = block106_X_Pos + Kirby_X_Step;
						block107_X_Pos = block107_X_Pos + Kirby_X_Step;
						block108_X_Pos = block108_X_Pos + Kirby_X_Step;
						block109_X_Pos = block109_X_Pos + Kirby_X_Step;
						block110_X_Pos = block110_X_Pos + Kirby_X_Step;
						block111_X_Pos = block111_X_Pos + Kirby_X_Step;
						block112_X_Pos = block112_X_Pos + Kirby_X_Step;
						block113_X_Pos = block113_X_Pos + Kirby_X_Step;
						block114_X_Pos = block114_X_Pos + Kirby_X_Step;
						block115_X_Pos = block115_X_Pos + Kirby_X_Step;
						block116_X_Pos = block116_X_Pos + Kirby_X_Step;
						block117_X_Pos = block117_X_Pos + Kirby_X_Step;
						block118_X_Pos = block118_X_Pos + Kirby_X_Step;
						block119_X_Pos = block119_X_Pos + Kirby_X_Step;
						block120_X_Pos = block120_X_Pos + Kirby_X_Step;
						block121_X_Pos = block121_X_Pos + Kirby_X_Step;
						block122_X_Pos = block122_X_Pos + Kirby_X_Step;
						block123_X_Pos = block123_X_Pos + Kirby_X_Step;
						block124_X_Pos = block124_X_Pos + Kirby_X_Step;
						block125_X_Pos = block125_X_Pos + Kirby_X_Step;
						block126_X_Pos = block126_X_Pos + Kirby_X_Step;
						block127_X_Pos = block127_X_Pos + Kirby_X_Step;
						block128_X_Pos = block128_X_Pos + Kirby_X_Step;
						block129_X_Pos = block129_X_Pos + Kirby_X_Step;
						block130_X_Pos = block130_X_Pos + Kirby_X_Step;
						block131_X_Pos = block131_X_Pos + Kirby_X_Step;
						block132_X_Pos = block132_X_Pos + Kirby_X_Step;
						block133_X_Pos = block133_X_Pos + Kirby_X_Step;
						block134_X_Pos = block134_X_Pos + Kirby_X_Step;
						block135_X_Pos = block135_X_Pos + Kirby_X_Step;
						block136_X_Pos = block136_X_Pos + Kirby_X_Step;
						block137_X_Pos = block137_X_Pos + Kirby_X_Step;
						block138_X_Pos = block138_X_Pos + Kirby_X_Step;
						block139_X_Pos = block139_X_Pos + Kirby_X_Step;
						block140_X_Pos = block140_X_Pos + Kirby_X_Step;
						block141_X_Pos = block141_X_Pos + Kirby_X_Step;
						block142_X_Pos = block142_X_Pos + Kirby_X_Step;
						block143_X_Pos = block143_X_Pos + Kirby_X_Step;
						block144_X_Pos = block144_X_Pos + Kirby_X_Step;
						block145_X_Pos = block145_X_Pos + Kirby_X_Step;
						block146_X_Pos = block146_X_Pos + Kirby_X_Step;
						block147_X_Pos = block147_X_Pos + Kirby_X_Step;
						block148_X_Pos = block148_X_Pos + Kirby_X_Step;
						block149_X_Pos = block149_X_Pos + Kirby_X_Step;
						block150_X_Pos = block150_X_Pos + Kirby_X_Step;
						block151_X_Pos = block151_X_Pos + Kirby_X_Step;
						block152_X_Pos = block152_X_Pos + Kirby_X_Step;
						block153_X_Pos = block153_X_Pos + Kirby_X_Step;
						block154_X_Pos = block154_X_Pos + Kirby_X_Step;
						block155_X_Pos = block155_X_Pos + Kirby_X_Step;
						block156_X_Pos = block156_X_Pos + Kirby_X_Step;
						block157_X_Pos = block157_X_Pos + Kirby_X_Step;
						block158_X_Pos = block158_X_Pos + Kirby_X_Step;
						block159_X_Pos = block159_X_Pos + Kirby_X_Step;
						block160_X_Pos = block160_X_Pos + Kirby_X_Step;
						block161_X_Pos = block161_X_Pos + Kirby_X_Step;
						block162_X_Pos = block162_X_Pos + Kirby_X_Step;
						block163_X_Pos = block163_X_Pos + Kirby_X_Step;
						block164_X_Pos = block164_X_Pos + Kirby_X_Step;
						block165_X_Pos = block165_X_Pos + Kirby_X_Step;
						block166_X_Pos = block166_X_Pos + Kirby_X_Step;
						block167_X_Pos = block167_X_Pos + Kirby_X_Step;
						block168_X_Pos = block168_X_Pos + Kirby_X_Step;
						block169_X_Pos = block169_X_Pos + Kirby_X_Step;
						block170_X_Pos = block170_X_Pos + Kirby_X_Step;
						block171_X_Pos = block171_X_Pos + Kirby_X_Step;
						block172_X_Pos = block172_X_Pos + Kirby_X_Step;
						block173_X_Pos = block173_X_Pos + Kirby_X_Step;
						block174_X_Pos = block174_X_Pos + Kirby_X_Step;
						block175_X_Pos = block175_X_Pos + Kirby_X_Step;
						block176_X_Pos = block176_X_Pos + Kirby_X_Step;
						block177_X_Pos = block177_X_Pos + Kirby_X_Step;
						block178_X_Pos = block178_X_Pos + Kirby_X_Step;
						block179_X_Pos = block179_X_Pos + Kirby_X_Step;
						block180_X_Pos = block180_X_Pos + Kirby_X_Step;
						block181_X_Pos = block181_X_Pos + Kirby_X_Step;
						block182_X_Pos = block182_X_Pos + Kirby_X_Step;
						block183_X_Pos = block183_X_Pos + Kirby_X_Step;
						block184_X_Pos = block184_X_Pos + Kirby_X_Step;
						block185_X_Pos = block185_X_Pos + Kirby_X_Step;
						block186_X_Pos = block186_X_Pos + Kirby_X_Step;
						block187_X_Pos = block187_X_Pos + Kirby_X_Step;
						block188_X_Pos = block188_X_Pos + Kirby_X_Step;
						block189_X_Pos = block189_X_Pos + Kirby_X_Step;
						block190_X_Pos = block190_X_Pos + Kirby_X_Step;
						block191_X_Pos = block191_X_Pos + Kirby_X_Step;
						block192_X_Pos = block192_X_Pos + Kirby_X_Step;
						block193_X_Pos = block193_X_Pos + Kirby_X_Step;
						block194_X_Pos = block194_X_Pos + Kirby_X_Step;
						block195_X_Pos = block195_X_Pos + Kirby_X_Step;
						block196_X_Pos = block196_X_Pos + Kirby_X_Step;
						block197_X_Pos = block197_X_Pos + Kirby_X_Step;
						block198_X_Pos = block198_X_Pos + Kirby_X_Step;
						block199_X_Pos = block199_X_Pos + Kirby_X_Step;
						block200_X_Pos = block200_X_Pos + Kirby_X_Step;
						
						block201_X_Pos = block201_X_Pos + Kirby_X_Step;
						block202_X_Pos = block202_X_Pos + Kirby_X_Step;
						block203_X_Pos = block203_X_Pos + Kirby_X_Step;
						block204_X_Pos = block204_X_Pos + Kirby_X_Step;
						
					end else if( (Kirby_X_Pos <= Kirby_X_Min) || (NO_LEFT)  ) begin
						Kirby_X_Pos <= Kirby_X_Pos + 0;
						move_x <= 0;
					end else begin
						Kirby_X_Pos <= Kirby_X_Pos + (~(Kirby_X_Step) + 1);
						ref_x <= ref_x + 0;
						move_x <= 0;
					end
			  end
			 else  if ( R ) begin  //occurs when you only press RIGHT
					if((Kirby_X_Pos >= xmax_line) && (ref_x <= 10'd1000) && (is_block)) begin
						Kirby_X_Pos <= Kirby_X_Pos + 0;
						ref_x <= ref_x + 1;
						move_x <= ((~Kirby_X_Step) + 1);
						
						//waddle0_X_Pos = waddle_X_Pos + ((~Kirby_X_Step) + 1);
						
						block0_X_Pos = block0_X_Pos + ((~Kirby_X_Step) + 1);
						block1_X_Pos = block1_X_Pos + ((~Kirby_X_Step) + 1);
						block2_X_Pos = block2_X_Pos + ((~Kirby_X_Step) + 1);
						block3_X_Pos = block3_X_Pos + ((~Kirby_X_Step) + 1);
						block4_X_Pos = block4_X_Pos + ((~Kirby_X_Step) + 1);
						block5_X_Pos = block5_X_Pos + ((~Kirby_X_Step) + 1);
						block6_X_Pos = block6_X_Pos + ((~Kirby_X_Step) + 1);
						block7_X_Pos = block7_X_Pos + ((~Kirby_X_Step) + 1);
						block8_X_Pos = block8_X_Pos + ((~Kirby_X_Step) + 1);
						block9_X_Pos = block9_X_Pos + ((~Kirby_X_Step) + 1);
						block10_X_Pos = block10_X_Pos + ((~Kirby_X_Step) + 1);
						block11_X_Pos = block11_X_Pos + ((~Kirby_X_Step) + 1);
						block12_X_Pos = block12_X_Pos + ((~Kirby_X_Step) + 1);
						block13_X_Pos = block13_X_Pos + ((~Kirby_X_Step) + 1);
						block14_X_Pos = block14_X_Pos + ((~Kirby_X_Step) + 1);
						block15_X_Pos = block15_X_Pos + ((~Kirby_X_Step) + 1);
						block16_X_Pos = block16_X_Pos + ((~Kirby_X_Step) + 1);
						block17_X_Pos = block17_X_Pos + ((~Kirby_X_Step) + 1);
						block18_X_Pos = block18_X_Pos + ((~Kirby_X_Step) + 1);
						block19_X_Pos = block19_X_Pos + ((~Kirby_X_Step) + 1);
						block20_X_Pos = block20_X_Pos + ((~Kirby_X_Step) + 1);
						block21_X_Pos = block21_X_Pos + ((~Kirby_X_Step) + 1);
						block22_X_Pos = block22_X_Pos + ((~Kirby_X_Step) + 1);
						block23_X_Pos = block23_X_Pos + ((~Kirby_X_Step) + 1);
						block24_X_Pos = block24_X_Pos + ((~Kirby_X_Step) + 1);
						block25_X_Pos = block25_X_Pos + ((~Kirby_X_Step) + 1);
						block26_X_Pos = block26_X_Pos + ((~Kirby_X_Step) + 1);
						block27_X_Pos = block27_X_Pos + ((~Kirby_X_Step) + 1);
						block28_X_Pos = block28_X_Pos + ((~Kirby_X_Step) + 1);
						block29_X_Pos = block29_X_Pos + ((~Kirby_X_Step) + 1);
						block30_X_Pos = block30_X_Pos + ((~Kirby_X_Step) + 1);
						block31_X_Pos = block31_X_Pos + ((~Kirby_X_Step) + 1);
						block32_X_Pos = block32_X_Pos + ((~Kirby_X_Step) + 1);
						block33_X_Pos = block33_X_Pos + ((~Kirby_X_Step) + 1);
						block34_X_Pos = block34_X_Pos + ((~Kirby_X_Step) + 1);
						block35_X_Pos = block35_X_Pos + ((~Kirby_X_Step) + 1);
						block36_X_Pos = block36_X_Pos + ((~Kirby_X_Step) + 1);
						block37_X_Pos = block37_X_Pos + ((~Kirby_X_Step) + 1);
						block38_X_Pos = block38_X_Pos + ((~Kirby_X_Step) + 1);
						block39_X_Pos = block39_X_Pos + ((~Kirby_X_Step) + 1);
						block40_X_Pos = block40_X_Pos + ((~Kirby_X_Step) + 1);
						block41_X_Pos = block41_X_Pos + ((~Kirby_X_Step) + 1);
						block42_X_Pos = block42_X_Pos + ((~Kirby_X_Step) + 1);
						block43_X_Pos = block43_X_Pos + ((~Kirby_X_Step) + 1);
						block44_X_Pos = block44_X_Pos + ((~Kirby_X_Step) + 1);
						block45_X_Pos = block45_X_Pos + ((~Kirby_X_Step) + 1);
						block46_X_Pos = block46_X_Pos + ((~Kirby_X_Step) + 1);
						block47_X_Pos = block47_X_Pos + ((~Kirby_X_Step) + 1);
						block48_X_Pos = block48_X_Pos + ((~Kirby_X_Step) + 1);
						block49_X_Pos = block49_X_Pos + ((~Kirby_X_Step) + 1);
						block50_X_Pos = block50_X_Pos + ((~Kirby_X_Step) + 1);
						block51_X_Pos = block51_X_Pos + ((~Kirby_X_Step) + 1);
						block52_X_Pos = block52_X_Pos + ((~Kirby_X_Step) + 1);
						block53_X_Pos = block53_X_Pos + ((~Kirby_X_Step) + 1);
						block54_X_Pos = block54_X_Pos + ((~Kirby_X_Step) + 1);
						block55_X_Pos = block55_X_Pos + ((~Kirby_X_Step) + 1);
						block56_X_Pos = block56_X_Pos + ((~Kirby_X_Step) + 1);
						block57_X_Pos = block57_X_Pos + ((~Kirby_X_Step) + 1);
						block58_X_Pos = block58_X_Pos + ((~Kirby_X_Step) + 1);
						block59_X_Pos = block59_X_Pos + ((~Kirby_X_Step) + 1);
						block60_X_Pos = block60_X_Pos + ((~Kirby_X_Step) + 1);
						block61_X_Pos = block61_X_Pos + ((~Kirby_X_Step) + 1);
						block62_X_Pos = block62_X_Pos + ((~Kirby_X_Step) + 1);
						block63_X_Pos = block63_X_Pos + ((~Kirby_X_Step) + 1);
						block64_X_Pos = block64_X_Pos + ((~Kirby_X_Step) + 1);
						block65_X_Pos = block65_X_Pos + ((~Kirby_X_Step) + 1);
						block66_X_Pos = block66_X_Pos + ((~Kirby_X_Step) + 1);
						block67_X_Pos = block67_X_Pos + ((~Kirby_X_Step) + 1);
						block68_X_Pos = block68_X_Pos + ((~Kirby_X_Step) + 1);
						block69_X_Pos = block69_X_Pos + ((~Kirby_X_Step) + 1);
						block70_X_Pos = block70_X_Pos + ((~Kirby_X_Step) + 1);
						block71_X_Pos = block71_X_Pos + ((~Kirby_X_Step) + 1);
						block72_X_Pos = block72_X_Pos + ((~Kirby_X_Step) + 1);
						block73_X_Pos = block73_X_Pos + ((~Kirby_X_Step) + 1);
						block74_X_Pos = block74_X_Pos + ((~Kirby_X_Step) + 1);
						block75_X_Pos = block75_X_Pos + ((~Kirby_X_Step) + 1);
						block76_X_Pos = block76_X_Pos + ((~Kirby_X_Step) + 1);
						block77_X_Pos = block77_X_Pos + ((~Kirby_X_Step) + 1);
						block78_X_Pos = block78_X_Pos + ((~Kirby_X_Step) + 1);
						block79_X_Pos = block79_X_Pos + ((~Kirby_X_Step) + 1);
						block80_X_Pos = block80_X_Pos + ((~Kirby_X_Step) + 1);
						block81_X_Pos = block81_X_Pos + ((~Kirby_X_Step) + 1);
						block82_X_Pos = block82_X_Pos + ((~Kirby_X_Step) + 1);
						block83_X_Pos = block83_X_Pos + ((~Kirby_X_Step) + 1);
						block84_X_Pos = block84_X_Pos + ((~Kirby_X_Step) + 1);
						block85_X_Pos = block85_X_Pos + ((~Kirby_X_Step) + 1);
						block86_X_Pos = block86_X_Pos + ((~Kirby_X_Step) + 1);
						block87_X_Pos = block87_X_Pos + ((~Kirby_X_Step) + 1);
						block88_X_Pos = block88_X_Pos + ((~Kirby_X_Step) + 1);
						block89_X_Pos = block89_X_Pos + ((~Kirby_X_Step) + 1);
						block90_X_Pos = block90_X_Pos + ((~Kirby_X_Step) + 1);
						block91_X_Pos = block91_X_Pos + ((~Kirby_X_Step) + 1);
						block92_X_Pos = block92_X_Pos + ((~Kirby_X_Step) + 1);
						block93_X_Pos = block93_X_Pos + ((~Kirby_X_Step) + 1);
						block94_X_Pos = block94_X_Pos + ((~Kirby_X_Step) + 1);
						block95_X_Pos = block95_X_Pos + ((~Kirby_X_Step) + 1);
						block96_X_Pos = block96_X_Pos + ((~Kirby_X_Step) + 1);
						block97_X_Pos = block97_X_Pos + ((~Kirby_X_Step) + 1);
						block98_X_Pos = block98_X_Pos + ((~Kirby_X_Step) + 1);
						block99_X_Pos = block99_X_Pos + ((~Kirby_X_Step) + 1);
						block100_X_Pos = block100_X_Pos + ((~Kirby_X_Step) + 1);
						block101_X_Pos = block101_X_Pos + ((~Kirby_X_Step) + 1);
						block102_X_Pos = block102_X_Pos + ((~Kirby_X_Step) + 1);
						block103_X_Pos = block103_X_Pos + ((~Kirby_X_Step) + 1);
						block104_X_Pos = block104_X_Pos + ((~Kirby_X_Step) + 1);
						block105_X_Pos = block105_X_Pos + ((~Kirby_X_Step) + 1);
						block106_X_Pos = block106_X_Pos + ((~Kirby_X_Step) + 1);
						block107_X_Pos = block107_X_Pos + ((~Kirby_X_Step) + 1);
						block108_X_Pos = block108_X_Pos + ((~Kirby_X_Step) + 1);
						block109_X_Pos = block109_X_Pos + ((~Kirby_X_Step) + 1);
						block110_X_Pos = block110_X_Pos + ((~Kirby_X_Step) + 1);
						block111_X_Pos = block111_X_Pos + ((~Kirby_X_Step) + 1);
						block112_X_Pos = block112_X_Pos + ((~Kirby_X_Step) + 1);
						block113_X_Pos = block113_X_Pos + ((~Kirby_X_Step) + 1);
						block114_X_Pos = block114_X_Pos + ((~Kirby_X_Step) + 1);
						block115_X_Pos = block115_X_Pos + ((~Kirby_X_Step) + 1);
						block116_X_Pos = block116_X_Pos + ((~Kirby_X_Step) + 1);
						block117_X_Pos = block117_X_Pos + ((~Kirby_X_Step) + 1);
						block118_X_Pos = block118_X_Pos + ((~Kirby_X_Step) + 1);
						block119_X_Pos = block119_X_Pos + ((~Kirby_X_Step) + 1);
						block120_X_Pos = block120_X_Pos + ((~Kirby_X_Step) + 1);
						block121_X_Pos = block121_X_Pos + ((~Kirby_X_Step) + 1);
						block122_X_Pos = block122_X_Pos + ((~Kirby_X_Step) + 1);
						block123_X_Pos = block123_X_Pos + ((~Kirby_X_Step) + 1);
						block124_X_Pos = block124_X_Pos + ((~Kirby_X_Step) + 1);
						block125_X_Pos = block125_X_Pos + ((~Kirby_X_Step) + 1);
						block126_X_Pos = block126_X_Pos + ((~Kirby_X_Step) + 1);
						block127_X_Pos = block127_X_Pos + ((~Kirby_X_Step) + 1);
						block128_X_Pos = block128_X_Pos + ((~Kirby_X_Step) + 1);
						block129_X_Pos = block129_X_Pos + ((~Kirby_X_Step) + 1);
						block130_X_Pos = block130_X_Pos + ((~Kirby_X_Step) + 1);
						block131_X_Pos = block131_X_Pos + ((~Kirby_X_Step) + 1);
						block132_X_Pos = block132_X_Pos + ((~Kirby_X_Step) + 1);
						block133_X_Pos = block133_X_Pos + ((~Kirby_X_Step) + 1);
						block134_X_Pos = block134_X_Pos + ((~Kirby_X_Step) + 1);
						block135_X_Pos = block135_X_Pos + ((~Kirby_X_Step) + 1);
						block136_X_Pos = block136_X_Pos + ((~Kirby_X_Step) + 1);
						block137_X_Pos = block137_X_Pos + ((~Kirby_X_Step) + 1);
						block138_X_Pos = block138_X_Pos + ((~Kirby_X_Step) + 1);
						block139_X_Pos = block139_X_Pos + ((~Kirby_X_Step) + 1);
						block140_X_Pos = block140_X_Pos + ((~Kirby_X_Step) + 1);
						block141_X_Pos = block141_X_Pos + ((~Kirby_X_Step) + 1);
						block142_X_Pos = block142_X_Pos + ((~Kirby_X_Step) + 1);
						block143_X_Pos = block143_X_Pos + ((~Kirby_X_Step) + 1);
						block144_X_Pos = block144_X_Pos + ((~Kirby_X_Step) + 1);
						block145_X_Pos = block145_X_Pos + ((~Kirby_X_Step) + 1);
						block146_X_Pos = block146_X_Pos + ((~Kirby_X_Step) + 1);
						block147_X_Pos = block147_X_Pos + ((~Kirby_X_Step) + 1);
						block148_X_Pos = block148_X_Pos + ((~Kirby_X_Step) + 1);
						block149_X_Pos = block149_X_Pos + ((~Kirby_X_Step) + 1);
						block150_X_Pos = block150_X_Pos + ((~Kirby_X_Step) + 1);
						block151_X_Pos = block151_X_Pos + ((~Kirby_X_Step) + 1);
						block152_X_Pos = block152_X_Pos + ((~Kirby_X_Step) + 1);
						block153_X_Pos = block153_X_Pos + ((~Kirby_X_Step) + 1);
						block154_X_Pos = block154_X_Pos + ((~Kirby_X_Step) + 1);
						block155_X_Pos = block155_X_Pos + ((~Kirby_X_Step) + 1);
						block156_X_Pos = block156_X_Pos + ((~Kirby_X_Step) + 1);
						block157_X_Pos = block157_X_Pos + ((~Kirby_X_Step) + 1);
						block158_X_Pos = block158_X_Pos + ((~Kirby_X_Step) + 1);
						block159_X_Pos = block159_X_Pos + ((~Kirby_X_Step) + 1);
						block160_X_Pos = block160_X_Pos + ((~Kirby_X_Step) + 1);
						block161_X_Pos = block161_X_Pos + ((~Kirby_X_Step) + 1);
						block162_X_Pos = block162_X_Pos + ((~Kirby_X_Step) + 1);
						block163_X_Pos = block163_X_Pos + ((~Kirby_X_Step) + 1);
						block164_X_Pos = block164_X_Pos + ((~Kirby_X_Step) + 1);
						block165_X_Pos = block165_X_Pos + ((~Kirby_X_Step) + 1);
						block166_X_Pos = block166_X_Pos + ((~Kirby_X_Step) + 1);
						block167_X_Pos = block167_X_Pos + ((~Kirby_X_Step) + 1);
						block168_X_Pos = block168_X_Pos + ((~Kirby_X_Step) + 1);
						block169_X_Pos = block169_X_Pos + ((~Kirby_X_Step) + 1);
						block170_X_Pos = block170_X_Pos + ((~Kirby_X_Step) + 1);
						block171_X_Pos = block171_X_Pos + ((~Kirby_X_Step) + 1);
						block172_X_Pos = block172_X_Pos + ((~Kirby_X_Step) + 1);
						block173_X_Pos = block173_X_Pos + ((~Kirby_X_Step) + 1);
						block174_X_Pos = block174_X_Pos + ((~Kirby_X_Step) + 1);
						block175_X_Pos = block175_X_Pos + ((~Kirby_X_Step) + 1);
						block176_X_Pos = block176_X_Pos + ((~Kirby_X_Step) + 1);
						block177_X_Pos = block177_X_Pos + ((~Kirby_X_Step) + 1);
						block178_X_Pos = block178_X_Pos + ((~Kirby_X_Step) + 1);
						block179_X_Pos = block179_X_Pos + ((~Kirby_X_Step) + 1);
						block180_X_Pos = block180_X_Pos + ((~Kirby_X_Step) + 1);
						block181_X_Pos = block181_X_Pos + ((~Kirby_X_Step) + 1);
						block182_X_Pos = block182_X_Pos + ((~Kirby_X_Step) + 1);
						block183_X_Pos = block183_X_Pos + ((~Kirby_X_Step) + 1);
						block184_X_Pos = block184_X_Pos + ((~Kirby_X_Step) + 1);
						block185_X_Pos = block185_X_Pos + ((~Kirby_X_Step) + 1);
						block186_X_Pos = block186_X_Pos + ((~Kirby_X_Step) + 1);
						block187_X_Pos = block187_X_Pos + ((~Kirby_X_Step) + 1);
						block188_X_Pos = block188_X_Pos + ((~Kirby_X_Step) + 1);
						block189_X_Pos = block189_X_Pos + ((~Kirby_X_Step) + 1);
						block190_X_Pos = block190_X_Pos + ((~Kirby_X_Step) + 1);
						block191_X_Pos = block191_X_Pos + ((~Kirby_X_Step) + 1);
						block192_X_Pos = block192_X_Pos + ((~Kirby_X_Step) + 1);
						block193_X_Pos = block193_X_Pos + ((~Kirby_X_Step) + 1);
						block194_X_Pos = block194_X_Pos + ((~Kirby_X_Step) + 1);
						block195_X_Pos = block195_X_Pos + ((~Kirby_X_Step) + 1);
						block196_X_Pos = block196_X_Pos + ((~Kirby_X_Step) + 1);
						block197_X_Pos = block197_X_Pos + ((~Kirby_X_Step) + 1);
						block198_X_Pos = block198_X_Pos + ((~Kirby_X_Step) + 1);
						block199_X_Pos = block199_X_Pos + ((~Kirby_X_Step) + 1);
						block200_X_Pos = block200_X_Pos + ((~Kirby_X_Step) + 1);
						
						block201_X_Pos = block201_X_Pos + ((~Kirby_X_Step) + 1);
						block202_X_Pos = block202_X_Pos + ((~Kirby_X_Step) + 1);
						block203_X_Pos = block203_X_Pos + ((~Kirby_X_Step) + 1);
						block204_X_Pos = block204_X_Pos + ((~Kirby_X_Step) + 1);
						
					end else if( (Kirby_X_Pos + 32 >= Kirby_X_Max) || (NO_RIGHT)  ) begin
						Kirby_X_Pos <= Kirby_X_Pos + 0;
						ref_x <= ref_x + 0;
						move_x <= 0;
					end else begin
						Kirby_X_Pos <= Kirby_X_Pos + Kirby_X_Step;
						ref_x <= ref_x + 0;
						move_x <= 0;
					end
			  end else begin
					move_x <= 0;
					ref_x <= ref_x;
			  end
    end    
	 
	 /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  	  always_comb
    begin
			BATKADDR = '0;
			ATKADDR = '0;
			WADDR = '0;
			ADDR = '0;
			KADDR = '0;
			row = '0;
			col = '0;
			temp1 = '0;
			temp2 = '0;
			if(is_atk_temp)
			begin
				if(KATKFSM == 10'd1) begin			//attack animation				
					row = 0;
					col = 0;
				end else if(KATKFSM == 10'd2) begin
					row = 0;
					col = 1;
				end else if(KATKFSM == 10'd3) begin
					row = 0;
					col = 1;
				end else if(KATKFSM == 10'd4) begin
					row = 0;
					col = 1;
				end else if(KATKFSM == 10'd5) begin
					row = 0;
					col = 1;
				end
				temp2 = '0;
				temp1 = (DrawY - atk_Y_Pos);
				ATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - atk_X_Pos);	
			end 
			
			
	/*		
			if(boss) begin
				if(bstill_FSM == 10'd1) begin			//attack animation				
					row = 0;
					col = 0;
				end else if(bstill_FSM == 10'd2) begin
					row = 0;
					col = 1;
				end else if(bstill_FSM == 10'd3) begin
					row = 0;
					col = 1;
				end else if(bstill_FSM == 10'd4) begin
					row = 0;
					col = 1;
				end else if(bstill_FSM == 10'd5) begin
					row = 0;
					col = 1;
				end
				temp2 = '0;
				temp1 = (DrawY - atk_Y_Pos);
				KADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - atk_X_Pos);	
			end
	*/		
			
			
			if(is_kirbysub) 
			begin
				if(FLOAT_FSM == 10'd1) begin
					row = 0;
					col = 8;
				end else if(FLOAT_FSM == 10'd2) begin
					row = 0;
					col = 9;
				end else if(FLOAT_FSM == 10'd3) begin
					row = 0;
					col = 10;
				end else if(FLOAT_FSM == 10'd4) begin
					row = 0;
					col = 11;
				end else if(FLOAT_FSM == 10'd5) begin
					row = 0;
					col = 12;
				end else if(FLOAT_FSM == 10'd6) begin
					row = 0;
					col = 13;
				end else if(FLOAT_FSM == 10'd7) begin
					row = 0;
					col = 14;
				end else if(FLOAT_FSM == 10'd8) begin
					row = 0;
					col = 15;
				
				//--------------------------------------------------
				end else if(REGWALK_FSM == 10'd1) begin
					row = 0;
					col = 0;
				end else if(REGWALK_FSM == 10'd2) begin
					row = 0;
					col = 1;
				end else if(REGWALK_FSM == 10'd3) begin
					row = 0;
					col = 2;
				end else if(REGWALK_FSM == 10'd4) begin
					row = 0;
					col = 3;
				end else if(REGWALK_FSM == 10'd5) begin
					row = 0;
					col = 4;
				end else if(REGWALK_FSM == 10'd6) begin
					row = 0;
					col = 5;
				end else if(REGWALK_FSM == 10'd7) begin
					row = 0;
					col = 6;
				end else if(REGWALK_FSM == 10'd8) begin
					row = 0;
					col = 7;
				//--------------------------------------------------
				end else if(KATKFSM == 10'd1) begin
					row = 1;
					col = 0;
				end else if(KATKFSM == 10'd2) begin
					row = 1;
					col = 1;
				end else if(KATKFSM == 10'd3) begin
					row = 1;
					col = 2;
				end else if(KATKFSM == 10'd4) begin
					row = 1;
					col = 3;
				end else if(KATKFSM == 10'd5) begin
					row = 1;
					col = 4;
				end else if(KATKFSM == 10'd6) begin
					row = 1;
					col = 3;
				end else if(KATKFSM == 10'd7) begin
					row = 1;
					col = 2;
				end else if(KATKFSM == 10'd8) begin
					row = 1;
					col = 1;
				//--------------------------------------------------
				end else if(STILL_FSM == 10'd1) begin
					row = 2;
					col = 0;
				end else if(STILL_FSM == 10'd2) begin
					row = 2;
					col = 1;
				end else if(STILL_FSM == 10'd3) begin
					row = 2;
					col = 2;
				end else if(STILL_FSM == 10'd4) begin
					row = 2;
					col = 3;
				end else if(STILL_FSM == 10'd5) begin
					row = 2;
					col = 4;
				end else if(STILL_FSM == 10'd6) begin
					row = 2;
					col = 2;
				end else if(STILL_FSM == 10'd7) begin
					row = 2;
					col = 3;		
				end else if(STILL_FSM == 10'd8) begin
					row = 2;
					col = 4;				
				end else begin
					row = 0;
					col = 0;
				end
				if(LorR) begin			//if kirby is floating faced right
					temp2 = '0;
					temp1 = (DrawY - Kirby_Y_Pos);
					KADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - Kirby_X_Pos);
				end else begin			//if kirby is floating faced left
					temp2 = '0;
					temp1 = (DrawY - Kirby_Y_Pos); 
					KADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - Kirby_X_Pos);
				end
			end
		  
		  
if(is_block == 1'b1)
begin

			
			if(is_waddle0_temp) 
			begin
				if(waddle0_FSM == 10'd1) begin
					row = 0;
					col = 0;
				end else if(waddle0_FSM == 10'd2) begin
					row = 0;
					col = 1;
				end else if(waddle0_FSM == 10'd3) begin
					row = 0;
					col = 2;
				end else if(waddle0_FSM == 10'd4) begin
					row = 0;
					col = 3;
				end else if(waddle0_FSM == 10'd5) begin
					row = 0;
					col = 4;
				end else if(waddle0_FSM == 10'd6) begin
					row = 0;
					col = 5;
				end else if(waddle0_FSM == 10'd7) begin
					row = 0;
					col = 6;
				end else if(waddle0_FSM == 10'd8) begin
					row = 0;
					col = 7;
				end else if(waddle0_hit_count != 10'd0) begin
					row = 0;
					col = 9;
				end
				if(!waddle0_LorR) begin			//if kirby is floating faced right
					temp2 = '0;
					temp1 = (DrawY - waddle0_Y_Pos);
					WADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - waddle0_X_Pos);
				end else begin			//if kirby is floating faced left
					temp2 = '0;
					temp1 = (DrawY - waddle0_Y_Pos); 
					WADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - waddle0_X_Pos);
				end
				
			end
			

		
if(block0) begin
      row = 20;
      col = 13;
      temp1 = (DrawY - block0_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block0_X_Pos);
end else if(block1) begin
      row = 21;
      col = 13;
      temp1 = (DrawY - block1_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block1_X_Pos);
end else if(block2) begin
      row = 22;
      col = 4;
      temp1 = (DrawY - block2_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block2_X_Pos);
end else if(block3) begin
      row = 23;
      col = 4;
      temp1 = (DrawY - block3_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block3_X_Pos);
end else if(block4) begin
      row = 23;
      col = 3;
      temp1 = (DrawY - block4_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block4_X_Pos);
end else if(block5) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block5_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block5_X_Pos);
end else if(block6) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block6_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block6_X_Pos);
end else if(block7) begin
      row = 23;
      col = 6;
      temp1 = (DrawY - block7_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block7_X_Pos);
end else if(block8) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block8_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block8_X_Pos);
end else if(block9) begin
      row = 21;
      col = 6;
      temp1 = (DrawY - block9_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block9_X_Pos);
end else if(block10) begin
      row = 23;
      col = 10;
      temp1 = (DrawY - block10_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block10_X_Pos);
end else if(block11) begin
      row = 22;
      col = 0;
      temp1 = (DrawY - block11_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block11_X_Pos);
end else if(block12) begin
      row = 23;
      col = 0;
      temp1 = (DrawY - block12_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block12_X_Pos);
end else if(block13) begin
      row = 22;
      col = 15;
      temp1 = (DrawY - block13_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block13_X_Pos);
end else if(block14) begin
      row = 21;
      col = 11;
      temp1 = (DrawY - block14_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block14_X_Pos);
end else if(block15) begin
      row = 20;
      col = 14;
      temp1 = (DrawY - block15_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block15_X_Pos);
end else if(block16) begin
      row = 21;
      col = 14;
      temp1 = (DrawY - block16_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block16_X_Pos);
end else if(block17) begin
      row = 23;
      col = 8;
      temp1 = (DrawY - block17_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block17_X_Pos);
end else if(block18) begin
      row = 23;
      col = 8;
      temp1 = (DrawY - block18_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block18_X_Pos);
end else if(block19) begin
      row = 22;
      col = 4;
      temp1 = (DrawY - block19_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block19_X_Pos);
end else if(block20) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block20_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block20_X_Pos);
end else if(block21) begin
      row = 22;
      col = 11;
      temp1 = (DrawY - block21_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block21_X_Pos);
end else if(block22) begin
      row = 22;
      col = 5;
      temp1 = (DrawY - block22_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block22_X_Pos);
end else if(block23) begin
      row = 22;
      col = 5;
      temp1 = (DrawY - block23_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block23_X_Pos);
end else if(block24) begin
      row = 22;
      col = 4;
      temp1 = (DrawY - block24_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block24_X_Pos);
end else if(block25) begin
      row = 21;
      col = 1;
      temp1 = (DrawY - block25_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block25_X_Pos);
end else if(block26) begin
      row = 22;
      col = 1;
      temp1 = (DrawY - block26_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block26_X_Pos);
end else if(block27) begin
      row = 23;
      col = 1;
      temp1 = (DrawY - block27_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block27_X_Pos);
end else if(block28) begin
      row = 21;
      col = 15;
      temp1 = (DrawY - block28_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block28_X_Pos);
end else if(block29) begin
      row = 22;
      col = 12;
      temp1 = (DrawY - block29_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block29_X_Pos);
end else if(block30) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block30_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block30_X_Pos);
end else if(block31) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block31_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block31_X_Pos);
end else if(block32) begin
      row = 20;
      col = 11;
      temp1 = (DrawY - block32_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block32_X_Pos);
end else if(block33) begin
      row = 22;
      col = 0;
      temp1 = (DrawY - block33_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block33_X_Pos);
end else if(block34) begin
      row = 23;
      col = 0;
      temp1 = (DrawY - block34_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block34_X_Pos);
end else if(block35) begin
      row = 22;
      col = 15;
      temp1 = (DrawY - block35_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block35_X_Pos);
end else if(block36) begin
      row = 20;
      col = 13;
      temp1 = (DrawY - block36_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block36_X_Pos);
end else if(block37) begin
      row = 21;
      col = 13;
      temp1 = (DrawY - block37_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block37_X_Pos);
end else if(block38) begin
      row = 22;
      col = 13;
      temp1 = (DrawY - block38_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block38_X_Pos);
end else if(block39) begin
      row = 23;
      col = 13;
      temp1 = (DrawY - block39_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block39_X_Pos);
end else if(block40) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block40_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block40_X_Pos);
end else if(block41) begin
      row = 22;
      col = 2;
      temp1 = (DrawY - block41_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block41_X_Pos);
end else if(block42) begin
      row = 23;
      col = 2;
      temp1 = (DrawY - block42_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block42_X_Pos);
end else if(block43) begin
      row = 23;
      col = 15;
      temp1 = (DrawY - block43_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block43_X_Pos);
end else if(block44) begin
      row = 22;
      col = 6;
      temp1 = (DrawY - block44_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block44_X_Pos);
end else if(block45) begin
      row = 23;
      col = 5;
      temp1 = (DrawY - block45_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block45_X_Pos);
end else if(block46) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block46_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block46_X_Pos);
end else if(block47) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block47_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block47_X_Pos);
end else if(block48) begin
      row = 22;
      col = 1;
      temp1 = (DrawY - block48_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block48_X_Pos);
end else if(block49) begin
      row = 23;
      col = 1;
      temp1 = (DrawY - block49_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block49_X_Pos);
end else if(block50) begin
      row = 21;
      col = 15;
      temp1 = (DrawY - block50_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block50_X_Pos);
end else if(block51) begin
      row = 20;
      col = 14;
      temp1 = (DrawY - block51_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block51_X_Pos);
end else if(block52) begin
      row = 21;
      col = 14;
      temp1 = (DrawY - block52_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block52_X_Pos);
end else if(block53) begin
      row = 22;
      col = 14;
      temp1 = (DrawY - block53_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block53_X_Pos);
end else if(block54) begin
      row = 23;
      col = 14;
      temp1 = (DrawY - block54_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block54_X_Pos);
end else if(block55) begin
      row = 21;
      col = 7;
      temp1 = (DrawY - block55_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block55_X_Pos);
end else if(block56) begin
      row = 22;
      col = 7;
      temp1 = (DrawY - block56_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block56_X_Pos);
end else if(block57) begin
      row = 22;
      col = 7;
      temp1 = (DrawY - block57_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block57_X_Pos);
end else if(block58) begin
      row = 23;
      col = 7;
      temp1 = (DrawY - block58_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block58_X_Pos);
end else if(block59) begin
      row = 22;
      col = 11;
      temp1 = (DrawY - block59_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block59_X_Pos);
end else if(block60) begin
      row = 21;
      col = 6;
      temp1 = (DrawY - block60_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block60_X_Pos);
end else if(block61) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block61_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block61_X_Pos);
end else if(block62) begin
      row = 19;
      col = 11;
      temp1 = (DrawY - block62_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block62_X_Pos);
end else if(block63) begin
      row = 22;
      col = 2;
      temp1 = (DrawY - block63_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block63_X_Pos);
end else if(block64) begin
      row = 23;
      col = 2;
      temp1 = (DrawY - block64_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block64_X_Pos);
end else if(block65) begin
      row = 23;
      col = 15;
      temp1 = (DrawY - block65_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block65_X_Pos);
end else if(block66) begin
      row = 22;
      col = 12;
      temp1 = (DrawY - block66_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block66_X_Pos);
end else if(block67) begin
      row = 22;
      col = 4;
      temp1 = (DrawY - block67_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block67_X_Pos);
end else if(block68) begin
      row = 22;
      col = 12;
      temp1 = (DrawY - block68_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block68_X_Pos);
end else if(block69) begin
      row = 21;
      col = 2;
      temp1 = (DrawY - block69_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block69_X_Pos);
end else if(block70) begin
      row = 21;
      col = 2;
      temp1 = (DrawY - block70_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block70_X_Pos);
end else if(block71) begin
      row = 22;
      col = 1;
      temp1 = (DrawY - block71_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block71_X_Pos);
end else if(block72) begin
      row = 23;
      col = 1;
      temp1 = (DrawY - block72_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block72_X_Pos);
end else if(block73) begin
      row = 21;
      col = 15;
      temp1 = (DrawY - block73_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block73_X_Pos);
end else if(block74) begin
      row = 22;
      col = 6;
      temp1 = (DrawY - block74_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block74_X_Pos);
end else if(block75) begin
      row = 21;
      col = 6;
      temp1 = (DrawY - block75_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block75_X_Pos);
end else if(block76) begin
      row = 20;
      col = 5;
      temp1 = (DrawY - block76_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block76_X_Pos);
end else if(block77) begin
      row = 19;
      col = 12;
      temp1 = (DrawY - block77_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block77_X_Pos);
end else if(block78) begin
      row = 20;
      col = 12;
      temp1 = (DrawY - block78_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block78_X_Pos);
end else if(block79) begin
      row = 20;
      col = 12;
      temp1 = (DrawY - block79_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block79_X_Pos);
end else if(block80) begin
      row = 21;
      col = 12;
      temp1 = (DrawY - block80_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block80_X_Pos);
end else if(block81) begin
      row = 21;
      col = 12;
      temp1 = (DrawY - block81_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block81_X_Pos);
end else if(block82) begin
      row = 23;
      col = 5;
      temp1 = (DrawY - block82_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block82_X_Pos);
end else if(block83) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block83_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block83_X_Pos);
end else if(block84) begin
      row = 21;
      col = 6;
      temp1 = (DrawY - block84_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block84_X_Pos);
end else if(block85) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block85_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block85_X_Pos);
end else if(block86) begin
      row = 22;
      col = 2;
      temp1 = (DrawY - block86_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block86_X_Pos);
end else if(block87) begin
      row = 23;
      col = 2;
      temp1 = (DrawY - block87_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block87_X_Pos);
end else if(block88) begin
      row = 23;
      col = 15;
      temp1 = (DrawY - block88_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block88_X_Pos);
end else if(block89) begin
      row = 22;
      col = 5;
      temp1 = (DrawY - block89_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block89_X_Pos);
end else if(block90) begin
      row = 21;
      col = 6;
      temp1 = (DrawY - block90_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block90_X_Pos);
end else if(block91) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block91_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block91_X_Pos);
end else if(block92) begin
      row = 19;
      col = 13;
      temp1 = (DrawY - block92_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block92_X_Pos);
end else if(block93) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block93_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block93_X_Pos);
end else if(block94) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block94_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block94_X_Pos);
end else if(block95) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block95_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block95_X_Pos);
end else if(block96) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block96_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block96_X_Pos);
end else if(block97) begin
      row = 21;
      col = 1;
      temp1 = (DrawY - block97_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block97_X_Pos);
end else if(block98) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block98_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block98_X_Pos);
end else if(block99) begin
      row = 21;
      col = 6;
      temp1 = (DrawY - block99_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block99_X_Pos);
end else if(block100) begin
      row = 23;
      col = 10;
      temp1 = (DrawY - block100_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block100_X_Pos);
end else if(block101) begin
      row = 22;
      col = 0;
      temp1 = (DrawY - block101_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block101_X_Pos);
end else if(block102) begin
      row = 23;
      col = 0;
      temp1 = (DrawY - block102_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block102_X_Pos);
end else if(block103) begin
      row = 22;
      col = 15;
      temp1 = (DrawY - block103_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block103_X_Pos);
end else if(block104) begin
      row = 21;
      col = 11;
      temp1 = (DrawY - block104_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block104_X_Pos);
end else if(block105) begin
      row = 23;
      col = 3;
      temp1 = (DrawY - block105_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block105_X_Pos);
end else if(block106) begin
      row = 22;
      col = 6;
      temp1 = (DrawY - block106_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block106_X_Pos);
end else if(block107) begin
      row = 21;
      col = 7;
      temp1 = (DrawY - block107_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block107_X_Pos);
end else if(block108) begin
      row = 22;
      col = 7;
      temp1 = (DrawY - block108_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block108_X_Pos);
end else if(block109) begin
      row = 22;
      col = 7;
      temp1 = (DrawY - block109_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block109_X_Pos);
end else if(block110) begin
      row = 22;
      col = 7;
      temp1 = (DrawY - block110_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block110_X_Pos);
end else if(block111) begin
      row = 22;
      col = 7;
      temp1 = (DrawY - block111_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block111_X_Pos);
end else if(block112) begin
      row = 23;
      col = 7;
      temp1 = (DrawY - block112_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block112_X_Pos);
end else if(block113) begin
      row = 22;
      col = 12;
      temp1 = (DrawY - block113_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block113_X_Pos);
end else if(block114) begin
      row = 22;
      col = 8;
      temp1 = (DrawY - block114_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block114_X_Pos);
end else if(block115) begin
      row = 22;
      col = 9;
      temp1 = (DrawY - block115_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block115_X_Pos);
end else if(block116) begin
      row = 22;
      col = 1;
      temp1 = (DrawY - block116_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block116_X_Pos);
end else if(block117) begin
      row = 23;
      col = 1;
      temp1 = (DrawY - block117_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block117_X_Pos);
end else if(block118) begin
      row = 21;
      col = 15;
      temp1 = (DrawY - block118_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block118_X_Pos);
end else if(block119) begin
      row = 23;
      col = 6;
      temp1 = (DrawY - block119_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block119_X_Pos);
end else if(block120) begin
      row = 20;
      col = 15;
      temp1 = (DrawY - block120_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block120_X_Pos);
end else if(block121) begin
      row = 21;
      col = 13;
      temp1 = (DrawY - block121_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block121_X_Pos);
end else if(block122) begin
      row = 21;
      col = 1;
      temp1 = (DrawY - block122_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block122_X_Pos);
end else if(block123) begin
      row = 21;
      col = 2;
      temp1 = (DrawY - block123_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block123_X_Pos);
end else if(block124) begin
      row = 21;
      col = 2;
      temp1 = (DrawY - block124_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block124_X_Pos);
end else if(block125) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block125_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block125_X_Pos);
end else if(block126) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block126_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block126_X_Pos);
end else if(block127) begin
      row = 21;
      col = 1;
      temp1 = (DrawY - block127_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block127_X_Pos);
end else if(block128) begin
      row = 22;
      col = 11;
      temp1 = (DrawY - block128_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block128_X_Pos);
end else if(block129) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block129_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block129_X_Pos);
end else if(block130) begin
      row = 20;
      col = 11;
      temp1 = (DrawY - block130_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block130_X_Pos);
end else if(block131) begin
      row = 22;
      col = 2;
      temp1 = (DrawY - block131_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block131_X_Pos);
end else if(block132) begin
      row = 23;
      col = 2;
      temp1 = (DrawY - block132_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block132_X_Pos);
end else if(block133) begin
      row = 23;
      col = 15;
      temp1 = (DrawY - block133_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block133_X_Pos);
end else if(block134) begin
      row = 22;
      col = 12;
      temp1 = (DrawY - block134_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block134_X_Pos);
end else if(block135) begin
      row = 20;
      col = 14;
      temp1 = (DrawY - block135_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block135_X_Pos);
end else if(block136) begin
      row = 20;
      col = 15;
      temp1 = (DrawY - block136_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block136_X_Pos);
end else if(block137) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block137_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block137_X_Pos);
end else if(block138) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block138_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block138_X_Pos);
end else if(block139) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block139_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block139_X_Pos);
end else if(block140) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block140_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block140_X_Pos);
end else if(block141) begin
      row = 23;
      col = 12;
      temp1 = (DrawY - block141_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block141_X_Pos);
end else if(block142) begin
      row = 19;
      col = 15;
      temp1 = (DrawY - block142_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block142_X_Pos);
end else if(block143) begin
      row = 23;
      col = 4;
      temp1 = (DrawY - block143_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block143_X_Pos);
end else if(block144) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block144_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block144_X_Pos);
end else if(block145) begin
      row = 21;
      col = 7;
      temp1 = (DrawY - block145_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block145_X_Pos);
end else if(block146) begin
      row = 22;
      col = 7;
      temp1 = (DrawY - block146_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block146_X_Pos);
end else if(block147) begin
      row = 22;
      col = 7;
      temp1 = (DrawY - block147_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block147_X_Pos);
end else if(block148) begin
      row = 23;
      col = 7;
      temp1 = (DrawY - block148_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block148_X_Pos);
end else if(block149) begin
      row = 22;
      col = 12;
      temp1 = (DrawY - block149_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block149_X_Pos);
end else if(block150) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block150_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block150_X_Pos);
end else if(block151) begin
      row = 18;
      col = 11;
      temp1 = (DrawY - block151_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block151_X_Pos);
end else if(block152) begin
      row = 20;
      col = 15;
      temp1 = (DrawY - block152_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block152_X_Pos);
end else if(block153) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block153_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block153_X_Pos);
end else if(block154) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block154_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block154_X_Pos);
end else if(block155) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block155_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block155_X_Pos);
end else if(block156) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block156_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block156_X_Pos);
end else if(block157) begin
      row = 21;
      col = 12;
      temp1 = (DrawY - block157_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block157_X_Pos);
end else if(block158) begin
      row = 23;
      col = 3;
      temp1 = (DrawY - block158_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block158_X_Pos);
end else if(block159) begin
      row = 19;
      col = 14;
      temp1 = (DrawY - block159_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block159_X_Pos);
end else if(block160) begin
      row = 21;
      col = 1;
      temp1 = (DrawY - block160_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block160_X_Pos);
end else if(block161) begin
      row = 22;
      col = 1;
      temp1 = (DrawY - block161_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block161_X_Pos);
end else if(block162) begin
      row = 23;
      col = 1;
      temp1 = (DrawY - block162_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block162_X_Pos);
end else if(block163) begin
      row = 21;
      col = 15;
      temp1 = (DrawY - block163_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block163_X_Pos);
end else if(block164) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block164_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block164_X_Pos);
end else if(block165) begin
      row = 23;
      col = 4;
      temp1 = (DrawY - block165_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block165_X_Pos);
end else if(block166) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block166_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block166_X_Pos);
end else if(block167) begin
      row = 21;
      col = 1;
      temp1 = (DrawY - block167_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block167_X_Pos);
end else if(block168) begin
      row = 20;
      col = 15;
      temp1 = (DrawY - block168_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block168_X_Pos);
end else if(block169) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block169_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block169_X_Pos);
end else if(block170) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block170_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block170_X_Pos);
end else if(block171) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block171_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block171_X_Pos);
end else if(block172) begin
      row = 21;
      col = 2;
      temp1 = (DrawY - block172_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block172_X_Pos);
end else if(block173) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block173_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block173_X_Pos);
end else if(block174) begin
      row = 21;
      col = 2;
      temp1 = (DrawY - block174_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block174_X_Pos);
end else if(block175) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block175_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block175_X_Pos);
end else if(block176) begin
      row = 22;
      col = 2;
      temp1 = (DrawY - block176_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block176_X_Pos);
end else if(block177) begin
      row = 23;
      col = 2;
      temp1 = (DrawY - block177_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block177_X_Pos);
end else if(block178) begin
      row = 23;
      col = 15;
      temp1 = (DrawY - block178_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block178_X_Pos);
end else if(block179) begin
      row = 22;
      col = 5;
      temp1 = (DrawY - block179_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block179_X_Pos);
end else if(block180) begin
      row = 21;
      col = 6;
      temp1 = (DrawY - block180_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block180_X_Pos);
end else if(block181) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block181_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block181_X_Pos);
end else if(block182) begin
      row = 21;
      col = 2;
      temp1 = (DrawY - block182_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block182_X_Pos);
end else if(block183) begin
      row = 21;
      col = 8;
      temp1 = (DrawY - block183_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block183_X_Pos);
end else if(block184) begin
      row = 20;
      col = 15;
      temp1 = (DrawY - block184_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block184_X_Pos);
end else if(block185) begin
      row = 23;
      col = 9;
      temp1 = (DrawY - block185_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block185_X_Pos);
end else if(block186) begin
      row = 21;
      col = 8;
      temp1 = (DrawY - block186_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block186_X_Pos);
end else if(block187) begin
      row = 21;
      col = 2;
      temp1 = (DrawY - block187_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block187_X_Pos);
end else if(block188) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block188_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block188_X_Pos);
end else if(block189) begin
      row = 21;
      col = 1;
      temp1 = (DrawY - block189_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block189_X_Pos);
end else if(block190) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block190_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block190_X_Pos);
end else if(block191) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block191_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block191_X_Pos);
end else if(block192) begin
      row = 22;
      col = 4;
      temp1 = (DrawY - block192_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block192_X_Pos);
end else if(block193) begin
      row = 22;
      col = 3;
      temp1 = (DrawY - block193_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block193_X_Pos);
end else if(block194) begin
      row = 22;
      col = 4;
      temp1 = (DrawY - block194_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block194_X_Pos);
end else if(block195) begin
      row = 21;
      col = 6;
      temp1 = (DrawY - block195_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block195_X_Pos);
end else if(block196) begin
      row = 21;
      col = 3;
      temp1 = (DrawY - block196_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block196_X_Pos);
end else if(block197) begin
      row = 21;
      col = 4;
      temp1 = (DrawY - block197_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block197_X_Pos);
end else if(block198) begin
      row = 21;
      col = 18;
      temp1 = (DrawY - block198_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block198_X_Pos);
end else if(block199) begin
      row = 21;
      col = 0;
      temp1 = (DrawY - block199_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block199_X_Pos);
end else if(block200) begin
      row = 20;
      col = 15;
      temp1 = (DrawY - block200_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block200_X_Pos);
end else if(block201) begin  //sky1
      row = 24;
      col = 0;
      temp1 = (DrawY - block201_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - block201_X_Pos) + rotate;
end else if(block202) begin  //ground1
      row = 0;
      col = 0;
      temp1 = (DrawY - block202_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - block202_X_Pos);
end else if(block203) begin  //sky2
      row = 37;
      col = 0;
      temp1 = (DrawY - block203_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - block203_X_Pos);
end else if(block204) begin  //ground1 shifted over
      row = 0;
      col = 0;
      temp1 = (DrawY - block204_Y_Pos);
      ADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - block204_X_Pos);
	end else 
		  begin
            // Background with nice color gradient
				row = 0;
				col = 0;
				temp2 = 0;
				temp1 = 0;
				ADDR = 0;
            /*Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]}; */
        end
	end
if(is_kirby) begin
	
	
		if(boss) begin
			if(bstill_FSM == 1) begin
				row = 2;
				col = 0;
			end else if (bstill_FSM == 2) begin
				row = 2;
				col = 3;
			end else if (bstill_FSM == 3) begin
				row = 2;
				col = 6;
			end else if (bstill_FSM == 4) begin
				row = 2;
				col = 9;
			end else if (bstill_FSM == 5) begin
				row = 2;
				col = 12;
			end else if (bstill_FSM == 6) begin
				row = 5;
				col = 0;
			end else if (bstill_FSM == 7) begin
				row = 5;
				col = 3;
			end else if (bstill_FSM == 8) begin
				row = 5;
				col = 6;
			end else if (bstill_FSM == 9) begin
				row = 5;
				col = 9;
			end else if (bstill_FSM == 10) begin
				row = 5;
				col = 12;
				
			
			end else if (bmid_FSM == 1) begin
				row = 8;
				col = 0;
			end else if (bmid_FSM == 2) begin
				row = 8;
				col = 3;
			end else if (bmid_FSM == 3) begin
				row = 8;
				col = 6;
			end else if (bmid_FSM == 4) begin
				row = 8;
				col = 9;
			end else if (bmid_FSM == 5) begin
				row = 8;
				col = 12;
			end else if (bmid_FSM == 6) begin
				row = 8;
				col = 9;
			end else if (bmid_FSM == 7) begin
				row = 8;
				col = 6;
			end else if (bmid_FSM == 8) begin
				row = 8;
				col = 3;
				
			
			end else if (bfire_FSM == 1) begin
				row = 8;
				col = 0;
			end else if (bfire_FSM == 2) begin
				row = 8;
				col = 3;
			end else if (bfire_FSM == 3) begin
				row = 8;
				col = 6;
			end else if (bfire_FSM == 4) begin
				row = 8;
				col = 9;
			end else if (bfire_FSM == 5) begin
				row = 8;
				col = 12;
			end else if (bfire_FSM == 6) begin
				row = 8;
				col = 9;
			end else if (bfire_FSM == 7) begin
				row = 8;
				col = 6;
			end else if (bfire_FSM == 8) begin
				row = 8;
				col = 3;
				
				
			end else if (bswoop_FSM == 1) begin
				row = 2;
				col = 0;
			end else if (bswoop_FSM == 2) begin
				row = 2;
				col = 3;
			end else if (bswoop_FSM == 3) begin
				row = 2;
				col = 6;
			end else if (bswoop_FSM == 4) begin
				row = 2;
				col = 9;
			end else if (bswoop_FSM == 5) begin
				row = 5;
				col = 12;
			end else if (bswoop_FSM == 6) begin
				row = 5;
				col = 3;
			end else if (bswoop_FSM == 7) begin
				row = 5;
				col = 3;
			end else begin
				row = 2;
				col = 0;
			end
				
			if(!bLorR) begin			//if boss is floating faced right
				temp2 = '0;
				temp1 = (DrawY - boss_Y_Pos);
				WADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - boss_X_Pos);
			end else begin			//if boss is floating faced left
				temp2 = '0;
				temp1 = (DrawY - boss_Y_Pos); 
				WADDR = (((row << 5) << 9) + (col << 5)) + 95 + (temp1 << 9) - (DrawX - boss_X_Pos);
			end
		end
	
	
	
	

	if(f0 && (bbcounter == 1)) begin
		row = 0;
		col = 0;
		temp1 = (DrawY - f0_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f0_X_Pos);
	end else if (f0 && (bbcounter == 2)) begin
		row = 0;
		col = 1;
		temp1 = (DrawY - f0_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f0_X_Pos);
	end else if (f0 && (bbcounter == 2)) begin
		row = 0;
		col = 2;
		temp1 = (DrawY - f0_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f0_X_Pos);
	end else if (f0 && (bbcounter == 2)) begin
		row = 0;
		col = 3;
		temp1 = (DrawY - f0_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f0_X_Pos);
	end
	
	if(f1 && (bbcounter == 1)) begin
		row = 0;
		col = 0;
		temp1 = (DrawY - f1_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f1_X_Pos);
	end else if (f1 && (bbcounter == 2)) begin
		row = 0;
		col = 1;
		temp1 = (DrawY - f1_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f1_X_Pos);
	end else if (f1 && (bbcounter == 2)) begin
		row = 0;
		col = 2;
		temp1 = (DrawY - f1_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f1_X_Pos);
	end else if (f1 && (bbcounter == 2)) begin
		row = 0;
		col = 3;
		temp1 = (DrawY - f1_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f1_X_Pos);
	end
	
	if(f2 && (bbcounter == 1)) begin
		row = 0;
		col = 0;
		temp1 = (DrawY - f2_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f2_X_Pos);
	end else if (f2 && (bbcounter == 2)) begin
		row = 0;
		col = 1;
		temp1 = (DrawY - f2_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f2_X_Pos);
	end else if (f2 && (bbcounter == 2)) begin
		row = 0;
		col = 2;
		temp1 = (DrawY - f2_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f2_X_Pos);
	end else if (f2 && (bbcounter == 2)) begin
		row = 0;
		col = 3;
		temp1 = (DrawY - f2_Y_Pos);
	   BATKADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - f2_X_Pos);
	end
	
	
	
	
	if(block205) begin   // boss background block (first half)
      row = 4;
		col = 0;
		temp1 = (DrawY - block205_Y_Pos);
	   ADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - block205_X_Pos);
	
	end else if(block206) begin  //boss background block (second half)
		row = 48;
		col = 0;
		temp1 = (DrawY - block206_Y_Pos);
	   ADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - block206_X_Pos);
	end else if(block207) begin  //boss background block (third part)
		row = 48;
		col = 4;
		temp1 = (DrawY - block207_Y_Pos);
	   ADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - block207_X_Pos);
	end else begin
            // Background with nice color gradient
				row = 0;
				col = 0;
				temp2 = 0;
				temp1 = 0;
				ADDR = 0;
            /*Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]}; */
   end
end

end
	 
endmodule








