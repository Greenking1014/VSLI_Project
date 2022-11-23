module mem_cpu(
	input clk, reset,
	input [7:0] switches,
	input [15:0] data_b, //?
	output wren_a, wren_b,
	output [15:0] address_a, address_b, data_a, q_a, q_b,
	output [6:0] seg0, seg1, seg2, seg3 
);	
	wire address_in_IO_A;//, wren_a, wren_b;
	wire address_in_IO_B; 
	//wire [15:0] address_a, address_b, data_a, q_a, q_b;

	reg writeEN_A, writeEN_B;
	wire [15:0] memOut_A, memOut_B;
	reg [15:0] segValue = 16'h0000;
	//reg [15:0] data_b = 16'b0;

	wire [3:0] segCode0, segCode1, segCode2, segCode3;
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
                    end
                LEDS_LOC:
                    begin
                        writeEN_A <= 0;
						if(wren_a)
							segValue <= data_a;
	                end
                default:
                    begin
                        writeEN_A <= wren_a;
                    end
            endcase
        end
        else begin
            writeEN_A <= wren_a;
        end

        if(address_in_IO_B) begin
            case(address_b)
                SWITCHES_LOC:
                    begin
                        writeEN_B <= 0;
                    end
                LEDS_LOC:
                    begin
                        writeEN_B <= 0;
						if(wren_b)
	                        segValue <= data_b;
                    end
                default:
                    begin
                        writeEN_B <= wren_b;
                    end
            endcase
        end
        else begin
            writeEN_B <= wren_b;
        end
		if(~reset)
			segValue <= 16'h0000;
	end

	assign memOut_A = (address_in_IO_A) ? {{8{1'b0}},switches}: q_a;
	assign memOut_B = (address_in_IO_B) ? {{8{1'b0}},switches}: q_b;
	
	assign segCode3 = (wren_a) ? data_a[15:12]: segCode3;
	assign segCode2 = (wren_a) ? data_a[11:8]: segCode2;
	assign segCode1 = (wren_a) ? data_a[7:4]: segCode1;
	assign segCode0 = (wren_a) ? data_a[3:0]: segCode0;

endmodule
