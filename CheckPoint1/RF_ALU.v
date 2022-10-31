/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/

module RF_ALU #(parameter WIDTH = 16, REGBITS = 4)(
    input                clk, reset,
    input                regWrite,
    input                shiftOrALU,
    input                alusrca, alusrcb,
    input  [WIDTH-1:0]   shiftDirection,
    input  [3:0]         aluControl,
    input  [REGBITS-1:0] regAddress1, regAddress2,
    input  [WIDTH-1:0]   immediate,
    input                shiftType,
    input  [WIDTH-1: 0]  pc,
	 input			       jumpEN,
	 input  [WIDTH-1: 0]  RTarget,
	 input                jalEN,
    input                ALUselect,
	 output [WIDTH-1: 0]  Rlink,
    output [WIDTH-1:0]   result,
    output [WIDTH-1:0]   pcreg,
    output [7:0]         PSR
);
    wire [WIDTH-1:0] regData1, regData2;
    wire [WIDTH-1:0] aluResult1,aluResult2,aluResult,shiftOut;
    wire [WIDTH-1:0] src1, src2;
    wire [WIDTH-1:0] opOutput;
    wire [7:0]       PSRresult;
	 wire [WIDTH-1:0] writeData;
    
    // registers for results ts
    flopr #(WIDTH) pcregUnit(clk, reset, opOutput, pcreg);
    flopr #(8) PSRreg(clk, reset, PSRresult, PSR);
    flopr #(WIDTH) resultreg(clk, reset, opOutput, result);
    
	 // set src1 and src2
    mux2 #(WIDTH) src1Mux(pcreg, regData1, alusrca, src1);
    mux2 #(WIDTH) src2mux(regData2, immediate, alusrcb, src2);
    
	 // output from shifter and AlU unit
    mux2 #(WIDTH) outputMux(shiftOut, aluResult, shiftOrALU, opOutput);
    
    // pc counter doesnt care about PSR for now
    pcALU #(WIDTH)pc_ALU(src1,src2,jumpEN,RTarget,jalEN,Rlink,aluResult2);
    
	 // Operational units
    shifter #(WIDTH) shifterUnit(src1, shiftDirection, shiftType, shiftOut);
    RegisterFile #(WIDTH, REGBITS) regFile(clk, regWrite, regAddress1, regAddress2, writeData, regData1, regData2);
    ALU #(WIDTH) alu_unit(src1, src2, aluControl,aluResult1, PSRresult);
    
	 // mux select from ALU basic or pcALU
    mux2 #(WIDTH) ALUmux(aluResult1, aluResult2, ALUselect, aluResult);

    assign writeData = opOutput;
	 
endmodule
