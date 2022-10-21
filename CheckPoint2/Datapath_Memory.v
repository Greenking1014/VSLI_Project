module Datapath_Memory(input	[15:0]  address_a,
	input	[15:0]  address_b,
	input	  clock,
	input	[15:0]  data_a,
	input	[15:0]  data_b,
	input	  wren_a,
	input	  wren_b,
	output	[15:0]  q_a,
	output	[15:0]  q_b);
	
    EXRAM RAM(
    .address_a(address_a),
	.address_b(address_b),
	.clock(clock),
	.data_a(data_a),
	.data_b(data_b),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.q_a(q_a),
	.q_b(q_b));


endmodule