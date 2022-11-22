/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/
module tb_RF_ALU();

	localparam WIDTH = 16, REGBITS = 4;
	reg regWrite, shiftOrALU, alusrca,alusrcb, shiftType,clk,reset;
	reg [WIDTH-1:0] shiftDirection, immediate;
	reg [REGBITS-1:0] aluControl, regAddress1, regAddress2;
	wire [WIDTH-1:0] result, pcreg;
   	wire [7:0] PSR;
	reg [WIDTH-1: 0]  pc;
	reg			    jumpEN;
	reg [WIDTH-1: 0]  RTarget;
	reg               jalEN;
   reg ALUselect;
	wire [WIDTH-1: 0] Rlink;
	
	RF_ALU rf_alu_testing(.clk(clk), .reset(reset),.regWrite(regWrite), .shiftOrALU(shiftOrALU), .alusrca(alusrca), .alusrcb(alusrcb), .shiftDirection(shiftDirection),
    .aluControl(aluControl), .regAddress1(regAddress1), .regAddress2(regAddress2), .immediate(immediate), .shiftType(shiftType),.pc(pc),
    .jumpEN(jumpEN),.RTarget(RTarget),.jalEN(jalEN),.ALUselect(ALUselect),.Rlink(Rlink), .result(result), .pcreg(pcreg), .PSR(PSR));
	
	localparam CLK_PERIOD = 10;
	always #(CLK_PERIOD/2) clk=~clk;

	 initial begin
	 clk = 0;
	 reset = 0;
	 regWrite = 0;
	 shiftOrALU = 0;
	 alusrca = 0; //for mux2
	 alusrcb = 0; //for mux2
	 shiftType = 0;
	 shiftDirection = 0;
	 immediate = 0;
	 aluControl = 4'b0000; //opcode extension for AND
	 regAddress1 = 1;
	 regAddress2 = 2;
	 ALUselect = 0;
	 end

	 initial begin
		reset = 1;
		# CLK_PERIOD reset = 0;
		
		// Testing Basic Datapath for ALU operations
		//opcode extension for AND
		aluControl = 4'b0001;
		alusrca = 1;
		shiftOrALU = 1;
		regAddress1 = 4'h1;
		regAddress2 = 4'h2;
		regWrite = 1;
		
		# 20;
		if(result != 16'haaaa) $display("result is wrong, value obtained %h",result);
		else $display("AND operation works correctly in the datapath");

		// Testing large unsigned number and negative number
		# CLK_PERIOD;
		aluControl = 4'b0101;
		
		if(result != 16'hffff) $display("result is wrong, value obtained %h",result);
		else $display("SUM operation works correctly in the datapath");


		


	 end
	 
	 
	 
endmodule 
