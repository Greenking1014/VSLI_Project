/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/

module RF_ALU #(parameter WIDTH = 16, REGBITS = 4)(
    input                clk, reset,
	 input [WIDTH-1:0]    memdata,
	 input                PCEN,
	 input					 NextInstruction,
	 //input					 WREN_A, WREN_B,
	 input					 StoreReg,
	 input					 WriteData,
	 input 					 ZeroExtend,
	 input					 PCinstruction,
	 input					 SrcB,
	 input					 shiftType,
	 input [WIDTH-1:0]    shiftDir,
	 input [7:0]          shiftAmt,
	 input [REGBITS-1:0]  ALUcond,
	 input					 JmpEN,
	 input 					 BranchEN,
	 input                JALEN,
	 input [1:0]			 chooseResult,
	 output [WIDTH-1:0]   DataOut,
	 output [WIDTH-1:0]   address,
);
    wire [WIDTH-1:0] regData1, regData2;
    wire [WIDTH-1:0] aluResult1,aluResult2,aluResult,shiftOut;
    wire [WIDTH-1:0] src1, src2;
    wire [WIDTH-1:0] opOutput;
    wire [7:0]       PSRresult;
	 wire [WIDTH-1:0] regDataWB;
	 wire [WIDTH-1:0] immediate;
    
    // registers for results
    flopr #(WIDTH) pcregUnit(clk, reset, opOutput, pcreg);
    flopr #(8) PSRreg(clk, reset, PSRresult, PSR);
    flopr #(WIDTH) resultreg(clk, reset, opOutput, result);
    
	 // set src1 and src2
    mux2 #(WIDTH) src1Mux(pcreg, regData1, alusrca, src1);
    mux2 #(WIDTH) src2mux(regData2, immediate, alusrcb, src2);
    
	 // output from shifter and AlU unit
    //mux2 #(WIDTH) outputMux(shiftOut, aluResult, shiftOrALU, opOutput);
    mux4 #(WIDTH) outputMUX(shiftOut, aluResult1, aluResult2, Rlink, chooseResult, DataOut);
	 
	 // Choose between load from memory or store result
	 mux2 #(WIDTH) updateReg(memdata, DataOut, WriteData, regDataWB);
	 
	 // Choose between Zero Extend or Sign Extend
	 mux2 #(WIDTH) extend({8{[7]instr}, [7:0]instr}, {0{8}, [7:0]instr}, ZeroExtend, immediate);
	 
	 // Next Address to pass to memeory
	 mux2 #(WIDTH) memAddress(regData2, pc, NextInstruction, address);
	 
	 // Data to write to memory
	 mux2 #(WIDTH) dataToStore(DataOut, regData2, StoreReg, DataOut);
	 
    // pc counter doesnt care about PSR for now
    pcALU #(WIDTH) pc_ALU(src1,src2,jumpEN,RTarget,jalEN,Rlink,aluResult2);
    
	 // Operational units
    shifter #(WIDTH) shifterUnit(src1, shiftDirection, shiftType, shiftOut);
    RegisterFile #(WIDTH, REGBITS) regFile(clk, regWrite, regAddress1, regAddress2, writeData, regData1, regData2);
    ALU #(WIDTH) alu_unit(src1, src2, aluControl,aluResult1, PSRresult);
    
	 // mux select from ALU basic or pcALU
    //mux2 #(WIDTH) ALUmux(aluResult1, aluResult2, ALUselect, aluResult);

    assign writeData = opOutput;
	 // Side Attempt
	 // Assuming memory is instatinated outside of datapath
	 // input memdata 16 bit
	 // Output instr? 16 bit reg
	 // output writedata/result
	 // pc enable signal and psr enable signal
	 
	 // wires to pass around outputs
	 wire [REGBITS-1:0] regAddr1, regAddr2;
	 wire [WIDTH-1:0]   pc, nextPC, loadAddr, addr, storeAddr, writeData, regData1, regData2, src1, src2,
									PSRresult, ALUResult, PCALUResult, Rlink;
	 
	 // assign addresses for registers
	 assign regAddr1 = instr[15:12];
	 assign regAddr2 = instr[3:0];
	 
	 // load instruction
	 flopr #(8) ir(clk, reset, memdata[15:0], instr[15:0]);
	 
	 // data path and muxes owo
	 flopenr #(WIDTH) pcreg(clk, reset, pcen, nextPC, pc);
	 	 
	 
endmodule
