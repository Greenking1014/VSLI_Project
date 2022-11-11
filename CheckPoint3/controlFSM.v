module controlFSM #(
    parameter WIDTH = 16, REGBITS = 4
) (
    input clk, reset,
    input [3:0] opCode1, opCode2, conditionCode,
    input [7:0] PSR,
    output storeReg, zeroExtend, SrcB, JmpEN, BranchEN, JALEN, PCEN, resultEN,
    output updateAddress, wren_a, wren_b, nextInstruction, writeData, PSREN,
    output regWriteEN, PCinstruction, shiftDir, logicalOrArithmetic,
    output [3:0] shiftAmt, ALUcontrol,
    output [1:0] result
);
    // LB -> Load byte, SB -> Store byte
    parameter FETCH = 4'h0 DECODE1 = 4'h1, DECODE2 = 4'h2, MEMADR = 4'h3;
    parameter LBRD = 4'h7, LBWR = 4'h8, SBWR = 4'h9, RTYPEEX = 4'ha, RTYPEWR = 4'hb, BEQEX = 4'hc, JEX = 4'hd;
    parameter MEM_INSTRUCTION =  4'h4;
    parameter RTYPE =  4'h0;
    parameter BEQ =  4'hc;
    parameter J = 6'b000010;
    // parameter for I type instruction as
    parameter   ITYPE = 6'b001000; // added this

    reg [3:0] state, nextstate;
    reg pcwrite, pcWriteControl;

    always @(posedge clk ) begin
        if(~reset) state <= FETCH;
        else state <= nextstate;
    end

    // Next State Logic (Combinational)
    always @(*) begin
        case(state)
            FETCH:  nextstate <= DECODE;
            DECODE:  case(opCode1)
                        MEM_INSTRUCTION:    nextstate <= MEMADR;
                        RTYPE:   nextstate <= RTYPEEX;
                        BEQ:     nextstate <= BEQEX;
                        J:       nextstate <= JEX;
                        // Implemented for ADDI instruction.
                        ITYPE:   nextstate <= ITYPEEX; // added to decode
                        default: nextstate <= FETCH; // should never happen
                     endcase
            MEMADR:  case(op)
                        LB:      nextstate <= LBRD;
                        SB:      nextstate <= SBWR;
                        default: nextstate <= FETCH; // should never happen
                     endcase
            LBRD:    nextstate <= LBWR;
            LBWR:    nextstate <= FETCH;
            SBWR:    nextstate <= FETCH;
            RTYPEEX: nextstate <= RTYPEWR;
            RTYPEWR: nextstate <= FETCH;
            BEQEX:   nextstate <= FETCH;
            JEX:     nextstate <= FETCH;
            // Implemented for ADDI instruction
            ITYPEEX: nextstate <= ITYPEWR;
            ITYPEWR: nextstate <= FETCH;
				//changes end
            default: nextstate <= FETCH; // should never happen
        endcase
    end
        // This combinational block generates the outputs from each state. 
always @(*) begin
        // set all outputs to zero, then conditionally assert just the appropriate ones
        storeRegEn <= 0;
        zeroExtend <= 1;
        SrcB <= 1;
        JmpEN <= 0; BranchEN <= 0, JALEN <= 0, PCEN <= 0;
        resultEN <= 0;
        updateAddress <= 1;
        wren_a <= 0; wren_b <= 0;
        nextInstruction <= 0;
        writeData <= 1;
        PSREN <= 0;
        regWriteEN <= 0;
        PCinstruction <= 0;
        shiftDir <= 0;
        logicalOrArithmetic <= 0;
        shiftAmt <= 0000, ALUcontrol <= 0101;
        result <= 2'h1;
        case(state)
            FETCH: 
                begin
                    nextInstruction <= 1;
                    PCinstruction <= 1;
                    PCEN <= 1;
                    // irwrite <= 4'b0001; // change to reflect new memory ordering
                    // alusrcb <= 2'b01;   // get the IR bits in the right spots
                    // pcwrite <= 1;       // FETCH 2,3,4 also changed... 
                end
            DECODE:
                begin
                    if(opCode2 & 4'h8) begin
                        zeroExtend <= (opCode1 == 4'h1 || opCode1 == 4'h2 || opCode1 == 4'h3 || opCode1 == 4'hd) ? 1: 0;
                    end
                    srcB <= 0;
                end
            MEMADR:
                begin
                    alusrca <= 1;
                    alusrcb <= 2'b10;
                end
            LBRD:
                begin
                    iord    <= 1;
                end
            LBWR:
                begin
                    regwrite <= 1;
                    memtoreg <= 1;
                end
            SBWR:
                begin
                    memwrite <= 1;
                    iord     <= 1;
                end
            RTYPEEX: 
                begin
                    ALUcontrol <= opCode2;
                    PSREN <= 1;
                    if(opCode2 != 4'hb) begin
                        resultEN <= 1;
                    end
                end
            RTYPEWR:
                begin
                    regWriteEN <= 1;
                end
            BEQEX:
                begin
                    alusrca     <= 1;
                    aluop       <= 2'b01;
                    pcwritecond <= 1;
                    pcsource    <= 2'b01;
                end
            JEX:
                begin
                    pcwrite  <= 1;
                    pcsource <= 2'b10;
                end
            // States for ITYPE instruction cycle
            ITYPEEX:
                begin
                    alusrca <= 1;
                    alusrcb <= 2'b10; // want 8 bit immediate from instruction decoder
                end
            ITYPEWR:
                begin
                    regdst <= 0; // basically want dest register to be rb
                    regwrite <= 1;
                end
                // end changes
        endcase
    end
endmodule