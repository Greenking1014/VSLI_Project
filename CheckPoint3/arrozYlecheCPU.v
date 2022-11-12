module arrozYlecheCPU #(parameter WIDTH = 16, REGBITS = 4)
   (input clk,                  // 50MHz clock
    input reset,                // active-low reset
    input [15:0] memdata,        // data that is read from memory
    output memwrite_a,  
    output memwrite_b,           // write-enable to memory
    output [15:0] adr,           // address to memory
    output [15:0] memOut      // write data to memory
    );

    wire [3:0] opCode1, opCode2, conditionCode;
    wire [7:0] PSR;
    wire storeReg, zeroExtend, SrcB, JmpEN, BranchEN, JALEN;
    wire PCEN, resultEN, immediateRegEN,updateAddress, wren_a, wren_b, nextInstruction;
    wire writeData, PSREN,regWriteEN, PCinstruction;
    wire [3:0] shifterControl, ALUcontrol,shiftAmtOut;
    wire [1:0] result;
    wire [15:0]instr;
controlFSM ctrlFSM (
    clk, reset,
    instr[15:12], instr[7:4], instr[11:8], instr[3:0],
    PSR,
    storeReg, zeroExtend, SrcB, JmpEN, BranchEN, JALEN, PCEN, resultEN, immediateRegEN,
    updateAddress, wren_a, wren_b, nextInstruction, writeData, PSREN,
    regWriteEN, PCinstruction,
    shifterControl, ALUcontrol,
    shiftAmtOut,
    result
);

wire not_reset = ~reset;
assign memwrite_a = wren_a;
assign memwrite_b = wren_b;


datapathDraft #(WIDTH, REGBITS) datapath (
    clk, not_reset,
    memdata,
    PCEN,
    PSREN,
    nextInstruction,
    updateAddress,
    storeReg,
    writeData,
    regWriteEN,
    zeroExtend,
    PCinstruction,
    SrcB,
    resultEN,
    immediateRegEN,
    shiftAmtOut,
    shifterControl,
    ALUcontrol,
    JmpEN,
    BranchEN,
    JALEN,
	result,
	memOut,
	adr,
	PSR,
    instr
);	

endmodule