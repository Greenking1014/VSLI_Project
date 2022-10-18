/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/

module pcALU #(parameter WIDTH = 16)(
	input [WIDTH-1: 0]  pc,
	input [WIDTH-1: 0]  immediate,     //Sign extend here or before passing to alu?
	input					  jumpEN,
	input [WIDTH-1: 0]  RTarget,
	input               jalEN,
	output [WIDTH-1: 0] Rlink,
	output [WIDTH-1: 0] pcOut
);


// Input of unsigned PC and signed immediate already in two's complement
// jumpEN is a signal that is set by another module that takes in a condition
// from the Bcond and Jcond. Depending on the condition bits and if the PSR
// are set correctly for jump, jumpEN will be set on and will use the immediate
// to increment the pc counter
// If we recieve a signal from the datapath that we want to do a jump and link
// instruction JAL, then we set the pc to the RTarget address and set the 
// Rlink output to be the previous pc + 1. There should be no situtation where
// both enable signals are on, if no enable signal are on, then we increment pc
// normally

reg [WIDTH-1:0] RlinkBack;
reg [WIDTH-1:0] newPC;

always@(*) begin
	RlinkBack <= 16'h0000;
	if(jalEN) begin
		newPC <= RTarget;
		RlinkBack <= pc + 1;
	end
	else if(jumpEN) newPC <= pc + immediate;
	else newPC <= pc + 1;
end

assign Rlink = RlinkBack;
assign pcOut = newPC;
    
endmodule 