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
					input [7:0]	  keycode,
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
    
    logic [9:0] Kirby_X_Motion, Kirby_Y_Motion;
    logic [9:0] Kirby_X_Pos_in, Kirby_X_Motion_in, Kirby_Y_Pos_in, Kirby_Y_Motion_in;
    
	 initial begin
			Kirby_X_Motion = 0;
			Kirby_Y_Motion = 0;
			Kirby_X_Motion_in = 0;
			Kirby_Y_Motion_in = 0;
		
	 end
	 
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Kirby_X_Pos <= Kirby_X_Center;
            Kirby_Y_Pos <= Kirby_Y_Center;
            Kirby_X_Motion <= 10'd0;
            Kirby_Y_Motion <= Kirby_Y_Step;
        end
        else
        begin
				Kirby_X_Pos <= Kirby_X_Center;
				Kirby_Y_Pos <= Kirby_Y_Center;
		  /*
            Kirby_X_Pos <= Kirby_X_Pos_in;
            Kirby_Y_Pos <= Kirby_Y_Pos_in;
            Kirby_X_Motion <= Kirby_X_Motion_in;
            Kirby_Y_Motion <= Kirby_Y_Motion_in;
				*/
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
	 
        // By default, keep motion and position unchanged
        Kirby_X_Pos_in = Kirby_X_Pos;
        Kirby_Y_Pos_in = Kirby_Y_Pos;
        Kirby_X_Motion_in = Kirby_X_Motion;
        Kirby_Y_Motion_in = Kirby_Y_Motion;
       
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Kirby_Y_Pos - Kirby_Size <= Kirby_Y_Min 
            // If Kirby_Y_Pos is 0, then Kirby_Y_Pos - Kirby_Size will not be -4, but rather a large positive number.
				
				case(keycode) 
						8'h1A: begin	//occurs when you press UP
							Kirby_Y_Motion_in = (~(Kirby_Y_Step) + 1);
							Kirby_X_Motion_in = 0;
						end
					
						8'h16: begin	//occurs when you press DOWN
							Kirby_Y_Motion_in = Kirby_Y_Step;
							Kirby_X_Motion_in = 0;
						end
						
						8'h04: begin	//occurs when you press LEFT
							Kirby_X_Motion_in = (~(Kirby_X_Step) + 1);
							Kirby_Y_Motion_in = 0;
						end
						
						8'h07: begin	//occurs when you press RIGHT
							Kirby_X_Motion_in = Kirby_X_Step;
							Kirby_Y_Motion_in = 0;
						end
				
				endcase
				if( Kirby_Y_Pos + Kirby_Size >= Kirby_Y_Max ) begin // Kirby is at the bottom edge, BOUNCE!
					Kirby_Y_Motion_in = (~(Kirby_Y_Step) + 1'b1);  // 2's complement.  
					Kirby_X_Motion_in = 0;
				end else if ( Kirby_Y_Pos <= Kirby_Y_Min + Kirby_Size ) begin // Kirby is at the top edge, BOUNCE!
					Kirby_Y_Motion_in = Kirby_Y_Step;
					Kirby_X_Motion_in = 0;
				end else if( Kirby_X_Pos + Kirby_Size >= Kirby_X_Max ) begin // Kirby is at the bottom edge, BOUNCE!
					Kirby_X_Motion_in = (~(Kirby_X_Step) + 1'b1);  // 2's complement.
					Kirby_Y_Motion_in = 0;		
				end else if ( Kirby_X_Pos <= Kirby_X_Min + Kirby_Size ) begin // Kirby is at the top edge, BOUNCE!
					Kirby_X_Motion_in = Kirby_X_Step;
					Kirby_Y_Motion_in = 0;
				end
            // Update the Kirby's position with its motion
            Kirby_X_Pos_in = Kirby_X_Pos + Kirby_X_Motion;
            Kirby_Y_Pos_in = Kirby_Y_Pos + Kirby_Y_Motion;
        end

    end
    
    // Compute whether the pixel corresponds to Kirby or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - Kirby_X_Pos;
    assign DistY = DrawY - Kirby_Y_Pos;
    assign Size = Kirby_Size;
    always_comb begin
        if ((DrawX >= Kirby_X_Pos) && (DrawX < Kirby_X_Pos + 33) && (DrawY >= Kirby_Y_Pos) && (DrawY < Kirby_Y_Pos + 33)) 
            is_kirby = 1'b1;
        else
            is_kirby = 1'b0;
      
    end
    
endmodule
