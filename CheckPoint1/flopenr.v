module flopenr #(parameter WIDTH = 8, DEFAULT <= 8'h00)
                (input                  clk, reset, en,
                 input      [WIDTH-1:0] d, 
                 output reg [WIDTH-1:0] q);
 
   always @(posedge clk)
      if      (reset) q <= DEFAULT;
      else if (en)     q <= d;
endmodule 