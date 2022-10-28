module tb_ALU();
parameter WIDTH = 16;
reg [WIDTH-1:0] tb_a,tb_b;
reg [3:0] tb_alucont;
wire [WIDTH-1:0] tb_result;
wire [7:0] tb_PSR;

 
ALU UUT(.a(tb_a), 
        .b(tb_b), // b is the dst 
        .alucont(tb_alucont), //opcode extension
        .result(tb_result),
        .PSR(tb_PSR));

localparam CLK_PERIOD = 10;

initial begin
    //initialize variables
    tb_a <= 16'h0000;
    tb_b <= 16'h0000;
    tb_alucont <= 4'h0;
end

initial begin
    # CLK_PERIOD;
    // testing AND 
    tb_a <= 16'h0000;
    tb_b <= 16'hffff;
    tb_alucont <= 4'b0001;
    if(tb_result != 16'h0000 && tb_PSR != 8'b0) $display("error in AND operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("AND operation is working as supposed");

    # CLK_PERIOD;
    // testing AND 
    tb_a <= 16'hffff;
    tb_b <= 16'haaaa;
    tb_alucont <= 4'b0001;
    #5;
    if(tb_result != 16'haaaa && tb_PSR != 8'b0) $display("error in AND operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("AND operation is working as supposed");

# CLK_PERIOD;
    // testing OR 
    tb_a <= 16'h0000;
    tb_b <= 16'hffff;
    tb_alucont <= 4'b0010;
    #5
    if(tb_result != 16'hffff && tb_PSR != 8'b0) $display("error in OR operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("OR operation is working as supposed");

    # CLK_PERIOD;
    // testing OR 
    tb_a <= 16'h5555;
    tb_b <= 16'haaaa;
    tb_alucont <= 4'b0010;
    #5;
    if(tb_result != 16'hffff && tb_PSR != 8'b0) $display("error in OR operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("OR operation is working as supposed");

    # CLK_PERIOD;
    // testing XOR
    tb_a <= 16'hffff;
    tb_b <= 16'haaaa;
    tb_alucont <= 4'b0011;
    #5;
    if(tb_result != 16'h5555 && tb_PSR != 8'b0) $display("error in XOR operationresult is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("XOR operation is working as supposed");

    # CLK_PERIOD;
    // testing XOR
    tb_a <= 16'haaaa;
    tb_b <= 16'haaaa;
    tb_alucont <= 4'b0011;
    #5;
    if(tb_result != 16'h0000 && tb_PSR != 8'b0) $display("error in XOR operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("XOR operation is working as supposed");


    //Testing the condition codes  this tests Zero and Carry flag 
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'hffff;
    tb_b <= 16'h0001;
    tb_alucont <= 4'b0101;
    #5;
    if(tb_result != 16'h0000 && tb_PSR != 8'b00011000) $display("error in Sum operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sum operation and condition flags are working as supposed");


    //Testing the condition codes  this tests sign and overflow flag
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'h7000;
    tb_b <= 16'h4000;
    tb_alucont <= 4'b0101;
    #5;
    if(tb_result != 16'hb000 && tb_PSR != 8'b00000110) $display("error in Sum operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sum operation and condition flags are working as supposed");

    //Testing the condition codes  Flag bit with two negative inputs
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'h8000;
    tb_b <= 16'h8001;
    tb_alucont <= 4'b0101;
    #5;
    if(tb_result != 16'h0001 && tb_PSR != 8'b00001100) $display("error in Sum operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sum operation and condition flags are working as supposed");

    // Testing Subtraction and Condition flags
    //Testing the zero flag
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'h8000;
    tb_b <= 16'h8000;
    tb_alucont <= 4'b1001;
    #5;
    if(tb_result != 16'h0000 && tb_PSR != 8'b00010000) $display("error in Sub operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sub operation and condition flags are working as supposed");

    //Testing the L flag
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'hff00;
    tb_b <= 16'hffff;
    tb_alucont <= 4'b1001;
    #5;
    if(tb_result != 16'hff01 && tb_PSR != 8'b00000011) $display("error in Sub operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sub operation and condition flags are working as supposed");

     //Testing the condition codes  C and F flags
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'h0003;
    tb_b <= 16'h0006;
    tb_alucont <= 4'b1001;
    #5;
    if(tb_result != 16'hfffd && tb_PSR != 8'b00001011) $display("error in Sub operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sub operation and condition flags are working as supposed");

     //Testing the condition codes  sign overflow
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'h7fff;
    tb_b <= 16'hffff;
    tb_alucont <= 4'b1001;
    #5;
    if(tb_result != 16'h8000 && tb_PSR != 8'b00001111) $display("error in Sub operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sub operation and condition flags are working as supposed");

     //Testing the condition codes sign overflow second condition
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'h8000;
    tb_b <= 16'h7fff;
    tb_alucont <= 4'b1001;
    #5;
    if(tb_result != 16'h0001 && tb_PSR != 8'b00000100) $display("error in Sub operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sub operation and condition flags are working as supposed");


    //Testing the condition codes for Carry flag 
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'hffff;
    tb_b <= 16'haaaa;
    tb_alucont <= 4'b0000;
    #5;
    if(tb_result != 16'h0000 && tb_PSR != 8'b00011000) $display("error in Sum operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sum operation and condition flags are working as supposed");

    // Testing Subtraction and Condition flags
    //Testing the zero flag
    # CLK_PERIOD;
    //PSR <= {3'b0,Z,C,F,N,L};
    tb_a <= 16'haaaa;
    tb_b <= 16'hffff;
    tb_alucont <= 4'b0101;
    #5;
    if(tb_result != 16'h0000 && tb_PSR != 8'b00010000) $display("error in Sub operation result is %h, PSR value : %b",tb_result,tb_PSR);
    else $display("Sub operation and condition flags are working as supposed");
end

endmodule
