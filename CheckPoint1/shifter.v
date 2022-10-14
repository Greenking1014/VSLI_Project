module shifter #(
    parameter WIDTH = 16
) (
    input [WIDTH-1:0] src,
    input [WIDTH-1:0] shiftDirection,
    input shiftType,
    output [WIDTH-1:0] shiftOut
);

    always @(*) begin
        if(shiftDirection == 16'hFFFF) shiftOut <= (shiftType) ? src >> 1: src >>> 1;
        else if(shiftDirection == 16'h0001) shiftOut <= (shiftType) ? src << 1: src <<< 1;
        else shiftOut <= src;
    end
endmodule
