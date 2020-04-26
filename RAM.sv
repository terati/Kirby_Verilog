/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  frameRAM
(
    // 256 colors, 8 bits
		input [7:0] data_In,
		input [19:0] write_address, read_address,
		input we, Clk,

		output logic [7:0] data_Out
);

// mem has width of 8 bits and a total of 640*480 addresses (for each pixel)
logic [7:0] mem [0:49151];

initial
begin
		$readmemh("sprite_bytes/tetris_I.txt", mem);
end

// read and write from frameRAM
always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
