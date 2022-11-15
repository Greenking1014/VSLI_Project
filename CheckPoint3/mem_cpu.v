module mem_cpu(
	input clk, reset,
	input [7:0] switches,
	input [15:0] data_b, //?
	output wren_a, wren_b,
	output [15:0] address_a, address_b, data_a, q_a, q_b,
	output [6:0] seg0, seg1, seg2, seg3 
);	
	wire address_in_IO_A;
	wire address_in_IO_B; 

	reg writeEN_A, writeEN_B;
	reg [15:0] memOut_A, memOut_B;
	reg [15:0] segValue;

	reg [3:0] segCode0, segCode1, segCode2, segCode3;
// instantiate devices to be tested 
// wire nonclk = ~clk;
	localparam INSTRUCTION_MEM = 16'h0000, INTERRUPT_CONTROL = 16'h5FFF, DATA_STACK = 16'h6FFE, IO_MEM = 16'hCFFD; // INSTRUCTION and DATA sections are of the same size (0x5FFE addresses).
	localparam SWITCHES_LOC = 16'hCFFD, LEDS_LOC = 16'hCFFE;

	assign address_b = 16'h0000;
	assign address_in_IO_A = address_a >= IO_MEM;
	assign address_in_IO_B = address_b >= IO_MEM;

	EXRAM mem(
		address_a,
		address_b,
		clk,
		data_a,
		data_b,
		writeEN_A,
		writeEN_B,
		q_a,
		q_b
	);

	arrozYlecheCPU #(16, 4, INSTRUCTION_MEM, INTERRUPT_CONTROL, DATA_STACK, IO_MEM) cpu 
	(
		clk,                  // 50MHz clock
		reset,                // active-low reset
		memOut_A,        // data that is read from memory
		wren_a,  
		wren_b,           // write-enable to memory
		address_a,           // address to memory
		data_a      // write data to memory
	);

	hexTo7Seg_3710 segUnit1(
		segCode0,
		seg0
	);
	hexTo7Seg_3710 segUnit2(
		segCode1,
		seg1
	);
	hexTo7Seg_3710 segUnit3(
		segCode2,
		seg2
	);
	hexTo7Seg_3710 segUnit4(
		segCode3,
		seg3
	);

	always @(*) begin
	
		segValue <= {segCode3, segCode2, segCode1, segCode0};
		if(address_in_IO_A) begin
			case(address_a)
				SWITCHES_LOC:
					begin
						writeEN_A <= 0;
						memOut_A <= {{8{1'b0}},switches};
					end
				LEDS_LOC:
					begin
						writeEN_A <= 0;
						memOut_A <= {segCode3, segCode2, segCode1, segCode0};
						segValue <= data_a;
					end
				default:
					begin
						writeEN_A <= wren_a;
						memOut_A <= q_a;
					end
			endcase
		end
		else begin
			writeEN_A <= wren_a;
			memOut_A <= q_a;
		end

		if(address_in_IO_B) begin
			case(address_b)
				SWITCHES_LOC:
					begin
						writeEN_B <= 0;
						memOut_B <= {{8{1'b0}},switches};
					end
				LEDS_LOC:
					begin
						writeEN_B <= 0;
						memOut_B <= {segCode3, segCode2, segCode1, segCode0};
						segValue <= data_b;
					end
				default:
					begin
						writeEN_B <= wren_b;
						memOut_B <= q_b;
					end
			endcase
		end
		else begin
			writeEN_B <= wren_b;
			memOut_B <= q_b;			
		end
	end
	always @(posedge clk) begin
		if((wren_a && ~writeEN_A) || (wren_b && ~writeEN_B)) begin
			{segCode3, segCode2, segCode1, segCode0} <= segValue;
		end
		if(~reset) begin
			{segCode3, segCode2, segCode1, segCode0} <= 16'h0000;
		end
	end
endmodule
