module tb_shifter();
	
	parameter WIDTH = 16;
	reg [WIDTH-1:0] src, shiftDirection;
	reg shiftType;
	wire [WIDTH-1:0] shiftOut;
	
	shifter shift(.src(src), .shiftDirection(shiftDirection), .shiftType(shiftType), .shiftOut(shiftOut));
	
	localparam CLK_PERIOD = 10;
	
	//initialize inputs
	initial begin
		//----------------------------------- Basic no shifting ------------------------------------------------
		//testing logical shift first with all values set to zero, should result in a zero.
		src = 16'h0;
		shiftDirection = 16'h0;
		shiftType = 0;
		
		#20; //waiting to display the values
		$display("No shifting");
		
		if(shiftOut == 0) $display("the output is 0, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		//----------------------------------- Logical shift ------------------------------------------------
		//testing logical right shift first with all values set to hex: FFFF, should result in a hex: 7FFF.
		src = 16'hffff;
		shiftDirection = 16'hFFFF;
		shiftType = 1;
		
		#20; //waiting to display the values
		$display("starting Logical shifting");
		
		if(shiftOut == 16'h7FFF) $display("the output is 7fff, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		//testing logical left shift first with all values set to hex: FFFF, should result in a hex: 7FFF.
		src = 16'hffff;
		shiftDirection = 16'h0001;
		
		#20; //waiting to display the values
		
		if(shiftOut == 16'hFFFE) $display("the output is hex: FFFE, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		//testing logical right shift first with all values set to hex: 0001, should result in a hex: 0000.
		src = 16'h0001;
		shiftDirection = 16'hFFFF;
		
		#20; //waiting to display the values
		
		if(shiftOut == 16'h0000) $display("the output is 0000, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		//testing logical left shift first with all values set to hex: 0001, should result in a hex: 0002.
		shiftDirection = 16'h0001;
		
		#20; //waiting to display the values
		
		if(shiftOut == 16'h0002) $display("the output is hex: 0002, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		//----------------------------------- Arthemtic shift ------------------------------------------------
		//testing Arthemtic right shift first with all values set to hex: FFFF, should result in a hex: BFFF.
		src = 16'hffff;
		shiftDirection = 16'hFFFF;
		shiftType = 0;
		
		#20; //waiting to display the values
		$display("Testing arthemtic shift");
		
		if(shiftOut == 16'hFFFF) $display("the output is hex: FFFF, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		//testing logical left shift first with all values set to hex: FFFF, should result in a hex: 7FFF.
		shiftDirection = 16'h0001;
		
		#20; //waiting to display the values
		
		if(shiftOut == 16'hFFFE) $display("the output is hex: FFFE, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		
		//testing Arthemtic right shift first with all values set to hex: 8000, should result in a hex: C000.
		src = 16'h8000;
		shiftDirection = 16'hFFFF;
		
		#20; //waiting to display the values
		
		if(shiftOut == 16'hc000) $display("the output is hex: c000, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		//testing logical left shift first with all values set to hex: 8000, should result in a hex: 8000.
		shiftDirection = 16'h0001;
		
		#20; //waiting to display the values
		
		if(shiftOut == 16'h0000) $display("the output is hex: FFFE, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
		
		#20; //waiting to display the values
		shiftDirection = 16'h0000;
		if(shiftOut == 16'h0000) $display("the output is hex: FFFE, it works!");
		else $display("it is wrong, we need help, the output value for shiftOut is: %b", shiftOut);
	end	
	
endmodule 