`timescale 1 ps / 1 ps
module tb_mem_cpu;

reg clk,reset;
reg [15:0] data_b;
reg [7:0] switches;
wire [6:0] seg0, seg1, seg2, seg3;
wire wren_a,wren_b;
wire [15:0]	address_a,
    address_b,
	data_a,
	q_a,
	q_b;

mem_cpu UUT(
	.clk(clk),
	.reset(reset),
	.switches(switches),
	.data_b(data_b),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.address_a(address_a),
    .address_b(address_b),
	.data_a(data_a),
	.q_a(q_a),
	.q_b(q_b),
	.seg0(seg0),
	.seg1(seg1),
	.seg2(seg2),
	.seg3(seg3)
);

localparam CLK_PERIOD = 10;
	always #(CLK_PERIOD/2) clk=~clk;

	initial begin
		{clk, reset} <= 0;
		switches <= 8'h03;
	end

    initial begin
	 reset <= 0;
     #CLK_PERIOD;
	 #5;
     reset <= 1;
	 end

endmodule