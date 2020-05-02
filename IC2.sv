module AUD_MUX (input [7:0] zerosecdata, zerothirddata,
									 onesecdata, onethirddata, 
									 twosecdata, twothirddata,
									 threesecdata, threethirddata,
									 foursecdata, fourthirddata,
									 fivesecdata, fivethirddata,
					 input  [2:0] sel,
					 output [7:0] secdata, thirddata
					 );
	always_comb
		begin
			case(sel)
				3'b000: begin secdata = zerosecdata;
						 thirddata = zerothirddata;
							end
						 
				3'b001: begin secdata = onesecdata;
						 thirddata = onethirddata;
						 end
						 
				3'b010: begin secdata = twosecdata;
						 thirddata = twothirddata;
						 end
						 
				3'b011: begin secdata = threesecdata;
						 thirddata = threethirddata;
						 end
						 
				3'b100: begin secdata = foursecdata;
						 thirddata = fourthirddata;
						 end
						 
				3'b101: begin secdata = fivesecdata;
						 thirddata = fivethirddata;
							end
			endcase
		end
					 
endmodule


module I2C_AUD (  input  Clk, Reset,
						input [7:0] AUD_ADDR, secdata, thirddata,
                  output I2C_SCLK,
						output  I2C_SDAT,
						input START,
						output logic DONE
						);
	
	



logic [7:0] SingleByteData;

logic SCL, SDA;
logic [2:0 ]flag;
logic [7:0] State;

logic ACK_bit;
localparam STATE_INIT = 8'b0;

assign I2C_SCLK = SCL;
assign I2C_SDAT = SDA;

initial begin
	SCL = 1'b1;
	flag = 3'b0;
	SDA = 1'b0;
	
	State = 8'b0;
end


always @(posedge Clk) begin
	case(State)
		 STATE_INIT : begin
                 if (START) begin
							State <= 8'd1;
							DONE <= 1'b0;
                 end else begin   
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd0;
                  end
            end            
            
            // This is the Start sequence            
            8'd1 : begin
						SingleByteData <= AUD_ADDR;
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            8'd2 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            // transmit bit 7   
            8'd3 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[7];
                  State <= State + 1'b1;                 
            end   

            8'd4 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd5 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd6 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd7 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[6];  
                  State <= State + 1'b1;               
            end   

            8'd8 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd9 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd10 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd11 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[5]; 
                  State <= State + 1'b1;                
            end   

            8'd12 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd13 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd14 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd15 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[4]; 
                  State <= State + 1'b1;                
            end   

            8'd16 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd17 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd18 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd19 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[3]; 
                  State <= State + 1'b1;                
            end   

            8'd20 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd21 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd22 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd23 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[2]; 
                  State <= State + 1'b1;                
            end   

            8'd24 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd25 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd26 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd27 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[1];  
                  State <= State + 1'b1;               
            end   

            8'd28 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd29 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd30 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd31 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[0];      
                  State <= State + 1'b1;           
            end   

            8'd32 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd33 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd34 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit 
            8'd35 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd36 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd37 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   

            8'd38 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
				
				8'd39 : begin
                  SCL <= 1'b0;
						if(flag == 3'd0) begin
							flag <= 3'd1;
							SingleByteData <= secdata;
							State <= 8'd3;
						end else if(flag == 3'd1) begin
							flag <= 3'd2;
							SingleByteData <= thirddata;
							State <= 8'd3;
						end else begin
							flag <= 3'd0;
							State <= State + 1'b1;
						end 
            end

				8'd40 : begin    //ending conditions
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            8'd41 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
						DONE <= 1'b1;
                  State <= 8'd1;    
            end   
		endcase		
end

endmodule
