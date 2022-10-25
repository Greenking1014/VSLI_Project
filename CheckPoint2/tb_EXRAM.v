`timescale 1 ps / 1 ps
module tb_EXRAM;
reg	  wren_b;
reg	[15:0]  address_a;
reg	[15:0]  address_b;
reg	  clock;
reg	[15:0]  data_a;
reg	[15:0]  data_b;
reg	  wren_a;
wire	[15:0]  q_a;
wire	[15:0]  q_b;

/* NOTE to be able to run the test the library altera_mf_ver needs to be included*/
EXRAM UUT(
	.address_a(address_a),
	.address_b(address_b),
	.clock(clock),
	.data_a(data_a),
	.data_b(data_b),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.q_a(q_a),
	.q_b(q_b));

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clock=~clock;

initial begin
    address_a <= 16'h0;
	address_b <= 16'h0;
	clock <= 0;
	data_a <= 16'h0;
	data_b <= 16'h0;
	wren_a <= 0;
	wren_b <= 0;
end

integer testnumber =  16'hC000;
initial begin
    // testing storing value to RAM
    data_a <= 16'hFFFF;
    address_a <= 16'h0004;
    wren_a <= 1;
    // output is obtained after one clock cycle when data is written to the mem loc
    #CLK_PERIOD;
    #CLK_PERIOD;
    $display("the value stored at %h is :  %h", address_a, q_a);

    // writing to location C000 to C0FF same adresses the LED will use
    #CLK_PERIOD;

		for(testnumber = 16'hC000;testnumber <= 16'hC0FF ;testnumber = testnumber + 1)
			begin
                address_a <= testnumber;
                #CLK_PERIOD;
			end

        wren_a <= 0;
    #CLK_PERIOD;
        for(testnumber = 16'hC000;testnumber <= 16'hC0FF ;testnumber = testnumber + 1)
			begin
                address_a <= testnumber;
                #CLK_PERIOD;
                if(q_a != 16'hFFFF ) $display("error in getting value from memoryat address %h is %h",address_a, q_a);
				else $display("the value stored at %h is :  %h", address_a, q_a);
                
			end
end

endmodule