module tb_cpALU();
parameter WIDTH = 16;
reg  [WIDTH-1:0] pc;
reg  [WIDTH-1:0] immediate;
reg 	 			  jumpEN;
reg  [WIDTH-1:0] RTarget;
reg				  jalEN;
wire [WIDTH-1:0] Rlink;
wire [WIDTH-1:0] pcOut;
 
pcALU UUT (.pc(pc), .immediate(immediate), .jumpEN(jumpEN), .RTarget(RTarget),
				.jalEN(jalEN), .Rlink(Rlink), .pcOut(pcOut));

initial begin
    pc <= 16'h0000;
	 immediate <= 16'h0000;
	 jumpEN <= 0;
	 RTarget <= 16'h0000;
	 jalEN <= 0;
	 
	 #10;
	 
	 //Test Regular PC incrementing
	 if(Rlink == 16'h0000 && pcOut == 16'h0001)
		$display("PC incremented normally");
	 else
		$display("PC did not increment as expected \ngot: %h should be: 0001", pc);
	 
	 #10;
	 immediate <= 16'h0009;
	 jumpEN <= 1;
	 pc <= pcOut;
	 #10;
	 
	 //Test jump based PC increment
	 if(Rlink == 16'h0000 && pcOut == 16'h000a)
		$display("PC incremented by the correct immediate value");
	 else
		$display("PC did not increment correctly \ngot: %h should be 000a", pcOut);
	 
	 #10;
	 jumpEN <= 0;
	 jalEN <= 1;
	 RTarget <= 16'h1000;
	 pc <= pcOut;
	 #10;
	 
	 //Test Jump and Link Increment
	 if(Rlink == 16'h000b && pcOut == RTarget)
		$display("PC changed corretly using JAL instruction");
	 else begin
		$display("PC did not jump and link the way it should");
		$display("PC: %h should be %h, Rlink: %h, should be 000b", pcOut, RTarget, Rlink);
	end
end



endmodule