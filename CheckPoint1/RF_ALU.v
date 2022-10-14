/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*   RF_ALU -> upper level module for checkpoint1, integrates ALU and register file.
*/

module #(parameter WIDTH = 16, REGBITS = 4)
RF_ALU (
    input clk, reset,
    input regWrite,
    input shiftOrALU,
    input alusrca, alusrcb,
    input [WIDTH-1:0] shiftDirection,
    input [3:0] aluControl,
    input [REGBITS-1:0] regAddress1, regAddress2,
    input [WIDTH-1:0] writeData,
    input [WIDTH-1:0] immediate,
    input [WIDTH-1:0] shiftDirection,
    input shiftType,
    output [WIDTH-1:0] result,
    output [WIDTH-1:0] pcreg,
    output [7:0] PSR
);
    wire [WIDTH-1:0] regData1, regData2;
    wire [WIDTH-1:0] aluResult, shiftOut;
    wire [WIDTH-1:0] src1, src2;
    wire [WIDTH-1:0] ALU_Out, opOutput;
    wire [7:0] PSRresult;

    // // set register for reg1 data output
    // flopr #(WIDTH) areg(clk, reset, regData1, regData1Out);
    // // set register for reg2 data output
    // flopr #(WIDTH) breg(clk, reset, regData2, regData2Out);
    // flopr #(WIDTH) aluoutUnit(clk, reset, aluResult, ALU_Out);

    flopr #(WIDTH) pcregUnit(clk, reset, opOutput, pcreg);
    flopr #(WIDTH) PSRreg(clk, reset, PSRresult, PSR);
    flopr #(WIDTH) resultreg(clk, reset, opOutput, result);
    // set src1 and src2
    mux2 #(WIDTH) src1Mux(pcAddress, regData1, alusrca, src1);
    mux2 #(WIDTH) src2mux(regData2, immediate, alusrcb, src2);
    // output from shifter and AlU unit
    mux2 #(WIDTH) outputMux(shiftOut, aluResult, shiftOrALU, opOutput)
    
    // Operational units
    shifter #(WIDTH) shifterUnit(src1, shiftDirection, shiftType, shiftOut);
    RegisterFile #(WIDTH, REGBITS) regFile(clk, regWrite, regAddress1, regAddress2,
        writeData, regData1, regData2);
    ALU #(WIDTH, REGBITS) alu_unit(src1, src2, aluControl,aluResult, PSRresult);
    
    assign writeData = opOutput;

endmodule