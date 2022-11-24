/*
*   Authors: Jordy Larrea, Brittney Morales, Misael Nava, Cristian Tapiero
*/

// The register file - in this case it's 16 bits wide, and
// only 17 registers deep. It's dual-ported so there 
// are two read ports, but only one write port. 
//
// This will likely get compiled into a block RAM by 
// Quartus, so it can be initialized with a $readmemb function.
// In this case, all the values in the ram.dat file are 0
// to clear the registers to 0 on initialization
module RegisterFile #(parameter WIDTH = 16, REGBITS = 4, INSTRUCTION_MEM = 16'h0000, INTERRUPT_CONTROL = 16'h5FFF, DATA_STACK = 16'h6FFE, IO_MEM = 16'hCFFD)
                (
                  input                clk,
                  input                reset,
                  input                regwrite, 
                  input  [REGBITS-1:0] ra1, ra2, 
                  input  [WIDTH-1:0]   wd, 
                  output [WIDTH-1:0]   rd1, rd2);
	
    reg  [WIDTH-1:0] RAM [(1<<REGBITS)-1:0]; // (1<<REGBITS)-1:0 this means, that there are registers numbered from 0 to 15
   localparam SP = 4'he, RA = 4'hf, ZR = 4'h0;
	//need to update this TODO
	initial begin //this is only done once at the begining of the program and initializes all the registers from 0 to 15 to the value zero.
	$display("Loading register file");
	// you'll need to change the path to this file! //TODO: change the filepath? to a relative path
	$readmemh("C:\\Users\\18019\\Documents\\UofU\\FALL2022\\CS3710\\16bitCPU\\sixteenBitComputer\\CheckPoint3\\initReg.dat",RAM); 
	//$readmemh("C:\\Users\\brifu\\OneDrive\\Documents\\Fall 2022\\ECE 3710\\final project\\sixteenBitComputer\\CheckPoint3\\InitReg.dat", RAM);
	//$readmemh("C:\\Users\\misae\\OneDrive\\Documents\\GitHub\\3710ProjectClone\\CheckPoint3\\InitReg.dat",RAM);
	// $readmemh("D:\\Project_repos\\repos\\sixteenBitComputer\\CheckPoint3\\InitReg.dat", RAM);
	$display("done with RF load"); 
	end 

	//TODO : CHECK if saving in correct register, in our case it will be the second register. We are using the syntax : add reg_source, reg_destintation;
   // dual-ported register file
   //   read two ports combinationally
   //   write third port on rising edge of clock
   always @(posedge clk) begin
      if(regwrite) RAM[ra1] <= wd;
      if(reset) begin
         RAM[SP] <= DATA_STACK;
			RAM[RA] <= 16'h0000;
			
			RAM[13] <= 16'h0000;
			RAM[12] <= 16'h0000;
			RAM[11] <= 16'h0000;
			RAM[10] <= 16'h0000;
			RAM[9] <= 16'h0000;
			RAM[8] <= 16'h0000;
			RAM[7] <= 16'h0000;
			RAM[6] <= 16'h0000;
			RAM[5] <= 16'h0000;
			RAM[3] <= 16'h0000;
			RAM[2] <= 16'h0000;
			RAM[1] <= 16'h0000;

         RAM[ZR] <= 16'h0000;
      end
   end
   // register 0 is hardwired to 0 //TODO, WHAT SHOULD WE DO ABOUT THIS?(keeps it as is?) (QUESTIONS: what should we do with register 0?)
   assign rd1 = ra1 ? RAM[ra1] : 0;
   assign rd2 = ra2 ? RAM[ra2] : 0;
	
endmodule 

