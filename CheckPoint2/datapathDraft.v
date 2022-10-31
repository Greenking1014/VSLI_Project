/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero//
*/

module datapathDraft #(parameter WIDTH = 16, REGBITS = 4)(
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
	 input					 SrcB,
	 input					 shiftType,
	 input					resultEn,
	 input [WIDTH-1:0]    shiftDir,
	 input [7:0]          shiftAmt,
	 input [REGBITS-1:0]  ALUcond,
	 input					 jumpEN,
	 input 					 BranchEN,
	 input                jalEN,
	 input [1:0]			 chooseResult,
	 output [WIDTH-1:0]   memOut,
	 output [WIDTH-1:0]   address,
	 output [7:0] PSROut
);	
    wire [WIDTH-1:0] regData1, regData2;
	wire [REGBITS -1:0] regAddress1, regAddress2;
    wire [WIDTH-1:0] aluResult1,aluResult2,aluResult,shiftOut;
    wire [WIDTH-1:0] src1, src2;
    wire [WIDTH-1:0] opOutput;
    wire [7:0]       PSRresult;
	wire [WIDTH-1:0] regDataWB;
	wire [WIDTH-1:0] immediate;
	wire  [15:0] instr;
    wire [15:0] pc;
	wire [WIDTH-1:0] Rlink;
	wire [WIDTH-1:0] shiftDirection;
	wire [WIDTH-1:0] newResult;
	wire [WIDTH-1:0] result;

	
    // registers for results
    flopenr #(WIDTH) pcregUnit(clk,reset,PCEN,aluResult2,pc); //enable based
    flopenr #(8) PSRreg(clk,reset,PSREN,PSRresult,PSROut);	// out to the control unit
    flopenr #(WIDTH) instrReg(clk,reset,nextInstruction,memdata,instr);
	flopenr #(WIDTH) resultReg(clk,reset,resultEn,newResult,result);

    
	// set Reg Addresses for src1 and src2
	assign regAddress1 = instr[11:8];
	assign regAddress2 = instr[3:0];
	 
	// Choose between load from memory or store result
	mux2 #(WIDTH) updateReg(memdata, result, WriteData, regDataWB);
	 
	// Choose between Zero Extend or Sign Extend
	mux2 #(WIDTH) extend({{8{instr[7]}},instr[7:0]},{{8{1'b0}},instr[7:0]}, ZeroExtend, immediate);
	 
	// set src1 and src2
    mux2 #(WIDTH) src1Mux(regData1, pc, PCinstruction, src1);
    mux2 #(WIDTH) src2mux(immediate, regData2, SrcB, src2);
    
	 // output from shifter and AlU unit
    mux4 #(WIDTH) outputMUX(shiftOut, aluResult1, aluResult2, Rlink, chooseResult, newResult);
	 
	 // Next Address to pass to memeory
	 mux2 #(WIDTH) memAddress(regData2, pc, updateAddress, address);
	 
	 // Data to write to memory
	 mux2 #(WIDTH) dataToStore(result, regData1, StoreReg, memOut);
	 
    // pc counter doesnt care about PSR for now
    pcALU #(WIDTH) pc_ALU(src1,src2,jumpEN,jalEN,BranchEN,Rlink,aluResult2);
    
	 // Operational units
    shifter #(WIDTH) shifterUnit(src1, shiftDirection, shiftType, shiftOut); // Check on later
    RegisterFile #(WIDTH, REGBITS) regFile(clk, regWrite, regAddress1, regAddress2, regDataWB, regData1, regData2);
    ALU #(WIDTH) alu_unit(src1, src2, ALUcond,aluResult1, PSRresult);

	assign shiftDirection = immediate;
	

endmodule 
