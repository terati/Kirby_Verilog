//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input               is_kirby, is_attack, is_block, is_testblock, is_kirbysub, is_nothing,
							  input logic 			 LorR,
							  input logic  [9:0]  FLOAT_FSM, REGWALK_FSM, STILL_FSM,
							  input logic  [15:0] Block_X_Pos, Block_Y_Pos,Kirby_X_Pos, Kirby_Y_Pos,
                       input        [9:0]  DrawX, DrawY,       // Current pixel coordinates
							  output logic [19:0] ADDR
						
							  
                     );
    
	 logic [19:0] temp1,temp2,row,col;
    // Output colors to VGA
 //   assign VGA_R = Red;
 //   assign VGA_G = Green;
 //   assign VGA_B = Blue;
    
    // Assign color based on is_ball signal
    always_comb
    begin
			ADDR = '0;
			row = '0;
			col = '0;
			temp1 = '0;
			temp2 = '0;
       if(is_kirby == 1'b1) 
       begin
			if(is_kirbysub) 
			begin
				ADDR = '0;
				if(FLOAT_FSM == 10'd0) begin
					row = 0;
					col = 0;
				end else if(FLOAT_FSM == 10'd1) begin
					row = 0;
					col = 1;
				end else if(FLOAT_FSM == 10'd2) begin
					row = 0;
					col = 2;
				end else if(FLOAT_FSM == 10'd3) begin
					row = 0;
					col = 3;
				end else if(FLOAT_FSM == 10'd4) begin
					row = 0;
					col = 4;
				end else if(FLOAT_FSM == 10'd5) begin
					row = 0;
					col = 5;
				end else if(FLOAT_FSM == 10'd6) begin
					row = 0;
					col = 6;
				
				//--------------------------------------------------
				end else if(REGWALK_FSM == 10'd0) begin
					row = 0;
					col = 0;
				end else if(REGWALK_FSM == 10'd1) begin
					row = 0;
					col = 1;
				end else if(REGWALK_FSM == 10'd2) begin
					row = 0;
					col = 2;
				end else if(REGWALK_FSM == 10'd3) begin
					row = 0;
					col = 3;
				end else if(REGWALK_FSM == 10'd4) begin
					row = 0;
					col = 4;
				end else if(REGWALK_FSM == 10'd5) begin
					row = 0;
					col = 5;
				end else if(REGWALK_FSM == 10'd6) begin
					row = 0;
					col = 6;
					
				//--------------------------------------------------
				end else if(STILL_FSM == 10'd0) begin
					row = 0;
					col = 0;
				end else if(STILL_FSM == 10'd1) begin
					row = 0;
					col = 1;
				end else if(STILL_FSM == 10'd2) begin
					row = 0;
					col = 2;
				end else if(STILL_FSM == 10'd3) begin
					row = 0;
					col = 3;
				end else if(STILL_FSM == 10'd4) begin
					row = 0;
					col = 4;
				end else if(STILL_FSM == 10'd5) begin
					row = 0;
					col = 5;
				end else if(STILL_FSM == 10'd6) begin
					row = 0;
					col = 6;					
				end else begin
					row = 0;
					col = 0;
				end
				if(LorR) begin			//if kirby is floating faced right
					temp2 = '0;
					temp1 = (DrawY - Kirby_Y_Pos);
					ADDR = (((row << 5) << 9) + (col << 5)) + (temp1 << 9) + (DrawX - Kirby_X_Pos);
				end else begin			//if kirby is floating faced left
					temp2 = '0;
					temp1 = (DrawY - Kirby_Y_Pos); 
					ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - Kirby_X_Pos);
				end
			end
		  
		  
		  end else if(is_block == 1'b1)
		  begin
				if(is_testblock) begin
					row = 0;
					col = 0;
					temp1 = (DrawY - Block_Y_Pos); 
					ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - Block_X_Pos);
				end
		  end else 
		  begin
            // Background with nice color gradient
				row = 0;
				col = 0;
				temp2 = DrawY;
				temp1 = (temp2 << 9);
				ADDR = temp1 + DrawX;
            /*Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]}; */
        end
    end 
    
endmodule





module color_mapper_two (	input wire [7:0] index,
									output wire [7:0] Red, Green, Blue
								
								 );
always_comb
begin
if ((index==8'b000001))
begin
    Red=8'h80;
    Green=8'h00;
    Blue=8'h00;
end
else if ((index==8'b000010))
begin
    Red=8'h00;
    Green=8'h80;
    Blue=8'h00;
end
else if ((index==8'b000011))
begin
    Red=8'h80;
    Green=8'h80;
    Blue=8'h00;
end
else if ((index==8'b000100))
begin
    Red=8'h00;
    Green=8'h00;
    Blue=8'h80;
end
else if ((index==8'b000101))
begin
    Red=8'h80;
    Green=8'h00;
    Blue=8'h80;
end
else if ((index==8'b000110))
begin
    Red=8'h00;
    Green=8'h80;
    Blue=8'h80;
end
else if ((index==8'b000111))
begin
    Red=8'h80;
    Green=8'h80;
    Blue=8'h80;
end
else if ((index==8'b001000))
begin
    Red=8'hc0;
    Green=8'hdc;
    Blue=8'hc0;
end
else if ((index==8'b001001))
begin
    Red=8'ha6;
    Green=8'hca;
    Blue=8'hf0;
end
else if ((index==8'b001010))
begin
    Red=8'h2a;
    Green=8'h3f;
    Blue=8'haa;
end
else if ((index==8'b001011))
begin
    Red=8'h2a;
    Green=8'h3f;
    Blue=8'hff;
end
else if ((index==8'b001100))
begin
    Red=8'h2a;
    Green=8'h5f;
    Blue=8'h00;
end
else if ((index==8'b001101))
begin
    Red=8'h2a;
    Green=8'h5f;
    Blue=8'h55;
end
else if ((index==8'b001110))
begin
    Red=8'h2a;
    Green=8'h5f;
    Blue=8'haa;
end
else if ((index==8'b001111))
begin
    Red=8'h2a;
    Green=8'h5f;
    Blue=8'hff;
end
else if ((index==8'b010000))
begin
    Red=8'h2a;
    Green=8'h7f;
    Blue=8'h00;
end
else if ((index==8'b010001))
begin
    Red=8'h2a;
    Green=8'h7f;
    Blue=8'h55;
end
else if ((index==8'b010010))
begin
    Red=8'h2a;
    Green=8'h7f;
    Blue=8'haa;
end
else if ((index==8'b010011))
begin
    Red=8'h2a;
    Green=8'h7f;
    Blue=8'hff;
end
else if ((index==8'b010100))
begin
    Red=8'h2a;
    Green=8'h9f;
    Blue=8'h00;
end
else if ((index==8'b010101))
begin
    Red=8'h2a;
    Green=8'h9f;
    Blue=8'h55;
end
else if ((index==8'b010110))
begin
    Red=8'h2a;
    Green=8'h9f;
    Blue=8'haa;
end
else if ((index==8'b010111))
begin
    Red=8'h2a;
    Green=8'h9f;
    Blue=8'hff;
end
else if ((index==8'b011000))
begin
    Red=8'h2a;
    Green=8'hbf;
    Blue=8'h00;
end
else if ((index==8'b011001))
begin
    Red=8'h2a;
    Green=8'hbf;
    Blue=8'h55;
end
else if ((index==8'b011010))
begin
    Red=8'h2a;
    Green=8'hbf;
    Blue=8'haa;
end
else if ((index==8'b011011))
begin
    Red=8'h2a;
    Green=8'hbf;
    Blue=8'hff;
end
else if ((index==8'b011100))
begin
    Red=8'h2a;
    Green=8'hdf;
    Blue=8'h00;
end
else if ((index==8'b011101))
begin
    Red=8'h2a;
    Green=8'hdf;
    Blue=8'h55;
end
else if ((index==8'b011110))
begin
    Red=8'h2a;
    Green=8'hdf;
    Blue=8'haa;
end
else if ((index==8'b011111))
begin
    Red=8'h2a;
    Green=8'hdf;
    Blue=8'hff;
end
else if ((index==8'b100000))
begin
    Red=8'h2a;
    Green=8'hff;
    Blue=8'h00;
end
else if ((index==8'b100001))
begin
    Red=8'h2a;
    Green=8'hff;
    Blue=8'h55;
end
else if ((index==8'b100010))
begin
    Red=8'h2a;
    Green=8'hff;
    Blue=8'haa;
end
else if ((index==8'b100011))
begin
    Red=8'h2a;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b100100))
begin
    Red=8'h55;
    Green=8'h00;
    Blue=8'h00;
end
else if ((index==8'b100101))
begin
    Red=8'h55;
    Green=8'h00;
    Blue=8'h55;
end
else if ((index==8'b100110))
begin
    Red=8'h55;
    Green=8'h00;
    Blue=8'haa;
end
else if ((index==8'b100111))
begin
    Red=8'h55;
    Green=8'h00;
    Blue=8'hff;
end
else if ((index==8'b101000))
begin
    Red=8'h55;
    Green=8'h1f;
    Blue=8'h00;
end
else if ((index==8'b101001))
begin
    Red=8'h55;
    Green=8'h1f;
    Blue=8'h55;
end
else if ((index==8'b101010))
begin
    Red=8'h55;
    Green=8'h1f;
    Blue=8'haa;
end
else if ((index==8'b101011))
begin
    Red=8'h55;
    Green=8'h1f;
    Blue=8'hff;
end
else if ((index==8'b101100))
begin
    Red=8'h55;
    Green=8'h3f;
    Blue=8'h00;
end
else if ((index==8'b101101))
begin
    Red=8'h55;
    Green=8'h3f;
    Blue=8'h55;
end
else if ((index==8'b101110))
begin
    Red=8'h55;
    Green=8'h3f;
    Blue=8'haa;
end
else if ((index==8'b101111))
begin
    Red=8'h55;
    Green=8'h3f;
    Blue=8'hff;
end
else if ((index==8'b110000))
begin
    Red=8'h55;
    Green=8'h5f;
    Blue=8'h00;
end
else if ((index==8'b110001))
begin
    Red=8'h55;
    Green=8'h5f;
    Blue=8'h55;
end
else if ((index==8'b110010))
begin
    Red=8'h55;
    Green=8'h5f;
    Blue=8'haa;
end
else if ((index==8'b110011))
begin
    Red=8'h55;
    Green=8'h5f;
    Blue=8'hff;
end
else if ((index==8'b110100))
begin
    Red=8'h55;
    Green=8'h7f;
    Blue=8'h00;
end
else if ((index==8'b110101))
begin
    Red=8'h55;
    Green=8'h7f;
    Blue=8'h55;
end
else if ((index==8'b110110))
begin
    Red=8'h55;
    Green=8'h7f;
    Blue=8'haa;
end
else if ((index==8'b110111))
begin
    Red=8'h55;
    Green=8'h7f;
    Blue=8'hff;
end
else if ((index==8'b111000))
begin
    Red=8'h55;
    Green=8'h9f;
    Blue=8'h00;
end
else if ((index==8'b111001))
begin
    Red=8'h55;
    Green=8'h9f;
    Blue=8'h55;
end
else if ((index==8'b111010))
begin

    Red=8'haa;
    Green=8'h55;
    Blue=8'h55;
/*
    Red=8'h55;
    Green=8'h9f;
    Blue=8'haa;*/
	 
end
else if ((index==8'b111011))
begin
    Red=8'h55;
    Green=8'h9f;
    Blue=8'hff;
end
else if ((index==8'b111100))
begin
    Red=8'h55;
    Green=8'hbf;
    Blue=8'h00;
end
else if ((index==8'b111101))
begin
    Red=8'h55;
    Green=8'hbf;
    Blue=8'h55;
end
else if ((index==8'b111110))
begin
    Red=8'h55;
    Green=8'hbf;
    Blue=8'haa;
end
else if ((index==8'b111111))
begin
    Red=8'h55;
    Green=8'hbf;
    Blue=8'hff;
end
else if ((index==8'b1000000))
begin
    Red=8'h55;
    Green=8'hdf;
    Blue=8'h00;
end
else if ((index==8'b1000001))
begin
    Red=8'h55;
    Green=8'hdf;
    Blue=8'h55;
end
else if ((index==8'b1000010))
begin
    Red=8'h55;
    Green=8'hdf;
    Blue=8'haa;
end
else if ((index==8'b1000011))
begin
    Red=8'h55;
    Green=8'hdf;
    Blue=8'hff;
end
else if ((index==8'b1000100))
begin
    Red=8'h55;
    Green=8'hff;
    Blue=8'h00;
end
else if ((index==8'b1000101))
begin
    Red=8'h55;
    Green=8'hff;
    Blue=8'h55;
end
else if ((index==8'b1000110))
begin
    Red=8'h55;
    Green=8'hff;
    Blue=8'haa;
end
else if ((index==8'b1000111))
begin
    Red=8'h55;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b1001000))
begin
    Red=8'h7f;
    Green=8'h00;
    Blue=8'h00;
end
else if ((index==8'b1001001))
begin
    Red=8'h7f;
    Green=8'h00;
    Blue=8'h55;
end
else if ((index==8'b1001010))
begin
    Red=8'h7f;
    Green=8'h00;
    Blue=8'haa;
end
else if ((index==8'b1001011))
begin
    Red=8'h7f;
    Green=8'h00;
    Blue=8'hff;
end
else if ((index==8'b1001100))
begin
    Red=8'h7f;
    Green=8'h1f;
    Blue=8'h00;
end
else if ((index==8'b1001101))
begin
    Red=8'h7f;
    Green=8'h1f;
    Blue=8'h55;
end
else if ((index==8'b1001110))
begin
    Red=8'h7f;
    Green=8'h1f;
    Blue=8'haa;
end
else if ((index==8'b1001111))
begin
    Red=8'h7f;
    Green=8'h1f;
    Blue=8'hff;
end
else if ((index==8'b1010000))
begin
    Red=8'h7f;
    Green=8'h3f;
    Blue=8'h00;
end
else if ((index==8'b1010001))
begin
    Red=8'h7f;
    Green=8'h3f;
    Blue=8'h55;
end
else if ((index==8'b1010010))
begin
    Red=8'h7f;
    Green=8'h3f;
    Blue=8'haa;
end
else if ((index==8'b1010011))
begin
    Red=8'h7f;
    Green=8'h3f;
    Blue=8'hff;
end
else if ((index==8'b1010100))
begin
    Red=8'h7f;
    Green=8'h5f;
    Blue=8'h00;
end
else if ((index==8'b1010101))
begin
    Red=8'h7f;
    Green=8'h5f;
    Blue=8'h55;
end
else if ((index==8'b1010110))
begin
    Red=8'h7f;
    Green=8'h5f;
    Blue=8'haa;
end
else if ((index==8'b1010111))
begin
    Red=8'h7f;
    Green=8'h5f;
    Blue=8'hff;
end
else if ((index==8'b1011000))
begin
    Red=8'h7f;
    Green=8'h7f;
    Blue=8'h00;
end
else if ((index==8'b1011001))
begin
    Red=8'h7f;
    Green=8'h7f;
    Blue=8'h55;
end
else if ((index==8'b1011010))
begin
    Red=8'h7f;
    Green=8'h7f;
    Blue=8'haa;
end
else if ((index==8'b1011011))
begin
    Red=8'h7f;
    Green=8'h7f;
    Blue=8'hff;
end
else if ((index==8'b1011100))
begin
    Red=8'h7f;
    Green=8'h9f;
    Blue=8'h00;
end
else if ((index==8'b1011101))
begin
    Red=8'h7f;
    Green=8'h9f;
    Blue=8'h55;
end
else if ((index==8'b1011110))
begin
    Red=8'h7f;
    Green=8'h9f;
    Blue=8'haa;
end
else if ((index==8'b1011111))
begin
    Red=8'h7f;
    Green=8'h9f;
    Blue=8'hff;
end
else if ((index==8'b1100000))
begin
    Red=8'h7f;
    Green=8'hbf;
    Blue=8'h00;
end
else if ((index==8'b1100001))
begin
    Red=8'h7f;
    Green=8'hbf;
    Blue=8'h55;
end
else if ((index==8'b1100010))
begin
    Red=8'h7f;
    Green=8'hbf;
    Blue=8'haa;
end
else if ((index==8'b1100011))
begin
    Red=8'h7f;
    Green=8'hbf;
    Blue=8'hff;
end
else if ((index==8'b1100100))
begin
    Red=8'h7f;
    Green=8'hdf;
    Blue=8'h00;
end
else if ((index==8'b1100101))
begin
    Red=8'h7f;
    Green=8'hdf;
    Blue=8'h55;
end
else if ((index==8'b1100110))
begin
    Red=8'h7f;
    Green=8'hdf;
    Blue=8'haa;
end
else if ((index==8'b1100111))
begin
    Red=8'h7f;
    Green=8'hdf;
    Blue=8'hff;
end
else if ((index==8'b1101000))
begin
    Red=8'h7f;
    Green=8'hff;
    Blue=8'h00;
end
else if ((index==8'b1101001))
begin
    Red=8'h7f;
    Green=8'hff;
    Blue=8'h55;
end
else if ((index==8'b1101010))
begin
    Red=8'h7f;
    Green=8'hff;
    Blue=8'haa;
end
else if ((index==8'b1101011))
begin
    Red=8'h7f;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b1101100))
begin
    Red=8'haa;
    Green=8'h00;
    Blue=8'h00;
end
else if ((index==8'b1101101))
begin
    Red=8'haa;
    Green=8'h00;
    Blue=8'h55;
end
else if ((index==8'b1101110))
begin
    Red=8'haa;
    Green=8'h00;
    Blue=8'haa;
end
else if ((index==8'b1101111))
begin
    Red=8'haa;
    Green=8'h00;
    Blue=8'hff;
end
else if ((index==8'b1110000))
begin
    Red=8'haa;
    Green=8'h1f;
    Blue=8'h00;
end
else if ((index==8'b1110001))
begin
    Red=8'haa;
    Green=8'h1f;
    Blue=8'h55;
end
else if ((index==8'b1110010))
begin
    Red=8'haa;
    Green=8'h1f;
    Blue=8'haa;
end
else if ((index==8'b1110011))
begin
    Red=8'haa;
    Green=8'h1f;
    Blue=8'hff;
end
else if ((index==8'b1110100))
begin
    Red=8'haa;
    Green=8'h3f;
    Blue=8'h00;
end
else if ((index==8'b1110101))
begin
    Red=8'haa;
    Green=8'h3f;
    Blue=8'h55;
end
else if ((index==8'b1110110))
begin
    Red=8'haa;
    Green=8'h3f;
    Blue=8'haa;
end
else if ((index==8'b1110111))
begin
    Red=8'haa;
    Green=8'h3f;
    Blue=8'hff;
end
else if ((index==8'b1111000))
begin
    Red=8'haa;
    Green=8'h5f;
    Blue=8'h00;
end
else if ((index==8'b1111001))
begin
    Red=8'haa;
    Green=8'h5f;
    Blue=8'h55;
end
else if ((index==8'b1111010))
begin
    Red=8'haa;
    Green=8'h5f;
    Blue=8'haa;
end
else if ((index==8'b1111011))
begin
    Red=8'haa;
    Green=8'h5f;
    Blue=8'hff;
end
else if ((index==8'b1111100))
begin
    Red=8'haa;
    Green=8'h7f;
    Blue=8'h00;
end
else if ((index==8'b1111101))
begin
    Red=8'haa;
    Green=8'h7f;
    Blue=8'h55;
end
else if ((index==8'b1111110))
begin
    Red=8'haa;
    Green=8'h7f;
    Blue=8'haa;
end
else if ((index==8'b1111111))
begin
    Red=8'haa;
    Green=8'h7f;
    Blue=8'hff;
end
else if ((index==8'b10000000))
begin
    Red=8'haa;
    Green=8'h9f;
    Blue=8'h00;
end
else if ((index==8'b10000001))
begin
    Red=8'haa;
    Green=8'h9f;
    Blue=8'h55;
end
else if ((index==8'b10000010))
begin
    Red=8'haa;
    Green=8'h9f;
    Blue=8'haa;
end
else if ((index==8'b10000011))
begin
    Red=8'haa;
    Green=8'h9f;
    Blue=8'hff;
end
else if ((index==8'b10000100))
begin
    Red=8'haa;
    Green=8'hbf;
    Blue=8'h00;
end
else if ((index==8'b10000101))
begin
    Red=8'haa;
    Green=8'hbf;
    Blue=8'h55;
end
else if ((index==8'b10000110))
begin
    Red=8'haa;
    Green=8'hbf;
    Blue=8'haa;
end
else if ((index==8'b10000111))
begin
    Red=8'haa;
    Green=8'hbf;
    Blue=8'hff;
end
else if ((index==8'b10001000))
begin
    Red=8'haa;
    Green=8'hdf;
    Blue=8'h00;
end
else if ((index==8'b10001001))
begin
    Red=8'haa;
    Green=8'hdf;
    Blue=8'h55;
end
else if ((index==8'b10001010))
begin
    Red=8'haa;
    Green=8'hdf;
    Blue=8'haa;
end
else if ((index==8'b10001011))
begin
    Red=8'haa;
    Green=8'hdf;
    Blue=8'hff;
end
else if ((index==8'b10001100))
begin
    Red=8'haa;
    Green=8'hff;
    Blue=8'h00;
end
else if ((index==8'b10001101))
begin
    Red=8'haa;
    Green=8'hff;
    Blue=8'h55;
end
else if ((index==8'b10001110))
begin
    Red=8'haa;
    Green=8'hff;
    Blue=8'haa;
end
else if ((index==8'b10001111))
begin
    Red=8'haa;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b10010000))
begin
    Red=8'hd4;
    Green=8'h00;
    Blue=8'h00;
end
else if ((index==8'b10010001))
begin
    Red=8'hd4;
    Green=8'h00;
    Blue=8'h55;
end
else if ((index==8'b10010010))
begin
    Red=8'hd4;
    Green=8'h00;
    Blue=8'haa;
end
else if ((index==8'b10010011))
begin
    Red=8'hd4;
    Green=8'h00;
    Blue=8'hff;
end
else if ((index==8'b10010100))
begin
    Red=8'hd4;
    Green=8'h1f;
    Blue=8'h00;
end
else if ((index==8'b10010101))
begin
    Red=8'hd4;
    Green=8'h1f;
    Blue=8'h55;
end
else if ((index==8'b10010110))
begin
    Red=8'hd4;
    Green=8'h1f;
    Blue=8'haa;
end
else if ((index==8'b10010111))
begin
    Red=8'hd4;
    Green=8'h1f;
    Blue=8'hff;
end
else if ((index==8'b10011000))
begin
    Red=8'hd4;
    Green=8'h3f;
    Blue=8'h00;
end
else if ((index==8'b10011001))
begin
    Red=8'hd4;
    Green=8'h3f;
    Blue=8'h55;
end
else if ((index==8'b10011010))
begin
    Red=8'hd4;
    Green=8'h3f;
    Blue=8'haa;
end
else if ((index==8'b10011011))
begin
    Red=8'hd4;
    Green=8'h3f;
    Blue=8'hff;
end
else if ((index==8'b10011100))
begin
    Red=8'hd4;
    Green=8'h5f;
    Blue=8'h00;
end
else if ((index==8'b10011101))
begin
    Red=8'hd4;
    Green=8'h5f;
    Blue=8'h55;
end
else if ((index==8'b10011110))
begin
    Red=8'hd4;
    Green=8'h5f;
    Blue=8'haa;
end
else if ((index==8'b10011111))
begin
    Red=8'hd4;
    Green=8'h5f;
    Blue=8'hff;
end
else if ((index==8'b10100000))
begin
    Red=8'hd4;
    Green=8'h7f;
    Blue=8'h00;
end
else if ((index==8'b10100001))
begin
    Red=8'hd4;
    Green=8'h7f;
    Blue=8'h55;
end
else if ((index==8'b10100010))
begin
    Red=8'hd4;
    Green=8'h7f;
    Blue=8'haa;
end
else if ((index==8'b10100011))
begin
    Red=8'hd4;
    Green=8'h7f;
    Blue=8'hff;
end
else if ((index==8'b10100100))
begin
    Red=8'hd4;
    Green=8'h9f;
    Blue=8'h00;
end
else if ((index==8'b10100101))
begin
    Red=8'hd4;
    Green=8'h9f;
    Blue=8'h55;
end
else if ((index==8'b10100110))
begin
    Red=8'hd4;
    Green=8'h9f;
    Blue=8'haa;
end
else if ((index==8'b10100111))
begin
    Red=8'hd4;
    Green=8'h9f;
    Blue=8'hff;
end
else if ((index==8'b10101000))
begin
    Red=8'hd4;
    Green=8'hbf;
    Blue=8'h00;
end
else if ((index==8'b10101001))
begin
    Red=8'hd4;
    Green=8'hbf;
    Blue=8'h55;
end
else if ((index==8'b10101010))
begin
    Red=8'hd4;
    Green=8'hbf;
    Blue=8'haa;
end
else if ((index==8'b10101011))
begin
    Red=8'hd4;
    Green=8'hbf;
    Blue=8'hff;
end
else if ((index==8'b10101100))
begin
    Red=8'hd4;
    Green=8'hdf;
    Blue=8'h00;
end
else if ((index==8'b10101101))
begin
    Red=8'hd4;
    Green=8'hdf;
    Blue=8'h55;
end
else if ((index==8'b10101110))
begin
    Red=8'hd4;
    Green=8'hdf;
    Blue=8'haa;
end
else if ((index==8'b10101111))
begin
    Red=8'hd4;
    Green=8'hdf;
    Blue=8'hff;
end
else if ((index==8'b10110000))
begin
    Red=8'hd4;
    Green=8'hff;
    Blue=8'h00;
end
else if ((index==8'b10110001))
begin
    Red=8'hd4;
    Green=8'hff;
    Blue=8'h55;
end
else if ((index==8'b10110010))
begin
    Red=8'hd4;
    Green=8'hff;
    Blue=8'haa;
end
else if ((index==8'b10110011))
begin
    Red=8'hd4;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b10110100))
begin
    Red=8'hff;
    Green=8'h00;
    Blue=8'h55;
end
else if ((index==8'b10110101))
begin
    Red=8'hff;
    Green=8'h00;
    Blue=8'haa;
end
else if ((index==8'b10110110))
begin
    Red=8'hff;
    Green=8'h1f;
    Blue=8'h00;
end
else if ((index==8'b10110111))
begin
    Red=8'hff;
    Green=8'h1f;
    Blue=8'h55;
end
else if ((index==8'b10111000))
begin
    Red=8'hff;
    Green=8'h1f;
    Blue=8'haa;
end
else if ((index==8'b10111001))
begin
    Red=8'hff;
    Green=8'h1f;
    Blue=8'hff;
end
else if ((index==8'b10111010))
begin
    Red=8'hff;
    Green=8'h3f;
    Blue=8'h00;
end
else if ((index==8'b10111011))
begin
    Red=8'hff;
    Green=8'h3f;
    Blue=8'h55;
end
else if ((index==8'b10111100))
begin
    Red=8'hff;
    Green=8'h3f;
    Blue=8'haa;
end
else if ((index==8'b10111101))
begin
    Red=8'hff;
    Green=8'h3f;
    Blue=8'hff;
end
else if ((index==8'b10111110))
begin
    Red=8'hff;
    Green=8'h5f;
    Blue=8'h00;
end
else if ((index==8'b10111111))
begin
    Red=8'hff;
    Green=8'h5f;
    Blue=8'h55;
end
else if ((index==8'b11000000))
begin
    Red=8'hff;
    Green=8'h5f;
    Blue=8'haa;
end
else if ((index==8'b11000001))
begin
    Red=8'hff;
    Green=8'h5f;
    Blue=8'hff;
end
else if ((index==8'b11000010))
begin
    Red=8'hff;
    Green=8'h7f;
    Blue=8'h00;
end
else if ((index==8'b11000011))
begin
    Red=8'hff;
    Green=8'h7f;
    Blue=8'h55;
end
else if ((index==8'b11000100))
begin
    Red=8'hff;
    Green=8'h7f;
    Blue=8'haa;
end
else if ((index==8'b11000101))
begin
    Red=8'hff;
    Green=8'h7f;
    Blue=8'hff;
end
else if ((index==8'b11000110))
begin
    Red=8'hff;
    Green=8'h9f;
    Blue=8'h00;
end
else if ((index==8'b11000111))
begin
    Red=8'hff;
    Green=8'h9f;
    Blue=8'h55;
end
else if ((index==8'b11001000))
begin
    Red=8'hff;
    Green=8'h9f;
    Blue=8'haa;
end
else if ((index==8'b11001001))
begin
    Red=8'hff;
    Green=8'h9f;
    Blue=8'hff;
end
else if ((index==8'b11001010))
begin
    Red=8'hff;
    Green=8'hbf;
    Blue=8'h00;
end
else if ((index==8'b11001011))
begin
    Red=8'hff;
    Green=8'hbf;
    Blue=8'h55;
end
else if ((index==8'b11001100))
begin
    Red=8'hff;
    Green=8'hbf;
    Blue=8'haa;
end
else if ((index==8'b11001101))
begin
    Red=8'hff;
    Green=8'hbf;
    Blue=8'hff;
end
else if ((index==8'b11001110))
begin
    Red=8'hff;
    Green=8'hdf;
    Blue=8'h00;
end
else if ((index==8'b11001111))
begin
    Red=8'hff;
    Green=8'hdf;
    Blue=8'h55;
end
else if ((index==8'b11010000))
begin
    Red=8'hff;
    Green=8'hdf;
    Blue=8'haa;
end
else if ((index==8'b11010001))
begin
    Red=8'hff;
    Green=8'hdf;
    Blue=8'hff;
end
else if ((index==8'b11010010))
begin
    Red=8'hff;
    Green=8'hff;
    Blue=8'h55;
end
else if ((index==8'b11010011))
begin
    Red=8'hff;
    Green=8'hff;
    Blue=8'haa;
end
else if ((index==8'b11010100))
begin
    Red=8'hcc;
    Green=8'hcc;
    Blue=8'hff;
end
else if ((index==8'b11010101))
begin
    Red=8'hff;
    Green=8'hcc;
    Blue=8'hff;
end
else if ((index==8'b11010110))
begin
    Red=8'h33;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b11010111))
begin
    Red=8'h66;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b11011000))
begin
    Red=8'h99;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b11011001))
begin
    Red=8'hcc;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b11011010))
begin
    Red=8'h00;
    Green=8'h7f;
    Blue=8'h00;
end
else if ((index==8'b11011011))
begin
    Red=8'h00;
    Green=8'h7f;
    Blue=8'h55;
end
else if ((index==8'b11011100))
begin
    Red=8'h00;
    Green=8'h7f;
    Blue=8'haa;
end
else if ((index==8'b11011101))
begin
    Red=8'h00;
    Green=8'h7f;
    Blue=8'hff;
end
else if ((index==8'b11011110))
begin
    Red=8'h00;
    Green=8'h9f;
    Blue=8'h00;
end
else if ((index==8'b11011111))
begin
    Red=8'h00;
    Green=8'h9f;
    Blue=8'h55;
end
else if ((index==8'b11100000))
begin
    Red=8'h00;
    Green=8'h9f;
    Blue=8'haa;
end
else if ((index==8'b11100001))
begin
    Red=8'h00;
    Green=8'h9f;
    Blue=8'hff;
end
else if ((index==8'b11100010))
begin
    Red=8'h00;
    Green=8'hbf;
    Blue=8'h00;
end
else if ((index==8'b11100011))
begin
    Red=8'h00;
    Green=8'hbf;
    Blue=8'h55;
end
else if ((index==8'b11100100))
begin
    Red=8'h00;
    Green=8'hbf;
    Blue=8'haa;
end
else if ((index==8'b11100101))
begin
    Red=8'h00;
    Green=8'hbf;
    Blue=8'hff;
end
else if ((index==8'b11100110))
begin
    Red=8'h00;
    Green=8'hdf;
    Blue=8'h00;
end
else if ((index==8'b11100111))
begin
    Red=8'h00;
    Green=8'hdf;
    Blue=8'h55;
end
else if ((index==8'b11101000))
begin
    Red=8'h00;
    Green=8'hdf;
    Blue=8'haa;
end
else if ((index==8'b11101001))
begin
    Red=8'h00;
    Green=8'hdf;
    Blue=8'hff;
end
else if ((index==8'b11101010))
begin
    Red=8'h00;
    Green=8'hff;
    Blue=8'h55;
end
else if ((index==8'b11101011))
begin
    Red=8'h00;
    Green=8'hff;
    Blue=8'haa;
end
else if ((index==8'b11101100))
begin
    Red=8'h2a;
    Green=8'h00;
    Blue=8'h00;
end
else if ((index==8'b11101101))
begin
    Red=8'h2a;
    Green=8'h00;
    Blue=8'h55;
end
else if ((index==8'b11101110))
begin
    Red=8'h2a;
    Green=8'h00;
    Blue=8'haa;
end
else if ((index==8'b11101111))
begin
    Red=8'h2a;
    Green=8'h00;
    Blue=8'hff;
end
else if ((index==8'b11110000))
begin
    Red=8'h2a;
    Green=8'h1f;
    Blue=8'h00;
end
else if ((index==8'b11110001))
begin
    Red=8'h2a;
    Green=8'h1f;
    Blue=8'h55;
end
else if ((index==8'b11110010))
begin
    Red=8'h2a;
    Green=8'h1f;
    Blue=8'haa;
end
else if ((index==8'b11110011))
begin
    Red=8'h2a;
    Green=8'h1f;
    Blue=8'hff;
end
else if ((index==8'b11110100))
begin
    Red=8'h2a;
    Green=8'h3f;
    Blue=8'h00;
end
else if ((index==8'b11110101))
begin
    Red=8'h2a;
    Green=8'h3f;
    Blue=8'h55;
end
else if ((index==8'b11110110))
begin
    Red=8'hff;
    Green=8'hfb;
    Blue=8'hf0;
end
else if ((index==8'b11110111))
begin
    Red=8'ha0;
    Green=8'ha0;
    Blue=8'ha4;
end
else if ((index==8'b11111000))
begin
    Red=8'h80;
    Green=8'h80;
    Blue=8'h80;
end
else if ((index==8'b11111001))
begin
    Red=8'hff;
    Green=8'h00;
    Blue=8'h00;
end
else if ((index==8'b11111010))
begin
    Red=8'h00;
    Green=8'hff;
    Blue=8'h00;
end
else if ((index==8'b11111011))
begin
    Red=8'hff;
    Green=8'hff;
    Blue=8'h00;
end
else if ((index==8'b11111100))
begin
    Red=8'h00;
    Green=8'h00;
    Blue=8'hff;
end
else if ((index==8'b11111101))
begin
    Red=8'hff;
    Green=8'h00;
    Blue=8'hff;
end
else if ((index==8'b11111110))
begin
    Red=8'h00;
    Green=8'hff;
    Blue=8'hff;
end
else if ((index==8'b11111111))
begin
    Red=8'hff;
    Green=8'hff;
    Blue=8'hff;
end
else
begin
    Red=8'h00 ;
    Green=8'h00;
    Blue=8'h00;
end
end
endmodule
