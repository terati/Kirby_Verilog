

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







module  waddleRAM
(
		input logic [19:0] R_ADDR,
		input 				Clk,

		output logic [7:0] data_Out
);

logic [7:0] mem [0:180224]; //the first three rows of the Kirby sprite sheet. 

initial
begin
	 $readmemh("Enemygrid.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[R_ADDR];
end

endmodule





module  atkRAM
(
		input logic [19:0] R_ADDR,
		input 				Clk,

		output logic [7:0] data_Out
);

logic [7:0] mem [0:16384]; //only contains 1 row. 

initial
begin
	 $readmemh("atk.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[R_ADDR];
end

endmodule




module  bossatkRAM
(
		input logic [19:0] R_ADDR,
		input 				Clk,

		output logic [7:0] data_Out
);

logic [7:0] mem [0:16384]; //only contains 1 row. 

initial
begin
	 $readmemh("bossattack.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[R_ADDR];
end

endmodule





