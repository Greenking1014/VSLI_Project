module arrozYlecheCPU #(parameter WIDTH = 16, REGBITS = 4, INSTRUCTION_MEM = 16'h0000, INTERRUPT_CONTROL = 16'h5FFF, DATA_STACK = 16'h6FFE, IO_MEM = 16'hCFFD)
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
    wire storeReg, zeroExtend, SrcB, JmpEN, BranchEN, JALEN,regDst;
    wire PCEN, resultEN, immediateRegEN,updateAddress, wren_a, wren_b, nextInstruction;
    wire writeData, PSREN,regWriteEN, PCinstruction, regDest;
    wire [3:0] shifterControl, ALUcontrol,shiftAmtOut;
    wire [1:0] result;
    wire [15:0]instr;

    controlFSM ctrlFSM (
        clk, reset,
        instr[15:12], instr[7:4], instr[11:8], instr[3:0],
        PSR,
        storeReg, zeroExtend, SrcB, JmpEN, BranchEN, JALEN, PCEN, resultEN, immediateRegEN,
        updateAddress, wren_a, wren_b, nextInstruction, writeData, PSREN,
        regWriteEN, PCinstruction, regDest,
        shifterControl, ALUcontrol,
        shiftAmtOut,
        result
    );

    wire not_reset = ~reset;
    assign memwrite_a = wren_a;
    assign memwrite_b = wren_b;

    datapathDraft #(WIDTH, REGBITS, INSTRUCTION_MEM, INTERRUPT_CONTROL, DATA_STACK, IO_MEM) datapath (
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
		  regDest,
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