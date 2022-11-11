/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/
// the ALU performs the arithmetic functions. 
module ALU #(parameter WIDTH = 16)
            (input      [WIDTH-1:0] a, b, // b is the dst 
             input      [3:0]       alucont, //opcode extension
             output reg [WIDTH-1:0] result,
             output [7:0] PSR); 

   wire     [WIDTH-1:0] b2, sum;
   reg Z,C,F,N,L; 
   assign b2 = (alucont[3]) ? ~b:b; // looks at MSB to determined signed or unsigned
   assign sum = a + b2 + alucont[3];
 
   always@(*)
   begin
        L <= 0;
        N <= 0;
        Z <= 0;
        C <= 0;
        F <= 0;
      case(alucont)
         4'b0001: result <= a & b;  // logical AND
         4'b0010: result <= a | b;  // logical OR
         4'b0101: begin
            result <= sum; // Add
            
            //setting  sign Flag
            if(sum[WIDTH-1] == 1'b1) N <= 1;
           
            //setting Zero Flag
            if(sum == 16'h0000) Z <= 1;
          
            //setting  the Flag bit Signed
            if(($signed(a) > 0 && $signed(b) > 0 && $signed(sum) < 0) || 
                 ($signed(a) < 0 && $signed(b) < 0 && $signed(sum) > 0) ) F <= 1;
          
            //setting  Carry Flag unsigned
            if(a[WIDTH -1] == 1'b1 && b[WIDTH -1] == 1'b1) C <= 1;
            else if (((a[WIDTH -1] ^ b[WIDTH -1]) & ~ sum[WIDTH -1] == 1'b1)) C <= 1;
    
         end   
         4'b1001: begin 
            result <= sum;    // Sub
            //setting  sign Flag
            if(sum[WIDTH-1] == 1'b1) N <= 1;
           
            //setting Zero Flag
            if(sum == 16'h0000) Z <= 1;
          
            //setting LOW Flag
            if (a < b) L <= 1;

            //setting  the Flag bit Signed, do we want a or b to be the src or dst?
            if(($signed(a) > 0 && $signed(b) < 0 && $signed(sum) < 0) || 
                 ($signed(a) < 0 && $signed(b) > 0 && $signed(sum) > 0) ) F <= 1;
          
            //setting  Carry Flag unsigned
            if(a < sum) C <= 1;
         end
         4'b0011: result <= a ^ b;    // logical XOR
         4'b1011: begin // CMP
            result <= sum;    // Sub
            //setting  sign Flag
            if(sum[WIDTH-1] == 1'b1) N <= 1;
           
            //setting Zero Flag
            if(sum == 16'h0000) Z <= 1;
          
            //setting LOW Flag
            if (a < b) L <= 1;
         end
         4'b1101: begin // MOV
            result <= b;
         end
         default: result <= sum; // should never happen
      endcase
   end

assign PSR = {3'b0,Z,C,F,N,L};

endmodule