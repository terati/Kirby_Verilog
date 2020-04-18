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
					input [15:0]	  keycode,
					output [9:0]  Kirby_X_Pos, Kirby_Y_Pos
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
        if ((DrawX >= Kirby_X_Pos) && (DrawX < Kirby_X_Pos + 33) && (DrawY >= Kirby_Y_Pos) && (DrawY < Kirby_Y_Pos + 33)) 
            is_kirby = 1'b1;
        else
            is_kirby = 1'b0;
      
    end
    
endmodule
