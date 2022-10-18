

module fp_ALU;
reg clk;
reg rst_n;

 
UUT(
    .rst_n (rst_n),
    .clk (clk)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    //initialize variables
end



endmodule