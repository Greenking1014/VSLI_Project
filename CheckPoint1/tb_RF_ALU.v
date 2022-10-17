module tb_RF_ALU();

	localparam WIDTH = 16, REGBITS = 4;
	reg regWrite, shiftOrALU, alusrca,alurcb, shiftType;
	reg [WIDTH-1:0] shiftDirection, immediate;
	reg [REGBITS-1:0] aluControl, regAddress1, regAddress2;
	wire [WIDTH-1:0] result, pcreg;
   wire [7:0] PSR;
	
	RF_ALU rf_alu_testing(.clk(clk), .reset(reset),.regWrite(regWrite), .shiftOrAlu(shiftOrALU), .alusrca(alusrca), .alusrcb(alusrcb), .shiftDirection(shiftDirection),
    .aluControl(aluControl), .regAddress1(regAddress1), .regAddress2(regAddress2), .immediate(immediate), .shiftType(shiftType), .result(result), .pcreg(pcreg), .PSR(PSR));
	 
	 initial begin
	 
	 end
	 
	 
	 
endmodule 