
module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic Clk = 0;
logic [7:0] AUD_ADDR = 8'b1100_0011;
logic [7:0] secdata = 8'b0011_1100;
logic [7:0] thirddata= 8'b1111_0000;
logic I2C_SCLK;
logic I2C_SDAT;
logic START;
logic DONE;
logic Reset;


I2C_AUD wolfram_aud(.*);	

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 



initial begin: TEST_VECTORS

#0 Reset = 1'b0;
#2 START = 1'b1; 


end 
endmodule


