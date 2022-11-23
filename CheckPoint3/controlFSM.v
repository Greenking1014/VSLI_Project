module controlFSM  (
    input clk, reset,
    input [3:0] opCode1, opCode2, conditionCode, shiftAmtIn,
    input [7:0] PSR,
    output reg storeReg, zeroExtend, SrcB, JmpEN, BranchEN, JALEN, PCEN, resultEN, immediateRegEN,
    output reg updateAddress, wren_a, wren_b, nextInstruction, writeData, PSREN,
    output reg regWriteEN, PCinstruction, regDest,
    output reg [3:0] shifterControl, ALUcontrol,
    output [3:0] shiftAmtOut,
    output reg [1:0] result
);
    /// Stages of Execution parameters Start
    localparam FETCH = 5'h0, DECODE = 5'h1,FETCH2 = 5'h11;
    localparam ITYPEEX = 5'h3, ITYPEWR = 5'h4;
    localparam SHIFTEX = 5'h5, SHIFTWR = 5'h6 , SBWR2 = 5'h14, SBWR3 = 5'h17;
    localparam LBRD = 5'h7, LBWR = 5'h8, LBWR2 = 5'h12, LBWR3 = 5'h16;
    localparam SBWR = 5'h9;
    localparam RTYPEEX = 5'ha, RTYPEWR = 5'hb;
    localparam BCONDEX = 5'hc, BCONDEX2 = 5'h15;
    localparam MEMADR = 5'hd;
    localparam JALEX = 5'he, JALWR = 5'hf;
    localparam JCONDEX = 5'h10, JCONDEX2 = 5'h13; 
    /// Stages of Execution parameters End

    /// Decode stage parameters Start
    localparam RTYPE =  4'h0;
    // I-Type Decode start
    localparam ADDI = 4'h5, SUBI = 4'h9;
    localparam CMPI = 4'hb;
    localparam ANDI = 4'h1, ORI = 4'h2, XORI = 4'h3;
    localparam MOVI = 4'hd;
    localparam LUI = 4'hf;
    localparam LB = 4'h0;
    localparam SB = 4'h4;
    localparam JAL = 4'h8;
    localparam JCOND = 4'hc;
    // I-Type Decode end
    localparam MEM_INSTRUCTION =  4'h4;
    localparam SHIFT_INSTRUCTION = 4'h8;
    localparam BCOND =  4'hc;
    /// Decode stage parameters End

    /// FSM State vars 
    reg [4:0] state, nextstate;
    reg passesCond;
    wire [4:0] PSRvals = PSR[4:0];

    always @(posedge clk ) begin
        if(~reset) state <= FETCH;
        else state <= nextstate;
    end

    // Next State Logic (Combinational)
    always @(*) begin
        case(state)
            FETCH:  nextstate <= FETCH2;
            FETCH2: nextstate <= DECODE;
            DECODE:  case(opCode1)
                        MEM_INSTRUCTION:    nextstate <= MEMADR;

                        RTYPE:  nextstate <= RTYPEEX;

                        SHIFT_INSTRUCTION: nextstate <= SHIFTEX;
                        LUI:  nextstate <= SHIFTEX;  
                        
                        ADDI:   nextstate <= ITYPEEX;
                        SUBI:   nextstate <= ITYPEEX;
                        CMPI:   nextstate <= ITYPEEX;
                        ANDI:   nextstate <= ITYPEEX;
                        ORI:    nextstate <= ITYPEEX;
                        XORI:   nextstate <= ITYPEEX;
                        MOVI:   nextstate <= ITYPEEX;

                        BCOND:     nextstate <= BCONDEX;
                        // Implemented for ADDI instruction.
                        default: nextstate <= FETCH; // should never happen
                     endcase
            MEMADR:  case(opCode2)
                        LB:      nextstate <= LBRD;
                        SB:      nextstate <= SBWR;
                        JAL:  nextstate <= JALEX;
                        JCOND: nextstate <= JCONDEX;
                        default: nextstate <= FETCH; // should never happen
                     endcase
            LBRD:    nextstate <= LBWR;
            LBWR:    nextstate <= LBWR2;
				LBWR2:   nextstate <= LBWR3;
            LBWR3:  nextstate <= FETCH;
				
            SBWR:    nextstate <= SBWR2;
			SBWR2:   nextstate <= FETCH;
				// SBWR3:	nextstate <= FETCH;
            
            RTYPEEX: nextstate <= RTYPEWR;
            RTYPEWR: nextstate <= FETCH;

            ITYPEEX: nextstate <= ITYPEWR;
            ITYPEWR: nextstate <= FETCH;

            SHIFTEX: nextstate <= SHIFTWR;
            SHIFTWR: nextstate <= FETCH;
            
            BCONDEX:   nextstate <= BCONDEX2;
				BCONDEX2:   nextstate <= FETCH;
            
            JALEX:     nextstate <= JALWR;
            JALWR:     nextstate <= FETCH;
            
            JCONDEX:  nextstate <= JCONDEX2;
				JCONDEX2:  nextstate <= FETCH;

            default: nextstate <= FETCH; // should never happen
        endcase
    end
        // This combinational block generates the outputs from each state. 
always @(*) begin
        // set all outputs to zero, then conditionally assert just the appropriate ones
        storeReg <= 0;
        zeroExtend <= 1;
        SrcB <= 1;
        JmpEN <= 0;
        BranchEN <= 0;
        JALEN <= 0;
        PCEN <= 0;
        resultEN <= 0;
        immediateRegEN <= 0;
        updateAddress <= 1;
        wren_a <= 0; wren_b <= 0;
        nextInstruction <= 0;
        writeData <= 1;
        PSREN <= 0;
        regWriteEN <= 0;
        PCinstruction <= 0;
        shifterControl <= 4'h0;
		  ALUcontrol <= 4'h5;
        result <= 2'h1;
		  regDest <= 1'b0;
		  
        case(state)
            FETCH: 
                begin

                    nextInstruction <= 1;
                    PCinstruction <= 1;
                    PCEN <= 1;
                end
            FETCH2:  nextInstruction <= 1;
                        
            DECODE:
                begin
                    if(opCode2 & 4'h8) begin
                        zeroExtend <= (opCode1 == 4'h1 || opCode1 == 4'h2 || opCode1 == 4'h3 || opCode1 == 4'hd) ? 1'b1: 1'b0;
                    end
                    SrcB <= 0;
                    immediateRegEN <= 1;
                    // if(opCode1 != BCOND && (opCode1 != MEM_INSTRUCTION || (opCode2 != JAL  || opCode2 != JCOND))) begin // Kinda sus
                    //     // PCinstruction <= 1;
                    //     // PCEN <= 1;
                    // end
                end
            MEMADR:
                begin
                end
            LBRD:
                begin
                    updateAddress <= 0;
						  //writeData <= 0;
                end
            LBWR:
                begin
                    updateAddress <= 0;
                    writeData <= 0;
                    regWriteEN <= 1;
                end
            LBWR2:
                begin
                    updateAddress <= 0;
                    writeData <= 0;
                    regWriteEN <= 1;
                end
            LBWR3:
                begin
                end
            SBWR:
                begin
                    storeReg <= 1;
					updateAddress <= 0;
                    wren_a <= 1;
                end
				SBWR2:
					begin
                    storeReg <= 1;
                    // updateAddress <= 0;
                    // wren_a <= 1;
				   end
				// SBWR3:
				// 	begin
				// 	end
            RTYPEEX: 
                begin
                    ALUcontrol <= opCode2;
						  if(opCode2 != 4'h0) begin
							PSREN <= 1;
							resultEN <= 1;
						  end
                end
            RTYPEWR:
                begin
                    if(opCode2 != 4'hb && opCode2 != 4'b0) begin
                        regWriteEN <= 1;
                    end
                end
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
            SHIFTEX:
                begin
                    if(opCode1 != LUI) begin
                        SrcB <= (opCode2 == 4'h4) ? 1'b1: 1'b0;
                    end
                    else begin
                        SrcB <= 0;
                    end
                    shifterControl <= (opCode1 != LUI) ? opCode2: opCode1;
                    result <= 2'h0;
                    resultEN <= 1; 
                end
            SHIFTWR:
                begin
                    regWriteEN <= 1;
                end
            BCONDEX:
                begin
                    BranchEN <= passesCond;
                    PCinstruction <= 1;
                    SrcB <= 0;
						  zeroExtend <= 0;
                    if(passesCond)PCEN <= 1;    
                end
				BCONDEX2: 
					begin
					end
            JALEX:
                begin
                    JALEN <= 1;
                    PCinstruction <= 1;
                    result <= 2'b11;
                    resultEN <= 1;
                    PCEN <= 1;
                end
            JALWR:
                begin
                    regWriteEN <= 1;
						  regDest <= 1;
                end
            JCONDEX:
                begin
                    JmpEN <= passesCond;
                    PCinstruction <= 1;
                    PCEN <= 1;
                end
				JCONDEX2:
					 begin
					 end
        endcase
    end
    always @(*) begin
        case(conditionCode)
            4'h0:
                begin
                    passesCond <= PSRvals[4] == 1'b1;
                end
            4'h1:
                begin
                    passesCond <= PSRvals[4] == 1'b0;
                end
            4'hd:
                begin
                    passesCond <= PSRvals[4] == 1'b1 || PSRvals[1] == 1'b1;
                end
            4'h2:
                begin
                    passesCond <= PSRvals[3] == 1'b1;
                end
            4'h3:
                begin
                    passesCond <= PSRvals[3] == 1'b0;
                end
            4'h4:
                begin
                    passesCond <= PSRvals[0] == 1'b1;
                end
            4'h5:
                begin
                    passesCond <= PSRvals[0] == 1'b0;
                end
            4'ha:
                begin
                    passesCond <= PSRvals[4] == 1'b0 && PSRvals[0] == 1'b0;
                end
            4'hb:
                begin
                    passesCond <= PSRvals[4] == 1'b1 || PSRvals[0] == 1'b1;
                end
            4'h6:
                begin
                    passesCond <= PSRvals[1] == 1'b1;
                end
            4'h7:
                begin
                    passesCond <= PSRvals[1] == 1'b0;
                end
            4'h8:
                begin
                    passesCond <= PSRvals[2] == 1'b1;
                end
            4'h9:
                begin
                    passesCond <= PSRvals[2] == 1'b0;
                end
            4'hc:
                begin
                    passesCond <= PSRvals[1] == 1'b0 && PSRvals[4] == 1'b0;
                end
            4'he:
                begin
                    passesCond <= 1;
                end
            4'hf:
                begin
                    passesCond <= 0;
                end
            default:
                begin
                    passesCond <= 0;
                end
        endcase
    end
    assign shiftAmtOut = shiftAmtIn;
endmodule