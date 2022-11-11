module controlFSM #(
    parameter WIDTH = 16, REGBITS = 4
) (
    input clk, reset,
    input [3:0] opCode1, opCode2, conditionCode,
    input [7:0] PSR,
    output storeReg, zeroExtend, SrcB, JmpEN, BranchEN, JALEN, PCEN, resultEN, immediateRegEN
    output updateAddress, wren_a, wren_b, nextInstruction, writeData, PSREN,
    output regWriteEN, PCinstruction, shiftDir, logicalOrArithmetic,
    output [3:0] shiftAmt, ALUcontrol,
    output [1:0] result
);
    /// Stages of Execution parameters Start
    parameter FETCH = 4'h0 DECODE = 4'h1;
    parameter MEMADR = 4'h2;
    parameter ITYPEEX = 4'h3, ITYPEWR = 4'h4;
    parameter LBRD = 4'h7, LBWR = 4'h8; 
    parameter SBWR = 4'h9;
    parameter RTYPEEX = 4'ha, RTYPEWR = 4'hb;
    parameter BEQEX = 4'hc;
    parameter JEX = 4'hd;
    /// Stages of Execution parameters End

    /// Decode stage parameters Start
    parameter RTYPE =  4'h0;
    // I-Type Decode start
    parameter ADDI = 4'h5, SUBI = 4'h9;
    parameter CMPI = 4'hb;
    parameter ANDI = 4'h1, ORI = 4'h2, XORI = 4'h3;
    parameter MOVI = 4'hd;
    parameter LUI = 4'hf;
    // I-Type Decode end
    parameter MEM_INSTRUCTION =  4'h4;
    parameter SHIFT_INSTRUCTION = 4'h8;
    parameter Bcond =  4'hc;
    /// Decode stage parameters End

    /// FSM State vars 
    reg [3:0] state, nextstate;

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

                        RTYPE:  nextstate <= RTYPEEX;
                        
                        ADDI:   nextstate <= ITYPEEX;
                        SUBI:   nextstate <= ITYPEEX;
                        CMPI:   nextstate <= ITYPEEX;
                        CMPI:   nextstate <= ITYPEEX;
                        ANDI:   nextstate <= ITYPEEX;
                        ORI:    nextstate <= ITYPEEX;
                        XORI:   nextstate <= ITYPEEX;
                        MOVI:   nextstate <= ITYPEEX;

                        LUI:

                        Bcond:     nextstate <= BEQEX;
                        // Implemented for ADDI instruction.
                        default: nextstate <= FETCH; // should never happen
                     endcase
            MEMADR:  case(opCode2)
                        LB:      nextstate <= LBRD;
                        SB:      nextstate <= SBWR;
                        J:
                        default: nextstate <= FETCH; // should never happen
                     endcase
            LBRD:    nextstate <= LBWR;
            LBWR:    nextstate <= FETCH;

            SBWR:    nextstate <= FETCH;
            
            RTYPEEX: nextstate <= RTYPEWR;
            RTYPEWR: nextstate <= FETCH;
            
            BEQEX:   nextstate <= FETCH;
            
            JEX:     nextstate <= FETCH;

            ITYPEEX: nextstate <= ITYPEWR;
            ITYPEWR: nextstate <= FETCH;
            
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
        immediateRegEN <= 0;
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
                    SrcB <= 0;
                    immediateRegEN <= 1;
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
                    resultEN <= 1;
                end
            RTYPEWR:
                begin
                    if(opCode1 != CMPI) begin
                        regWriteEN <= 1;
                    end
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
                    ALUcontrol <= opCode1;
                    SrcB <= 0;
                    PSREN <= 1;
                    resultEN <= 1;
                end
            ITYPEWR:
                begin
                    if(opCode1 != CMPI) begin
                        regWriteEN <= 1;
                    end
                end
                // end changes
        endcase
    end
endmodule