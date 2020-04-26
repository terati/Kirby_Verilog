
module  kirbyRAM
(
		input logic [19:0] R_ADDR,
		input 				Clk,

		output logic [7:0] data_Out
);

logic [7:0] mem [0:49151]; //the first three rows of the Kirby sprite sheet. 

initial
begin
	 $readmemh("spritesheet4.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[R_ADDR];
end

endmodule
