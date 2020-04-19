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
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_kirby, is_block,             // Whether current pixel belongs to Kirby or background
					output [31:0] kirby_dir,   		//kirby direction
					input [31:0]  keycode,
					output [15:0]  Kirby_X_Pos, Kirby_Y_Pos, Block_X_Pos, Block_Y_Pos,
					output logic  LorR,  				 // L = 0 and R = 1
					output [9:0]  FLOAT_FSM, REGWALK_FSM, STILL_FSM
              );
    
    parameter [9:0] Kirby_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Kirby_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Kirby_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Kirby_X_Max = 10'd639;     // Rightmost point on the X axis
	 parameter [9:0] xmin_line = 10'd90;
	 parameter [9:0] xmax_line = 10'd550;
    parameter [9:0] Kirby_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Kirby_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] Kirby_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Kirby_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Kirby_Size = 10'd4;        // Kirby size
	 
	 
    
    logic [15:0] prev_press = 0;
	 logic [15:0] curr_press = 0;
	 logic [31:0] UP_COUNT = 0;
	 logic [31:0] WALK_COUNT = 0;
	 logic [31:0] STILL_COUNT = 0;
	 logic 		  U,D,L,R,A = 0;
	 logic [31:0] ref_x = 500;
	 logic [9:0]  move_x = 0;
	 
	 initial begin
		LorR = 1'b1;
		Kirby_X_Pos = Kirby_X_Center;
		Kirby_Y_Pos = Kirby_Y_Center;
		Block_X_Pos = 16'd700;
		Block_Y_Pos = 16'd200;
	 end
    //////// Do not modify the always_ff blocks. ////////
	 
	 //  1A == UP
	 //  16 == DOWN
	 //  04 == LEFT
	 //  07 == RIGHT
	 //  28 == ATTACK
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
	 
	     // Compute whether the pixel corresponds to Kirby or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */

    always_comb begin
        if ((DrawX >= Kirby_X_Pos) && (DrawX < Kirby_X_Pos + 32) && (DrawY >= Kirby_Y_Pos) && (DrawY < Kirby_Y_Pos + 32)) 
            is_kirby = 1'b1;
        else
            is_kirby = 1'b0;
				
				
		  if((DrawX >= Block_X_Pos) && (DrawX < Block_X_Pos + 32) && (DrawY >= Block_Y_Pos) && (DrawY < Block_Y_Pos + 32)) 
            is_block = 1'b1;
        else
            is_block = 1'b0;
				
		  
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
							if(FLOAT_FSM == 10'd6) begin
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
							if(REGWALK_FSM == 10'd6) begin
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
			//STAYING STILL KIRBY
			  if (keycode == 32'd0) begin		
						if(STILL_COUNT == 32'hFFFFFFFF) begin
							STILL_COUNT <= 0;
						end else begin
							STILL_COUNT <= STILL_COUNT + 1;			// Basically creates the images for regular walking Kirby
						end
						if((STILL_COUNT%(8) == 0) && (STILL_COUNT !== 0)) begin
							if(STILL_FSM == 10'd6) begin
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
			  
			  if ( (keycode[7:0] == 8'h04) || (keycode[15:8] == 8'h04)) begin  // if LEFT was pressed, mark L
						LorR <= 0;
			  end else if ( (keycode[7:0] == 8'h07) || (keycode[15:8] == 8'h07) ) begin //if RIGHT was pressed, mark R
						LorR <= 1; 
			  end
				
				
			  if ( U ) begin  //occurs when you only press UP
					if( Kirby_Y_Pos <= Kirby_Y_Min )
						Kirby_Y_Pos <= Kirby_Y_Pos + 0;
					else begin
						Kirby_Y_Pos <= Kirby_Y_Pos + (~(Kirby_Y_Step) + 1);
					end
			  end else if ( D) begin  //occurs when you only press DOWN
					if( Kirby_Y_Pos + 32 >= Kirby_Y_Max  )
						Kirby_Y_Pos <= Kirby_Y_Pos + 0;
					else 
						Kirby_Y_Pos <= Kirby_Y_Pos + (Kirby_Y_Step << 1) ;
			  end else begin
					if( Kirby_Y_Pos + 32 >= Kirby_Y_Max  ) //the default "gravity" should pull Kirby down
						Kirby_Y_Pos <= Kirby_Y_Pos + 0;
					else 
						Kirby_Y_Pos <= Kirby_Y_Pos + Kirby_Y_Step;
			  end
			  if ( L ) begin  //occurs when you only press LEFT
					if( Kirby_X_Pos <= Kirby_X_Min  )
						Kirby_X_Pos <= Kirby_X_Pos + 0;
					else begin
						Kirby_X_Pos <= Kirby_X_Pos + (~(Kirby_X_Step) + 1);
					end
			  end
			  if ( R ) begin  //occurs when you only press RIGHT
					if((Kirby_X_Pos >= xmax_line) && (ref_x <= 10'd700)) begin
						Kirby_X_Pos <= Kirby_X_Pos + 0;
						ref_x <= ref_x + 1;
						move_x <= Kirby_X_Step;
						Block_X_Pos = Block_X_Pos + ((~Kirby_X_Step) + 1);
					end else if( Kirby_X_Pos + 32 >= Kirby_X_Max  ) begin
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
    

    
endmodule
