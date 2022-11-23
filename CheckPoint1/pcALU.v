/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/

module pcALU #(parameter WIDTH = 16, parameter INTERRUPT_CONTROL = 16'h5FFF)(
	input [WIDTH-1: 0]  pc,
	input [WIDTH-1: 0]  src2,
	input					  jumpEN,
	//input [WIDTH-1: 0]  RTarget,
	input               jalEN,
	input					  branchEN,
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
		newPC <= src2;
		RlinkBack <= pc;
	end
	else if(jumpEN) newPC <= src2;        // Here src2 is Rtarget / Address
	else if(branchEN) newPC <= pc + $signed(src2) - 2; // Here src2 is the immediate 
	else begin
		newPC  <= pc + 1;
		if(pc + 1 > INTERRUPT_CONTROL - 1) begin
			newPC <= pc;
		end
	end
end

assign Rlink = RlinkBack;
assign pcOut = newPC;
    
endmodule 