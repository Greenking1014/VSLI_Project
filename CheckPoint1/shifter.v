
// UPDATE THIS, shift amt, up to 15 positions in a right shit, and up to 14 positions in a left shift. 
//if shift direction is 1, then shift left, else shift right
// if shiftType is 1, then logical shift, else arithmetic shift.'
// Have shifter ready for all shift instructions.
/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
This module does arithmetic shifting (extends the sign value) and logical shifting (Leftshifting and rightshifting) by one bit
arithmetic shifting : >>> and <<< 
logical shifting : >> and <<
IMPORTANT: when shiftType is 1, it's type is logical shift, else it is arithmetic shifting
when shiftDirection is FFFF (hex and signed for -1) it will shift right, or when shiftDirection is 1 it will shift left or when shift is anyother number it will return the same value.
*/
module shifter #(
    parameter WIDTH = 16
) (
    input signed [WIDTH-1:0] src,
    input shiftDirection,
    input [3:0] shiftAmt,
    input shiftType,
    output reg signed [WIDTH-1:0] shiftOut
);

    always @(*) begin
	 
        if(shiftDirection == 16'hFFFF) shiftOut <= (shiftType) ? src >> 1: $signed(src) >>> 1;
        else if(shiftDirection == 16'h0001) shiftOut <= (shiftType) ? src << 1: $signed(src) <<< 1;
        else shiftOut <= src;
    end
endmodule
