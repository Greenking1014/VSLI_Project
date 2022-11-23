/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero//
*/

module datapathDraft #(parameter WIDTH = 16, REGBITS = 4, INSTRUCTION_MEM = 16'h0000, INTERRUPT_CONTROL = 16'h5FFF, DATA_STACK = 16'h6FFE, IO_MEM = 16'hCFFD)(
   input                clk, reset,
	input [WIDTH-1:0]    memdata,
	input                PCEN,
	input					 PSREN,
	input                   nextInstruction,
	input					 updateAddress,
	input					 StoreReg,
	input					 WriteData,
	input					 regWrite,
	input 					 ZeroExtend,
	input					 PCinstruction,
	input					 regDest,
	input					 SrcB,
	input					resultEn,
	input					immediateRegEN,
	input [REGBITS-1:0]	shiftAmt,
	input [REGBITS-1:0]	shifterControl,
	input [REGBITS-1:0]  ALUcond,
	input					 jumpEN,
	input 					 BranchEN,
	input                jalEN,
	input [1:0]			 chooseResult,
	output [WIDTH-1:0]   memOut,
	output [WIDTH-1:0]   address,
	output [7:0] PSROut,
	output [15:0] instrOut
);	
	localparam RA = 4'hf;
	
   wire [WIDTH-1:0] regData1, regData2;
	wire [REGBITS -1:0] regAddress1, regAddress2, regDestination;
   wire [WIDTH-1:0] aluResult1,aluResult2,aluResult,shiftOut;
   wire [WIDTH-1:0] src1, src2;
   wire [WIDTH-1:0] opOutput;
   wire [7:0]       PSRresult;
	wire [WIDTH-1:0] regDataWB;
	wire [WIDTH-1:0] immediate, immediateRegVal;
	wire  [15:0] instr;
   wire [15:0] pc;
	wire [WIDTH-1:0] Rlink;
	wire [WIDTH-1:0] shiftDirection;
	wire [WIDTH-1:0] newResult;
	wire [WIDTH-1:0] result;

	
	// registers for results
	flopenr #(WIDTH, INSTRUCTION_MEM) pcregUnit(clk,reset,PCEN,aluResult2,pc); //enable based
	flopenr #(8, 8'h00) PSRreg(clk,reset,PSREN,PSRresult,PSROut);	// out to the control unit
	flopenr #(WIDTH, 16'h0000) instrReg(clk,reset,nextInstruction,memdata,instr);
	flopenr #(WIDTH, 16'h0000) resultReg(clk,reset,resultEn,newResult,result);
	flopenr #(WIDTH, 16'h0000) immediateReg(clk, reset, immediateRegEN, immediate, immediateRegVal);
  
	// set Reg Addresses for src1 and src2
	assign regAddress1 = instr[11:8];
	assign regAddress2 = instr[3:0];
	assign instrOut = instr;
	// Choose between load from memory or store result
	mux2 #(WIDTH) updateReg(memdata, result, WriteData, regDataWB);
	 
	// Choose between Zero Extend or Sign Extend
	mux2 #(WIDTH) extend({{8{instr[7]}},instr[7:0]},{{8{1'b0}},instr[7:0]}, ZeroExtend, immediate);
	 
	// set Rdest
	mux2 #(WIDTH) rDestMux(regAddress1, RA, regDest, regDestination);
	// set src1 and src2
	mux2 #(WIDTH) src1Mux(regData1, pc, PCinstruction, src1);
	mux2 #(WIDTH) src2mux(immediateRegVal, regData2, SrcB, src2);

	// output from shifter and AlU unit
	mux4 #(WIDTH) outputMUX(shiftOut, aluResult1, aluResult2, Rlink, chooseResult, newResult);
 
	// Next Address to pass to memeory
	mux2 #(WIDTH) memAddress(regData2, pc, updateAddress, address);
	
	// Data to write to memory
	mux2 #(WIDTH) dataToStore(result, regData1, StoreReg, memOut);
	 
	// pc counter doesnt care about PSR for now
	pcALU #(WIDTH, INTERRUPT_CONTROL) pc_ALU(src1,src2,jumpEN,jalEN,BranchEN,Rlink,aluResult2);

	// Operational units
	shifter #(WIDTH) shifterUnit(src1, src2, shiftAmt, shifterControl, shiftOut);
	RegisterFile #(WIDTH, REGBITS, INSTRUCTION_MEM, INTERRUPT_CONTROL, DATA_STACK, IO_MEM) regFile(clk, reset, regWrite, regDestination, regAddress2, regDataWB, regData1, regData2);
	ALU #(WIDTH) alu_unit(src1, src2, ALUcond,aluResult1, PSRresult);	

endmodule 
