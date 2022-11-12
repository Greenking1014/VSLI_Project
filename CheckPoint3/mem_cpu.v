module mem_cpu(
	clk,
	reset,
	wren_a,
	wren_b,
	address_a,
    address_b,
	data_a,
    data_b,
	q_a,
	q_b
);

input clk , reset;
input [15:0] data_b;
output wren_a,wren_b;
output [15:0] address_a, address_b,data_a,q_a,q_b;
// instantiate devices to be tested 
// wire nonclk = ~clk;

EXRAM mem(
	address_a,
	address_b,
	clk,
	data_a,
	data_b,
	wren_a,
	wren_b,
	q_a,
	q_b);

arrozYlecheCPU cpu 
   (clk,                  // 50MHz clock
    reset,                // active-low reset
    q_a,        // data that is read from memory
    wren_a,  
    wren_b,           // write-enable to memory
    address_a,           // address to memory
    data_a      // write data to memory
    );

endmodule
