/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/
module tb_datapathDraft #(parameter WIDTH = 16, REGBITS = 4);
    
     reg  clk, reset, PCEN,PSREN,
	      nextInstruction, updateAddress,
	 	  StoreReg, WriteData,regWrite,
	  	ZeroExtend, PCinstruction,SrcB,
	 	shiftType,resultEn, jumpEN,BranchEN,jalEN;

	 reg [WIDTH-1:0]    shiftDir,  memdata;
	 reg [7:0]          shiftAmt;
	 reg [REGBITS-1:0]  ALUcond;
	 reg [1:0]			 chooseResult;
	 wire [WIDTH-1:0]   memOut;
	 wire [WIDTH-1:0]   address;
	 wire [7:0] PSROut;

    datapathDraft UUT(
    .clk(clk), 
    .reset(reset),
	.memdata(memdata),
	.PCEN(PCEN),
	.PSREN(PSREN),
	.nextInstruction(nextInstruction),
	.updateAddress(updateAddress),
	.StoreReg(StoreReg),
	.WriteData(WriteData),
	.regWrite(regWrite),
	.ZeroExtend(ZeroExtend),
	.PCinstruction(PCinstruction),
	.SrcB(SrcB),
	.shiftType(shiftType),
	.resultEn(resultEn),
	.shiftDir(shiftDir),
	.shiftAmt(shiftAmt),
	.ALUcond(ALUcond),
	.jumpEN(jumpEN),
	.BranchEN(BranchEN),
	.jalEN(jalEN),
	.chooseResult(chooseResult),
	.memOut(memOut),
	.address(address),
	.PSROut(PSROut)
);

localparam CLK_PERIOD = 10;
	always #(CLK_PERIOD/2) clk=~clk;

	initial begin
	{clk, reset, PCEN,PSREN,
	      nextInstruction, updateAddress,
	 	  StoreReg, WriteData,regWrite,
	  	ZeroExtend, PCinstruction,SrcB,
	 	shiftType, jumpEN,BranchEN,jalEN,resultEn} <= 17'h0;

	{shiftDir,  memdata} <= 32'h0;
	shiftAmt <= 8'h0;
	ALUcond  <= 4'h0;
	chooseResult <= 2'b0;
	 end

	 initial begin
		# CLK_PERIOD reset = 1;
		# CLK_PERIOD reset = 0;

		// testing datapath 
		// Addition memdata = 0x0152 -> R1 = R1 + R2
		// dstreg is ffff dstsrc aaaa 
		// NOTES: we expect the result to be aaa9 the PSR to be updated the adress should be 0000 because we have to
		// increment pc in a different state. Destination register should have the value of the result store to it.
		
		WriteData = 1;
		nextInstruction = 1;
		SrcB = 1;
		memdata = 16'h0152;
		updateAddress = 1;
		chooseResult = 2'b01;
		regWrite = 1;
		PSREN = 1;
		ALUcond = 4'b0101;
		resultEn = 1;

		# CLK_PERIOD;
		#CLK_PERIOD;
		
		if(memOut != 16'haaa9) $display("the result of the sum op is incorrect, the value was: %h",memOut);
		else $display("the result of the sum op is correct");

		PSREN = 0;
		
		if(PSROut != 8'h0a) $display("the result of the PSR is incorrect, the value was: %h",PSROut);
		else $display("the result of PSR is correct");
		
		#CLK_PERIOD;

		if(UUT.regFile.rd1 != 16'haaa9)  $display("the result stored in the Register Destination is incorrect, the value was: %h",UUT.regFile.RAM[4'b0001]);
		else $display("the result is stored in the destination register is correct");


		// testing the pc path to see if it increases by one
		# CLK_PERIOD; 
		PCEN = 1;
		updateAddress = 1;
		PCinstruction = 1;
		resultEn = 1;
		# CLK_PERIOD;
		PCEN = 0;
		if(address != 16'h0001) $display("the result of the PCis incorrect, the value was: %h",address);
		else $display("the result of PSR is correct");


		// testing sign extend path to pc
		# CLK_PERIOD reset = 1;
		# CLK_PERIOD reset = 0;
		
		#CLK_PERIOD;
		nextInstruction = 1;
		memdata = 16'h0182;
		resultEn = 1;

		#CLK_PERIOD;
		SrcB = 0;
		PCEN = 1;
		BranchEN = 1;

		#CLK_PERIOD;
		PCEN = 0;
		

		if(address != 16'hFF82) $display("the result of the PCis incorrect, the value was: %h",address);
		else $display("the value for address is correct");


		// testing zero extend path to pc
		# CLK_PERIOD reset = 1;
		# CLK_PERIOD reset = 0;
		
		#CLK_PERIOD;
		nextInstruction = 1;
		memdata = 16'h0182;
		
		
		#CLK_PERIOD;
		SrcB = 0;
		PCEN = 1;
		BranchEN = 1;
		ZeroExtend = 1;
		chooseResult = 2'b10;
		resultEn = 1;

		#CLK_PERIOD;
		PCEN = 0;

		if(address != 16'h0082 && memOut != 16'h0082) $display("the result of the PC is incorrect, the value was: %h the value of memOUT is incorrect should be %h",address,memOut);
		else $display("the value for address and memOut is correct");


		// testing JAL path 
		# CLK_PERIOD reset = 1;
		# CLK_PERIOD reset = 0;

		#CLK_PERIOD;
		nextInstruction = 1;
		memdata = 16'h0384;

		#CLK_PERIOD;
		SrcB = 1;
		PCEN = 1;
		resultEn = 1;
		
		jalEN = 1;
		chooseResult = 2'b11;

	    #CLK_PERIOD;
		PCEN = 0;

		if(address != 16'hbbbb && memOut != 16'h0001) $display("the result of the PC is incorrect, the value was: %h the value of memOUT is incorrect should be %h",address,memOut);
		else $display("the value for address and memOut is correct");

		
		// Test storeReg =1, where the first reg/ regDst data is memOut
		# CLK_PERIOD reset = 1;
		# CLK_PERIOD reset = 0;

		#CLK_PERIOD;
		regWrite = 0;
		nextInstruction = 1;
		memdata = 16'h0484;

		#CLK_PERIOD;
		StoreReg = 1;

		#CLK_PERIOD;
		PCEN = 0;
		
		if(memOut != 16'hbbbb) $display("the data set to memory is incorrect the value obtain was %h and it should be %h ",memOut,UUT.regFile.rd1);
		else $display("the value for address and memOut is correct");

		// Test WriteData = 0, where memData or data input is stored to redDst
		# CLK_PERIOD reset = 1;
		# CLK_PERIOD reset = 0;

		#CLK_PERIOD;
		regWrite = 1;
		WriteData = 0;
		nextInstruction = 1;
		memdata = 16'hfbaf;

		#CLK_PERIOD;
		StoreReg = 1;

		#CLK_PERIOD;
		PCEN = 0;
		
		if(memOut != 16'hfbaf) $display("the data set to memory is incorrect the value obtain was %h and it should be %h ",memOut,UUT.regFile.rd1);
		else $display("the value for address and memOut is correct");

		//Test shifter and choosing shifter result expecting 5555 shifting right aaaa
		# CLK_PERIOD reset = 1;
		# CLK_PERIOD reset = 0;

		PCinstruction = 0;
		nextInstruction = 1;

		#CLK_PERIOD;
		memdata = 16'haaaa;
		shiftDir = 16'hFFFF;
		regWrite = 1;
		shiftType = 0;
		WriteData = 1;
		#CLK_PERIOD;
		chooseResult = 2'b00;
		StoreReg = 0;

		if(memOut != 16'h5555) $display("the data set to memory is incorrect the value obtain was %h and it should be %h ",memOut,UUT.regFile.rd1);
		else $display("the value for address and memOut is correct");
		

	 end

endmodule