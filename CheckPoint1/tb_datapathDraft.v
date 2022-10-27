/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/
module tb_datapathDraft #(parameter WIDTH = 16, REGBITS = 4);
    
     reg  clk, reset, PCEN,PSREN,
	      nextInstruction, updateAddress,
	 	  StoreReg, WriteData,regWrite,
	  	ZeroExtend, PCinstruction,SrcB,
	 	shiftType, jumpEN,BranchEN,jalEN;

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
	 	shiftType, jumpEN,BranchEN,jalEN} <= 16'h0;

	{shiftDir,  memdata} <= 32'h0;
	shiftAmt <= 8'h0;
	ALUcond  <= 4'h0;
	chooseResult <= 2'b0;
	 end

	 initial begin
		# CLK_PERIOD reset = 1;
		# CLK_PERIOD reset = 0;

		




	 end

endmodule