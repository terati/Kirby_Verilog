//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module Final_Topfile( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,     //SDRAM Clock
				 output logic 			SRAM_CE_N, SRAM_CE_UB, SRAM_LB_N, SRAM_OE_N, SRAM_WE_N,
				 output logic [19:0] SRAM_ADDR,
/*inout  wire*/input logic  [15:0] SRAM_DQ,
				 
				 output logic  		FL_WE_N,      // Write Enable 
				 output        		FL_WP_N,      // Write Protect / Programming Acceleration
				 output logic  		FL_RST_N,     // Reset
				 output        		FL_OE_N,      // Output Enable
				 output       			FL_CE_N,      // Chip Enable
				 input         		FL_RY,	 	  // Ready / Busy
				 inout  wire  [7:0]  FL_DQ,        // Data bus (8 Bits)
				 output logic [22:0] FL_ADDR       // Address bus (23 Bits)
                    );
    
    logic Reset_h, Clk, FAST_CLK, is_kirbysub, is_testblock, LorR, is_background, is_kirby_temp, is_waddle0_temp, is_atk_temp, is_block_temp, is_background_temp, is_attack_temp, is_flame;
	 logic  is_block,  is_kirby, is_attack, is_nothing, boss;
	 logic [31:0] keycode;
    logic [7:0] Red, Green, Blue, kred, kgreen, kblue, wred, wgreen, wblue, ared, agreen, ablue, bred, bgreen, bblue;
	 logic [9:0] DrawX, DrawY, FLOAT_FSM, REGWALK_FSM, STILL_FSM;
	 logic [15:0] Kirby_X_Pos, Kirby_Y_Pos, Block_X_Pos, Block_Y_Pos;
	 logic [7:0] index;
	 logic [7:0] test;
	 logic [4:0] which;
	 logic [3:0] health;

	 logic [19:0] KADDR, WADDR, ATKADDR, BATKADDR;
	 logic [7:0] kirbydata, waddledata, atkdata, Batkdata;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 logic [15:0] Data_from_SRAM, Data_to_SRAM;
	
	 logic BOSSTIME;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     final_projectqs nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
   vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(
														.Clk,
														.FAST_CLK,
														.Reset(Reset_h),
														.VGA_HS,
														.VGA_VS,
														.VGA_CLK,
														.VGA_BLANK_N,
														.VGA_SYNC_N,
														.DrawX,
														.DrawY,
														.VGA_R, 
														.VGA_G,
														.VGA_B,
														.is_kirby_temp, 
														.is_block_temp, 
														.is_waddle0_temp,
														.is_kirby, 
														.is_block,
														.is_attack,
														.is_background,
														.is_atk_temp,
														.is_flame,
														//.is_nothing,
														.Red,
														.Green,
														.Blue,
														.kred,
														.kgreen,
														.kblue,
														.wred,
														.wgreen,
														.wblue,
														.kirbydata,
														.atkdata,
														.ared,
														.agreen,
														.ablue,
														.BOSSTIME,
														.boss,
														.bred,
														.bgreen,
														.bblue,
														.Batkdata,
														.waddledata
	 );
    
    // Which signal should be frame_clk?
    Kirby kirby_instance(
							.Clk,
							.Reset(Reset_h),
							.frame_clk(VGA_VS),
							.DrawX,
							.DrawY,
							.is_attack_temp,
							.is_kirby_temp,
							.is_waddle0_temp,
							.is_block_temp,
							.is_testblock,
							.is_kirbysub,
							.is_flame,
							.keycode,
							.Kirby_X_Pos, 
							.Kirby_Y_Pos,
							.LorR,
							.FLOAT_FSM,
							.is_kirby,
							.is_block,
							.is_atk_temp,
							.ADDR(SRAM_ADDR),
							.KADDR,
							.WADDR,
							.ATKADDR,
							.BOSSTIME,
							.boss,
							.BATKADDR,
							.health
							
						
	 );
    
 /*   color_mapper color_instance(
										.is_kirby,
										.is_block,
										.is_attack,
										.is_testblock,
										.is_nothing,
									//	.which,
										.Kirby_X_Pos,
										.Kirby_Y_Pos,
										.Block_X_Pos,
										.Block_Y_Pos,
										.DrawX,
										.DrawY,
									//	.VGA_R,
									//	.VGA_G,
									//	.VGA_B,
										.ADDR(SRAM_ADDR),
										//.FL_ADDR,
										.LorR,
										.FLOAT_FSM,
										.REGWALK_FSM,
										.STILL_FSM,
										.is_kirbysub
									//	.fred,
									//	.fgreen,
									//	.fblue					
	 ); */
	 
	 color_mapper_two quantizer(
										.index(SRAM_DQ),
										.Red,
										.Green,
										.Blue
	 );
	 
	 color_mapper_two OCMquantizer(
										.index(kirbydata),
										.Red(kred),
										.Green(kgreen),
										.Blue(kblue)
	 );
	 
	 color_mapper_two OCMquantizer2(
										.index(waddledata),
										.Red(wred),
										.Green(wgreen),
										.Blue(wblue)
	 );
	 
	  color_mapper_two OCMquantizer3(
										.index(atkdata),
										.Red(ared),
										.Green(agreen),
										.Blue(ablue)
	 );
	 
	 	color_mapper_two OCMquantizer4(
										.index(Batkdata),
										.Red(bred),
										.Green(bgreen),
										.Blue(bblue)
	 );
	 
	 
	/* Mem2IO sram(
					.Clk,
					.Reset(Reset_h),
					.ADDR(SRAM_ADDR),
					.CE(SRAM_CE_N),
					.UB(SRAM_UB_N),
					.LB(SRAM_LB_N),
					.OE(SRAM_OE_N),
					.WE(SRAM_WE_N),
					.Data_from_CPU(),
					.Data_from_SRAM(SRAM_DQ),
					.Data_out(),
					.Data_to_SRAM(Data_to_SRAM),
					.out(test)
	 ); */
	 
	 SRAMPLL fastclock(
						.areset(),
						.inclk0(CLOCK_50),
						.c0(FAST_CLK),
						.locked()
	 );
	 
	 
	 kirbyRAM KRAM (	.Clk,
							.R_ADDR(KADDR),
							.data_Out(kirbydata)
	);
	
	 waddleRAM WRAM (	.Clk,
							.R_ADDR(WADDR),
							.data_Out(waddledata)
	);
	 
	 
	 atkRAM ARAM (	.Clk,
							.R_ADDR(ATKADDR),
							.data_Out(atkdata)
	);
	 
	 bossatkRAM BARAM (	.Clk,
							.R_ADDR(BATKADDR),
							.data_Out(Batkdata)
	);
    
	/* tristate #(.N(16)) trimod(
									.Clk(VGA_CLK),
									.tristate_output_enable(~SRAM_WE_N),
									.Data_write(Data_to_SRAM),
									.Data_read(Data_from_SRAM),
									.Data(SRAM_DQ)   
	 );*/
	 
	 //SRAM forced PINs
	 assign SRAM_CE_N = 1'b0;
	 assign SRAM_UB_N = 1'b0;
	 assign SRAM_LB_N = 1'b0;
	 assign SRAM_WE_N = 1'b1; //I assume that we are never writing. 
	 assign SRAM_OE_N = 1'b0;
	 
	 //FLASH forced PINs
	 assign FL_WE_N = 1'b1;	//writing into FLASH is slow so no
	 assign FL_WP_N = 1'b1;	//used in the factory to accelerate processing
	 assign FL_RST_N = 1'b1;
	 assign FL_OE_N = 1'b0;
	 assign FL_CE_N = 1'b0;
	 
	 
    // Display keycode on hex display
    HexDriver hex_inst_0 (health, HEX0);
    HexDriver hex_inst_1 (0, HEX1);

    HexDriver hex_inst_2 (0, HEX2);
    HexDriver hex_inst_3 (0, HEX3);
endmodule
