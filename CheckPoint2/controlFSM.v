module controlFSM #(
    parameter WIDTH = 16, REGBITS = 4
) (
    input clk, reset,
    input [3:0] opCode1, opCode2, conditionCode,
    input [7:0] PSR,
    output storeRegEn, zeroExtend, SrcB, JmpEN, BranchEN, JALEN, PCEN, resultEN,
    output updateAddress, wren_a, wren_b, nextInstruction, writeData, PSREN,
    output regWriteEN, PCinstruction, shiftDir, logicalOrArithmetic,
    output [3:0] shiftAmt, ALUcontrol,
    output [1:0] result
);
    parameter FETCH = 4'h0;
    parameter LBRD = 4'h7, LBWR = 4'h8, SBWR = 4'h9, RTYPEEX = 4'ha, RTYPEWR = 4'hb, BEQEX = 4'hc, JEX = 4'hd;
    parameter   LB      =  6'b100000;
    parameter   SB      =  6'b101000;
    parameter   RTYPE   =  6'b0;
    parameter   BEQ     =  6'b000100;
    parameter   J       =  6'b000010;
    // parameter for I type instruction as
    parameter   ITYPE = 6'b001000; // added this

    reg [3:0] state, nextstate;
    reg pcwrite, pcWriteControl;

    always @(posedge clk ) begin
        if(~reset) state <= FETCH1;
        else state <= nextstate;
    end

    // Next State Logic (Combinational)
    always @(*) begin
        case(state)
            FETCH1:  nextstate <= DECODE;
            DECODE:  case(op)
                        LB:      nextstate <= MEMADR;
                        SB:      nextstate <= MEMADR;
                        RTYPE:   nextstate <= RTYPEEX;
                        BEQ:     nextstate <= BEQEX;
                        J:       nextstate <= JEX;
                        // Implemented for ADDI instruction.
                        ITYPE:   nextstate <= ITYPEEX; // added to decode
                        default: nextstate <= FETCH1; // should never happen
                     endcase
            MEMADR:  case(op)
                        LB:      nextstate <= LBRD;
                        SB:      nextstate <= SBWR;
                        default: nextstate <= FETCH1; // should never happen
                     endcase
            LBRD:    nextstate <= LBWR;
            LBWR:    nextstate <= FETCH1;
            SBWR:    nextstate <= FETCH1;
            RTYPEEX: nextstate <= RTYPEWR;
            RTYPEWR: nextstate <= FETCH1;
            BEQEX:   nextstate <= FETCH1;
            JEX:     nextstate <= FETCH1;
            // Implemented for ADDI instruction
            ITYPEEX: nextstate <= ITYPEWR;
            ITYPEWR: nextstate <= FETCH1;
				//changes end
            default: nextstate <= FETCH1; // should never happen
        endcase
    end
endmodule