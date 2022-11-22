`timescale 1 ps / 1 ps
module tb_mem_cpu;

reg clk,reset;
reg [15:0] data_b;
wire wren_a,wren_b;
wire [15:0]	address_a,
    address_b,
	data_a,
	q_a,
	q_b;

mem_cpu UUT(
	.clk(clk),
	.reset(reset),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.address_a(address_a),
    .address_b(address_b),
	.data_a(data_a),
    .data_b(data_b),
	.q_a(q_a),
	.q_b(q_b)
);

localparam CLK_PERIOD = 10;
	always #(CLK_PERIOD/2) clk=~clk;

	initial begin
	{clk, reset} <= 0;
	 end

    initial begin
	 reset <= 0;
     #CLK_PERIOD;
	 #5;
     reset <= 1;
	 end

endmodule