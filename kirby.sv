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
               output logic  is_kirby,             // Whether current pixel belongs to Kirby or background
					output [31:0] kirby_dir,   		//kirby direction
					input [15:0]  keycode,
					output [9:0]  Kirby_X_Pos, Kirby_Y_Pos,
					output logic  LorR,  				 // L = 0 and R = 1
					output [9:0]  FLOAT_FSM, REGWALK_FSM, STILL_FSM
              );
    
    parameter [9:0] Kirby_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Kirby_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Kirby_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Kirby_X_Max = 10'd639;     // Rightmost point on the X axis
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
	 
	 initial begin
		LorR = 1'b1;
	 end
    //////// Do not modify the always_ff blocks. ////////
	 
	 //  1A == UP
	 //  16 == DOWN
	 //  04 == LEFT
	 //  07 == RIGHT
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
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
			  if (((prev_press[15:8] == 8'h1A) || (prev_press[7:0] == 8'h1A)) && ((curr_press[15:8] == 8'h1A) || (curr_press[7:0] == 8'h1A))) begin
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
			  else if (((prev_press[15:8] == 8'h04) || (prev_press[7:0] == 8'h04) || (prev_press[7:0] == 8'h07) || (prev_press[7:0] == 8'h07) ) && 
			  ((curr_press[15:8] == 8'h04) || (curr_press[7:0] == 8'h04) || (curr_press[7:0] == 8'h07) || (curr_press[7:0] == 8'h07) )) begin
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
				else begin
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
				
				
			  if ( (keycode[7:0] == 8'h1A) || (keycode[15:8] == 8'h1A) ) begin  //occurs when you only press UP
					if( Kirby_Y_Pos <= Kirby_Y_Min )
						Kirby_Y_Pos <= Kirby_Y_Pos + 0;
					else begin
						Kirby_Y_Pos <= Kirby_Y_Pos + (~(Kirby_Y_Step) + 1);
					end
			  end else if ( keycode[7:0] == 8'h16 || (keycode[15:8] == 8'h16)) begin  //occurs when you only press DOWN
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
			  if ( (keycode[7:0] == 8'h04) || (keycode[15:8] == 8'h04) ) begin  //occurs when you only press LEFT
					if( Kirby_X_Pos <= Kirby_X_Min  )
						Kirby_X_Pos <= Kirby_X_Pos + 0;
					else begin
						Kirby_X_Pos <= Kirby_X_Pos + (~(Kirby_X_Step) + 1);
					end
			  end
			  if ( (keycode[7:0] == 8'h07) || (keycode[15:8] == 8'h07) ) begin  //occurs when you only press RIGHT
					if( Kirby_X_Pos + 32 >= Kirby_X_Max  )
						Kirby_X_Pos <= Kirby_X_Pos + 0;
					else begin
						Kirby_X_Pos <= Kirby_X_Pos + Kirby_X_Step;
					end
			  end

	
     
    end
    
    // Compute whether the pixel corresponds to Kirby or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */

    always_comb begin
        if ((DrawX >= Kirby_X_Pos) && (DrawX < Kirby_X_Pos + 32) && (DrawY >= Kirby_Y_Pos) && (DrawY < Kirby_Y_Pos + 32)) 
            is_kirby = 1'b1;
        else
            is_kirby = 1'b0;
      
    end
    
endmodule
