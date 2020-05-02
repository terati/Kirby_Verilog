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


module testing_Topfile( input               CLOCK_50,
           
				 
				 output logic  		FL_WE_N,      // Write Enable 
				 output        		FL_WP_N,      // Write Protect / Programming Acceleration
				 output logic  		FL_RST_N,     // Reset
				 output        		FL_OE_N,      // Output Enable
				 output       			FL_CE_N,      // Chip Enable
				 input         		FL_RY,	 	  // Ready / Busy
				 inout  wire  [7:0]  FL_DQ,        // Data bus (8 Bits)
				 output logic [22:0] FL_ADDR,       // Address bus (23 Bits)
				 
				 output 					AUD_ADCLRCK,	//ignored
											AUD_ADCDAT,		//ignored
											AUD_DACLRCK,   //DAC sample clock
											AUD_DACDAT,		//data line
											AUD_XCK,       //master clock
											AUD_BCLK,		//bit clock
											I2C_SCLK,
				 inout 					I2C_SDAT
											
				 
                    );
    
	 logic START, DONE, Reset, twelveclock;
	 logic [7:0] AUD_ADDR = 8'b0011_0100;
	 logic [7:0] FSM_state;
	 logic [7:0] zerosecdata = 8'b000_0100_0, zerothirddata = 8'b0001_0101,
					 onesecdata = 8'b000_0101_0, onethirddata = 8'b0000_0000, 
					 twosecdata = 8'b000_0110_0, twothirddata = 8'b0000_0000,
					 threesecdata = 8'b000_0111_0, threethirddata = 8'b0100_0010,
					 foursecdata = 8'b000_1000_0, fourthirddata = 8'b0001_1001,
					 fivesecdata = 8'b000_1001_0, fivethirddata = 8'b0000_0001,
					 secdata, thirddata;
	 logic [2:0] sel; 
   
    assign Clk = CLOCK_50;
	 
	 initial begin
			FSM_state = 8'b0;
			START = 1'b0;
	 end
	 
    always_ff @ (posedge Clk) begin
        
		  case(FSM_state)
				8'd0: begin			//0
					START <= 1'b1;
					sel <= 3'd0;
					FSM_state <= FSM_state + 1'd1;
				end
				
				8'd1: begin
					START <= 1'b0;
					if(DONE) begin
						FSM_state <= FSM_state + 1'd1;
					end else begin
						FSM_state <= 8'd1;
					end
				end
				
				8'd2: begin    		//1
					START <= 1'b1;
					sel <= 3'd1;
					FSM_state <= FSM_state + 1'd1; 
				end
				
				8'd3: begin
					START <= 1'b0;
					if(DONE) begin
						FSM_state <= FSM_state + 1'd1;
					end else begin
						FSM_state <= 8'd3;
					end
				end
				
				8'd4: begin			 //2
					START <= 1'b1;
					sel <= 3'd2;
					FSM_state <= FSM_state + 1'd1; 
				end
				
				
				8'd5: begin
					START <= 1'b0;
					if(DONE) begin
						FSM_state <= FSM_state + 1'd1;
					end else begin
						FSM_state <= 8'd5;
					end
				end
				
				8'd6: begin			 //3
					START <= 1'b1;
					sel <= 3'd3;
					FSM_state <= FSM_state + 1'd1; 
				end
				
				
				8'd7: begin
					START <= 1'b0;
					if(DONE) begin
						FSM_state <= FSM_state + 1'd1;
					end else begin
						FSM_state <= 8'd7;
					end
				end
				
				8'd8: begin			 //4
					START <= 1'b1;
					sel <= 3'd4;
					FSM_state <= FSM_state + 1'd1; 
				end
				
				
				8'd9: begin
					START <= 1'b0;
					if(DONE) begin
						FSM_state <= FSM_state + 1'd1;
					end else begin
						FSM_state <= 8'd9;
					end
				end
				
				8'd10: begin			 //5
					START <= 1'b1;
					sel <= 3'd5;
					FSM_state <= FSM_state + 1'd1; 
				end
				
				
				8'd11: begin
					START <= 1'b0;
					if(DONE) begin
						FSM_state <= 8'd0;
					end else begin
						FSM_state <= 8'd11;
					end
				end
				
		  
		  endcase
    end

    
	 AUD_MUX(	 .zerosecdata, 
					 .zerothirddata,
					 .onesecdata, 
					 .onethirddata, 
					 .twosecdata, 
					 .twothirddata,
					 .threesecdata, 
					 .threethirddata,
					 .foursecdata, 
					 .fourthirddata,
					 .fivesecdata, 
					 .fivethirddata,
					 
					 .sel,
					 .secdata, 
					 .thirddata
				
			);
	 
	 I2C_AUD aud(  .Clk,
						.Reset,
						.AUD_ADDR, 
						.secdata,
						.thirddata,
						.I2C_SCLK,
						.I2C_SDAT,
						.START,
						.DONE
				);
    

	 pll pll1( .areset(),
					.inclk0(Clk),
					.c0(twelveclock),
					.locked()
				);
	 
	 //FLASH forced PINs
	 assign FL_WE_N = 1'b1;	//writing into FLASH is slow so no
	 assign FL_WP_N = 1'b1;	//used in the factory to accelerate processing
	 assign FL_RST_N = 1'b1;
	 assign FL_OE_N = 1'b0;
	 assign FL_CE_N = 1'b0;
	 
	
	 
	 
	 
endmodule
